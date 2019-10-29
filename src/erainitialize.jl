"""
This file initializes the ClimateERA module by setting and determining the
ECMWF reanalysis parameters to be analyzed and the regions upon which the data
are to be extracted from.  Functionalities include:
    - Setting up of reanalysis module type
    - Setting up of reanalysis parameters to be analyzed
    - Setting up of time steps upon which data are to be downloaded
    - Setting up of region of analysis based on ClimateEasy

"""

# ClimateERA Module Setup

function eramoduledisp(init::Dict)

    if init["actionID"] == 1; len = 6; elseif init["actionID"] == 2; len = 4; end
    @info "$(Dates.now()) - There are $(len) types of modules that ClimateERA can $(init["action"])."

    @info "$(Dates.now()) - 1) Dry Surface Modules    (e.g. Surface Winds)"
    @info "$(Dates.now()) - 2) Dry Pressure Modules   (e.g. Winds at Pressure Height)"
    @info "$(Dates.now()) - 3) Moist Surface Modules  (e.g. Rainfall, Total Column Water)"
    @info "$(Dates.now()) - 4) Moist Pressure Modules (e.g. Humidity at Pressure Height)"

    if init["actionID"] == 2
        @info "$(Dates.now()) - 5) Calc Surface Modules   (e.g. PI)"
        @info "$(Dates.now()) - 6) Calc Pressure Modules  (e.g. Eddy Kinetic Energy, Psi)"
    end

    return len

end

# ClimateERA Parameter Setup

function eraparametersload(init::Dict)

    @debug "$(Dates.now()) - Loading information on parameters used in ERA reanalysis."
    allparams = readdlm(joinpath(@__DIR__,"eraparameters.txt"),',',comments=true);

    @debug "$(Dates.now()) - Filtering out for parameters in the $(init["modulename"]) module."
    parmods = allparams[:,1]; return allparams[(parmods.==init["moduletype"]),:];

end

function eraparametersdisp(parlist::AbstractArray,init::Dict)
    @info "$(Dates.now()) - The following variables are offered in the $(init["modulename"]) module:"
    for ii = 1 : size(parlist,1); @info "$(Dates.now()) - $(ii)) $(parlist[ii,6])" end
end

function erapressure(emod::Dict)
    if (emod["moduleID"] in [2,4,6]);
        @info "$(Dates.now()) - A pressure module was selected, and therefore all available pressure levels will be saved into the parameter Dictionary."
        emod["levels"] = erapressureload();
    else
        @info "$(Dates.now()) - A surface module was selected, and therefore we will save 'sfc' into the parameter level Dictionary."
        emod["levels"] = ["sfc"];
    end
end

function erapressureload()
    return [1,2,3,5,7,10,20,30,50,70,100,125,150,175,200,
            225,250,300,350,400,450,500,550,600,650,700,750,
            775,800,825,850,875,900,925,950,975,1000]
end

# ClimateERA Region Setup

function eraregionload(regionID::Int64,init::Dict)

    @info "$(Dates.now()) - Loading available regions from the ClimateEasy.jl module."
    reginfo = regionload(); eraregiondisp(regionID,reginfo,init);
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
        @error "$(Dates.now()) - $(regionID) is not a valid Region ID in ClimateEasy.jl."
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

    if     reg["isglobe"] == true && init["datasetID"] == 1; step = 1.0;
    elseif reg["isglobe"] == true && init["datasetID"] == 2; step = 0.75;
    else;  step = 0.25;
    end
    reg["step"] = step

    N,S,E,W = reg["grid"];
    lon = convert(Array,W:step:E);  nlon = size(lon,1);
    lat = convert(Array,N:-step:S); nlat = size(lat,1);
    reg["lon"] = lon; reg["lat"] = lat; reg["size"] = [nlon,nlat];

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

# Initialization

function eramodule(moduleID::Int64,init::Dict)

    init["moduleID"] = moduleID; len = eramoduledisp(init);
    if !(moduleID in 1:len); @error "$(Dates.now()) - Module ID $(moduleID) not defined for action '$(init["action"])'."  end;

    if     moduleID == 1; init["moduletype"] = "dsfc"; init["modulename"] = "dry surface";
    elseif moduleID == 2; init["moduletype"] = "dpre"; init["modulename"] = "dry pressure";
    elseif moduleID == 3; init["moduletype"] = "msfc"; init["modulename"] = "moist surface";
    elseif moduleID == 4; init["moduletype"] = "mpre"; init["modulename"] = "moist pressure";
    elseif moduleID == 5; init["moduletype"] = "csfc"; init["modulename"] = "calc surface";
    elseif moduleID == 6; init["moduletype"] = "cpre"; init["modulename"] = "calc pressure";
    end

    if init["actionID"] == 1 && init["datasetID"] == 1
        if     moduleID in [1,3]; init["moduleprint"] = "reanalysis-era5-single-levels";
        elseif moduleID in [2,4]; init["moduleprint"] = "reanalysis-era5-pressure-levels";
        end
    end

    if moduleID in [2,4,6];
        @info "$(Dates.now()) - A pressure module was selected, and therefore all available pressure levels will be saved into the parameter Dictionary."
        init["levels"] = erapressureload();
    else
        @info "$(Dates.now()) - A surface module was selected, and therefore we will save 'sfc' into the parameter level Dictionary."
        init["levels"] = ["sfc"];
    end

    return init

end

function eraparameters(parameterID::Int64,init::Dict)

    parlist = eraparametersload(init); eraparametersdisp(parlist,init)
    npar = size(parlist,1);

    if !(parameterID in 1:npar); @error "$(Dates.now()) - Invalid parameter choice for $(eramod["name"])."  end;

    parinfo = parlist[parameterID,:];
    @info "$(Dates.now()) - ClimateERA will $(init["action"]) $(parinfo[6]) data."
    return Dict("ID"  =>parinfo[2],"IDnc"=>parinfo[3],
                "era5"=>parinfo[4],"erai"=>parinfo[5],
                "name"=>parinfo[6],"unit"=>parinfo[7]);

end

function eratime(timeID::Int64,init::Dict)
    if timeID == 0; fin = Dates.year(Dates.now())-1;
        return Dict("Begin"=>1979,"End"=>fin);
        @info "$(Dates.now()) - User has chosen to $(init["action"]) $(init["dataset"]) datasets from 1979 to $(fin)."
    else
        return Dict("Begin"=>timeID,"End"=>timeID)
        @info "$(Dates.now()) - User has chosen to $(init["action"]) $(init["dataset"]) datasets in $(timeID)."
    end
end

function eratime(timeID::Array,init::Dict)
    beg = minimum(timeID); fin = maximum(timeID)
    return Dict("Begin"=>beg,"End"=>fin)
    @info "$(Dates.now()) - User has chosen to $(init["action"]) $(init["dataset"]) datasets from $(beg) to $(fin)."
end

function eraregion(regionID::Int64,init::Dict)
    reg = eraregionload(regionID,init); reg = eraregionvec(reg,init); return reg;
end

function erainitialize(moduleID::Int64,parameterID::Int64,timeID::Int64,regionID::Int64,init::Dict)
    emod = eramodule(moduleID,init);
    epar = eraparameters(parameterID,emod);
    time = eratime(timeID,init);
    ereg = eraregion(regionID,emod);
    return emod,epar,ereg,time
end
