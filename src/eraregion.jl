"""
Temporary file for setting up of ClimateERA region modules before shoving
everything into the erainitialize module.

Much of the functionality here is dependent on the the ClimateTools.jl package

"""

function eraregion(init,regionID)
    @info "Loading available regions from the ClimateTools.jl module"
    reginfo = regionload(); regioninfodisp(reginfo);
    regname = regionname(reginfo,regionID)
end
