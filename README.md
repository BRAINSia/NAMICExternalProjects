NAMICExternalProjects
=====================
A superbuild infrastructure to build all superbuild structures

<align=middle>_Ash nazg durbatulûk, ash nazg gimbatul,
    Ash nazg thrakatulûk agh burzum-ishi krimpatul._
</align>

This project acts as a template to model building all other SuperBuild projects around.
* * *
### Directory layout
__NAMICExternalProjects/__

* __CMakeLists.txt__

    A file that acts as a top level switch, it runs the building of pre-requisite ExternalProjects defined in SuperBuild.cmake (where ${MyProject} is last ExternalProject to be built).  **_This file is processed by CMake 2 times_**: the first time processes SuperBuild.cmake and the second time processes ${MyProject}.cmake

* __Common.cmake__

    Included in SuperBuild.cmake and ${MYProject}.cmake for common conditional compilation options to be set.  These options must be passed to all ExternalProjects (including ${MYProject})

* __SuperBuild.cmake__

    Infrastructure to build all the pre-requisite packages where ${MYProject} is the last one listed

* __${MYProject}.cmake__

    Standard cmake build instructions for ${MYProject}

* __SuperBuild/__

    A directory full of External_${extProjName}.cmake files defining how to build external dependencies.

* __CMake/__

    A directory of support files.

