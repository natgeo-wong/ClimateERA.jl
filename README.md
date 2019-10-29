# ClimateERA
ClimateERA is a package specifically designed to download and analyse ERA reanalysis data.  This
package is meant to automate the process of downloading, resort and display specific ERA5 and
ERA-Interim datasets, and can be customized to include other reanalysis datasets that were not
utilized by the creator.

ClimateERA supports the following ECMWF reanalysis datasets:
* ERA5 (1979 - present)
* ERA-Interim (1979 - 2018) (NB: 2019 is not supported because the full year data is not available.)

The following functionalities are currently available in ClimateERA:
* Creation of python download scripts for ERA5 and ERA-Interim

The following functionalities are in development in ClimateERA:
* Analysis of downloaded data
* Calculations of various climatological parameters:
    - Water Vapour Weighted Column Temperature
    - Eddy Intensity
    - Streamfunction (Zonal/Meridional/Horizontal)
    - Fluxes (Momentum/Heat/Moisture)
    - Tropopause Height/Gradients

ClimateERA requires the following Julia dependencies:
* Dates, DelimitedFiles, Printf
* NetCDF, Glob, JLD2, FileIO
* ClimateEasy

Author(s):
* Nathanael Zhixin Wong: nathanaelwong@fas.harvard.edu
