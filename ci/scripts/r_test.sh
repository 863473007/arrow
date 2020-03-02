#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set -ex

: ${R_BIN:=R}

source_dir=${1}/r

pushd ${source_dir}

if [ "$ARROW_USE_PKG_CONFIG" != "false" ]; then
  export LD_LIBRARY_PATH=${ARROW_HOME}/lib:${LD_LIBRARY_PATH}
  export R_LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
fi
if [ "$ARROW_R_CXXFLAGS" != "" ]; then
  export _R_CHECK_COMPILATION_FLAGS_=FALSE
fi
export TEST_R_WITH_ARROW=TRUE
export ARROW_R_DEV=TRUE # For log verbosity
export _R_CHECK_TESTS_NLINES_=0
export _R_CHECK_CRAN_INCOMING_REMOTE_=FALSE
export _R_CHECK_LIMIT_CORES_=FALSE
export VERSION=$(grep ^Version DESCRIPTION | sed s/Version:\ //)

# Make sure we aren't writing to the home dir (CRAN _hates_ this but there is no official check)
BEFORE=$(ls -alh ~/)

${R_BIN} -e "rcmdcheck::rcmdcheck(build_args = '--no-build-vignettes', args = c('--no-manual', '--as-cran', '--ignore-vignettes', '--run-donttest'), error_on = 'warning', check_dir = 'check')"

AFTER=$(ls -alh ~/)
if [ "$BEFORE" != "$AFTER" ]; then
  ls -alh ~/.cmake/packages
  exit 1
fi
popd
