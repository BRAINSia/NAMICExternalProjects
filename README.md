NAMICExternalProjects
=====================
A superbuild infrastructure to build all superbuild structures

    Ash nazg durbatulûk, 
    ash nazg gimbatul,
    Ash nazg thrakatulûk 
    agh burzum-ishi krimpatul.
                    - Sauron, the Abhorred

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
    
### Requirements

* CMake 3.28 through 4.2
* A C++17 compiler (GCC 13 and Clang are tested)
* Python 3.12 or newer, found at configure time
* Ninja (recommended); ccache is used automatically when found
* FFTW 3 development files for calatk (`libfftw3-dev` on Ubuntu)

### Building

```bash
git clone https://github.com/BRAINSia/NAMICExternalProjects.git
cmake -S NAMICExternalProjects -B NEP-build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build NEP-build
```

Each tool installs or builds into its own directory under `NEP-build`;
most command line tools are also placed in `NEP-build/bin`.

### Options

* `NAMICExternalProjects_REQUIRES_VTK` (ON): build VTK and the tools
  that need it (DTIProcess, niral_utilities, UKF).
* `NAMICExternalProjects_REQUIRES_TBB` (ON): build oneTBB and use it in
  ITK and VTK; BRAINSABC is built only when this is ON.
* `NAMICExternalProjects_BUILD_SimpleITK` (OFF): build SimpleITK with
  Python wrapping against the superbuild ITK.  `pip install SimpleITK`
  is the quicker route when the superbuild ITK is not needed.
* `BUILD_STYLE_UTILS` (OFF): build KWStyle, Cppcheck, and Uncrustify.
* `BUILD_CALATK` (ON): build calatk.
* `NAMICExternalProjects_EP_GIT_SHALLOW` (OFF): shallow clones.

### What is built

The toolkits are ITK 5.4.8, VTK 9, oneTBB, zlib-ng, DCMTK, teem,
Eigen, and SlicerExecutionModel.  The tools are BRAINSTools, ANTs,
DTIProcess, niral_utilities, UKFTractography, dcm2niix,
MRParameterMaps, LogSymmetricDemons, MultiAtlas (MABMIS), calatk,
JointRicianAnisotropicLMMSEFilter, UnbiasedNonLocalMeans, and
DoubleConvert.  The nipype and tract_querier Python sources are
fetched for installation with pip.

Tools whose upstream has not been updated for ITK 5 carry a patch in
`SuperBuild/patches/`, applied in the external project's patch step.

### Diffusion MRI quality control

DTIPrep is no longer built.  Its quality control is superseded by
`dmriprep` in [DTIPlayground](https://github.com/NIRALUser/DTIPlayground),
which installs with `pip install dtiplayground` and calls the
DTIProcess and niral_utilities tools built here.
