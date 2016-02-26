project(TestProgram)
#-----------------------------------------------------------------------------
# Output directories.
#

set(ALL_PROGS_LIST
  TestProgram
  )

add_executable(TestProgram TestProgram.cxx)

## Only test for compatible compilers
if (CMAKE_C_COMPILER_ID MATCHES GNU  OR
    CMAKE_C_COMPILER_ID MATCHES AppleClang  OR
    CMAKE_C_COMPILER_ID MATCHES Clang)

if( NOT ( CMAKE_CXX_STANDARD EQUAL 98 ) )
  get_property(known_features GLOBAL PROPERTY CMAKE_CXX_KNOWN_FEATURES)
  set(BABC_CXX11_Required_Features
    cxx_lambdas
    cxx_strong_enums
    cxx_constexpr
    cxx_auto_type)
  target_compile_features(TestProgram PRIVATE ${BABC_CXX11_Required_Features})
  foreach(reqFeat ${BABC_CXX11_Required_Features})
    list(FIND known_features ${reqFeat} HAS_FEAT)
    if(HAS_FEAT EQUAL -1)
      foreach(i ${known_features})
        message("Your CMake version supports these C++ features:")
        message(STATUS "Found CXX11 feature: ${i}")
      endforeach()
      message("Your CMake version does not support these C++ features:")
      message(FATAL_ERROR "MISSING REQUIRED COMPILER FEATURE: ${reqFeat}")
    endif()
  endforeach()
endif()
endif()

#if(BUILD_TESTING AND NOT Slicer_BUILD_${PROJECT_NAME})
#    add_subdirectory(TestSuite)
##endif()
