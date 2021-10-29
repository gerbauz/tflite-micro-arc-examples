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
# TODO: change this description
#=============================================================

GENDIR := gen
MLIDIR := mli_lib

ifeq ($(TCF_FILE),)
	TCF_FILE = em7d_voice_audio
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
	LIBMLI := $(MLI_LIB_DIR)/bin/libmli.a
endif



#=================================================================
# TODO: rename to links or something and move to up
#=================================================================

ifneq ($(filter $(ARC_TAGS), mli20_experimental),)
	EMBARC_MLI_URL := "https://github.com/foss-for-synopsys-dwc-arc-processors/embarc_mli/archive/refs/tags/Release_2.0.zip"
	EMBARC_MLI_MD5 := "fe256e06e31e27b75fb166aeeafc7f88"
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
CXXFLAGS += -tcf=$(TCF_FILE)
CCFLAGS += -tcf=$(TCF_FILE)
# CXXFLAGS += -Hlib=$(BUILD_LIB_DIR)
# CCFLAGS += -Hlib=$(BUILD_LIB_DIR)

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

APP_RUN := mdb -run -tcf=$(TCF_FILE) $(DBG_ARGS)
APP_DEBUG := mdb -OK -tcf=$(TCF_FILE) $(DBG_ARGS)

# run: $(OUT_NAME)
# 	$(APP_RUN) $(OUT_NAME) $(RUN_ARGS)

# debug: $(OUT_NAME)
# 	$(APP_DEBUG) $(OUT_NAME) $(RUN_ARGS)

microlite: $(LIBTFLM)

hello_world: hello_world.elf
	$(APP_RUN) $(BINDIR)/$@/$< $(RUN_ARGS)

micro_speech: micro_speech.elf
	$(APP_RUN) $(BINDIR)/$@/$< $(RUN_ARGS)

person_detection: person_detection.elf
	$(APP_RUN) $(BINDIR)/$@/$< $(RUN_ARGS)

hello_world.elf: build_mli microlite $(HW_OBJS)
	@mkdir -p $(BINDIR)/$(basename $@)
	$(eval LDFLAGS += -Coutput=$(BINDIR)/$(basename $@)/memory.map)
	$(LD) $(CXXFLAGS) $(HW_OBJS) $(LIBTFLM) $(LIBMLI) $(LDFLAGS) -o $(BINDIR)/$(basename $@)/$@

micro_speech.elf: build_mli microlite $(MS_OBJS)
	@mkdir -p $(BINDIR)/$(basename $@)
	$(eval LDFLAGS += -Coutput=$(BINDIR)/$(basename $@)/memory.map)
	$(LD) $(CXXFLAGS) $(MS_OBJS) $(LIBTFLM) $(LIBMLI) $(LDFLAGS) -o $(BINDIR)/$(basename $@)/$@

person_detection.elf: build_mli microlite $(PD_OBJS)
	@mkdir -p $(BINDIR)/$(basename $@)
	$(eval LDFLAGS += -Coutput=$(BINDIR)/$(basename $@)/memory.map)
	$(LD) $(CXXFLAGS) $(PD_OBJS) $(LIBTFLM) $(LIBMLI) $(LDFLAGS) -o $(BINDIR)/$(basename $@)/$@

clean: 
	-@$(RM) $(GENDIR)

clean_mli:
	-@$(RM) $(MLIDIR)

clean_all: clean clean_mli
	-@$(RM) `find examples -type d -name adapted_model`

build_mli:
	-@$(DOWNLOAD_SCRIPT) $(MLI_LIB_DIR) $(TCF_FILE) $(EMBARC_MLI_URL)

adapt_model:
	-@$(ADAPTATION_SCRIPT) $(MODEL_NAME)



#=================================================================
# Execution rules
#=================================================================



