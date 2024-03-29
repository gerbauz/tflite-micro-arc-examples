#
# Copyright 2021, Synopsys, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-3-Clause license found in
# the LICENSE file in the root directory of this source tree.
#

#=============================================================
# OS-specific definitions
#=============================================================
COMMA=,
OPEN_PAREN=(
CLOSE_PAREN=)
BACKSLASH=\$(nullstring)
ifneq ($(ComSpec)$(COMSPEC),)
	O_SYS=Windows
	RM=del /F /Q
	MKDIR=mkdir 
	CP=copy /Y
	TYPE=type
	PS=$(BACKSLASH)
	Q=
	coQ=\$(nullstring)
	fix_platform_path = $(subst /,$(PS), $(1))
	DEV_NULL = nul
else
	O_SYS=Unix
	RM=rm -rf
	MKDIR=mkdir -p
	CP=cp 
	TYPE=cat
	PS=/
	Q=$(BACKSLASH)
	coQ=
	fix_platform_path=$(1)
	DEV_NULL=/dev/null
endif



#=============================================================
# Toolchain definitions
#=============================================================
CC = ccac
CXX = ccac
LD = ccac
AR = arac

DOWNLOAD_SCRIPT := ./scripts/download_mli.sh
ADAPTATION_SCRIPT := ./scripts/adapt_model.sh



#=============================================================
# General definitions
#=============================================================

GENDIR := gen
MLIDIR := mli_lib
EMSDPDIR := emsdp

ifeq ($(TCF_FILE),)
  ifneq ($(filter $(ARC_TAGS), emsdp),)
    TCF_FILE = $(MLIDIR)/arc_mli_emsdp_em11d_em9d_dfss/hw/emsdp_em11d_em9d_dfss.tcf
    LCF_FILE = $(EMSDPDIR)/emsdp.lcf
  else
    TCF_FILE = em7d_voice_audio
  endif
endif

TARGET_POSTFIX = $(notdir $(basename $(TCF_FILE)))
ifneq ($(filter $(ARC_TAGS), mli20_experimental),)
  TARGET_POSTFIX := $(TARGET_POSTFIX)_mli20
endif

LIBTFLM := $(GENDIR)/$(TARGET_POSTFIX)/lib/libtensorflow-microlite.a
OBJDIR := $(GENDIR)/$(TARGET_POSTFIX)/obj
BINDIR := $(GENDIR)/$(TARGET_POSTFIX)/bin
ADAPTDIR := $(GENDIR)/adapted_models

MLI_LIB_DIR := $(MLIDIR)/arc_mli_$(TARGET_POSTFIX)

ifneq ($(filter $(ARC_TAGS), mli20_experimental),)
  LIBMLI := $(MLI_LIB_DIR)/bin/arc/libmli.a
else
  ifneq ($(filter $(ARC_TAGS), emsdp),)
    LIBMLI := $(MLI_LIB_DIR)/bin/emsdp_em11d_em9d_dfss/release/libmli.a
  else
    LIBMLI := $(MLI_LIB_DIR)/bin/libmli.a
  endif
endif



#=================================================================
# URLs to packages
#=================================================================

ifneq ($(filter $(ARC_TAGS), mli20_experimental),)
  EMBARC_MLI_URL := "https://github.com/foss-for-synopsys-dwc-arc-processors/embarc_mli/archive/refs/tags/Release_2.0.zip"
  EMBARC_MLI_MD5 := "13dcc1ea81ed836326a616e7e842ae4d"
else ifneq ($(filter $(ARC_TAGS), emsdp),)
  EMBARC_MLI_URL := "https://github.com/foss-for-synopsys-dwc-arc-processors/embarc_mli/releases/download/Release_1.1/embARC_MLI_package.zip"
  EMBARC_MLI_MD5 := "173990c2dde4efef6a2c95b92d1f0244"
else
  EMBARC_MLI_URL := "https://github.com/foss-for-synopsys-dwc-arc-processors/embarc_mli/archive/refs/tags/Release_1.1.zip"
  EMBARC_MLI_MD5 := "22555d76097727b00e731563b42cb098"
endif



#=============================================================
# Applications settings
#=============================================================

DBG_ARGS ?= 

RUN_ARGS ?= 

EXT_CFLAGS ?=

