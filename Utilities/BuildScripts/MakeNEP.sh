#!/bin/bash

if [ ! -f "$1" ]; then
  echo "ERROR: Missing build config"
  exit -1
fi
source $1

if [ ${OLD_CC} != ${CC} ] || [ ${OLD_CXX} != ${CXX} ]; then
   echo "WARNING:  Environment does not match coded version"
   echo "[ ${OLD_CC} != ${CC} ] || [ ${OLD_CXX} != ${CXX} ]"
   echo "RUN:"
   cat > /tmp/x << EOF
   # echo you need to setup environment first
   source $1
EOF
   cat /tmp/x
   exit -1
fi

if [ ! -d ${INSTALL_DIR}/NAMICExternalProjects ]; then
  cd ${INSTALL_DIR}
  git clone https://github.com/BRAINSia/NAMICExternalProjects.git
fi

cd ${INSTALL_DIR}
mkdir -p ${INSTALL_DIR}/${NEP_BUILD_NAME}
cd ${INSTALL_DIR}/${NEP_BUILD_NAME}
CC=${CC} CXX=${CXX} \
  cmake ${INSTALL_DIR}/NAMICExternalProjects \
 -DCMAKE_CXX_FLAGS:STRING="${CXXFLAGS}" \
 -DCMAKE_C_FLAGS:STRING="${CFLAGS}" \
  \
 -DCMAKE_BUILD_TYPE:STRING=Release \
 \
 -DQT_QMAKE_EXECUTABLE:FILE_PATH=${QT4PREFIX}/bin/qmake \
 \
 -DPYTHON_EXECUTABLE:FILE_PATH=${ANACONDA_DIR}/bin/python2.7 \
 -DPYTHON_INCLUDE_DIR:PATH=${ANACONDA_DIR}/include/python2.7/ \
 -DPYTHON_LIBRARY:FILE_PATH=${ANACONDA_DIR}/lib/libpython2.7.so \
 -DPYTHON_LIBRARY_DEBUG:FILE_PATH=${ANACONDA_DIR}/lib/libpython2.7.so \
 -DPYTHON_LIBRARY_RELEASE:FILE_PATH=${ANACONDA_DIR}/lib/libpython2.7.so \
 ${MAC_PLATFORM_EXTRAS} \

make -j 16 -k -C ${INSTALL_DIR}/${NEP_BUILD_NAME}
