set(proj LogSymmetricDemons)

set(${proj}_DEPENDENCIES ITKv5)
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

ExternalProject_SetIfNotDefined(
  ${CMAKE_PROJECT_NAME}_${proj}_GIT_REPOSITORY
  "${git_protocol}://github.com/BRAINSia/LogSymmetricDemons.git"
  QUIET
  )
ExternalProject_SetIfNotDefined(
  ${CMAKE_PROJECT_NAME}_${proj}_GIT_TAG
  8a79adf90d0a4d6f07175fd11242604af833900e
  QUIET
  )

ExternalProject_Add(${proj}
  ${${proj}_EP_ARGS}
  GIT_REPOSITORY "${${CMAKE_PROJECT_NAME}_${proj}_GIT_REPOSITORY}"
  GIT_TAG "${${CMAKE_PROJECT_NAME}_${proj}_GIT_TAG}"
  GIT_SHALLOW ${${SUPERBUILD_TOPLEVEL_PROJECT}_EP_GIT_SHALLOW}
  UPDATE_DISCONNECTED TRUE
  PATCH_COMMAND ${CMAKE_COMMAND} -DGIT_EXECUTABLE=${GIT_EXECUTABLE} -DPATCH_FILE=${CMAKE_CURRENT_LIST_DIR}/patches/LogSymmetricDemons-itk54.patch -P ${CMAKE_CURRENT_LIST_DIR}/../CMake/ExternalProjectApplyPatch.cmake
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
    -DUSE_SYSTEM_ITK:BOOL=ON
    -DITK_DIR:PATH=${ITK_DIR}
    -DBUILD_TESTING:BOOL=OFF
  INSTALL_COMMAND ""
  DEPENDS
    ${${proj}_DEPENDENCIES}
  )
set(${proj}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)
mark_as_superbuild(VARS ${proj}_DIR:PATH LABELS "FIND_PACKAGE")
