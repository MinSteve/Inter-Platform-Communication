################################################################################
#                                                                              #
#   Makefile for building Shared Memory Driver as Static Library               #
#                                                                              #
#   This makefile is intended to be called by the sample CMake project on this #
#   same directory and not manually.                                           #
#                                                                              #
#   Copyright 2021 NXP                                                         #
#                                                                              #
################################################################################

ifeq (,$(ZEPHYR_BASE))
    $(error Environment variable ZEPHYR_BASE (Zephyr base directory) not set)
endif

# Other executables
ECHO := echo
RM := rm
MKDIR := mkdir

# shm driver configuration
os_target := zephyr

ifeq ($(platform),s32r45)
    override platform := s32xx
endif

# Location of objects and final source directories
BUILD_DIR ?= output
OBJ_DIR ?= $(BUILD_DIR)/obj
LIB_DIR ?= $(BUILD_DIR)/lib
LIB_NAME ?= libipc-shm

# ShM driver lookup paths
SHM_RTOS_OBJ_DIR ?= $(OBJ_DIR)
SHM_RTOS_PATH ?= ../..

include $(SHM_RTOS_PATH)/ipc-shm-rtos.mk

# ShM driver sources to build
SOURCEDIR += $(SHM_RTOS_SRC_DIR)
CSOURCES += $(SHM_RTOS_SOURCE_FILES)

# Sources to build
VPATH += $(SOURCEDIR)

# Objects
OBJECTS = $(addprefix $(OBJ_DIR)/,$(CSOURCES:%.c=%.o))

.DEFAULT_GOAL := all

# Compile C source files
$(OBJ_DIR)/%.o: %.c
	@$(ECHO) Compiling $@
	@$(CC) $(CFLAGS) $(SHM_RTOS_DEF_FLAGS) $(SHM_RTOS_INCL_FLAGS) -c $< -o $@

# Create static library
lib: $(OBJECTS)
	@$(ECHO) Archiving to $(LIB_NAME).a
	@$(AR) -rcs $(LIB_DIR)/$(LIB_NAME).a $(OBJECTS)

# Create folder used to store temporary objects
mkdir:
	@$(ECHO) Creating build directories
	@$(MKDIR) -p $(OBJ_DIR) $(LIB_DIR)

# Print compile flags and environment variables
showflags:
	@$(ECHO) ZEPHYR_BASE: $(ZEPHYR_BASE)
	@$(ECHO) CC: $(CC)
	@$(ECHO) AR: $(AR)
	@$(ECHO) CFLAGS: $(CFLAGS)
	@$(ECHO) EXTRA_CFLAGS: $(EXTRA_CFLAGS)
	@$(ECHO) INCLUDES: $(INCLUDES)

# Remove files and folders
clean:
	@$(ECHO) Removing files and directories
	@$(RM) -rf $(BUILD_DIR)
	@$(RM) -rf $(OBJ_DIR)
	@$(RM) -rf $(LIB_DIR)

all: mkdir lib
	@$(ECHO) Build complete!

.PHONY: all showflags clean
