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
    @debug "$(Dates.now()) - There are $(len) types of modules that ClimateERA can $(init["action"])."

    @debug "$(Dates.now()) - 1) Dry Surface Modules    (e.g. Surface Winds)"
    @debug "$(Dates.now()) - 2) Dry Pressure Modules   (e.g. Winds at Pressure Height)"
    @debug "$(Dates.now()) - 3) Moist Surface Modules  (e.g. Rainfall, Total Column Water)"
    @debug "$(Dates.now()) - 4) Moist Pressure Modules (e.g. Humidity at Pressure Height)"

    if init["actionID"] == 2
        @debug "$(Dates.now()) - 5) Calc Surface Modules   (e.g. PI)"
        @debug "$(Dates.now()) - 6) Calc Pressure Modules  (e.g. Eddy Kinetic Energy, Psi)"
    end

    return len

end

# ClimateERA Parameter Setup

function eraparameterscopy(;overwrite::Bool=false)

    jfol = joinpath(DEPOT_PATH[1],"files/ClimateERA/"); mkpath(jfol);
    ftem = joinpath(@__DIR__,"../extra/epartemplate.txt")
    fpar = joinpath(jfol,"eraparameters.txt")

    if !overwrite
        if !isfile(fpar)
            @debug "$(Dates.now()) - Unable to find eraparameters.txt, copying data from epartemplate.txt ..."
            cp(ftem,fpar,force=true);
        end
    else
        @warn "$(Dates.now()) - Overwriting eraparameters.txt in $jfol ..."
        cp(ftem,fpar,force=true);
    end

    return fpar

end

function eraparametersload()

    @debug "$(Dates.now()) - Loading information on parameters used in ERA reanalysis."
    return readdlm(eraparameterscopy(),',',comments=true);

end

function eraparametersload(init::Dict)

    @debug "$(Dates.now()) - Loading information on parameters used in ERA reanalysis."
    allparams = readdlm(eraparameterscopy(),',',comments=true);

    @debug "$(Dates.now()) - Filtering out for parameters in the $(init["modulename"]) module."
    parmods = allparams[:,1]; return allparams[(parmods.==init["moduletype"]),:];

end

function eraparametersdisp(parlist::AbstractArray,init::Dict)
    @info "$(Dates.now()) - The following variables are offered in the $(init["modulename"]) module:"
    for ii = 1 : size(parlist,1); @info "$(Dates.now()) - $(ii)) $(parlist[ii,6])" end
end

function eraparametersadd(fadd::AbstractString)

    if !isfile(fadd); error("$(Dates.now()) - The file $(fadd) does not exist."); end
    ainfo = readdlm(fadd,',',comments=true); aparID = ainfo[:,2]; nadd = length(aparID);

    for iadd = 1 : nadd
        eraparameteradd(modID=ainfo[iadd,1],parID=ainfo[iadd,2],ncID=ainfo[iadd,3],
                        era5=ainfo[iadd,4],erai=ainfo[iadd,5],
                        full=ainfo[iadd,6],unit=ainfo[iadd,7],throw=false);
    end

end

function eraparameteradd(;
    modID::AbstractString, parID::AbstractString, ncID::AbstractString,
    era5::AbstractString, erai::AbstractString,
    full::AbstractString, unit::AbstractString,
    throw::Bool=true
)
    fpar = eraparameterscopy(); pinfo = eraparametersload(); eparID = pinfo[:,2];

    if sum(eparID.==parID) > 0

        if throw
            error("$(Dates.now()) - Parameter ID already exists.  Please choose a new parID.")
        else
            @info "$(Dates.now()) - $(parID) has already been added to eraparameters.txt"
        end

    else

        open(fpar,"a") do io
            writedlm(io,[modID parID ncID era5 erai full unit],',')
        end

    end

end

function erapressure(emod::Dict)

    if occursin("pre",emod["moduleID"])
        @debug "$(Dates.now()) - A pressure module was selected, and therefore all available pressure levels will be saved into the parameter Dictionary."
        emod["levels"] = erapressureload();
    else
        @debug "$(Dates.now()) - A surface module was selected, and therefore we will save 'sfc' into the parameter level Dictionary."
        emod["levels"] = ["sfc"];
    end

    return

end

function erapressureload()
    return [1,2,3,5,7,10,20,30,50,70,100,125,150,175,200,
            225,250,300,350,400,450,500,550,600,650,700,750,
            775,800,825,850,875,900,925,950,975,1000]
end

# ClimateERA Region Setup

function eraregionload(gregID::AbstractString,init::Dict)

    @info "$(Dates.now()) - Loading available GeoRegions ..."
    greginfo = gregioninfoload(); eraregionfilter(gregID,greginfo,init);
    gregfull = gregionfullname(gregID,greginfo)
    greggrid = gregionbounds(gregID,greginfo)
    if gregID == "GLB"; regglbe = true; else; regglbe = false; end

    @info "$(Dates.now()) - Storing GeoRegion properties and information for the $(gregfull) region ..."
    return Dict("region"=>gregID,"grid"=>greggrid,"name"=>gregfull,"isglobe"=>regglbe)

end

