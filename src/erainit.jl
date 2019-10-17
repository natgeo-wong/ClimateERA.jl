"""
This file initializes the ClimateERA module by creating the root directory and
by specifying whether the data is to be downloaded or analyzed.  Functionalities
include:
    - Creation of root directory
    - Specifying whether purpose is to download or analyse data

"""

function eraroot()

    svrstr = "/n/kuangdss01/users/nwong/ecmwf/";
    svrrun = "/n/holylfs/LABS/kuang_lab/nwong/ecmwf/";
    dskdir = "/Volumes/CliNat-ERA";
    docdir = "/Users/natgeo-wong/Documents/research/ecmwf/";

    if     isdir(svrstr); eramkroot(svrstr); return svrstr;
        @info "$(Dates.now()) - The path $(svrdir) exists and therefore can be used as a directory for ClimateERA data downloads."
    elseif isdir(svrrun); eramkroot(svrrun); return svrrun;
        @warn "$(Dates.now()) - The path $(svrdir) is not readable."
        @info "$(Dates.now()) - The path $(svrrun) exists and therefore can be used as a directory for ClimateERA data downloads."
    elseif isdir(dskdir); eramkroot(dskdir); return dskdir;
        @info "$(Dates.now()) - Not running on remote server.  Checking for external disks."
        @info "$(Dates.now()) - External disk $(dskdir) exists and therefore can be used as a directory for ClimateERA data downloads."
    elseif isdir(docdir); eramkroot(docdir); return docdir;
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

end
