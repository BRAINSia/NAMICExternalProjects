set(proj calatk)

set(${proj}_DEPENDENCIES ITKv5 SlicerExecutionModel)
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

ExternalProject_SetIfNotDefined(
  ${CMAKE_PROJECT_NAME}_${proj}_GIT_REPOSITORY
  "${git_protocol}://github.com/BRAINSia/calatk.git"
  QUIET
  )
ExternalProject_SetIfNotDefined(
  ${CMAKE_PROJECT_NAME}_${proj}_GIT_TAG
  784f6ee7e04a0a32344cf2ddce43faf8023cf88f
  QUIET
  )

# FFTW is found by calatk itself (find_library fftw3 and fftw3f).
ExternalProject_Add(${proj}
  ${${proj}_EP_ARGS}
  GIT_REPOSITORY "${${CMAKE_PROJECT_NAME}_${proj}_GIT_REPOSITORY}"
  GIT_TAG "${${CMAKE_PROJECT_NAME}_${proj}_GIT_TAG}"
  UPDATE_DISCONNECTED TRUE
  PATCH_COMMAND ${GIT_EXECUTABLE} apply --whitespace=nowarn ${CMAKE_CURRENT_LIST_DIR}/patches/calatk-itk54.patch
  SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}
  BINARY_DIR ${proj}-build
  CMAKE_ARGS -Wno-dev --no-warn-unused-cli
  CMAKE_CACHE_ARGS
    ${EXTERNAL_PROJECT_DEFAULTS}
    -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/${proj}-install
    -DCALATK_USE_SUPERBUILD:BOOL=OFF
    -DUSE_SYSTEM_ITK:BOOL=ON
    -DITK_DIR:PATH=${ITK_DIR}
    -DUSE_SYSTEM_SlicerExecutionModel:BOOL=ON
    -DSlicerExecutionModel_DIR:PATH=${SlicerExecutionModel_DIR}
  INSTALL_COMMAND ""
  DEPENDS
    ${${proj}_DEPENDENCIES}
  )

set(${proj}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)
mark_as_superbuild(VARS ${proj}_DIR:PATH LABELS "FIND_PACKAGE")