CXXFLAGS += -fno-rtti -fno-exceptions -fno-threadsafe-statics -Werror -fno-unwind-tables -ffunction-sections -fdata-sections -fmessage-length=0 -DTF_LITE_STATIC_MEMORY -DTF_LITE_DISABLE_X86_NEON -DARC_CUSTOM -DARC_MLI -tcf_core_config -Hnocopyr -Hpurge -Hdense_prologue -fslp-vectorize-aggressive -ffunction-sections -fdata-sections  -Hcl -Hcrt_fast_memcpy -Hcrt_fast_memset -Hheap=24K -I. -I./third_party/gemmlowp -I./third_party/flatbuffers/include -I./third_party/ruy -I. -I./third_party/kissfft -O3

CCFLAGS +=  -Wimplicit-function-declaration -Werror -fno-unwind-tables -ffunction-sections -fdata-sections -fmessage-length=0 -DTF_LITE_STATIC_MEMORY -DTF_LITE_DISABLE_X86_NEON -DARC_CUSTOM -DARC_MLI -tcf_core_config -Hnocopyr -Hpurge -Hdense_prologue -fslp-vectorize-aggressive -ffunction-sections -fdata-sections  -Hcl -Hcrt_fast_memcpy -Hcrt_fast_memset -Hheap=24K -I. -I./third_party/gemmlowp -I./third_party/flatbuffers/include -I./third_party/ruy -I. -I./third_party/kissfft -O3

LDFLAGS := -m
ifneq ($(BUILDLIB_DIR), )
  LDFLAGS += -Hlib=$(BUILDLIB_DIR)
else
  $(warning BUILDLIB_DIR variable is not specified. Default will be used.)
endif
CXXFLAGS += -tcf=$(TCF_FILE)
CCFLAGS += -tcf=$(TCF_FILE)
ifneq ($(LCF_FILE), )
  LDFLAGS += $(LCF_FILE)
endif

ifneq ($(filter $(ARC_TAGS), mli20_experimental),)
  CXXFLAGS += -DMLI_2_0
  CCFLAGS += -DMLI_2_0
else
  CXXFLAGS += -Hon=Long_enums
  CCFLAGS += -Hon=Long_enums
endif


ARFLAGS := -r
 
MLI_ONLY ?= false

INCLUDES := \
	-I./$(MLI_LIB_DIR)/include/ \
	-I./$(MLI_LIB_DIR)/include/api

MS_INCLUDES := \
	$(INCLUDES) \
	-I./examples/micro_speech \
	-I./examples/micro_speech/model
 
PD_INCLUDES := \
	$(INCLUDES) \
	-I./examples/person_detection \
	-I./examples/person_detection/model

ifeq ($(MLI_ONLY), true) 
	CCFLAGS += -DTF_LITE_STRIP_REFERENCE_IMPL 
	CXXFLAGS += -DTF_LITE_STRIP_REFERENCE_IMPL 
endif



#=============================================================
# Files and directories
#=============================================================

TFLM_CC_SRCS := $(shell find tensorflow -name "*.cc" -o -name "*.c")

ALL_SRCS := \
	$(TFLM_CC_SRCS) \
	$(wildcard third_party/kissfft/*.c) \
	$(wildcard third_party/kissfft/*/*.c)

