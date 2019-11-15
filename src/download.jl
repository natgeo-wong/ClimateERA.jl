"""
This holds all the scripts that are relevant to the downloading of ECMWF reanalysis
data, which includes the following functionalities:
    - Creation of python download scripts
    - Creation of respective folders to put data in within the ClimateERA directory

"""

# Creation of ClimateERA Download Scripts

function eradscriptcreate(modID::Integer,emod::Dict,epar::Dict,ereg::Dict)

    if !(epar["level"] == "sfc")
          fname = "$(emod["prefix"])-$(ereg["region"])-$(epar["ID"])-$(epar["level"])hPa";
    else; fname = "$(emod["prefix"])-$(ereg["region"])-$(epar["ID"])-$(epar["level"])";
    end

    fID = open("$(fname).py","w");

    write(fID,"#!/usr/bin/env python\n");

    if modID == 1
        write(fID,"import cdsapi\n");
        write(fID,"c = cdsapi.Client()\n\n");
    else
        write(fID,"from ecmwfapi import ECMWFDataServer\n");
        write(fID,"server = ECMWFDataServer()\n\n");
    end

    return fname,fID

end

function eradscriptheader(fID,modID::Integer,emod::Dict,epar::Dict)

    parID = epar["ID"];

    if modID == 1
        write(fID,"c.retrieve($(emod["moduleprint"]),\n");
        write(fID,"    {\n");
        write(fID,"        \"product_type\": \"reanalysis\",\n");
    else
        write(fID,"server.retrieve({\n");
        write(fID,"    \"class\": \"ei\",\n");
        write(fID,"    \"dataset\": \"interim\",\n");
        write(fID,"    \"stream\": \"oper\",\n");

        if !(parID == "cape") && !(parID[1:4] == "prcp")
              write(fID,"    \"type\": \"an\",\n");
        else; write(fID,"    \"type\": \"fc\",\n");
        end

        write(fID,"    \"type\": \"an\",\n");
        write(fID,"    \"expver\": \"1\",\n");
    end

end

function eradscriptpprint(fID,modID::Integer,emod::Dict,epar::Dict)

    pre = epar["level"];

    if modID == 1; var = epar["era5"];
        write(fID,"        \"variable\": $(var),\n");
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

function eradscriptregion(fID,modID::Integer,emod::Dict,ereg::Dict)

    estep = ereg["step"];
    if modID == 1
        if !ereg["isglobe"]; N,S,E,W = ereg["grid"];
              write(fID,"        \"area\": [$(N),$(W),$(S),$(E)],\n");
        end
        write(fID,"        \"grid\": [$(estep),$(estep)],\n");
    else
        if !ereg["isglobe"]; N,S,E,W = ereg["grid"];
              write(fID,"    \"area\": \"$(N)/$(W)/$(S)/$(E)\",\n");
        end
        write(fID,"    \"grid\": \"$(estep)/$(estep)\",\n");
    end

end

function eradscriptdprint(fID,modID::Integer,epar::Dict,year::Integer)

    parID = epar["ID"];

    if modID == 1
        write(fID,"        \"year\": \"$(year)\",\n");
        write(fID,"        \"month\":[\n");
        write(fID,"            \"01\",\"02\",\"03\",\"04\",\"05\",\"06\",\n");
        write(fID,"            \"07\",\"08\",\"09\",\"10\",\"11\",\"12\"\n");
        write(fID,"        ],\n");
        write(fID,"        \"day\":[\n");
        write(fID,"            \"01\",\"02\",\"03\",\"04\",\"05\",\"06\",\n");
        write(fID,"            \"07\",\"08\",\"09\",\"10\",\"11\",\"12\",\n");
        write(fID,"            \"13\",\"14\",\"15\",\"16\",\"17\",\"18\",\n");
        write(fID,"            \"19\",\"20\",\"21\",\"22\",\"23\",\"24\",\n");
        write(fID,"            \"25\",\"26\",\"27\",\"28\",\"29\",\"30\",\n");
        write(fID,"            \"31\"\n");
        write(fID,"        ],\n");
        write(fID,"        \"time\":[\n");
        write(fID,"            \"00:00\",\"01:00\",\"02:00\",\"03:00\",\"04:00\",\n");
        write(fID,"            \"05:00\",\"06:00\",\"07:00\",\"08:00\",\"09:00\",\n");
        write(fID,"            \"10:00\",\"11:00\",\"12:00\",\"13:00\",\"14:00\",\n");
        write(fID,"            \"15:00\",\"16:00\",\"17:00\",\"18:00\",\"19:00\",\n");
        write(fID,"            \"20:00\",\"21:00\",\"22:00\",\"23:00\"\n");
        write(fID,"        ],\n");
    else
        write(fID,"    \"date\": \"$(year)-01-01/to/$(year)-12-31\",\n");
        if !(parID == "cape") && !(parID[1:4] == "prcp")
            write(fID,"    \"time\": \"00:00:00/06:00:00/12:00:00/18:00:00\",\n");
            write(fID,"    \"step\": \"0\",\n");
        else
            write(fID,"    \"time\": \"00:00:00/12:00:00\",\n");
            write(fID,"    \"step\": \"3/6/9/12\",\n");
        end
    end

