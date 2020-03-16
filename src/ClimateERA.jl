module ClimateERA

# Main file for the ClimateERA module that downloads and processes ECMWF
# reanalysis data.

## Modules Used
using Logging, Dates
using DelimitedFiles, Printf, Statistics
using NCDatasets, Glob, JLD2, FileIO
using Crayons, PrettyTables
using GeoRegions

## Exporting the following functions:
export
        eramodule, eraparameters, erapressure, eratime, eraregion,
        erastartup, erainitialize, eraroot, erancread, erawelcome,
        erafolder, eratmp2raw, eradownload, eraanalysis,
        erarawregion, erarawpoint, erarawgrid,
        queryeaction, queryedataset, queryemod, queryepar

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
