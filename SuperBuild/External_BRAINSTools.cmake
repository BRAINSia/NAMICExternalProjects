set(proj        BRAINSTools) #This local name

set(${proj}_DEPENDENCIES ITKv4 SlicerExecutionModel DCMTK JPEG TIFF teem OpenCV)
# Boost
if(USE_ANTS)
  list(APPEND ${proj}_DEPENDENCIES ANTs)
endif()
if(${PRIMARY_PROJECT_NAME}_REQUIRES_VTK)
  list(APPEND ${proj}_DEPENDENCIES VTK )
endif()

# Set dependency list
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

  set(BRAINS_ANTS_PARAMS
    -DUSE_ANTS:BOOL=${USE_ANTS}
    )
  if(USE_ANTS)
    list(APPEND BRAINS_ANTS_PARAMS
      -DUSE_SYSTEM_ANTS:BOOL=ON
      -DANTs_SOURCE_DIR:PATH=${ANTs_SOURCE_DIR}
      -DANTs_LIBRARY_DIR:PATH=${ANTs_LIBRARY_DIR}
      -DUSE_SYSTEM_Boost:BOOL=ON
      -DBoost_NO_BOOST_CMAKE:BOOL=ON #Set Boost_NO_BOOST_CMAKE to ON to disable the search for boost-cmake
      -DBoost_DIR:PATH=${BOOST_ROOT}
      -DBOOST_DIR:PATH=${BOOST_ROOT}
      -DBOOST_ROOT:PATH=${BOOST_ROOT}
      -DBOOST_INCLUDE_DIR:PATH=${BOOST_INCLUDE_DIR}
      )
  endif()

  if(${CMAKE_CXX_STANDARD} EQUAL 98  OR NOT TBB_ROOT)
     message(FATAL_ERROR "When running cmake the first time, you must specify:
        cmake -DCMAKE_CXX_STANDARD:STRING=11 -DTBB_ROOT:PATH=(PATH to system TBB)")
  endif()

  ### --- Project specific additions here
  # message("VTK_DIR: ${VTK_DIR}")
  # message("ITK_DIR: ${ITK_DIR}")
  # message("SlicerExecutionModel_DIR: ${SlicerExecutionModel_DIR}")
  # message("BOOST_INCLUDE_DIR:PATH=${BOOST_INCLUDE_DIR}")
  # message("${PRIMARY_PROJECT_NAME}_USE_QT=${${PRIMARY_PROJECT_NAME}_USE_QT}")
  set(${proj}_CMAKE_OPTIONS
  -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
  -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
  -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
  -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
  -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/${proj}-install
      -DBUILD_EXAMPLES:BOOL=OFF
      -DBUILD_TESTING:BOOL=ON
      -DUSE_SYSTEM_OpenCV:BOOL=ON
      -DOpenCV_DIR:PATH=${OpenCV_DIR}
      -DATLAS_NAME:STRING=${ATLAS_NAME}
      -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE}
      -DPYTHON_LIBRARY:FILEPATH=${PYTHON_LIBRARY}
      -DPYTHON_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIR}
      -DUSE_SYSTEM_SlicerExecutionModel:BOOL=ON
      -DUSE_SYSTEM_DCMTK:BOOL=ON
      -DDCMTK_DIR:PATH=${DCMTK_DIR}
      -DDCMTK_config_INCLUDE_DIR:PATH=${DCMTK_DIR}/include
      -DUSE_SYSTEM_JPEG:BOOL=ON
      -DJPEG_DIR:PATH=${JPEG_DIR}
      -DUSE_SYSTEM_TIFF:BOOL=ON
      -DTIFF_DIR:PATH=${TIFF_DIR}
      -DSlicerExecutionModel_DIR:PATH=${SlicerExecutionModel_DIR}
      -DSuperBuild_BRAINSTools_USE_GIT_PROTOCOL:BOOL=${${CMAKE_PROJECT_NAME}_USE_GIT_PROTOCOL}
      -DBRAINSTools_SUPERBUILD:BOOL=OFF
      -DUSE_SYSTEM_ITK:BOOL=ON
      -DITK_DIR:PATH=${ITK_DIR}
      -DUSE_SYSTEM_VTK:BOOL=ON
      -DVTK_DIR:PATH=${VTK_DIR}
      -DUSE_SYSTEM_Teem:BOOL=ON
      -DTeem_DIR:PATH=${Teem_DIR}
      -D${proj}_USE_QT:BOOL=${${PRIMARY_PROJECT_NAME}_USE_QT}
      -DUSE_SYSTEM_ZLIB:BOOL=ON
      -Dzlib_DIR:PATH=${zlib_DIR}
      -DZLIB_ROOT:PATH=${ZLIB_ROOT}
      -DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_DIR}
      -DZLIB_LIBRARY:FILEPATH=${ZLIB_LIBRARY}
      -DUSE_BRAINSABC:BOOL=ON
      -DUSE_BRAINSConstellationDetector:BOOL=ON
      -DUSE_BRAINSContinuousClass:BOOL=ON
      -DUSE_BRAINSCut:BOOL=ON
      -DUSE_BRAINSDemonWarp:BOOL=ON
      -DUSE_BRAINSFit:BOOL=ON
      -DUSE_BRAINSImageConvert:BOOL=ON
      -DUSE_BRAINSInitializedControlPoints:BOOL=ON
      -DUSE_BRAINSLandmarkInitializer:BOOL=ON
      -DUSE_BRAINSMultiModeSegment:BOOL=ON
      -DUSE_BRAINSMush:BOOL=ON
      -DUSE_BRAINSROIAuto:BOOL=ON
      -DUSE_BRAINSResample:BOOL=ON
      -DUSE_BRAINSSnapShotWriter:BOOL=ON
      -DUSE_BRAINSSurfaceTools:BOOL=ON  ## HACK: KENT:  This needs to be off for the builds to succeed.
      -DUSE_BRAINSTransformConvert:BOOL=ON
      -DUSE_BRAINSPosteriorToContinuousClass:BOOL=ON
      -DUSE_BRAINSCreateLabelMapFromProbabilityMaps:BOOL=ON
      -DUSE_DebugImageViewer:BOOL=OFF
      -DUSE_GTRACT:BOOL=ON
      -DUSE_ICCDEF:BOOL=OFF
      -DUSE_ConvertBetweenFileFormats:BOOL=ON
      -DUSE_ImageCalculator:BOOL=ON
      -DUSE_AutoWorkup:BOOL=OFF
      -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
      -DTBB_ROOT:PATH=${TBB_ROOT}
      ${BRAINS_ANTS_PARAMS}
    )
  # message("${proj}_CMAKE_OPTIONS=${${proj}_CMAKE_OPTIONS}")
  ### --- End Project specific additions
  set(${proj}_REPOSITORY "${git_protocol}://github.com/BRAINSia/BRAINSTools.git")
  set(${proj}_GIT_TAG "b5e27412868ec9834814318fac3b04e3de95b451") # 20160531 Improve masking and registration and fixing
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
  set(BRAINSCommonLib_DIR    ${CMAKE_BINARY_DIR}/${proj}-build/BRAINSCommonLib)

mark_as_superbuild(
  VARS ${proj}_DIR:PATH ${proj}_SOURCE_DIR:PATH BRAINSCommonLib_DIR:PATH
  LABELS "FIND_PACKAGE"
  )