function eraregionfilter(gregID::AbstractString,greginfo::AbstractArray,init::Dict)

    isgeoregion(gregID,greginfo);

    if (init["actionID"] == 2) && (gregionparent(gregID;levels=2) != "GLB")
        error("$(Dates.now()) - ClimateERA.jl only has the option to analyse data from the $(gregionfullname(gregID,greginfo)) and not download it.")
    end

end

function eraregionvec(ereg::Dict,emod::Dict,step::Real)

    @debug "$(Dates.now()) - Determining spacing between grid points in the GeoRegion ..."
    if step == 0
        if ereg["isglobe"] == true;
              step = 1.0;
        else; step = 0.25;
        end
    else
        if !checkegrid(step)
            error("$(Dates.now()) - The grid resolution specified is not valid.")
        end
    end
    ereg["step"] = step

    N,S,E,W = ereg["grid"];
    @info "$(Dates.now()) - Creating longitude and latitude vectors for the GeoRegion ..."
    lon = convert(Array,W:step:E); if mod(E,360) == mod(W,360); pop!(lon); end
    lat = convert(Array,N:-step:S); nlon = size(lon,1); nlat = size(lat,1);
    ereg["lon"] = lon; ereg["lat"] = lat; ereg["size"] = [nlon,nlat];

    return ereg

end

function eraregionparent(gregID::AbstractString,emod::Dict)
    @info "$(Dates.now()) - Extracting parent GeoRegion properties/information ..."
    parentID = gregionparent(gregID); return eraregion(gregID,emod);
end

function eraregionparent(gregID::AbstractString,reginfo::AbstractArray,emod::Dict)
    @info "$(Dates.now()) - Extracting parent GeoRegion properties/information ..."
    parentID = gregionparent(gregID,reginfo); return eraregion(parentID,emod);
end

function eraregionextract(data::AbstractArray,gregID::AbstractString,emod::Dict)
    @info "$(Dates.now()) - Extracting data for GeoRegion from parent GeoRegion ..."
    preg = eraregionparent(gregID,emod); return regionextractgrid(data,reg,plon,plat)
end

function eraregionextract(data::AbstractArray,preg::Dict,reg::AbstractString)
    @info "$(Dates.now()) - Extracting data for GeoRegion from parent GeoRegion ..."
    return regionextractgrid(data,reg,preg["lon"],preg["lat"])
end

# Initialization

function eramodule(moduleID::AbstractString,init::Dict)

    init["moduletype"] = moduleID; len = eramoduledisp(init);
    if init["actionID"] == 1 && (sum(["csfc","cpre"] .== moduleID) != 0)
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
        @debug "$(Dates.now()) - A pressure module was selected, and therefore all available pressure levels will be saved into the parameter Dictionary."
        init["levels"] = erapressureload();
    else
        @debug "$(Dates.now()) - A surface module was selected, and therefore we will save 'sfc' into the parameter level Dictionary."
        init["levels"] = ["sfc"];
    end

    return init

end

function eraparameters(parameterID::AbstractString,emod::Dict)

    parlist = eraparametersload(emod);

    if sum(parlist[:,2] .== parameterID) == 0
        error("$(Dates.now()) - Invalid parameter choice for $(emod["name"]).  Call queryepar(modID=$(emod["name"]),parID=$(parameterID)) for more information.")
    else
        ID = (parlist[:,2] .== parameterID);
    end

    parinfo = parlist[ID,:];
    @info "$(Dates.now()) - ClimateERA will $(emod["action"]) $(parinfo[6]) data."
    return Dict("ID"  =>parinfo[2],"IDnc"=>parinfo[3],
                "era5"=>parinfo[4],"erai"=>parinfo[5],
                "name"=>parinfo[6],"unit"=>parinfo[7]);

end

function eratime(timeID::Integer,emod::Dict)
    if timeID == 0;

        if emod["datasetID"] == 1
              fin = Dates.year(Dates.now())-1;
        else; fin = 2018
        end

        return Dict("Begin"=>1979,"End"=>fin);
        @info "$(Dates.now()) - User has chosen to $(emod["action"]) $(emod["dataset"]) datasets from 1979 to $(fin)."

    else
        return Dict("Begin"=>timeID,"End"=>timeID)
        @info "$(Dates.now()) - User has chosen to $(emod["action"]) $(emod["dataset"]) datasets in $(timeID)."
    end
end

function eratime(timeID::Vector,emod::Dict)
    beg = minimum(timeID); fin = maximum(timeID)
    return Dict("Begin"=>beg,"End"=>fin)
    @info "$(Dates.now()) - User has chosen to $(emod["action"]) $(emod["dataset"]) datasets from $(beg) to $(fin)."
end

function eraregion(gregID::AbstractString,emod::Dict,gres::Real)
    return eraregionvec(eraregionload(gregID,emod),emod,gres)
end

function erainitialize(
    init::Dict;
    modID::AbstractString, parID::AbstractString,
    regID::AbstractString="GLB", timeID::Union{Integer,Vector}=0,
    gres::Real=0
)

    emod = eramodule(modID,init); epar = eraparameters(parID,emod);
    ereg = eraregion(regID,emod,gres); etime = eratime(timeID,emod);

    return emod,epar,ereg,etime

end