HW_SRCS := \
	$(wildcard examples/hello_world/*.cc)

# Use adapted model if EmbARC MLI 2.0 is used
ifneq ($(filter $(ARC_TAGS), mli20_experimental), )
  MS_MODEL := examples/micro_speech/adapted_model/micro_speech_model_data.cc
  PD_MODEL := examples/person_detection/adapted_model/person_detect_model_data.cc
else
  MS_MODEL := examples/micro_speech/model/micro_speech_model_data.cc
  PD_MODEL := examples/person_detection/model/person_detect_model_data.cc
endif

MS_SRCS := \
	$(MS_MODEL) \
	$(wildcard examples/micro_speech/*.cc) \
	$(wildcard examples/micro_speech/testdata/*.cc) \
	$(wildcard examples/micro_speech/micro_features/*.cc)

PD_SRCS := \
	$(PD_MODEL) \
	$(wildcard examples/person_detection/*.cc)

OBJS := \
	$(addprefix $(OBJDIR)/, $(patsubst %.cc,%.o,$(patsubst %.c,%.o,$(ALL_SRCS))))

HW_OBJS := \
	$(addprefix $(OBJDIR)/, $(patsubst %.cc,%.o,$(HW_SRCS)))

MS_OBJS := \
	$(addprefix $(OBJDIR)/, $(patsubst %.cc,%.o,$(MS_SRCS)))

PD_OBJS := \
	$(addprefix $(OBJDIR)/, $(patsubst %.cc,%.o,$(PD_SRCS)))



#=============================================================
# Common rules
#=============================================================
.PHONY: all app flash clean run debug

$(OBJDIR)/%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(EXT_CFLAGS) $(INCLUDES) -c $< -o $@

$(OBJDIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CCFLAGS) $(EXT_CFLAGS) $(INCLUDES) -c $< -o $@

$(LIBTFLM): $(OBJS)
	@mkdir -p $(dir $@)
	$(AR) $(ARFLAGS) $(LIBTFLM) $(OBJS)

$(MLI_LIB_DIR):
	@mkdir -p $@

# Building example with specified includes.
$(OBJDIR)/examples/micro_speech/%.o: examples/micro_speech/%.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(EXT_CFLAGS) $(MS_INCLUDES) -c $< -o $@

# Building example with specified includes.
$(OBJDIR)/examples/person_detection/%.o: examples/person_detection/%.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(EXT_CFLAGS) $(PD_INCLUDES) -c $< -o $@



#=================================================================
# Global rules
#=================================================================

ifneq ($(filter $(ARC_TAGS), emsdp),)
  APP_RUN := mdb -run -digilent -nooptions $(DBG_ARGS)
  APP_DEBUG := mdb -OK -digilent -nooptions $(DBG_ARGS)
else
  APP_RUN := mdb -run -tcf=$(TCF_FILE) $(DBG_ARGS)
  APP_DEBUG := mdb -OK -tcf=$(TCF_FILE) $(DBG_ARGS)
endif

microlite: $(LIBTFLM)

hello_world: hello_world.elf
	$(APP_RUN) $(BINDIR)/$@/$< $(RUN_ARGS)

micro_speech: micro_speech.elf
	$(APP_RUN) $(BINDIR)/$@/$< $(RUN_ARGS)

person_detection: person_detection.elf
	$(APP_RUN) $(BINDIR)/$@/$< $(RUN_ARGS)

hello_world.elf: build_mli microlite $(HW_OBJS)
	@mkdir -p $(BINDIR)/$(basename $@)
	$(eval LDFLAGS += -Hldopt=-Coutput=$(BINDIR)/$(basename $@)/memory.map)
	$(LD) $(CXXFLAGS) $(HW_OBJS) $(LIBTFLM) $(LIBMLI) $(LDFLAGS) -o $(BINDIR)/$(basename $@)/$@

micro_speech.elf: build_mli microlite $(MS_OBJS)
	@mkdir -p $(BINDIR)/$(basename $@)
	$(eval LDFLAGS += -Hldopt=-Coutput=$(BINDIR)/$(basename $@)/memory.map)
	$(LD) $(CXXFLAGS) $(MS_OBJS) $(LIBTFLM) $(LIBMLI) $(LDFLAGS) -o $(BINDIR)/$(basename $@)/$@

person_detection.elf: build_mli microlite $(PD_OBJS)
	@mkdir -p $(BINDIR)/$(basename $@)
	$(eval LDFLAGS += -Hldopt=-Coutput=$(BINDIR)/$(basename $@)/memory.map)
	$(LD) $(CXXFLAGS) $(PD_OBJS) $(LIBTFLM) $(LIBMLI) $(LDFLAGS) -o $(BINDIR)/$(basename $@)/$@

clean: 
	-@$(RM) $(GENDIR)

clean_mli:
	-@$(RM) $(MLIDIR)

clean_all: clean clean_mli
	-@$(RM) `find examples -type d -name adapted_model`

build_mli:
	@$(DOWNLOAD_SCRIPT) $(MLI_LIB_DIR) $(TCF_FILE) $(EMBARC_MLI_URL) $(EMBARC_MLI_MD5)

adapt_model:
	-@$(ADAPTATION_SCRIPT) $(MODEL_NAME)
