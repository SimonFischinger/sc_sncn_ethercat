# The TARGET variable determines what target system the application is
# compiled for. It either refers to an XN file in the source directories
# or a valid argument for the --target option when compiling.

TARGET = SOMANET_C22

# The APP_NAME variable determines the name of the final .xe file. It should
# not include the .xe postfix. If left blank the name will default to
# the project name

APP_NAME = httpserver

# The flags passed to xcc when building the application
# You can also set the following to override flags for a particular language:
#
#    XCC_XC_FLAGS, XCC_C_FLAGS, XCC_ASM_FLAGS, XCC_CPP_FLAGS
#
# If the variable XCC_MAP_FLAGS is set it overrides the flags passed to
# xcc for the final link (mapping) stage.

XCC_FLAGS = -O3 -save-temps -g -report -Xmapper --map -Xmapper MAPFILE -DEOE_TRANSMISSION

# The USED_MODULES variable lists other module used by the application.
USED_MODULES = sc_sncn_ethercat/module_ethercat

# This uses the tcp mac filtering in module_xtcp
USE_XTCP_MAC_CUSTOM_FILTER=1


#=============================================================================
# The following part of the Makefile includes the common build infrastructure
# for compiling XMOS applications. You should not need to edit below here.

#XMOS_MAKE_PATH ?= ..
#include $(XMOS_MAKE_PATH)/module_xmos_common/build/Makefile.common

# Since XDE 11.11.0 the xcommon module is included into XDE, so use this
XMOS_MAKE_PATH ?= ..
include $(XMOS_MAKE_PATH)/xcommon/module_xcommon/build/Makefile.common




all: $(BIN_DIR)/$(APP_NAME).xe
	@echo Build Complete


clean: clean_common
