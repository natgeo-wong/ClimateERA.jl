module ClimateERA

# Main file for the ClimateERA module that downloads and processes ECMWF
# reanalysis data.

## Modules Used
using Dates, Printf
using NetCDF, Glob
using ClimateEasy

## Exporting the following functions:
export
        eramodule, eraparameters, erapressure, eratime, eraregion,
        erastartup, erainitialize, eroot,
        erafolder, eratmp2raw, eradownload

## Including other files in the module

include("erastartup.jl")
include("erainitialize.jl")
#include("eradownload.jl")
#include("eracalculate.jl")
#include("eraanalysis.jl")
#include("eragnss.jl")

end # module
