#!/bin/bash

HERE=$(pwd)

# This script is to document how to install NEP on neon cluster
# for the purpose of running BRAINSAutoWorkup
#
## --
## -- Setup environment
## --
export QT4PREFIX=/usr/local

export NEP_BUILD_NAME="NEP-11"

export MAC_PLATFORM_EXTRAS="-DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=10.9"
#ANACONDA_SHELL_INSTALL=https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda-2.3.0-MacOSX-x86_64.sh

ANACONDA_SHELL_INSTALL=https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda-2.3.0-MacOSX-x86_64.sh
## /Shared/pinc/sharedopt/20150703/RHEL6
BASE_DIR=/Shared/pinc/sharedopt
#BASE_DIR=/tmp
DATE_STAMP=20150704
PLATFORM_NAME=DARWIN
INSTALL_DIR=${BASE_DIR}/${DATE_STAMP}/${PLATFORM_NAME}

echo "INSTALLING in : $INSTALL_DIR"
# -Setup compilers
#export CC=/scratch/johnsonhj/local/bin/clang11
#export CXX=/scratch/johnsonhj/local/bin/clang++11
OLD_CC=/scratch/johnsonhj/local/bin/clang11
OLD_CXX=/scratch/johnsonhj/local/bin/clang++11

export CC=/scratch/johnsonhj/local/bin/clang11
export CXX=/scratch/johnsonhj/local/bin/clang++11
export CXXFLAGS=" -O3 "
export CFLAGS="-O3 "

mkdir -p ${INSTALL_DIR}
cd ${INSTALL_DIR}
if [ ! -f Anaconda.sh ] ; then
  curl ${ANACONDA_SHELL_INSTALL} -o Anaconda.sh
fi
chmod u+x Anaconda.sh

ANACONDA_DIR=${INSTALL_DIR}/anaconda_${DATE_STAMP}/anaconda
conda_bin=$(which conda)
if [ ! -z "${conda_bin}" ]; then
if [ "${conda_bin}" != "${ANACONDA_DIR}/bin/conda" ] ; then
  echo "ERROR:  conflicting anaconda install at"
  echo "ERROR: ${conda_bin} != ${ANACONDA_DIR}/bin/conda"
  echo "temporarily remove anaconda from path before continuing."
fi
fi

export PATH=${ANACONDA_DIR}/bin:${QT4PREFIX}/bin:${PATH}
if [ ! -d ${ANACONDA_DIR} ]; then
  export DYLD_LIBRARY_PATH=/Shared/pinc/sharedopt/20150704/DARWIN/anaconda_20150704/pkgs/zlib-1.2.8-0/lib
  bash  --norc ${INSTALL_DIR}/Anaconda.sh -b -p ${ANACONDA_DIR}
  conda install docopt
  pip install nipype
fi
python_bin=$(which python)
if [ ! -z "${python_bin}" ]; then
if [ "${python_bin}" != "${ANACONDA_DIR}/bin/python" ] ; then
  echo "ERROR:  conflicting anapython install at"
  echo "ERROR: ${python_bin} != ${ANACONDA_DIR}/bin/python"
  echo "temporarily remove anapython from path before continuing."
  echo "bash  --norc ${INSTALL_DIR}/Anaconda.sh -b -p ${ANACONDA_DIR}"
fi
fi
echo "USING: $(which python)"

if [ ! -d ${INSTALL_DIR}/cmake ]; then
    git clone git://cmake.org/cmake.git
fi

if [ ! -f ${INSTALL_DIR}/local/bin/cmake ]; then
   mkdir -p ${INSTALL_DIR}/cmake-bld
   cd cmake-bld
   CC=${CC} CXX=${CXX} \
     cmake \
      -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_DIR}/local \
      -DCMAKE_CXX_FLAGS:STRING=${CXXFLAGS} \
      -DCMAKE_C_FLAGS:STRING=${CFLAGS} \
      ${INSTALL_DIR}/cmake
   make -j 16
   make install
fi

export PATH=${INSTALL_DIR}/local/bin:${PATH}


cd ${HERE}
