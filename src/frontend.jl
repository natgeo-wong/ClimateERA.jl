"""
This file istarts the ClimateERA module by creating the root directory and by
specifying whether the data is to be downloaded or analyzed.  Functionalities
include:
    - Creation of root directory
    - Specifying whether purpose is to download or analyse data

"""

function eraroot(actionID)

    path = joinpath("$(homedir())","research","ecmwf");
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

# ClimateERA Folders

function eraregfolder(ereg::Dict,eroot::Dict)

    fol = joinpath(eroot["era"],ereg["region"]);

    if !isdir(fol)
        @info "$(Dates.now()) - The folder for the $(ereg["name"]) region at does not exist.  Creating now ..."
        mkpath(fol);
    end

    return fol

end

function eravarfolder(epar::Dict,ereg::Dict,eroot::Dict)

    fol = joinpath(eroot["era"],ereg["region"],epar["ID"]);

    if !isdir(fol)
        @info "$(Dates.now()) - The folder for the $(epar["name"]) parameter in the $(ereg["name"]) region does not exist.  Creating now ..."
        mkpath(fol);
    end

    return fol

end

function erarawfolder(epar::Dict,ereg::Dict,eroot::Dict)

    if epar["level"] != "sfc"; phPa = "$(epar["ID"])-$(epar["level"])hPa"

        fol = joinpath(eroot["era"],ereg["region"],epar["ID"],phPa,"raw");
        if !isdir(fol)
            @info "$(Dates.now()) - The folder for raw data of the $(epar["name"]) parameter at pressure level $(epar["level"])hPa in the $(ereg["name"]) region does not exist.  Creating now ..."
            mkpath(fol);
        end

    else

        fol = joinpath(eroot["era"],ereg["region"],epar["ID"],"raw");
        if !isdir(fol)
            @info "$(Dates.now()) - The folder for raw data of the $(epar["name"]) parameter in the $(ereg["name"]) region does not exist.  Creating now ..."
            mkpath(fol);
        end

    end

    return fol

end

function eraanafolder(epar::Dict,ereg::Dict,eroot::Dict)

    if epar["level"] != "sfc"; phPa = "$(epar["ID"])-$(epar["level"])hPa"

        fol = joinpath(eroot["era"],ereg["region"],epar["ID"],phPa,"ana");
        if !isdir(fol)
            @info "$(Dates.now()) - The folder for analyzed data of the $(epar["name"]) parameter at pressure level $(epar["level"])hPa in the $(ereg["name"]) region does not exist.  Creating now ..."
            mkpath(fol);
        end

    else

        fol = joinpath(eroot["era"],ereg["region"],epar["ID"],"ana");
        if !isdir(fol)
            @info "$(Dates.now()) - The folder for analyzed data of the $(epar["name"]) parameter in the $(ereg["name"]) region does not exist.  Creating now ..."
            mkpath(fol);
        end

    end

    return fol

end

function eraimgfolder(epar::Dict,ereg::Dict,eroot::Dict)

    if epar["level"] != "sfc"; phPa = "$(epar["ID"])-$(epar["level"])hPa"

        fol = joinpath(eroot["era"],ereg["region"],epar["ID"],phPa,"img");
        if !isdir(fol)
            @info "$(Dates.now()) - The folder for images of the $(epar["name"]) parameter at pressure level $(epar["level"])hPa in the $(ereg["name"]) region does not exist.  Creating now ..."
            mkpath(fol);
        end

    else

        fol = joinpath(eroot["era"],ereg["region"],epar["ID"],"img");
        if !isdir(fol)
            @info "$(Dates.now()) - The folder for images of the $(epar["name"]) parameter in the $(ereg["name"]) region does not exist.  Creating now ..."
            mkpath(fol);
        end

    end

    return fol

end

function erafolder(emod::Dict,epar::Dict,ereg::Dict,etime::Dict,eroot::Dict)

    yrbeg = etime["Begin"]; yrend = etime["End"];

    folreg = joinpath(eroot["era"],ereg["region"]);
    if !isdir(folreg)
        @debug "$(Dates.now()) - Creating folder for the $(ereg["name"]) region at $(folreg) ..."
        mkpath(folreg);
    else; @debug "$(Dates.now()) - The folder for the $(ereg["name"]) region $(folreg) exists."
    end

    folvar = joinpath(eroot["era"],ereg["region"],epar["ID"]);
    if !isdir(folvar)
        @debug "$(Dates.now()) - Creating variable folder for the $(epar["name"]) parameter at $(folvar) ..."
        mkpath(folvar);
    else; @debug "$(Dates.now()) - The folder for the $(epar["name"]) parameter $(folvar) exists."
    end

    if epar["level"] != "sfc"
        folvar = joinpath(folvar,"$(epar["ID"])-$(epar["level"])hPa")
    end
    folraw = joinpath(folvar,"raw"); foltmp = joinpath(folvar,"tmp");
    folana = joinpath(folvar,"ana"); folimg = joinpath(folvar,"img");

    @debug "$(Dates.now()) - Creating relevant subdirectories for data downloading, temporary storage, analysis and image creation."
    if !isdir(folraw);
        @debug "$(Dates.now()) - Creating folder for downloaded raw data: $(folraw)";
        for yr = yrbeg : yrend; mkpath(joinpath(folraw,"$(yr)")); end
    end
    if !isdir(folana);
        @debug "$(Dates.now()) - Creating folder for data analysis ouput: $(folana)"; mkpath(folana)
    end
    if !isdir(folimg);
        @debug "$(Dates.now()) - Creating folder for data images: $(folimg)"; mkpath(folimg)
    end
    if emod["actionID"] == 1 && !isdir(foltmp);
        @debug "$(Dates.now()) - Creating folder for temporary data storage: $(foltmp)";
        mkpath(foltmp)
    end

    return Dict("reg"=>folreg,"var"=>folvar,"raw"=>folraw,
                "tmp"=>foltmp,"ana"=>folana,"img"=>folimg);

