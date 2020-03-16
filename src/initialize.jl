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

    if init["actionID"] == 1; len = 4; elseif init["actionID"] == 2; len = 6; end
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

function eraparameterscopy()
    ftem = joinpath(@__DIR__,"../data/epartemplate.txt")
    freg = joinpath(@__DIR__,"../data/eraparameters.txt")
    if !isfile(freg)
        @debug "$(Dates.now()) - Unable to find eraparameters.txt, copying data from epartemplate.txt ..."
        cp(ftem,freg,force=true);
    end
end

function eraparametersload(init::Dict)

    @debug "$(Dates.now()) - Loading information on parameters used in ERA reanalysis."
    allparams = readdlm(joinpath(@__DIR__,"../data/eraparameters.txt"),',',comments=true);

    @debug "$(Dates.now()) - Filtering out for parameters in the $(init["modulename"]) module."
    parmods = allparams[:,1]; return allparams[(parmods.==init["moduletype"]),:];

end

function eraparametersdisp(parlist::AbstractArray,init::Dict)
    @info "$(Dates.now()) - The following variables are offered in the $(init["modulename"]) module:"
    for ii = 1 : size(parlist,1); @info "$(Dates.now()) - $(ii)) $(parlist[ii,6])" end
end

function erapressure(emod::Dict)
    if occursin("pre",emod["moduleID"])
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

function eraregionload(gregID::AbstractString,init::Dict)

    @info "$(Dates.now()) - Loading available GeoRegions from the GeoRegions.jl module."
    greginfo = gregioninfoload(); eraregiondisp(gregID,greginfo,init);
    gregfull = gregionfullname(gregID,greginfo)
    greggrid = gregionbounds(gregID,greginfo)
    if gregID == "GLB"; regglbe = true; else; regglbe = false; end

    @info "$(Dates.now()) - Storing region properties and information for the $(gregfull) region ..."
    return Dict("region"=>gregID,"grid"=>greggrid,"name"=>gregfull,"isglobe"=>regglbe)

end

function eraregiondisp(gregID::AbstractString,greginfo::AbstractArray,init::Dict)

    if sum(greginfo[:,2] .== gregID) == 0
        @error "$(Dates.now()) - $(regionID) is not a valid Region ID in GeoRegions.jl."
    end

    if init["actionID"] == 1
        @info "$(Dates.now()) - Only certain regions are available for $(init["action"]) in ClimateERA.jl.  All other regions must be extracted as a subset of these regions."
        gregdwn = greginfo[:,2]; isglobe = (gregdwn .== "GLB");
        greginfo = greginfo[isglobe,:];
          gregioninfodisplay(greginfo);
    else; gregioninfodisplay(greginfo);
    end

    if sum(greginfo[:,2] .== gregID) > 0
        @info "$(Dates.now()) - ClimateERA.jl will $(init["action"]) data from the $(gregionfullname(gregID,greginfo)) region."
    else
        @error "$(Dates.now()) - ClimateERA.jl only has the option to analyse data from the $(gregionfullname(gregID,greginfo)) and not download it."
    end

end

function eraregionvec(ereg::Dict,init::Dict)

    @info "$(Dates.now()) - Determining spacing between grid points in the region ..."
    if     ereg["isglobe"] == true && init["datasetID"] == 1; step = 1.0;
    elseif ereg["isglobe"] == true && init["datasetID"] == 2; step = 0.75;
    else;  step = 0.25;
    end
    ereg["step"] = step

    N,S,E,W = ereg["grid"];
    @info "$(Dates.now()) - Creating longitude and latitude vectors for the region ..."
    lon = convert(Array,W:step:E);  nlon = size(lon,1);
    lat = convert(Array,N:-step:S); nlat = size(lat,1);
    ereg["lon"] = lon; ereg["lat"] = lat; ereg["size"] = [nlon,nlat];

    return ereg

end

function eraregionparent(gregID::AbstractString,init::Dict)
    @info "$(Dates.now()) - Extracting parent region properties/information ..."
    parentID = gregionparent(gregID); return eraregion(gregID,init);
end

function eraregionparent(gregID::AbstractString,reginfo::AbstractArray,init::Dict)
    @info "$(Dates.now()) - Extracting parent region properties/information ..."
    parentID = gregionparent(gregID,reginfo); return eraregion(parentID,init);
