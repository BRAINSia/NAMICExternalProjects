set(proj NIPYPE)

set(${proj}_DEPENDENCIES "")
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

# Python package: the source is fetched for "pip install" into a Python 3.12+ environment.

ExternalProject_SetIfNotDefined(
  ${CMAKE_PROJECT_NAME}_${proj}_GIT_REPOSITORY
  "${git_protocol}://github.com/nipy/nipype.git"
  QUIET
  )
ExternalProject_SetIfNotDefined(
  ${CMAKE_PROJECT_NAME}_${proj}_GIT_TAG
  1.12.0
  QUIET
  )

ExternalProject_Add(${proj}
  ${${proj}_EP_ARGS}
  GIT_REPOSITORY "${${CMAKE_PROJECT_NAME}_${proj}_GIT_REPOSITORY}"
  GIT_TAG "${${CMAKE_PROJECT_NAME}_${proj}_GIT_TAG}"
  GIT_SHALLOW ${${SUPERBUILD_TOPLEVEL_PROJECT}_EP_GIT_SHALLOW}
  UPDATE_DISCONNECTED TRUE
  SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  DEPENDS
    ${${proj}_DEPENDENCIES}
  )
set(${proj}_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj})
mark_as_superbuild(VARS ${proj}_SOURCE_DIR:PATH LABELS "FIND_PACKAGE")