end

function erafolder(emod::Dict,epar::Dict,ereg::Dict,etime::Dict,eroot::Dict,pre::Integer)

    yrbeg = etime["Begin"]; yrend = etime["End"];

    folreg = joinpath(eroot["era"],ereg["region"]);
    if !isdir(folreg)
        @debug "$(Dates.now()) - Creating folder for the $(ereg["name"]) region at $(folreg) ..."
        mkpath(folreg);
    else; @debug "$(Dates.now()) - The folder for the $(ereg["name"]) region $(folreg) exists."
    end

    folvar = joinpath(eroot["era"],ereg["region"],epar["ID"]);
    if !isdir(folvar)
        @debug "$(Dates.now()) - Creating variable folder for the $(epar["name"]) parameter at $(folvar) ..."
        mkpath(folvar);
    else; @debug "$(Dates.now()) - The folder for the $(epar["name"]) parameter $(folvar) exists."
    end

    if pre != "sfc"; folvar = joinpath(folvar,"$(epar["ID"])-$(pre)hPa"); end
    folraw = joinpath(folvar,"raw"); foltmp = joinpath(folvar,"tmp");
    folana = joinpath(folvar,"ana"); folimg = joinpath(folvar,"img");

    @info "$(Dates.now()) - Creating relevant subdirectories for data downloading, temporary storage, analysis and image creation."
    if !isdir(folraw);
        @debug "$(Dates.now()) - Creating folder for downloaded raw data: $(folraw)";
        for yr = yrbeg : yrend; mkpath(joinpath(folraw,"$(yr)")); end
    end
    if !isdir(folana);
        @debug "$(Dates.now()) - Creating folder for data analysis ouput: $(folana)"; mkpath(folana)
    end
    if !isdir(folimg);
        @debug "$(Dates.now()) - Creating folder for data images: $(folimg)"; mkpath(folimg)
    end
    if emod["actionID"] == 1 && !isdir(foltmp);
        @debug "$(Dates.now()) - Creating folder for temporary data storage: $(foltmp)";
        mkpath(foltmp)
    end

    return Dict("reg"=>folreg,"var"=>folvar,"raw"=>folraw,
                "tmp"=>foltmp,"ana"=>folana,"img"=>folimg);

end

# ClimateERA NetCDF Names

function erarawname(emod::Dict,epar::Dict,ereg::Dict,date::TimeType)

    if !(epar["level"] == "sfc")
          fname = "$(emod["prefix"])-$(ereg["region"])-$(epar["ID"])-$(epar["level"])hPa";
    else; fname = "$(emod["prefix"])-$(ereg["region"])-$(epar["ID"])-$(epar["level"])";
    end

    return "$(fname)-$(yrmo2str(date)).nc"

end

function eraananame(emod::Dict,epar::Dict,ereg::Dict,date::TimeType)

    prefix = replace(emod["prefix"],"era"=>"eraa")

    if !(epar["level"] == "sfc")
          fname = "$(prefix)-$(ereg["region"])-$(epar["ID"])-$(epar["level"])hPa";
    else; fname = "$(prefix)-$(ereg["region"])-$(epar["ID"])-$(epar["level"])";
    end

    return "$(fname)-$(yr2str(date)).nc"

end

function erancread(ncname::AbstractString,epar::Dict)

    ds = Dataset(ncname);
    try; return ds[epar["ID"]]; catch; return ds[epar["IDnc"]]; end
    close(ds);

end

function erancread(ncname::AbstractString,ID::AbstractString)

    ds = Dataset(ncname); return ds[ID];
    close(ds);

end

function erancread(fol::AbstractString,ncname::AbstractString,epar::Dict)

    ds = Dataset(joinpath(fol,ncname));
    try; return ds[epar["ID"]]; catch; return ds[epar["IDnc"]]; end
    close(ds);

end

function erancread(fol::AbstractString,ncname::AbstractString,ID::AbstractString)

    ds = Dataset(joinpath(fol,ncname)); return ds[ID];
    close(ds);

end