end

function eraregionextract(data::AbstractArray,gregID::AbstractString,init::Dict)
    @info "$(Dates.now()) - Extracting regional data from parent region ..."
    preg = eraregionparent(gregID,init); return regionextractgrid(data,reg,plon,plat)
end

function eraregionextract(data::AbstractArray,preg::Dict,init::Dict)
    @info "$(Dates.now()) - Extracting regional data from parent region ..."
    return regionextractgrid(data,reg,preg["lon"],preg["lat"])
end

# Initialization

function eramodule(moduleID::AbstractString,init::Dict)

    init["moduletype"] = moduleID; len = eramoduledisp(init);
    if init["action"] == 1 && sum(["csfc","cpre"] .== moduleID) != 0
        error("$(Dates.now()) - Module ID \"$(moduleID)\" not defined for action \"$(init["action"])\".  Call queryemod(modID=$(moduleID)) for more details.")
    end

    if     moduleID == "dsfc"; init["modulename"] = "dry surface";
    elseif moduleID == "dpre"; init["modulename"] = "dry pressure";
    elseif moduleID == "msfc"; init["modulename"] = "moist surface";
    elseif moduleID == "mpre"; init["modulename"] = "moist pressure";
    elseif moduleID == "csfc"; init["modulename"] = "calc surface";
    elseif moduleID == "cpre"; init["modulename"] = "calc pressure";
    end

    if init["actionID"] == 1 && init["datasetID"] == 1
        if occursin("sfc",moduleID)
            init["moduleprint"] = "reanalysis-era5-single-levels";
        elseif occursin("pre",moduleID)
            init["moduleprint"] = "reanalysis-era5-pressure-levels";
        end
    end

    if occursin("pre",moduleID)
        @info "$(Dates.now()) - A pressure module was selected, and therefore all available pressure levels will be saved into the parameter Dictionary."
        init["levels"] = erapressureload();
    else
        @info "$(Dates.now()) - A surface module was selected, and therefore we will save 'sfc' into the parameter level Dictionary."
        init["levels"] = ["sfc"];
    end

    return init

end

function eraparameters(parameterID::AbstractString,init::Dict)

    parlist = eraparametersload(init); eraparametersdisp(parlist,init)

    if sum(parlist[:,2] .== parameterID) == 0
        error("$(Dates.now()) - Invalid parameter choice for $(eramod["name"]).  Call queryepar(modID=$(eramod["name"]),parID=$(parameterID)) for more information.")
    else
        ID = (parlist[:,2] .== parameterID);
    end

    parinfo = parlist[ID,:];
    @info "$(Dates.now()) - ClimateERA will $(init["action"]) $(parinfo[6]) data."
    return Dict("ID"  =>parinfo[2],"IDnc"=>parinfo[3],
                "era5"=>parinfo[4],"erai"=>parinfo[5],
                "name"=>parinfo[6],"unit"=>parinfo[7]);

end

function eratime(timeID::Integer,init::Dict)
    if timeID == 0;

        if init["datasetID"] == 1
              fin = Dates.year(Dates.now())-1;
        else; fin = 2018
        end

        return Dict("Begin"=>1979,"End"=>fin);
        @info "$(Dates.now()) - User has chosen to $(init["action"]) $(init["dataset"]) datasets from 1979 to $(fin)."

    else
        return Dict("Begin"=>timeID,"End"=>timeID)
        @info "$(Dates.now()) - User has chosen to $(init["action"]) $(init["dataset"]) datasets in $(timeID)."
    end
end

function eratime(timeID::Vector,init::Dict)
    beg = minimum(timeID); fin = maximum(timeID)
    return Dict("Begin"=>beg,"End"=>fin)
    @info "$(Dates.now()) - User has chosen to $(init["action"]) $(init["dataset"]) datasets from $(beg) to $(fin)."
end

function eraregion(gregID::AbstractString,init::Dict)
    return eraregionvec(eraregionload(gregID,init),init)
end

function erainitialize(
    init::Dict;
    modID::AbstractString, parID::AbstractString,
    regID::AbstractString="GLB", timeID::Union{Integer,Vector}=0
)

    emod = eramodule(modID,init); epar  = eraparameters(parID,emod);
    ereg = eraregion(regID,emod); etime = eratime(timeID,init);

    return emod,epar,ereg,etime

end
