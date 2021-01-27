#! /bin/bash

set -e

function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

[ ${BREEZE_LSB_ID} ]
[ ${BREEZE_LSB_RELEASE} ]
#[ ${BREEZE_KERNEL} ]
[ ${BREEZE_PYTHON_VERSION} ]
if [ "${BREEZE_LSB_ID}" != "RedHat" ] && [ "${BREEZE_LSB_ID}" != "CentOS" ] && [ "${BREEZE_LSB_ID}" != "Ubuntu" ]; then
  echo "please use RHEL or CentOS or Ubuntu"
  exit
fi

