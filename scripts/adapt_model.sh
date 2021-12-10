#!/bin/bash
#
# Copyright 2021, Synopsys, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-3-Clause license found in
# the LICENSE file in the root directory of this source tree.
#

set -e

adapt_model() {
	local MODEL_NAME=${1}
    local ADAPTDIR=examples/${MODEL_NAME}/adapted_model

	if [[ -z "${MODEL_NAME}" ]]; then
		echo "MODEL_NAME is not specified."
		exit 1
	else
		if [[ ${MODEL_NAME} == "micro_speech" ]]; then
			mkdir -p ${ADAPTDIR}
			python adaptation_tool/adaptation_tool.py examples/micro_speech/model/micro_speech_model_data.cc ${ADAPTDIR}/micro_speech_model_data.cc
			# Need to do some additional actions for micro_speech model.
			sed -i "${ADAPTDIR}/micro_speech_model_data.cc" -e '$s/const int/const unsigned int/g' -e '$s/len/size/g'
		elif [[ ${MODEL_NAME} == "person_detection" ]]; then
			mkdir -p ${ADAPTDIR}
			python adaptation_tool/adaptation_tool.py examples/person_detection/model/person_detect_model_data.cc ${ADAPTDIR}/person_detect_model_data.cc
			# Need to do some additional actions for micro_speech model.
			sed -i "${ADAPTDIR}/person_detect_model_data.cc" -e '$s/const int/const unsigned int/g' -e '$s/len/size/g'
		else
			# The user is prompted to create their own rules for model adaptation based on examples above.
			echo "\"${MODEL_NAME}\" is unknown MODEL_NAME."
			exit 1
		fi
	fi
}

set +e

adapt_model "$1"