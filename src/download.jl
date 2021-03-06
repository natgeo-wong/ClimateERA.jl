"""
This holds all the scripts that are relevant to the downloading of ECMWF reanalysis
data, which includes the following functionalities:
    - Creation of python download scripts
    - Creation of respective folders to put data in within the ClimateERA directory

"""

# Creation of ClimateERA Download Scripts

function eradscriptcreate(dataID::Integer,emod::Dict,epar::Dict,ereg::Dict)

    if !(epar["level"] == "sfc")
          fname = "$(emod["prefix"])-$(ereg["fol"])-$(epar["ID"])-$(epar["level"])hPa";
    else; fname = "$(emod["prefix"])-$(ereg["fol"])-$(epar["ID"])-$(epar["level"])";
    end

    fID = open("$(fname).py","w");

    write(fID,"#!/usr/bin/env python\n");

    if dataID == 1
        write(fID,"import cdsapi\n");
        write(fID,"c = cdsapi.Client()\n\n");
    else
        write(fID,"from ecmwfapi import ECMWFDataServer\n");
        write(fID,"server = ECMWFDataServer()\n\n");
    end

    return fname,fID

end

function eradscriptheader(fID,dataID::Integer,emod::Dict,epar::Dict)

    parID = epar["ID"];

    if dataID == 1
        write(fID,"c.retrieve(\"$(emod["moduleprint"])\",\n");
        write(fID,"    {\n");
        write(fID,"        \"product_type\": \"reanalysis\",\n");
    else
        write(fID,"server.retrieve({\n");
        write(fID,"    \"class\": \"ei\",\n");
        write(fID,"    \"dataset\": \"interim\",\n");
        write(fID,"    \"stream\": \"oper\",\n");

        if !all(occursin.(["cape","prcp"],parID))
              write(fID,"    \"type\": \"an\",\n");
        else; write(fID,"    \"type\": \"fc\",\n");
        end

        write(fID,"    \"type\": \"an\",\n");
        write(fID,"    \"expver\": \"1\",\n");
    end

end

function eradscriptpprint(fID,dataID::Integer,emod::Dict,epar::Dict)

    pre = epar["level"];

    if dataID == 1; var = epar["era5"];
        write(fID,"        \"variable\": \"$(var)\",\n");
        if !(pre == "sfc"); write(fID,"        \"pressure_level\": $(pre),\n"); end
    else; var = epar["erai"];
        write(fID,"    \"param\": $(var),\n");
        if pre == "sfc"
            write(fID,"    \"levtype\": \"sfc\",\n");
        else
            write(fID,"    \"levtype\": \"pl\",\n");
            write(fID,"    \"levelist\": \"$(pre)\",\n");
        end
    end

end

function eradscriptregion(fID,dataID::Integer,emod::Dict,ereg::Dict)

    estep = ereg["step"]; N,S,E,W = ereg["grid"]
    if W == E; E = W + 0.1 end
    if N == S; S = N - 0.1 end
    if dataID == 1
        if !ereg["isglobe"]
              write(fID,"        \"area\": [$(N),$(W),$(S),$(E)],\n");
        end
        write(fID,"        \"grid\": [$(estep),$(estep)],\n");
    else
        if !ereg["isglobe"]
              write(fID,"    \"area\": \"$(N)/$(W)/$(S)/$(E)\",\n");
        end
        write(fID,"    \"grid\": \"$(estep)/$(estep)\",\n");
    end

end

