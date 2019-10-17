"""
This file initializes the ClimateERA module by providing the basic functions
that are applicable to all the different uses.  Current functionalities include:
    - loading of parameters and their properties
    - folder creation
    - ERA-specific read/write of NetCDF files
    - root directory creation and module startup

"""

function eraparamload()
    @debug "$(Dates.now()) - Loading information on parameters used in ERA reanalysis."
    return readdlm(joinpath(@__DIR__,"eraparam.txt"),',',comments=true);
end
