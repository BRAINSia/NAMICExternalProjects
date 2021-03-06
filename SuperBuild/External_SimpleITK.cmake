
set(proj SimpleITK)

# Set dependency list
set(${proj}_DEPENDENCIES ITKv5 Swig python VTK)

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})
  message(FATAL_ERROR "Enabling ${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj} is not supported !")
endif()

# Sanity checks
if(DEFINED SimpleITK_DIR AND NOT EXISTS ${SimpleITK_DIR})
  message(FATAL_ERROR "SimpleITK_DIR variable is defined but corresponds to nonexistent directory")
endif()

if(NOT ${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})

  configure_file(SuperBuild/SimpleITK_install_step.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/SimpleITK_install_step.cmake
    @ONLY)
set(${proj}_CMAKE_OPTIONS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    # SimpleITK does not work with shared libs turned on
    -DBUILD_SHARED_LIBS:BOOL=OFF
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}
    -DITK_DIR:PATH=${ITK_DIR}
    -DBUILD_TESTING:BOOL=OFF
    -DBUILD_DOXYGEN:BOOL=OFF
    -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE}
    -DSITK_INT64_PIXELIDS:BOOL=OFF
    -DWRAP_PYTHON:BOOL=ON
    -DWRAP_TCL:BOOL=OFF
    -DWRAP_JAVA:BOOL=OFF
    -DWRAP_RUBY:BOOL=OFF
    -DWRAP_LUA:BOOL=OFF
    -DWRAP_CSHARP:BOOL=OFF
    -DWRAP_R:BOOL=OFF
    -DPYTHON_EXECUTABLE:PATH=${PYTHON_EXECUTABLE}
    -DPYTHON_LIBRARY:STRING=${PYTHON_LIBRARY}
    -DPYTHON_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIR}
    -DPYTHON_INCLUDE_DIRS:PATH=${PYTHON_INCLUDE_DIR}
    -DPYTHON_DEBUG_LIBRARIES:STRING=${PYTHON_DEBUG_LIBRARIES}
    -DSWIG_EXECUTABLE:PATH=${SWIG_EXECUTABLE}
    #
  )
  set(SimpleITK_INSTALL_COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/SimpleITK_install_step.cmake)

  set(SimpleITK_REPOSITORY ${git_protocol}://itk.org/SimpleITK.git)
  set(SimpleITK_GIT_TAG 463172a4d69be57a21cdedbde32312e52060467d) #20151030

  ExternalProject_add(SimpleITK
    ${${proj}_EP_ARGS}
    SOURCE_DIR SimpleITK/SuperBuild
    BINARY_DIR SimpleITK-build
    GIT_REPOSITORY ${SimpleITK_REPOSITORY}
    GIT_TAG ${SimpleITK_GIT_TAG}
    CMAKE_ARGS -Wno-dev --no-warn-unused-cli
    CMAKE_CACHE_ARGS
    ${${proj}_CMAKE_OPTIONS}
    INSTALL_COMMAND ${SimpleITK_INSTALL_COMMAND}
    #
    DEPENDS ${${proj}_DEPENDENCIES}
    )
  set(SimpleITK_DIR ${CMAKE_BINARY_DIR}/SimpleITK-build)

  set(_lib_subdir lib)
  if(WIN32)
    set(_lib_subdir bin)
  endif()

  #-----------------------------------------------------------------------------
  # Launcher setting specific to build tree

  set(${proj}_LIBRARY_PATHS_LAUNCHER_BUILD ${SimpleITK_DIR}/${_lib_subdir}/<CMAKE_CFG_INTDIR>)
  mark_as_superbuild(
    VARS ${proj}_LIBRARY_PATHS_LAUNCHER_BUILD
    LABELS "LIBRARY_PATHS_LAUNCHER_BUILD"
    )

else()
  ExternalProject_Add_Empty(${proj} DEPENDS ${${proj}_DEPENDENCIES})
endif()

mark_as_superbuild(
  VARS SimpleITK_DIR:PATH
  LABELS "FIND_PACKAGE"
  )
