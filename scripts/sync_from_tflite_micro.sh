#!/usr/bin/env bash
#
# Copyright 2022, Synopsys, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-3-Clause license found in
# the LICENSE file in the root directory of this source tree.
#

set -e -x

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
cd "${ROOT_DIR}"

TEMP_DIR=$(mktemp -d)
cd "${TEMP_DIR}"

echo Cloning tflite-micro repo to "${TEMP_DIR}"
git clone --depth 1 --single-branch "https://github.com/tensorflow/tflite-micro.git"
cd tflite-micro

TARGET=arc_custom
OPTIMIZED_KERNEL_DIR=arc_mli
TARGET_ARCH=arc


# Create the TFLM base tree
python3 tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py \
  -e hello_world -e micro_speech_mock -e person_detection \
  --makefile_options="OPTIMIZED_KERNEL_DIR=${OPTIMIZED_KERNEL_DIR} TARGET=${TARGET} TARGET_ARCH=${TARGET_ARCH} ARC_TAGS=project_generation" \
  "${TEMP_DIR}/tflm-arc"

cd "${ROOT_DIR}"
rm -rf tensorflow
rm -rf third_party
rm -rf examples
mv "${TEMP_DIR}/tflm-arc/tensorflow" tensorflow
mv "${TEMP_DIR}/tflm-arc/third_party" tensorflow
mv "${TEMP_DIR}/tflm-arc/examples" examples
mkdir examples/micro_speech/model
mv examples/micro_speech/micro_speech_model_data.cc examples/micro_speech/model/micro_speech_model_data.cc
mv examples/micro_speech/micro_speech_model_data.h examples/micro_speech/model/micro_speech_model_data.h
mv tensorflow/lite/micro/models examples/person_detection/model

rm -rf "${TEMP_DIR}"