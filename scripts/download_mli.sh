#!/bin/bash
#
# Copyright 2021, Synopsys, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-3-Clause license found in
# the LICENSE file in the root directory of this source tree.
#

set -e

build_mli() {
	echo "Building MLI in ${MLI_LIB_DIR}..."
	if [[ ${ARC_TAGS} =~ "mli20_experimental" ]] ; then
		make -C ${PWD}/${MLI_LIB_DIR}/lib/make build TCF_FILE=${TCF_FILE} BUILDLIB_DIR=${BUILDLIB_DIR} GEN_EXAMPLES=0 JOBS=4
	else
		make -j 4 -C ${PWD}/${MLI_LIB_DIR}/lib/make TCF_FILE=${TCF_FILE}
	fi
}

download_mli() {
	MLI_LIB_DIR=${1}
	TCF_FILE=${2}
	local EMBARC_MLI_URL=${3}

  	# Check if destionation already downloaded.
	if [[ ! -d ${PWD}/${MLI_LIB_DIR} ]]; then
		mkdir -p ${MLI_LIB_DIR}
		echo "Downloading MLI archive..."
		TMP=$(mktemp)
		TMP_DIR=$(mktemp -d)
		curl -LsS --fail --retry 5 ${EMBARC_MLI_URL} -o ${TMP}
		echo "Unpacking MLI archive..."
		unzip ${TMP} -d ${TMP_DIR} 2>&1 1>/dev/null
		cp -R ${TMP_DIR}/*/* ${MLI_LIB_DIR}/
		rm -rf ${TMP} ${TMP_DIR}
		build_mli
	fi
}

set +e

download_mli "$1" "$2" "$3"