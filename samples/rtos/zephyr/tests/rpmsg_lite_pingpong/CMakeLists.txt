################################################################################
#                                                                              #
#   IPC Shared Memory Driver sample application for S32/Zephyr                 #
#                                                                              #
#   Copyright 2021 NXP                                                         #
#                                                                              #
################################################################################

cmake_minimum_required(VERSION 3.13.1)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(s32_zephyr)

# Sample options
option(SAMPLE_MASTER "Build sample for master core" ON)

# ShM driver directories
set(ipc_shm_sample_dir ${CMAKE_CURRENT_SOURCE_DIR})
set(ipc_shm_build_dir  ${CMAKE_CURRENT_SOURCE_DIR}/output)
set(ipc_shm_root_dir   ${CMAKE_CURRENT_SOURCE_DIR}/../..)

# Sample sources
target_sources(app PRIVATE src/sample.c)
if(SAMPLE_MASTER)
  target_sources(app PRIVATE src/sample_master.c)
else()
  target_sources(app PRIVATE src/sample_slave.c)
endif()

# Sample includes
target_include_directories(app PRIVATE "${ipc_shm_root_dir}/src/common")
target_include_directories(app PRIVATE "${ipc_shm_sample_dir}/src")

# Export all the flags used in this Zephyr build to the external build system
zephyr_get_include_directories_for_lang_as_string(       C includes)
zephyr_get_system_include_directories_for_lang_as_string(C system_includes)
zephyr_get_compile_definitions_for_lang_as_string(       C definitions)
zephyr_get_compile_options_for_lang_as_string(           C options)

set(external_project_cflags
  "${includes} ${definitions} ${options} ${system_includes}"
  )

include(ExternalProject)

# Add an external project to be able to build the ipc-shm static library
set(IPC_SHM_LIB_DIR ${ipc_shm_build_dir}/lib)

if(CMAKE_GENERATOR STREQUAL "Unix Makefiles")
set(submake "$(MAKE)")
else()
set(submake "make")
endif()

ExternalProject_Add(
  ipc_shm_lib_project              # Name for custom target
  PREFIX     ${ipc_shm_build_dir}  # Root dir for entire project
  SOURCE_DIR ${ipc_shm_sample_dir}
  BINARY_DIR ${ipc_shm_sample_dir} # Invoked from the root
  CONFIGURE_COMMAND ""             # No configuration command needed
  BUILD_COMMAND
  ${submake}
  platform=s32r45                  # TODO: get from West board parameter
  PREFIX=${ipc_shm_build_dir}
  CC=${CMAKE_C_COMPILER}           # CC and AR picked up from West configuration
  AR=${CMAKE_AR}
  CFLAGS=${external_project_cflags}
  INSTALL_COMMAND ""               # No install command needed
  BUILD_BYPRODUCTS ${IPC_SHM_LIB_DIR}/libipc-shm.a
  )

# Create a wrapper CMake library that the sample app can link with
add_library(ipc_shm_lib STATIC IMPORTED GLOBAL)
add_dependencies(
  ipc_shm_lib
  ipc_shm_lib_project
  )
add_dependencies(
  ipc_shm_lib_project
  zephyr
  )
set_target_properties(ipc_shm_lib PROPERTIES IMPORTED_LOCATION ${IPC_SHM_LIB_DIR}/libipc-shm.a)

target_link_libraries(app PUBLIC ipc_shm_lib)
