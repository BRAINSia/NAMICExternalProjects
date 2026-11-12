set(proj UnbiasedNonLocalMeans)

set(${proj}_DEPENDENCIES ITKv5 SlicerExecutionModel)
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

ExternalProject_SetIfNotDefined(
  ${CMAKE_PROJECT_NAME}_${proj}_GIT_REPOSITORY
  "${git_protocol}://github.com/BRAINSia/UnbiasedNonLocalMeans.git"
  QUIET
  )
ExternalProject_SetIfNotDefined(
  ${CMAKE_PROJECT_NAME}_${proj}_GIT_TAG
  80ae4451473bb8bec7b91682a1bbcbf92d5146ab # 2018-04-14
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
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/${proj}-install
    -DITK_DIR:PATH=${ITK_DIR}
    -DSlicerExecutionModel_DIR:PATH=${SlicerExecutionModel_DIR}
    -DTeem_DIR:PATH=${Teem_DIR}
    -DUnbiasedNonLocalMeans_SUPERBUILD:BOOL=OFF
    -DUnbiasedNonLocalMeansTractography_SuperBuild:BOOL=ON
    -DSlicer_SOURCE_DIR:BOOL=ON # selects the standalone (non-Slicer) build
    -DBUILD_TESTING:BOOL=OFF
  INSTALL_COMMAND ""
  DEPENDS
    ${${proj}_DEPENDENCIES}
  )
set(${proj}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)
mark_as_superbuild(VARS ${proj}_DIR:PATH LABELS "FIND_PACKAGE")
