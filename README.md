# **<div align="center">ClimateERA.jl</div>**

**Created By:** Nathanael Wong (nathanaelwong@fas.harvard.edu)

**Developer To-Do for v1.0:**
* [x] Testing of `analysis` functions
* [ ] Comprehensive documentation and Jupyter notebook examples
* [ ] `eraquery` function series development

## Introduction

`ClimateERA.jl` is a Julia package that aims to streamline the following processes:
* downloading of ECMWF reanalysis data (ERA-Interim and ERA5)
* basic analysis (mean, maximum, minimum, standard deviation, etc.) of downloaded data
* extraction of data for a given **GeoRegion** (see `GeoRegions.jl` for more information)

`ClimateERA.jl` can be installed via
```
] add ClimateERA
```

## Requirements
There are some non-Julia functionalities required in order to download reanalysis data using `ClimateERA.jl`:
* A working Python installation
* For ERA-Interim, please follow the instructions here to install the ECMWF API
* For ERA5, please follow the instructions here to install the CDS API

## ECMWF Reanalysis
Both ERA-Interim and ERA5 are produced by the European Centre for Medium-Range Weather Forecasts.  For more information regarding the ERA-Interim and ERA5 reanalysis models, please refer to the following:
* ERA-Interim [[Documentation](https://www.ecmwf.int/en/elibrary/8174-era-interim-archive-version-20)] [[Paper](https://rmets.onlinelibrary.wiley.com/doi/full/10.1002/qj.828)]
* ERA5 [[Documentation](https://confluence.ecmwf.int/display/CKB/ERA5%3A+data+documentation)]

## Workflow

### Startup and Initialization

## Setup
### Directories
By default, `ClimateERA.jl` saves all data into a `datadir` repository that is user-specified, or else it will otherwise default to
```
datadir="~/research/ecmwf/"
```

### Regions
`ClimateERA.jl` utlizes `GeoRegions.jl` to specify domains from which data is to be extracted.  If the option is not specified, then `ClimateERA.jl` will assume that the user wishes to process **global** data (which may not be wise especially for GPM due to the large file sizes involved and memory required).

For more information, please see the repository for `GeoRegions.jl` [here](https://github.com/natgeo-wong/GeoRegions.jl).

### Downloads
`ClimateERA.jl` does not directly download reanalysis data from ECMWF/CDS.  Instead, it generates a `Python` script according to the user's choice of parameters that the user will run with Python to download the data required.
