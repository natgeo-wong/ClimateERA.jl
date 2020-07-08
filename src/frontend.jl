"""
This file istarts the ClimateERA module by creating the root directory and by
specifying whether the data is to be downloaded or analyzed.  Functionalities
include:
    - Creation of root directory
    - Specifying whether purpose is to download or analyse data

"""

## ClimateERA Folders

function eraregfolder(ereg::Dict,eroot::Dict)

    fol = joinpath(eroot["era"],ereg["fol"]);

    if !isdir(fol)
        @info "$(Dates.now()) - The folder for the $(ereg["name"]) region at does not exist.  Creating now ..."
        mkpath(fol);
    end

    return fol

end

function eravarfolder(epar::Dict,ereg::Dict,eroot::Dict)

    fol = joinpath(eroot["era"],ereg["fol"],epar["ID"]);

    if !isdir(fol)
        @info "$(Dates.now()) - The folder for the $(epar["name"]) parameter in the $(ereg["name"]) region does not exist.  Creating now ..."
        mkpath(fol);
    end

    return fol

end

function erarawfolder(epar::Dict,ereg::Dict,eroot::Dict)

    if !haskey(epar,"level")

        fol = joinpath(eroot["era"],ereg["fol"],epar["ID"],"raw");
        if !isdir(fol)
            @info "$(Dates.now()) - The folder for raw data of the $(epar["name"]) parameter in the $(ereg["name"]) region does not exist.  Creating now ..."
            mkpath(fol);
        end

    else

        if epar["level"] == "sfc";

            fol = joinpath(eroot["era"],ereg["fol"],epar["ID"],"raw");
            if !isdir(fol)
                @info "$(Dates.now()) - The folder for raw data of the $(epar["name"]) parameter in the $(ereg["name"]) region does not exist.  Creating now ..."
                mkpath(fol);
            end

        else

            phPa = "$(epar["ID"])-$(epar["level"])hPa"
            fol = joinpath(eroot["era"],ereg["fol"],epar["ID"],phPa,"raw");
            if !isdir(fol)
                @info "$(Dates.now()) - The folder for raw data of the $(epar["name"]) parameter at pressure level $(epar["level"])hPa in the $(ereg["name"]) region does not exist.  Creating now ..."
                mkpath(fol);
            end
        end

    end

    return fol

end

function erarawfolder(epar::Dict,ereg::Dict,eroot::Dict,date::TimeType)

    yr = "$(yr2str(date))";

    if epar["level"] == "sfc";

        fol = joinpath(eroot["era"],ereg["fol"],epar["ID"],"raw",yr);
        if !isdir(fol)
            @info "$(Dates.now()) - The folder for raw data of the $(epar["name"]) parameter in the $(ereg["name"]) region does not exist.  Creating now ..."
            mkpath(fol);
        end

    else

        phPa = "$(epar["ID"])-$(epar["level"])hPa"
        fol = joinpath(eroot["era"],ereg["fol"],epar["ID"],phPa,"raw",yr);
        if !isdir(fol)
            @info "$(Dates.now()) - The folder for raw data of the $(epar["name"]) parameter at pressure level $(epar["level"])hPa in the $(ereg["name"]) region does not exist.  Creating now ..."
            mkpath(fol);
        end

    end

    return fol

end

function eraanafolder(epar::Dict,ereg::Dict,eroot::Dict)

    if epar["level"] == "sfc";

        fol = joinpath(eroot["era"],ereg["fol"],epar["ID"],"ana");
        if !isdir(fol)
            @info "$(Dates.now()) - The folder for analyzed data of the $(epar["name"]) parameter in the $(ereg["name"]) region does not exist.  Creating now ..."
            mkpath(fol);
        end

    else

        phPa = "$(epar["ID"])-$(epar["level"])hPa"
        fol = joinpath(eroot["era"],ereg["fol"],epar["ID"],phPa,"ana");
        if !isdir(fol)
            @info "$(Dates.now()) - The folder for analyzed data of the $(epar["name"]) parameter at pressure level $(epar["level"])hPa in the $(ereg["name"]) region does not exist.  Creating now ..."
            mkpath(fol);
        end

    end

    return fol

end

function eraimgfolder(epar::Dict,ereg::Dict,eroot::Dict)

    if epar["level"] == "sfc";

        fol = joinpath(eroot["era"],ereg["fol"],epar["ID"],"img");
        if !isdir(fol)
            @info "$(Dates.now()) - The folder for images/maps of the $(epar["name"]) parameter in the $(ereg["name"]) region does not exist.  Creating now ..."
            mkpath(fol);
        end

    else

        phPa = "$(epar["ID"])-$(epar["level"])hPa"
        fol = joinpath(eroot["era"],ereg["fol"],epar["ID"],phPa,"img");
        if !isdir(fol)
            @info "$(Dates.now()) - The folder for images/maps of the $(epar["name"]) parameter at pressure level $(epar["level"])hPa in the $(ereg["name"]) region does not exist.  Creating now ..."
            mkpath(fol);
        end

    end

    return fol