function eradscriptdprint(fID,dataID::Integer,epar::Dict,yr::Integer,mo::Integer)

    parID = epar["ID"]; ndy = daysinmonth(yr,mo); mo = mo2str(mo);
    dystr = "\"25\""; for dy = 26 : ndy; dystr = string(dystr,",\"$(dy2str(dy))\""); end

    if dataID == 1
        write(fID,"        \"year\": \"$(yr)\",\n");
        write(fID,"        \"month\": \"$(mo)\",\n");
        write(fID,"        \"day\":[\n");
        write(fID,"            \"01\",\"02\",\"03\",\"04\",\"05\",\"06\",\n");
        write(fID,"            \"07\",\"08\",\"09\",\"10\",\"11\",\"12\",\n");
        write(fID,"            \"13\",\"14\",\"15\",\"16\",\"17\",\"18\",\n");
        write(fID,"            \"19\",\"20\",\"21\",\"22\",\"23\",\"24\",\n");
        write(fID,"            $(dystr)\n");
        write(fID,"        ],\n");
        write(fID,"        \"time\":[\n");
        write(fID,"            \"00:00\",\"01:00\",\"02:00\",\"03:00\",\"04:00\",\n");
        write(fID,"            \"05:00\",\"06:00\",\"07:00\",\"08:00\",\"09:00\",\n");
        write(fID,"            \"10:00\",\"11:00\",\"12:00\",\"13:00\",\"14:00\",\n");
        write(fID,"            \"15:00\",\"16:00\",\"17:00\",\"18:00\",\"19:00\",\n");
        write(fID,"            \"20:00\",\"21:00\",\"22:00\",\"23:00\"\n");
        write(fID,"        ],\n");
    else
        write(fID,"    \"date\": \"$(yr)-$(mo)-01/to/$(yr)-$(mo)-$(ndy)\",\n");
        if !all(occursin.(["cape","prcp"],parID))
            write(fID,"    \"time\": \"00:00:00/06:00:00/12:00:00/18:00:00\",\n");
            write(fID,"    \"step\": \"0\",\n");
        else
            write(fID,"    \"time\": \"00:00:00/12:00:00\",\n");
            write(fID,"    \"step\": \"3/6/9/12\",\n");
        end
    end

end

function eradscripttarget(
    fID,dataID::Integer,fname::AbstractString,
    yr::Integer,mo::Integer
)

    fnc = joinpath("..","raw","$(yr)","$(fname)-$(yrmo2str(yr,mo)).nc")
    if dataID == 1
        write(fID,"        \"format\": \"netcdf\"\n");
        write(fID,"    },\n");
        write(fID,"    \"$(fnc)\")\n\n");
    else
        write(fID,"    \"format\": \"netcdf\",\n");
        write(fID,"    \"target\": \"$(fnc)\",\n");
        write(fID,"})\n\n");
    end

end

# Master ClimateERA Download Scripts.end

function eradscript(emod::Dict,epar::Dict,ereg::Dict,etime::Dict)

    dataID = emod["datasetID"];
    fname,fID = eradscriptcreate(dataID,emod,epar,ereg);

    for yr = etime["Begin"] : etime["End"]
        for mo = 1 : 12

            eradscriptheader(fID,dataID,emod,epar);
            eradscriptpprint(fID,dataID,emod,epar);
            eradscriptregion(fID,dataID,emod,ereg);
            eradscriptdprint(fID,dataID,epar,yr,mo);
            eradscripttarget(fID,dataID,fname,yr,mo);

        end
    end

    close(fID); return "$(fname).py"

end

function eradownload(
    init::Dict, eroot::Dict;
    modID::AbstractString, parID::AbstractString,
    regID::AbstractString="GLB", timeID::Union{Integer,Vector}=0,
    gres::Real=0
)

    emod,epar,ereg,etime = erainitialize(
        init;
        modID=modID,parID=parID,regID=regID,timeID=timeID,
        gres=gres
    );
    eradownload(emod,epar,ereg,etime,eroot)

end

