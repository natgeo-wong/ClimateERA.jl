module ClimateERA

# Main file for the ClimateERA module that downloads and processes ECMWF
# reanalysis data.

## Modules Used
using Dates, DelimitedFiles, Printf, Statistics
using NCDatasets, Glob, JLD2, FileIO
using GeoRegions

## Exporting the following functions:
export
        eramodule, eraparameters, erapressure, eratime, eraregion,
        erastartup, erainitialize, eroot, erancread,
        erafolder, eratmp2raw, eradownload, eraanalysis

## Including other files in the module

include("frontend.jl")
include("backend.jl")
include("initialize.jl")
include("download.jl")
include("analysis.jl")
#include("calculate.jl")

end # module
