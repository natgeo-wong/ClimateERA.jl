module ClimateERA

# Main file for the ClimateERA module that downloads and processes ECMWF
# reanalysis data.

## Modules Used
using Logging, Dates
using DelimitedFiles, Printf, Statistics
using NCDatasets, Glob, JLD2, FileIO
using Crayons
using GeoRegions

## Exporting the following functions:
export
        eramodule, eraparameters, erapressure, eratime, eraregion,
        erastartup, erainitialize, eraroot, erawelcome, eradownload, eraanalysis,
        eratmp2raw, erasubregion,
        erarawregion, erarawpoint, erarawgrid,
        eraparameterscopy, eraparametersload, eraparametersadd,
        erarawname, eraananame, erancread, erarawread, eraanaread, erarawsave,
        eraregfolder, eravarfolder, erarawfolder, eraanafolder, eraimgfolder, erafolder,
        queryeaction, queryedataset, queryemod, queryepar,
        hrstep, hrindy

## Including other files in the module

include("startup.jl")
include("frontend.jl")
include("backend.jl")
include("query.jl")

include("initialize.jl")
include("download.jl")
include("analysis.jl")
#include("calculate.jl")

end # module