end

function eradscripttarget(fID,modID::Integer,fname::AbstractString,year::Integer)

    if modID == 1
        write(fID,"        \"format\": \"netcdf\"\n");
        write(fID,"    },\n");
        write(fID,"    \"$(fname)-$(year).nc\")\n\n");
    else
        write(fID,"    \"format\": \"netcdf\",\n");
        write(fID,"    \"target\": \"$(fname)-$(year).nc\",\n");
        write(fID,"})\n\n");
    end

end

# Master ClimateERA Download Scripts.end

function eradscript(emod::Dict,epar::Dict,ereg::Dict,time::Dict)

    modID = emod["moduleID"];
    fname,fID = eradscriptcreate(modID,emod,epar,ereg);

    for year = time["Begin"] : time["End"]

        eradscriptheader(fID,modID,emod,epar);
        eradscriptpprint(fID,modID,emod,epar);
        eradscriptregion(fID,modID,emod,ereg);
        eradscriptdprint(fID,modID,epar,year);
        eradscripttarget(fID,modID,fname,year);

    end

    close(fID); return "$(fname).py"

end

function eradownload(emod::Dict,epar::Dict,ereg::Dict,time::Dict,eroot::Dict)

    prelist = emod["levels"]; modID = emod["moduleID"];

    if modID == 1; dwnsh = joinpath(@__DIR__,"./extra/erad5.sh");
    else;          dwnsh = joinpath(@__DIR__,"./extra/eradi.sh");
    end

    for preii in prelist; epar["level"] = preii;

        @info "$(Dates.now()) - Creating download scripts and directories ..."
        fname = eradscript(emod,epar,ereg,time);
        fol = erafolder(emod,epar,ereg,eroot);

        @info "$(Dates.now()) - Moving download scripts to tmp directory $(fol["tmp"]) ..."
        mv(fname,joinpath(fol["tmp"],fname),force=true);
        if isfile(dwnsh); cp(dwnsh,joinpath(fol["tmp"],"erad.sh"),force=true); end

    end

    fol = erafolder(emod,epar,ereg,eroot);
    @info "$(Dates.now()) - Saving information and moving info files to directories ..."
    @save "info_par.jld2" emod epar; @save "info_reg.jld2" ereg;
    mv("info_par.jld2",joinpath(fol["var"],"info_par.jld2"),force=true)
    mv("info_reg.jld2",joinpath(fol["reg"],"info_reg.jld2"),force=true)

end

function eratmp2raw(efol::Dict)

    @info "$(Dates.now()) - Retrieving list of downloaded data files in ERA reanalysis tmp folder."
    fnc = glob("*.nc",efol["tmp"]); lf = size(fnc,1);

    if lf > 0
        @info "$(Dates.now()) - Moving ERA reanalysis data from tmp to raw folder."
        for ii = 1 : lf; mv(fnc[ii],efol["raw"]); end
        @info "$(Dates.now()) - Downloaded ERA reanalysis data has been moved raw folder."
    else
        @info "$(Dates.now()) - ERA reanalysis tmp folder is empty.  Nothing to shift."
    end

end
