module ClimateERA

# Main file for the ClimateERA module that downloads and processes ECMWF
# reanalysis data.

## Modules Used
using Crayons
using Dates
using DelimitedFiles
using GeoRegions
using Glob
using JLD2
using Logging
using NCDatasets
using Printf
using Statistics

## Exporting the following functions:
export
        erastartup, erainitialize, eradownload, eraanalysis, eracompile, eralvlsplit,
        erasubregion, erancread,
        erarawname, erarawread, erarawfolder, erarawsave,
        eraananame, eraanaread, eraanafolder,
        eracmpname, eracmpread,
        erafolder, eraregfolder, eravarfolder, eraimgfolder,
        erarawregion, erarawpoint, erarawgrid,
        eraparameterload, eraparametercopy, eraparameteradd, erapressureload,
        eraregionstep,
        eplotsubregion, eplotlsm, eplotlsmgrid,
        queryeaction, queryedataset, queryemod, queryepar, putinfo,
        hrstep, hrindy

## Including other files in the module

include("startup.jl")
include("initialize.jl")
include("download.jl")
include("analysis.jl")
include("compile.jl")
#include("calculate.jl")
include("eraplots.jl")

include("frontend.jl")
include("backend.jl")
include("query.jl")

end # module
