"""
Temporary file for setting up of ClimateERA region modules before shoving
everything into the erainitialize module.

Much of the functionality here is dependent on the the ClimateTools.jl package

"""

function eraregionload(regionID::Int64,init::Dict)

    @info "$(Dates.now()) - Loading available regions from the ClimateTools.jl module."
    reginfo = regionload(); reginfo = eraregiondisp(reginfo,init);
    regname = regionshortname(regionID,reginfo);
    regfull = regionfullname(regionID,reginfo)
    reggrid = regionbounds(regionID,reginfo)
    regglbe = regionisglobe(regionID)
    if regionID == 1; regglbe = true;
    else;             regglbe = false;
    end

    @info "$(Dates.now()) - Storing region information ..."
    return Dict("region"=>regname,"grid"=>reggrid,"name"=>regfull,"isglobe"=>regglbe)

end

function eraregiondisp(regionID::Int64,reginfo::AbstractArray,init::Dict)

    if regionID > size(reginfo,1);
        @error "$(Dates.now()) - $(regionID) is not a valid Region ID in ClimateTools.jl."
    end

    if init["actionID"] == 1
        @info "$(Dates.now()) - Only certain regions are available for $(init["action"]) in ClimateERA.jl.  All other regions must be extracted as a subset of these regions."
        regdwn = reginfo[:,2]; isglobe = (regdwn .== "GLB"); reginfo = reginfo[isglobe,:];
          regioninfodisplay(reginfo);
    else; regioninfodisplay(reginfo);
    end

    if regionID < size(reginfo,1)
        @info "$(Dates.now()) - ClimateERA.jl will $(init["action"]) data from the $(reginfo[regionID,7]) region."
    else
        @error "$(Dates.now()) - ClimateERA.jl only has the option to analyse data from the $(reginfo[regionID,7]) and not download it."
    end

end

function eraregionvec(reg::Dict,init::Dict)

    if     reg["isglobe"] == true && init["datasetID"] == 1; step = 0.5;
    elseif reg["isglobe"] == true && init["datasetID"] == 2; step = 0.75;
    else;  step = 0.25;
    end
    reg["step"=>step]

    N,S,E,W = reg["grid"];
    lon = convert(Array,W:step:E);  nlon = size(lon,1);
    lat = convert(Array,N:-step:S); nlat = size(lat,1);
    reg["lon"=>lon,"lat"=>lat,"size"=>[nlon,nlat]]

    return reg

end

function eraregionparent(regionID::Int64,init::Dict)
    parentID = regionparent(regionID); return eraregion(parentID,init);
end

function eraregionparent(regionID::Int64,reginfo::AbstractArray,init::Dict)
    parentID = regionparent(regionID,reginfo); return eraregion(parentID,init);
end

function eraregionextract(data::AbstractArray,regionID::Int64,init::Dict)
    preg = eraregionparent(regionID,init); return regionextractgrid(data,reg,plon,plat)
end

function eraregionextract(data::AbstractArray,preg::Dict,init::Dict)
    return regionextractgrid(data,reg,preg["lon"],preg["lat"])
end

function eraregion(regionID::Int64,init::Dict)
    reg = eraregionload(regionID,init); reg = eraregionvec(reg,init); return reg;
end
