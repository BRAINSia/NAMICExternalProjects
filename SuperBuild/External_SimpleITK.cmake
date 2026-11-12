set(proj SimpleITK)

set(${proj}_DEPENDENCIES ITKv5)
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

ExternalProject_SetIfNotDefined(
  ${CMAKE_PROJECT_NAME}_${proj}_GIT_REPOSITORY
  "${git_protocol}://github.com/SimpleITK/SimpleITK.git"
  QUIET
  )
ExternalProject_SetIfNotDefined(
  ${CMAKE_PROJECT_NAME}_${proj}_GIT_TAG
  v2.5.7
  QUIET
  )

# SimpleITK's own superbuild supplies SWIG; ITK comes from the ITKv5 project.
ExternalProject_Add(${proj}
  ${${proj}_EP_ARGS}
  GIT_REPOSITORY "${${CMAKE_PROJECT_NAME}_${proj}_GIT_REPOSITORY}"
  GIT_TAG "${${CMAKE_PROJECT_NAME}_${proj}_GIT_TAG}"
  GIT_SHALLOW ${${SUPERBUILD_TOPLEVEL_PROJECT}_EP_GIT_SHALLOW}
  UPDATE_DISCONNECTED TRUE
  SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}
  SOURCE_SUBDIR SuperBuild
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
    -DSimpleITK_USE_SYSTEM_ITK:BOOL=ON
    -DITK_DIR:PATH=${ITK_DIR}
    -DWRAP_DEFAULT:BOOL=OFF
    -DWRAP_PYTHON:BOOL=ON
    -DPython_EXECUTABLE:FILEPATH=${Python3_EXECUTABLE}
    -DSimpleITK_PYTHON_USE_VIRTUALENV:BOOL=OFF
    -DBUILD_EXAMPLES:BOOL=OFF
    -DBUILD_TESTING:BOOL=OFF
  INSTALL_COMMAND ""
  DEPENDS
    ${${proj}_DEPENDENCIES}
  )

set(${proj}_DIR ${CMAKE_BINARY_DIR}/${proj}-build/SimpleITK-build)
mark_as_superbuild(VARS ${proj}_DIR:PATH LABELS "FIND_PACKAGE")