function eradownload(emod::Dict,epar::Dict,ereg::Dict,etime::Dict,eroot::Dict)

    prelist = emod["levels"]; dataID = emod["datasetID"];

    jfol = joinpath(DEPOT_PATH[1],"files/ClimateERA/"); mkpath(jfol);
    if dataID == 1; dwnsh = joinpath(jfol,"erad5.sh");
    else;           dwnsh = joinpath(jfol,"eradi.sh");
    end

    if !isfile(dwnsh);
        if dataID == 1; template = joinpath(@__DIR__,"../extra/erad5_eg.sh");
        else;           template = joinpath(@__DIR__,"../extra/eradi_eg.sh");
        end
        cp(template,dwnsh,force=true);
    end

    @info "$(Dates.now()) - Creating download scripts, directories and subdirectories for data downloading, temporary storage, analysis and image creation..."

    for preii in prelist; epar["level"] = preii;

        @debug "$(Dates.now()) - Creating download scripts and directories at pressure level preii ..."
        fname = eradscript(emod,epar,ereg,etime);
        efol  = erafolder(emod,epar,ereg,etime,eroot);

        @debug "$(Dates.now()) - Moving download scripts to tmp folder $(efol["tmp"]) ..."
        mv(fname,joinpath(efol["tmp"],fname),force=true);
        cp(dwnsh,joinpath(efol["tmp"],"erad.sh"),force=true);

        @debug "$(Dates.now()) - Saving module and variable information into efol[\"var\"] directory ..."
        @save "info_par.jld2" emod epar;
        mv("info_par.jld2",joinpath(efol["var"],"info_par.jld2"),force=true)

    end

    efol = erafolder(emod,epar,ereg,etime,eroot);
    @info "$(Dates.now()) - Saving region information into efol[\"reg\"] directory ..."
    @save "info_reg.jld2" ereg;
    mv("info_reg.jld2",joinpath(efol["reg"],"info_reg.jld2"),force=true)

end

function eralvlsplit(
    init::Dict, eroot::Dict;
    modID::AbstractString, parID::AbstractString,
    regID::AbstractString="GLB", timeID::Union{Integer,Vector}=0,
    gres::Real=0, plist::Union{Integer,Vector{<:Real}}=0
)

    emod,epar,ereg,etime = erainitialize(
        init;
        modID=modID,parID=parID,regID=regID,timeID=timeID,
        gres=gres
    );
    eralvlsplit(emod,epar,ereg,etime,eroot,plist)

end

function eralvlsplit(
    emod::Dict,epar::Dict,ereg::Dict,etime::Dict,eroot::Dict,
    plist::Union{Integer,Vector{<:Real}}=0
)

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    if typeof(plist) <: Array

        for dtii in datevec

            fol = joinpath(eroot["era"],ereg["fol"],epar["ID"],"raw",yr2str(dtii));
            fnc = "$(emod["prefix"])-$(ereg["fol"])-$(epar["ID"])-$(yrmo2str(dtii)).nc"
            eds = NCDataset(joinpath(fol,fnc))
            pre = eds["level"][:]

            for preii in plist
                ip = argmin(abs.(pre.-preii)); epar["level"] = pre[ip];
                efol = erafolder(emod,epar,ereg,etime,eroot,epar["level"]);
                dataii = eds[epar["IDnc"]][:,:,ip,:]*1
                erarawsave(dataii,emod,epar,ereg,dtii,eroot)
            end

            close(eds); rm(joinpath(fol,fnc),force=true)

        end

    elseif iszero(plist)

        for dtii in datevec

            fol = joinpath(eroot["era"],ereg["fol"],epar["ID"],"raw",yr2str(dtii));
            fnc = "$(emod["prefix"])-$(ereg["fol"])-$(epar["ID"])-$(yrmo2str(dtii)).nc"
            eds = NCDataset(joinpath(fol,fnc))
            pre = eds["level"][:]; np = length(pre)

            for ip in 1 : np; epar["level"] = pre[ip];

                efol = erafolder(emod,epar,ereg,etime,eroot,epar["level"]);
                dataii = eds[epar["IDnc"]][:,:,ip,:]*1
                erarawsave(dataii,emod,epar,ereg,dtii,eroot)

            end

            close(eds); rm(joinpath(fol,fnc),force=true)

        end

    else

        for dtii in datevec

            fol = joinpath(eroot["era"],ereg["fol"],epar["ID"],"raw",yr2str(dtii));
            fnc = "$(emod["prefix"])-$(ereg["fol"])-$(epar["ID"])-$(yrmo2str(dtii)).nc"
            eds = NCDataset(joinpath(fol,fnc))
            pre = eds["level"][:]; ip = argmin(abs.(pre.-plist)); epar["level"] = pre[ip];

            efol = erafolder(emod,epar,ereg,etime,eroot,epar["level"]);
            dataii = eds[epar["IDnc"]][:,:,ip,:]*1
            erarawsave(dataii,emod,epar,ereg,dtii,eroot)

            close(eds); rm(joinpath(fol,fnc),force=true)

        end

    end

end
