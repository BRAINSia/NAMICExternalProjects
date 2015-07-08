#!/bin/bash

HERE=$(pwd)

# This script is to document how to install NEP on neon cluster
# for the purpose of running BRAINSAutoWorkup
#
## --
## -- Setup environment
## --
export QT4PREFIX=/Shared/pinc/sharedopt/apps/qt/Linux/x86_64/4.8.7

export NEP_BUILD_NAME="NEP-icc"

#ANACONDA_SHELL_INSTALL=https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda-2.3.0-MacOSX-x86_64.sh

ANACONDA_SHELL_INSTALL=https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda-2.3.0-Linux-x86_64.sh
## /Shared/pinc/sharedopt/20150703/RHEL6
BASE_DIR=/Shared/pinc/sharedopt
#BASE_DIR=/tmp
DATE_STAMP=20150704
PLATFORM_NAME=RHEL6
INSTALL_DIR=${BASE_DIR}/${DATE_STAMP}/${PLATFORM_NAME}

echo "INSTALLING in : $INSTALL_DIR"
# -Setup compilers
#export CC=/scratch/johnsonhj/local/bin/clang11
#export CXX=/scratch/johnsonhj/local/bin/clang++11
OLD_CC=$(which icc)
OLD_CXX=$(which icpc)

module unload gcc/4.8.2
module load intel/2015.3.187

source /opt/intel/composer_xe_2015.3.187/bin/compilervars.sh intel64
export CXX=$(which icpc)
export CC=$(which icc)
export CXXFLAGS="-axAVX,SSSE3 -O3 -g -std=c++11 -inline-level=1 "
export CFLAGS="-axAVX,SSSE3 -O3 -g -inline-level=1 "

mkdir -p ${INSTALL_DIR}
cd ${INSTALL_DIR}
if [ ! -f Anaconda.sh ] ; then
  curl ${ANACONDA_SHELL_INSTALL} -o Anaconda.sh
fi
chmod u+x Anaconda.sh

ANACONDA_DIR=${INSTALL_DIR}/anaconda_${DATE_STAMP}
conda_bin=$(which conda)
if [ ! -z "${conda_bin}" ]; then
if [ "${conda_bin}" != "${ANACONDA_DIR}/bin/conda" ] ; then
  echo "ERROR:  conflicting anaconda install at"
  echo "ERROR: ${conda_bin} != ${ANACONDA_DIR}/bin/conda"
  echo "temporarily remove anaconda from path before continuing."
fi
fi

if [ ! -d ${ANACONDA_DIR} ]; then
  bash  --norc ${INSTALL_DIR}/Anaconda.sh -b -p ${ANACONDA_DIR}
  conda install docopt
  pip install nipype
fi
echo "USING: $(which python)"
export PATH=${ANACONDA_DIR}/bin:$PATH

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
