set(proj Eigen)

set(${proj}_DEPENDENCIES "")
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

ExternalProject_SetIfNotDefined(
  ${CMAKE_PROJECT_NAME}_${proj}_GIT_REPOSITORY
  "https://gitlab.com/libeigen/eigen.git"
  QUIET
  )
ExternalProject_SetIfNotDefined(
  ${CMAKE_PROJECT_NAME}_${proj}_GIT_TAG
  3.4.0
  QUIET
  )

ExternalProject_Add(${proj}
  ${${proj}_EP_ARGS}
  GIT_REPOSITORY "${${CMAKE_PROJECT_NAME}_${proj}_GIT_REPOSITORY}"
  GIT_TAG "${${CMAKE_PROJECT_NAME}_${proj}_GIT_TAG}"
  GIT_SHALLOW ${${SUPERBUILD_TOPLEVEL_PROJECT}_EP_GIT_SHALLOW}
  UPDATE_DISCONNECTED TRUE
  SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}
  BINARY_DIR ${proj}-build
  LOG_CONFIGURE ON
  LOG_BUILD ON
  LOG_INSTALL ON
  LOG_OUTPUT_ON_FAILURE ON
  CMAKE_ARGS -Wno-dev --no-warn-unused-cli
  CMAKE_CACHE_ARGS
    ${EXTERNAL_PROJECT_DEFAULTS}
    -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/${proj}-install
    -DEIGEN_BUILD_PKGCONFIG:BOOL=OFF
    -DEIGEN_TEST_NOQT:BOOL=ON
    -DBUILD_TESTING:BOOL=OFF
  DEPENDS
    ${${proj}_DEPENDENCIES}
  )
set(Eigen_DIR ${CMAKE_BINARY_DIR}/${proj}-install)
set(Eigen_INCLUDE_DIR ${CMAKE_BINARY_DIR}/${proj}-install/include/eigen3)
mark_as_superbuild(VARS Eigen_DIR:PATH Eigen_INCLUDE_DIR:PATH LABELS "FIND_PACKAGE")