end

## ClimateERA Folder Setup

function erafolder(emod::Dict,epar::Dict,ereg::Dict,etime::Dict,eroot::Dict)

    yrbeg = etime["Begin"]; yrend = etime["End"];

    folreg = joinpath(eroot["era"],ereg["fol"]);
    if !isdir(folreg)
        @debug "$(Dates.now()) - Creating folder for the $(ereg["name"]) region at $(folreg) ..."
        mkpath(folreg);
    else; @debug "$(Dates.now()) - The folder for the $(ereg["name"]) region $(folreg) exists."
    end

    folvar = joinpath(eroot["era"],ereg["fol"],epar["ID"]);
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

    return Dict(
        "reg"=>folreg,"var"=>folvar,"raw"=>folraw,
        "tmp"=>foltmp,"ana"=>folana,"img"=>folimg
    );

end

function erafolder(emod::Dict,epar::Dict,ereg::Dict,etime::Dict,eroot::Dict,pre)

    yrbeg = etime["Begin"]; yrend = etime["End"];

    folreg = joinpath(eroot["era"],ereg["fol"]);
    if !isdir(folreg)
        @debug "$(Dates.now()) - Creating folder for the $(ereg["name"]) region at $(folreg) ..."
        mkpath(folreg);
    else; @debug "$(Dates.now()) - The folder for the $(ereg["name"]) region $(folreg) exists."
    end

    folvar = joinpath(eroot["era"],ereg["fol"],epar["ID"]);
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

    return Dict(
        "reg"=>folreg,"var"=>folvar,"raw"=>folraw,
        "tmp"=>foltmp,"ana"=>folana,"img"=>folimg
    );

end

## ClimateERA NetCDF Names

function erarawname(emod::Dict,epar::Dict,ereg::Dict,date::TimeType)

    if !(emod["levels"][1] == "sfc")
          fname = "$(emod["prefix"])-$(ereg["fol"])-$(epar["ID"])-$(epar["level"])hPa";
    else; fname = "$(emod["prefix"])-$(ereg["fol"])-$(epar["ID"])-sfc";
    end

    return "$(fname)-$(yrmo2str(date)).nc"

end

function eraananame(emod::Dict,epar::Dict,ereg::Dict,date::TimeType)

    prefix = replace(emod["prefix"],"era"=>"eraa")

    if !(emod["levels"][1] == "sfc")
          fname = "$(prefix)-$(ereg["fol"])-$(epar["ID"])-$(epar["level"])hPa";
    else; fname = "$(prefix)-$(ereg["fol"])-$(epar["ID"])-sfc";
    end

    return "$(fname)-$(yr2str(date)).nc"

end

erancread(ncname::AbstractString,fol::AbstractString="") = Dataset(joinpath(fol,ncname))

function erarawread(
    emod::Dict,epar::Dict,ereg::Dict,eroot::Dict,
    date::TimeType
)

    ebase = erarawfolder(epar,ereg,eroot,date);
    enc = erarawname(emod,epar,ereg,date);
    eds = erancread(enc,ebase);
    if haskey(eds,epar["ID"]); ID = epar["ID"]; else; ID = epar["IDnc"]; end
    return eds,eds[ID]

end

function eraanaread(
    ID::AbstractString,
    emod::Dict, epar::Dict, ereg::Dict, eroot::Dict,
    date::TimeType
)

    ebase = eraanafolder(epar,ereg,eroot);
    enc = eraananame(emod,epar,ereg,date);
    eds = erancread(enc,ebase);
    return eds,eds[ID]

end

function erancoffsetscale(data::Array{<:Real})

    dmax = maximum(data); dmin = minimum(data);
    scale = (dmax-dmin) / 65533;
    offset = (dmax+dmin-scale) / 2;

    return scale,offset

end

