"""
This file istarts the ClimateERA module by creating the root directory and by
specifying whether the data is to be downloaded or analyzed.  Functionalities
include:
    - Creation of root directory
    - Specifying whether purpose is to download or analyse data

"""

function eraroot()

    svrstr = "/n/kuangdss01/users/nwong/ecmwf/";
    svrrun = "/n/holylfs/LABS/kuang_lab/nwong/ecmwf/";
    dskdir = "/Volumes/CliNat-ERA/";
    docdir = "/Users/natgeo-wong/Documents/research/ecmwf/";

    if     isdir(svrstr); return eramkroot(svrstr);
        @info "$(Dates.now()) - The path $(svrdir) exists and therefore can be used as a directory for ClimateERA data downloads."
    elseif isdir(svrrun); return eramkroot(svrrun);
        @warn "$(Dates.now()) - The path $(svrdir) is not readable."
        @info "$(Dates.now()) - The path $(svrrun) exists and therefore can be used as a directory for ClimateERA data downloads."
    elseif isdir(dskdir); return eramkroot(dskdir);
        @info "$(Dates.now()) - Not running on remote server.  Checking for external disks."
        @info "$(Dates.now()) - External disk $(dskdir) exists and therefore can be used as a directory for ClimateERA data downloads."
    elseif isdir(docdir); return eramkroot(docdir);
        @info "$(Dates.now()) - Not running on remote server.  Checking for external disks."
        @info "$(Dates.now()) - External disks not found.  Using local research data directory $(docdir) for ClimateERA data downloads."
    else
        @error "$(Dates.now()) - The predefined directories in eraroot.jl do not exist.  They are user-dependent, so please modify/customize accordingly."
    end

end

function eramkroot(eroot)

    eiroot = "$(eroot)/erai"; e5root = "$(eroot)/era5"; eproot = "$(eroot)/plot";

    if !isdir(eiroot)
        mkpath(eiroot); @info "$(Dates.now()) - Created root folder for ERA-Interim reanalysis data $(eiroot)."
    else;               @info "$(Dates.now()) - Root folder for ERA-Interim reanalysis data $(eiroot) exists."
    end

    if !isdir(e5root)
        mkpath(e5root); @info "$(Dates.now()) - Created root folder for ERA5 reanalysis data $(e5root)."
    else;               @info "$(Dates.now()) - Root folder for ERA5 reanalysis data $(e5root) exists."
    end

    if !isdir(eproot)
        mkpath(eproot); @info "$(Dates.now()) - Created root folder for ERA plotting data $(eproot)."
    else;               @info "$(Dates.now()) - Root folder for ERA plotting data $(eproot) exists."
    end

    return Dict("erai"=>eiroot,"era5"=>e5root,"plot"=>eproot);

end

function eraaction(actionID)
    if     actionID == 1; return Dict("ID"=>1,"name"=>"download");
    elseif actionID == 2; return Dict("ID"=>2,"name"=>"analyse");
    end
end

function eradataset(datasetID)
    if     datasetID == 1; return Dict("ID"=>1,"name"=>"ERA5");
    elseif datasetID == 2; return Dict("ID"=>2,"name"=>"ERA-Interim");
    end
end

# Startup ClimateERA

function erastartup(actionID::UInt8,datasetID::UInt8)

    if !(actionID  in [1,2]); @error "$(Dates.now()) - Please input a valid action-type."  end;
    if !(datasetID in [1,2]); @error "$(Dates.now()) - Please input a valid dataset-type." end;

    eroot = eraroot();

    if     datasetID == 1; eroot["era"=eroot["era5"]]; delete!(eroot,"era5","erai");
    elseif datasetID == 2; eroot["era"=eroot["erai"]]; delete!(eroot,"era5","erai");
    end

    action = eraaction(actionID); dataset = eradataset(datasetID);
    @info "$(Dates.now()) - This script will $(action["name"]) $(dataset["name"]) data."
    cd(root["era"]); return Dict("actionID"=>actionID,"action"=>action["name"],
                                 "datasetID"=>datasetID,"dataset"=>dataset["name"]);

end