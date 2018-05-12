set(proj        dcm2niix) #This local name

set(${proj}_DEPENDENCIES )

# Set dependency list
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

  ### --- Project specific additions here
  set(${proj}_CMAKE_OPTIONS
  -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
  -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
  -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
  -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
  -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}
      -DBUILD_EXAMPLES:BOOL=OFF
      -DBUILD_TESTING:BOOL=ON
      -DBATCH_VERSION:BOOL=ON
      -DUSE_OPENJPEG:BOOL=ON
      #-DUSE_SYSTEM_JPEG:BOOL=ON
      -DJPEG_DIR:PATH=${JPEG_DIR}
      #-DUSE_SYSTEM_TIFF:BOOL=ON
      #-DTIFF_DIR:PATH=${TIFF_DIR}
      -DUSE_SYSTEM_ZLIB:BOOL=ON
      -Dzlib_DIR:PATH=${zlib_DIR}
      -DZLIB_ROOT:PATH=${ZLIB_ROOT}
      -DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_DIR}
      -DZLIB_LIBRARY:FILEPATH=${ZLIB_LIBRARY}
    )
  # message("${proj}_CMAKE_OPTIONS=${${proj}_CMAKE_OPTIONS}")
  ### --- End Project specific additions
  set(${proj}_REPOSITORY "${git_protocol}://github.com/rordenlab/dcm2niix.git")
  set(${proj}_GIT_TAG "eb899dbb26bb85b1166af5f118eef7975ef5cbff")
  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY ${${proj}_REPOSITORY}
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
      ${${proj}_CMAKE_OPTIONS}
#    INSTALL_COMMAND ""
    DEPENDS
      ${${proj}_DEPENDENCIES}
    )
  set(${proj}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)
  set(${proj}_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj})

mark_as_superbuild(
  VARS ${proj}_DIR:PATH ${proj}_SOURCE_DIR:PATH
  LABELS "FIND_PACKAGE"
  )
