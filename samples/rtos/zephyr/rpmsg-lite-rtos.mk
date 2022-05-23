################################################################################
#                                                                              #
#   RPMsg Lite - Makefile                                                      #
#                                                                              #
#   Copyright 2021 NXP                                                         #
#                                                                              #
################################################################################

# List of supported OS targets
rpmsglite_os_targets := zephyr

# List of supported platforms
rpmsglite_platforms := $(mimx8m_platforms)

# Platform and OS target check
PLATFORM ?= $(platform)
OS_TARGET ?= $(os_target)
rpmsglite_platforms := $(strip $(rpmsglite_platforms))
rpmsglite_os_targets := $(strip $(rpmsglite_os_targets))
# ifneq ($(filter-out $(PLATFORM),$(mimx8m_platforms)),$(mimx8m_platforms))
#     RPMSGLITE_RTOS_DEFINES := $(PLATFORM)
#     PLATFORM := mimx8mm_evk
# else ifeq ($(filter-out $(PLATFORM),$(rpmsglite_platforms)),$(rpmsglite_platforms))
#     $(info Supported platforms: $(rpmsglite_platforms))
#     $(error Undefined platform: '$(PLATFORM)')
# endif
PLATFORM := mimx8m_evk

ifeq ($(filter-out $(OS_TARGET),$(rpmsglite_os_targets)),$(rpmsglite_os_targets))
    $(info Supported OS targets: $(rpmsglite_os_targets))
    $(error Undefined OS target: '$(OS_TARGET)')
endif

# RPMSGLITE_RTOS_PATH check
ifeq (,$(RPMSGLITE_RTOS_PATH))
    $(error Environment variable RPMSGLITE_RTOS_PATH not set)
endif
ifneq (1,$(words [$(RPMSGLITE_RTOS_PATH)]))
    $(error Spaces are not allowed in RPMSGLITE_RTOS_PATH)
endif

# Driver includes
RPMSGLITE_RTOS_INCLUDES := $(RPMSGLITE_RTOS_PATH)/lib/common       \
                           $(RPMSGLITE_RTOS_PATH)/lib/include

ifeq ($(PLATFORM),mimx8m_evk)
    RPMSGLITE_RTOS_INCLUDES += $(RPMSGLITE_RTOS_PATH)/lib/include/platform/imx8mm_m4
    ifeq ($(OS_TARGET), zephyr)
        RPMSGLITE_RTOS_INCLUDES += $(RPMSGLITE_RTOS_PATH)/lib/include/environment/zephyr
    endif
endif

# Driver defines
# RPMSGLITE_RTOS_DEFINES += $(PLATFORM)

# Driver sources lookup paths
RPMSGLITE_RTOS_SRC_DIR := $(RPMSGLITE_RTOS_PATH)/lib/common                        \
                          $(RPMSGLITE_RTOS_PATH)/lib/virtio                        \
                          $(RPMSGLITE_RTOS_PATH)/lib/rpmsg_lite

ifeq ($(PLATFORM),mimx8m_evk)
    RPMSGLITE_RTOS_SRC_DIR += $(RPMSGLITE_RTOS_PATH)/lib/rpmsg_lite/porting/platform/imx8mm_m4
    ifeq ($(OS_TARGET), zephyr)
        RPMSGLITE_RTOS_SRC_DIR += $(RPMSGLITE_RTOS_PATH)/lib/rpmsg_lite/porting/environment
    endif
endif

# Prepend -D compiler option to defines
# SHM_RTOS_DEF_FLAGS = $(foreach def,$(RPMSGLITE_RTOS_DEFINES),-D$(def))

# Prepend -I compiler option to includes
RPMSGLITE_RTOS_INCL_FLAGS = $(foreach incl,$(RPMSGLITE_RTOS_INCLUDES),-I$(incl))

# Object files list
RPMSGLITE_RTOS_SOURCES := $(foreach path,$(RPMSGLITE_RTOS_SRC_DIR),$(wildcard $(path)/*.c))
RPMSGLITE_SOURCE_FILES := $(notdir $(RPMSGLITE_RTOS_SOURCES))
ifneq (,$(RPMSGLITE_RTOS_OBJ_DIR))
    RPMSGLITE_RTOS_OBJS := $(subst .c,.o,$(RPMSGLITE_SOURCE_FILES))
    RPMSGLITE_RTOS_OBJS := $(foreach obj,$(RPMSGLITE_RTOS_OBJS),$(RPMSGLITE_RTOS_OBJ_DIR)/$(obj))
else
    RPMSGLITE_RTOS_OBJS := $(subst .c,.o,$(RPMSGLITE_RTOS_SOURCES))
endif
