# TensorFlow Lite Micro Library Examples for EmbARC MLI Library
 
This repository contains [TensorFlow Lite Micro Library (TFLM)](https://github.com/tensorflow/tflite-micro) examples and script files to run them on ARC platforms using The Synopsys DesignWare ARC MetaWare Development Toolkit (MWDT).

## Table of Contents

-   [List of Supported Examples](#List-of-Supported-Examples)
-   [Important Links to the Original TFLM Repository](#Important-Links-to-the-Original-TFLM-Repository)
-   [Prerequisites](#Prerequisites)
-   [How to Install](#How-to-Install)
-   [General Build Process](#General-Build-Process)
-   [Build and Run Examples](#Build-and-Run-Examples)
-   [Model Adaptation Tool](#Model-Adaptation-Tool-beta)

## List of Supported Examples

* Hello World ([link to the original repository](https://github.com/tensorflow/tflite-micro/tree/main/tensorflow/lite/micro/examples/hello_world))
* Micro Speech ([link to the original repository](https://github.com/tensorflow/tflite-micro/tree/main/tensorflow/lite/micro/examples/micro_speech))
* Person Detection ([link to the original repository](https://github.com/tensorflow/tflite-micro/tree/main/tensorflow/lite/micro/examples/person_detection))

## Important Links to the Original TFLM Repository

* [EmbARC MLI Library optimized TFLM kernels](https://github.com/foss-for-synopsys-dwc-arc-processors/tflite-micro/tree/fork_main/tensorflow/lite/micro/kernels/arc_mli)
* [Building TFLM for Synopsys DesignWare ARC VPX and EM/HS Processors](https://github.com/tensorflow/tflite-micro/tree/main/tensorflow/lite/micro/tools/make/targets/arc)

## Prerequisites

To build and run examples for an ARC EM/HS/VPX platform, you need the following software:

* [Synopsys MetaWare
Development Toolkit](https://www.synopsys.com/dw/ipdir.php?ds=sw_metaware) version 2019.12 or higher for MLI 1.1 and 2021.09 or higher for MLI Library 2.0
* [GNU Make](https://www.gnu.org/software/make/) tool (make or gmake) version 3.82 or higher
* [CMake](https://cmake.org/) 3.18 or higher

If you are using MLI 2.0, the [Model Adaptation Tool](#Model-Adaptation-Tool-beta) will also require following:
* [Python](https://www.python.org/downloads/) 3.7 or higher
* [TensorFlow for Python](https://www.tensorflow.org/install/pip) version 2.5

See
[Install the Synopsys DesignWare ARC MetaWare Development Toolkit](#Install-the-Synopsys-DesignWare-ARC-MetaWare-Development-Toolkit)
section for instructions on toolchain installation. See MetaWare Development 
Toolkit and Make Tool sections in [Initial Setup](#Initial-Setup) section for 
instructions on toolchain installation and comments about make versions.

## How to Install

### Install the Synopsys DesignWare ARC MetaWare Development Toolkit

The Synopsys DesignWare ARC MetaWare Development Toolkit (MWDT) is required to
build and run Tensorflow Lite Micro applications for all ARC VPX and EM/HS targets.

To license MWDT, please see further details
[here](https://www.synopsys.com/dw/ipdir.php?ds=sw_metaware)

To request an evaluation version of MWDT, please use the
[Synopsys Eval Portal](https://eval.synopsys.com/) and follow the link for the
MetaWare Development Toolkit (Important: Do not confuse this with MetaWare EV
Development Toolkit or MetaWare Lite options also available on this page).

Run the downloaded installer and follow the instructions to set up the toolchain on your platform.

Please consider that the examples can be only built and run on Linux machines, so you need to install Linux version of MWDT.

### ARC EM Software Development Platform (ARC EM SDP)

This section describes how to set up an
[ARC EM SDP board](https://www.synopsys.com/dw/ipdir.php?ds=arc-em-software-development-platform)

#### Initial Setup

To use the EM SDP, you need the following hardware and software:

* ARC EM SDP

More information on the platform, including ordering information, can be found
[here](https://www.synopsys.com/dw/ipdir.php?ds=arc-em-software-development-platform).

* MetaWare Development Toolkit

See
[Install the Synopsys DesignWare ARC MetaWare Development Toolkit](#Install-the-Synopsys-DesignWare-ARC-MetaWare-Development-Toolkit)
section for instructions on toolchain installation.

* Digilent Adept 2 System Software Package

If you wish to use the MetaWare Debugger to debug your code, you need to also
install the Digilent Adept 2 software, which includes the necessary drivers for
connecting to the targets. This is available from official
[Digilent site](https://reference.digilentinc.com/reference/software/adept/start?redirect=1#software_downloads).
You should install the “System” component, and Runtime. Utilities and SDK are
NOT required.

Digilent installation is NOT required if you plan to deploy to EM SDP via the SD
card instead of using the debugger.

* Make Tool

[GNU Make](https://www.gnu.org/software/make/) tool (make or gmake) version 3.82 or higher
is required.

* Serial Terminal Emulation Application

The Debug UART port of the EM SDP is used to print application output. The USB
connection provides both the debug channel and RS232 transport. You can use any
terminal emulation program (like [PuTTY](https://www.putty.org/)) to view UART
output from the EM SDP.

* microSD Card

If you want to self-boot your application (start it independently from a
debugger connection), you also need a microSD card with a minimum size of 512 MB
and a way to write to the card from your development host. Note that the card
must be formatted as FAT32 with default cluster size (but less than 32 Kbytes)

#### Connect the Board

1.  Make sure Boot switches of the board (S3) are configured in the next way:

Switch # | Switch position
:------: | :-------------:
1        | Low (0)
2        | Low (0)
3        | High (1)
4        | Low (0)

1.  Connect the power supply included in the product package to the ARC EM SDP.
2.  Connect the USB cable to connector J10 on the ARC EM SDP (near the RST and
    CFG buttons) and to an available USB port on your development host.
3.  Determine the COM port assigned to the USB Serial Port (on Windows, using
    Device Manager is an easy way to do this)
4.  Execute the serial terminal application you installed in the previous step
    and open the serial connection with the early defined COM port (speed 115200
    baud; 8 bits; 1 stop bit; no parity).
5.  Push the CFG button on the board. After a few seconds you should see the
    boot log in the terminal which begins as follows:

```
U-Boot <Versioning info>

CPU:   ARC EM11D v5.0 at 40 MHz
Subsys:ARC Data Fusion IP Subsystem
Model: snps,emsdp
Board: ARC EM Software Development Platform v1.0
…
```

### Custom ARC EM/HS/VPX Platform

This section describes how to deploy on a Custom ARC VPX or EM/HS platform defined only by a TCF (Tool configuration File, created at CPU configuration time) and optional LCF (Linker Command File). In this case, the real hardware is unknown, and applications can be run only in the nSIM simulator included with the MetaWare toolkit.

VPX support is presented as an experimental feature of supporting embARC MLI Library version 2.0 and model adaptation.

#### Initial Setup

To use a custom ARC EM/HS/VPX platform, you need the following : 

* MetaWare Development Toolkit

See
[Install the Synopsys DesignWare ARC MetaWare Development Toolkit](#Install-the-Synopsys-DesignWare-ARC-MetaWare-Development-Toolkit)
section for instructions on toolchain installation.

* Make Tool

[GNU Make](https://www.gnu.org/software/make/) tool (make or gmake) version 3.82 or higher
is required.

* CMake Tool

[CMake](https://cmake.org/) 3.18 or higher is required.

If you are using the [Model Adaptation Tool](#Model-Adaptation-Tool-experimental-feature), you will also need to install:

* Python 

[Python](https://www.python.org/downloads/) 3.7 or higher is required.

* TensorFlow for Python 

[TensorFlow for Python](https://www.tensorflow.org/install/pip) version 2.5 or higher is required.


## General Build Process

General template of the build command looks like:
```
make <options> <target>
```
Available `<targets>`:
- `<example_name>` - build and run example with all dependencies. More at [Build and Run Examples](#Build-and-Run-Examples).
- `build_mli` - only download and build embARC MLI Library for target configuration.
- `microlite` - only build TFLM as a library for specific configuration. Note: you have to build MLI Library using `build_mli` target before running this one.
- `adapt_model MODEL_NAME=<example_name>` - use Model Adaptation Tool to adapt example model to use it with MLI 2.0. Available `<example_names>`: micro_speech, person_detection. More at [Model Adaptation Tool](#Model-Adaptation-Tool-beta).
- `clean` - delete binaries and object files for built examples.
- `clean_mli` - delete MLI Libraries.
- `clean_all` - delete everything built or downloaded including converted models.

Available `<options>`:
- `TCF_FILE=<path_to_tcf_file>` - tool configuration file (TCF) file path.
- `LCF_FILE=<path_to_lcf_file>` - linker command file (LCF) file path.
- `BUILDLIB_DIR=` - path to runtime libraries for the ARC platform to link applications with. Learn more at [embARC MLI Library README](https://github.com/foss-for-synopsys-dwc-arc-processors/embarc_mli#buildlib_dir).
- `ARC_TAGS=<tag_1>, <tag_2>, ...` - list of specific tags. Currently only `mli20_experimental` tag is supported. It is used to turn on build for embARC MLI 2.0.

## Build and Run Examples

### Hello World

[Link to the original example description.](https://github.com/tensorflow/tflite-micro/tree/main/tensorflow/lite/micro/examples/hello_world)

#### For EM SDP (using MLI 1.1):
```
make ARC_TAGS=emsdp hello_world
```

#### For EM (using MLI 1.1):
```
make TCF_FILE=<path_to_tcf_file> LCF_FILE=<path_to_lcf_file> hello_world
```

#### For VPX (using MLI 2.0):
```
make TCF_FILE=<path_to_tcf_file> LCF_FILE=<path_to_lcf_file> ARC_TAGS=mli20_experimental hello_world
```

### Micro Speech

[Link to the original example description.](https://github.com/tensorflow/tflite-micro/tree/main/tensorflow/lite/micro/examples/micro_speech)

#### For EM SDP (using MLI 1.1):
```
make ARC_TAGS=emsdp micro_speech
```

#### For EM (using MLI 1.1):
```
make TCF_FILE=<path_to_tcf_file> LCF_FILE=<path_to_lcf_file> micro_speech
```

#### For VPX (using MLI 2.0):
First you need to convert model using [Model Adaptation Tool](#Model-Adaptation-Tool-beta):
```
make adapt_model micro_speech
```
Then build and run an example:
```
make TCF_FILE=<path_to_tcf_file> LCF_FILE=<path_to_lcf_file> ARC_TAGS=mli20_experimental micro_speech
```

### Person Detection

[Link to the original example description.](https://github.com/tensorflow/tflite-micro/tree/main/tensorflow/lite/micro/examples/person_detection)

#### For EM SDP (using MLI 1.1):
```
make ARC_TAGS=emsdp person_detection
```

#### For EM (using MLI 1.1):
```
make TCF_FILE=<path_to_tcf_file> LCF_FILE=<path_to_lcf_file> person_detection
```

#### For VPX (using MLI 2.0):
First you need to convert model using [Model Adaptation Tool](#Model-Adaptation-Tool-beta):
```
make adapt_model person_detection
```
Then build and run an example:
```
make TCF_FILE=<path_to_tcf_file> LCF_FILE=<path_to_lcf_file> ARC_TAGS=mli20_experimental person_detection
```

### Run the Application on the EM SDP Board from the microSD Card

1.  Go to `gen/<target_name>/bin/<example_name>` and copy `.elf` file as `app.elf`.
    For example:
```
    cd gen/emsdp_em11d_em9d_dfss/bin/hello_world
    cp hello_world.elf app.elf
```

2.  Copy `app.elf` into the root of microSD card. Note that the card must be formatted
    as FAT32 with default cluster size (but less than 32 KBytes)

3.  Plug in the microSD card into the J11 connector.

4.  Push the RST button. If a red LED is lit beside RST button, push the CFG
    button.

5.  Using serial terminal, create uboot environment file to automatically run
    the application on start-up. Type or copy next sequence of commands into
    serial terminal one-by-another:
```
   setenv loadaddr 0x10800000
   setenv bootfile app.elf
   setenv bootdelay 1
   setenv bootcmd fatload mmc 0 \$\{loadaddr\} \$\{bootfile\} \&\& bootelf
   saveenv
```

6.  Push the CFG button on the board.

You will see the application output in the serial terminal.

## Model Adaptation Tool (beta)

Models in TFLM format need to be pre-adapted before being used with MLI 2.0 due to differences in weights' tensor layout in some kernels. Adaptation is done automatically during TFLM project generation, but requires TensorFlow to be installed.

To use the Model Adaptation Tool, you need the following tools in addition to common requirments:
* [Python](https://www.python.org/downloads/) 3.7 or higher
* [TensorFlow for Python](https://www.tensorflow.org/install/pip) version 2.5 using following command:

```
pip install --upgrade tensorflow==2.5.0
```

For examples in this repository following command can be used to prepare model for MLI 2.0:
```
make adapt_model MODEL_NAME=<example_name>
```

If you want to use your own custom model, exported from TensorFlow in **.tflite** or **.cc** format, you will need to adapt it manually using the Model Adaptation Tool from the current folder, using the following command:

```
python adaptation_tool/adaptation_tool.py <path_to_input_model_file> \
<path_to_adapted_model_file>
```