function erarawsave(
    data::Array{<:Real,3},
    emod::Dict, epar::Dict, ereg::Dict, date::TimeType, eroot::Dict
)

    @info "$(Dates.now()) - Saving raw $(uppercase(emod["dataset"])) $(epar["name"]) data in $(gregionfullname(ereg["region"])) (Horizontal Resolution: $(ereg["step"])) for $(year(date)) $(Dates.monthname(date)) ..."

    fnc = joinpath(erarawfolder(epar,ereg,eroot,date),erarawname(emod,epar,ereg,date));
    if isfile(fnc)
        @info "$(Dates.now()) - Stale NetCDF file $(fnc) detected.  Overwriting ..."
        rm(fnc);
    end
    ds = NCDataset(fnc,"c",attrib = Dict("Conventions"=>"CF-1.6"));

    ehr = hrindy(emod); nhr = ehr * daysinmonth(date);
    scale,offset = erancoffsetscale(data);

    ds.dim["longitude"] = ereg["size"][1];
    ds.dim["latitude"] = ereg["size"][2];
    ds.dim["time"] = nhr

    nclongitude = defVar(ds,"longitude",Float32,("longitude",),attrib = Dict(
        "units"     => "degrees_east",
        "long_name" => "longitude",
    ))

    nclatitude = defVar(ds,"latitude",Float32,("latitude",),attrib = Dict(
        "units"     => "degrees_north",
        "long_name" => "latitude",
    ))

    nctime = defVar(ds,"time",Int32,("time",),attrib = Dict(
        "units"     => "hours since $(date) 00:00:00.0",
        "long_name" => "time",
        "calendar"  => "gregorian",
    ))

    ncvar = defVar(ds,epar["ID"],Int16,("longitude","latitude","time"),attrib = Dict(
        "long_name"     => epar["era5"],
        "full_name"     => epar["name"],
        "units"         => epar["unit"],
        "scale_factor"  => scale,
        "add_offset"    => offset,
        "_FillValue"    => Int16(-32767),
        "missing_value" => Int16(-32767),
    ))

    nclongitude[:] = ereg["lon"]; nclatitude[:] = ereg["lat"]
    nctime[:] = (collect(1:nhr).-1) * ehr; ncvar[:] = data;

    close(ds)

    @info "$(Dates.now()) - Raw $(uppercase(emod["dataset"])) $(epar["name"]) in $(gregionfullname(ereg["region"])) (Horizontal Resolution: $(ereg["step"])) for $(year(date)) $(Dates.monthname(date)) has been saved into $(fnc)."

end

function erasubregion!(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict, eroot::Dict,
    preg::Dict
)

    elon,elat,reginfo = gregiongridvec(ereg["fol"],preg["lon"],preg["lat"])
    ereg["lon"]  = elon
    ereg["lat"]  = elat
    ereg["step"] = preg["step"]
    ereg["size"] = [length(elon),length(elat)]

    for yr = etime["Begin"] : etime["End"], mo = 1:12

        @info "$(Dates.now()) - Extracting $(uppercase(emod["dataset"])) $(epar["name"]) data in $(gregionfullname(ereg["region"])) (Horizontal Resolution: $(ereg["step"])) from $(gregionfullname(preg["region"])) for $yr $(Dates.monthname(mo)) ..."

        date  = Date(yr,mo); nt = daysinmonth(date) * hrindy(emod)
        pdata = Array{Float32,2}(undef,preg["size"][1],preg["size"][2])
        tdata = Array{Float32,2}(undef,preg["size"][1],preg["size"][2])
        edata = Array{Float32,3}(undef,ereg["size"][1],ereg["size"][2],nt)
        pds,pvar = erarawread(emod,epar,preg,eroot,date);

        for it = 1 : nt
            pdata = pvar[:,:,it]*1;
            edata[:,:,it] .= regionextractgrid!(pdata,reginfo,tdata);
        end

        close(pds);
        erarawsave(edata,emod,epar,ereg,date,eroot);

    end

    return

end

function erasubregion(
    init::AbstractDict, eroot::AbstractDict;
    modID::AbstractString, parID::AbstractString,
    regID::AbstractString, timeID::Union{Integer,Vector}=0,
    gres::Real=0,
    pregID::AbstractString="GLB"
)

    _,_,preg,_ = erainitialize(
        init;
        modID=modID,parID=parID,regID=pregID,timeID=timeID,
        gres=gres
    );

    emod,epar,ereg,etime = erainitialize(
        init;
        modID=modID,parID=parID,regID=regID,timeID=timeID,
        gres=gres
    );

    erasubregion!(emod,epar,ereg,etime,eroot,preg)
    putinfo(emod,epar,ereg,etime,eroot);

end

function putinfo(emod::Dict,epar::Dict,ereg::Dict,etime::Dict,eroot::Dict)

    rfol = pwd(); efol = erafolder(emod,epar,ereg,etime,eroot,"sfc");

    @info "$(Dates.now()) - Saving emodule, eparameter, and GeoRegion information ..."

    cd(efol["var"]); @save "info_par.jld2" emod epar;
    cd(efol["reg"]); @save "info_reg.jld2" ereg;
    cd(rfol);

end
