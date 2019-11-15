"""
This file istarts the ClimateERA module by creating the root directory and by
specifying whether the data is to be downloaded or analyzed.  Functionalities
include:
    - Creation of root directory
    - Specifying whether purpose is to download or analyse data

"""

function eraroot(actionID)

    path = joinpath("$(homedir)","research","ecmwf");
    @warn "$(Dates.now()) - No directory path was given.  Setting to default path: $(path) for ClimateERA data downloads."

    if isdir(path)
        @info "$(Dates.now()) - The default path $(path) exists and therefore can be used as a directory for ClimateERA data downloads."
    else
        if actionID != 1
            error("$(Dates.now()) - The path $(path) does not exist.  If you are doing analysis, please point towards the correct path before proceeding ...")
        else
            @warn "$(Dates.now()) - The path $(path) does not exist.  A new directory will be created here.  Therefore if you already have an existing repository for ClimateERA data, make sure that $(path) is the correct location."
            @info "$(Dates.now()) - Creating path $(path) ..."
            mkpath(path);
        end
    end

    return eramkroot(path)

end

function eraroot(path::AbstractString,actionID::Integer)

    if isdir(path)
        @info "$(Dates.now()) - The default path $(path) exists and therefore can be used as a directory for ClimateERA data downloads."
    else
        if actionID != 1
            error("$(Dates.now()) - The path $(path) does not exist.  If you are doing analysis, please point towards the correct path before proceeding ...")
        else
            @warn "$(Dates.now()) - The path $(path) does not exist.  A new directory will be created here.  Therefore if you already have an existing repository for ClimateERA data, make sure that $(path) is the correct location."
            mkpath(path);
        end
    end

    return eramkroot(path)

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

    eroot = eraroot(actionID);

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

function erastartup(actionID::Integer,datasetID::Integer,path::AbstractString)

    if !(actionID  in [1,2]); @error "$(Dates.now()) - Please input a valid action-type."  end;
    if !(datasetID in [1,2]); @error "$(Dates.now()) - Please input a valid dataset-type." end;

    eroot = eraroot(actionID,path);

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

function erafolder(emod::Dict,epar::Dict,ereg::Dict,eroot::Dict)

    pre = epar["level"];

    folreg = joinpath(eroot["era"],ereg["region"]);
    if !isdir(folreg)
        @info "$(Dates.now()) - Creating folder for the $(ereg["name"]) region at $(folreg) ..."
        mkpath(folreg);
    else; @info "$(Dates.now()) - The folder for the $(ereg["name"]) region $(folreg) exists."
    end

    folvar = joinpath(eroot["era"],ereg["region"],epar["ID"]);
    if !isdir(folvar)
        @info "$(Dates.now()) - Creating variable folder for the $(epar["name"]) parameter at $(folvar) ..."
        mkpath(folvar);
    else; @info "$(Dates.now()) - The folder for the $(epar["name"]) parameter $(folvar) exists."
    end

    folraw = joinpath(folvar,"raw"); foltmp = joinpath(folvar,"tmp");
    folana = joinpath(folvar,"ana"); folimg = joinpath(folvar,"img");
    if !(pre == "sfc"); phPa = "$(epar["ID"])-$(pre)hPa"
        folraw = joinpath(folraw,phPa); foltmp = joinpath(foltmp,phPa);
        folana = joinpath(folana,phPa); folimg = joinpath(folimg,phPa);
    end

    @info "$(Dates.now()) - Creating relevant subdirectories for data downloading, temporary storage, analysis and image creation."
    if !isdir(folraw);
        @info "$(Dates.now()) - Creating folder for raw data: $(folraw)"; mkpath(folraw)
    end
    if !isdir(folana);
        @info "$(Dates.now()) - Creating folder for data analysis ouput: $(folana)"; mkpath(folana)
    end
    if !isdir(folimg);
        @info "$(Dates.now()) - Creating folder for data images: $(folimg)"; mkpath(folimg)
    end
    if emod["actionID"] == 1
        if !isdir(foltmp);
            @info "$(Dates.now()) - Creating folder for temporary raw data storage: $(foltmp)";
            mkpath(foltmp)
        end
    end

    return Dict("reg"=>folreg,"var"=>folvar,"raw"=>folraw,
                "tmp"=>foltmp,"ana"=>folana,"img"=>folimg);

end

function erancread(ncname::AbstractString,epar::Dict)

    try;   data = ncread(ncname,epar["IC"]);
    catch; data = ncread(ncname,epar["ICnc"]);
    end
    ncclose()

end

function erancread(ncname::AbstractString,epar::Dict;erastart)

    try;   data = ncread(ncname,epar["IC"],start=erastart);
    catch; data = ncread(ncname,epar["ICnc"],start=erastart);
    end
    ncclose()

end

function erancread(ncname::AbstractString,epar::Dict;eracount)

    try;   data = ncread(ncname,epar["IC"],count=eracount);
    catch; data = ncread(ncname,epar["ICnc"],count=eracount);
    end
    ncclose()

end

function erancread(ncname::AbstractString,epar::Dict;erastart,eracount)

    try;   data = ncread(ncname,epar["IC"],start=erastart,count=eracount);
    catch; data = ncread(ncname,epar["ICnc"],start=erastart,count=eracount);
    end
    ncclose()

end
