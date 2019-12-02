module ClimateERA

# Main file for the ClimateERA module that downloads and processes ECMWF
# reanalysis data.

## Modules Used
using Dates, DelimitedFiles, Printf, Statistics
using NetCDF, NCDatasets, Glob, JLD2, FileIO
using ClimateEasy

## Exporting the following functions:
export
        eramodule, eraparameters, erapressure, eratime, eraregion,
        erastartup, erainitialize, eroot, erancread,
        erafolder, eratmp2raw, eradownload

## Including other files in the module

include("startup.jl")
include("initialize.jl")
include("download.jl")
#include("calculate.jl")
#include("analysis.jl")

end # module
