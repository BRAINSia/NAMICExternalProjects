# Make sure this file is included only once by creating globally unique varibles
# based on the name of this included file.
# get_filename_component(CMAKE_CURRENT_LIST_FILENAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
# if(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED)
#   return()
# endif()
# set(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED 1)

superbuild_stack_push(CACHED_extProjName ${extProjName})
superbuild_stack_push(CACHED_proj ${proj})

set(extProjName UnbiasedNonLocalMeans)
set(proj UnbiasedNonLocalMeans)

set(${proj}_DEPENDENCIES ITKv4 SlicerExecutionModel )
# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj}  PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

set(${proj}_GIT_REPOSITORY "git://github.com/BRAINSia/UnbiasedNonLocalMeans.git")
set(${proj}_GIT_TAG "master")

ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
  GIT_REPOSITORY ${${proj}_GIT_REPOSITORY}
  GIT_TAG ${${proj}_GIT_TAG}
  SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}
  BINARY_DIR ${proj}-build
  LOG_CONFIGURE 0  # Wrap configure in script to ignore log output from dashboards
  LOG_BUILD     0  # Wrap build in script to to ignore log output from dashboards
  LOG_TEST      0  # Wrap test in script to to ignore log output from dashboards
  LOG_INSTALL   0  # Wrap install in script to to ignore log output from dashboards
  ${cmakeversion_external_update} "${cmakeversion_external_update_value}"
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS -Wno-dev --no-warn-unused-cli
  CMAKE_CACHE_ARGS
  -DUSE_SYSTEM_ITK:BOOL=ON
  -DUSE_SYSTEM_SLICER_EXECUTION_MODEL:BOOL=ON
  -DITK_DIR:PATH=${ITK_DIR}
  -DBUILD_EXAMPLES:BOOL=OFF
  -DBUILD_TESTING:BOOL=OFF
  -DUnbiasedNonLocalMeans_SUPERBUILD:BOOL=OFF
  -DTeem_DIR:PATH=${Teem_DIR}
  -DSlicerExecutionModel_DIR:PATH=${SlicerExecutionModel_DIR}
  -DSlicer_SOURCE_DIR:BOOL=ON ## THIS is a hack to prevent looking for slicer
  -DUnbiasedNonLocalMeansTractography_SuperBuild:BOOL=ON ## THIS should be the single flag
  ${${proj}_CMAKE_OPTIONS}
  INSTALL_COMMAND ""
  DEPENDS ${${proj}_DEPENDENCIES}
  )
#ExternalProject_Add_Step(${proj} forcebuild
#    COMMAND ${CMAKE_COMMAND} -E remove
#    ${CMAKE_CURRENT_BUILD_DIR}/${proj}-prefix/src/${proj}-stamp/${proj}-build
#    DEPENDEES configure
#    DEPENDERS build
#    ALWAYS 1
#  )
superbuild_stack_pop(CACHED_extProjName extProjName)
superbuild_stack_pop(CACHED_proj proj)
