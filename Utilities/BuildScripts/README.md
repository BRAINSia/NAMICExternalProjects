INSTALL NOTES FOR NAMICExternalProjects
=======================================

These instructions are designed to assist with
building NAMICExternalProjects (NEP) on clusters
or local machines for the purpose of data analysis
using BRAINSAutoWorkup.

This can be a complicated process (especially on clusters)
where there may be many different compilers, versions of
python, versions of QT/Matlab/etc, all of which may make
it difficult to build the tools.

General Approach
----------------
Use our own custom version of python from the Anaconda distribution
to facilitate addition of tools and manage pathing.

Use anaconda version of SimpleITK

* NEON Difficulties installing SimpleITK:

** http://www.itk.org/Wiki/SimpleITK/GettingStarted
** Can not use default anaconda build of SimpleITK due to RHEL6 missing libpng15.so
** conda install -c https://conda.binstar.org/simpleitk/channel/dev SimpleITK
ImportError: libpng15.so.15: cannot open shared object file: No such file or directory
