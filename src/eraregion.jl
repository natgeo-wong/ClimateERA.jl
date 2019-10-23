"""
Temporary file for setting up of ClimateERA region modules before shoving
everything into the erainitialize module.

Much of the functionality here is dependent on the the ClimateTools.jl package

"""

function eraregion(init,regionID::Int64)

    if !(moduleID in 1:len); @error "$(Dates.now()) - $(regionID) is not a valid Region ID in ClimateTools.jl." end

    @info "$(Dates.now()) - Loading available regions from the ClimateTools.jl module."
    reginfo = regionload(); regioninfodisp(reginfo);
    regname = regionshortname(reginfo,regionID);
    regfull = regionfullname(reginfo,regionID)
    reggrid = regionbounds(reginfo,regionID)
    regglbe = regionisglobe(regionID)
    if regionID == 1; regglbe = true;
    else;             regglbe = false;
    end

    @info "$(Dates.now()) - Storing region information ..."
    return Dict("region"=>regname,"grid"=>reggrid,"name"=>regfull,"isglobe"=>regglbe)

end

function eraregionvec(reg,init)

    if     reg["isglobe"] == true && init["datasetID"] == 1; step = 0.5;
    elseif reg["isglobe"] == true && init["datasetID"] == 2; step = 0.75;
    else;  step = 0.25;
    end

    N,S,E,W = reg["grid"];

end
