module ClimateERA

# Main file for the ClimateERA module that downloads and processes ECMWF
# reanalysis data.

## Modules Used
using Dates, Printf
using NetCDF
using ClimateTools

## Exporting the following functions:
export
        eramodule, eraparameters, eratime, eraregion,
        erastartup, erainitialize, eroot

## Including other files in the module

include("erastartup.jl")
include("erainitialize.jl")
#include("eradwn.jl")
#include("eracalc.jl")
#include("eraana.jl")
#include("eragnss.jl")

end # module
