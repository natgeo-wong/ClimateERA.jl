"""
This file istarts the ClimateERA module by creating the root directory and by
specifying whether the data is to be downloaded or analyzed.  Functionalities
include:
    - Creation of root directory
    - Specifying whether purpose is to download or analyse data

"""

function eraroot()

    path = joinpath("$(homedir)","research","ecmwf";
    @info "$(Dates.now()) - No directory path was given.  Setting to default path: $(path) for ClimateERA data downloads."

    if isdir(path)
        @info "$(Dates.now()) - The default path $(path) exists and therefore can be used as a directory for ClimateERA data downloads."
    else
        @warn "$(Dates.now()) - The path $(path) does not exist.  Creating now ..."
        mkpath(path);
    end

    return path

end

function eramkroot(eroot::AbstractString)

    eiroot = joinpath(eroot,"erai");
    if !isdir(eiroot)
        mkpath(eiroot); @info "$(Dates.now()) - Created root folder for ERA-Interim reanalysis data $(eiroot)."
    else;               @info "$(Dates.now()) - Root folder for ERA-Interim reanalysis data $(eiroot) exists."
    end

    e5root = joinpath(eroot,"era5");
    if !isdir(e5root)
        mkpath(e5root); @info "$(Dates.now()) - Created root folder for ERA5 reanalysis data $(e5root)."
    else;               @info "$(Dates.now()) - Root folder for ERA5 reanalysis data $(e5root) exists."
    end

    eproot = joinpath(eroot,"plot");
    if !isdir(eproot)
        mkpath(eproot); @info "$(Dates.now()) - Created root folder for ERA plotting data $(eproot)."
    else;               @info "$(Dates.now()) - Root folder for ERA plotting data $(eproot) exists."
    end

    return Dict("erai"=>eiroot,"era5"=>e5root,"plot"=>eproot);

end

function eraaction(actionID::Integer)
    if     actionID == 1; return Dict("ID"=>1,"name"=>"download");
    elseif actionID == 2; return Dict("ID"=>2,"name"=>"analyse");
    end
end

function eradataset(datasetID::Integer)
    if     datasetID == 1; return Dict("ID"=>1,"short"=>"era5","name"=>"ERA5");
    elseif datasetID == 2; return Dict("ID"=>2,"short"=>"erai","name"=>"ERA-Interim");
    end
end

# Startup ClimateERA

function erastartup(actionID::Integer,datasetID::Integer)

    if !(actionID  in [1,2]); @error "$(Dates.now()) - Please input a valid action-type."  end;
    if !(datasetID in [1,2]); @error "$(Dates.now()) - Please input a valid dataset-type." end;

    eroot = eraroot();

    if     datasetID == 1; eroot["era"]=eroot["era5"]; delete!(eroot,["era5","erai"]);
    elseif datasetID == 2; eroot["era"]=eroot["erai"]; delete!(eroot,["era5","erai"]);
    end

    action = eraaction(actionID); dataset = eradataset(datasetID);
    @info "$(Dates.now()) - This script will $(action["name"]) $(dataset["name"]) data."
    init = Dict("actionID"=>actionID,"action"=>action["name"],
                "datasetID"=>datasetID,"dataset"=>dataset["name"],
                "prefix"=>dataset["short"])
    cd(eroot["era"]); return init,eroot

end
