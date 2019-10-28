"""
This holds all the scripts that are relevant to the downloading of ECMWF reanalysis
data, which includes the following functionalities:
    - Creation of python download scripts
    - Creation of respective folders to put data in within the ClimateERA directory

"""

function eradownload(emod::Dict,epar::Dict,ereg::Dict,time::Dict,eroot::Dict)

    prelist = emod["levels"]

    for preii in prelist; epar["level"] = preii;

        fname,fID = eradscript(emod,epar,ereg,time)
        fol = erafolder(emod,epar,ereg,eroot);

    end

    @save "info_par.jld2" emod epar
    @save "info_reg.jld2" ereg

end

function erafolder(emod::Dict,epar::Dict,ereg::Dict,eroot::Dict)

    pre = epar["level"];

    folreg = joinpath(eroot["era"],ereg["region"]);
    if !isdir(folreg)
        @info "$(Dates.now()) - Creating folder for the $(ereg["name"]) region at $(folreg) ...";
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
    if !isdir(folraw); @info "$(Dates.now()) - Creating folder $(folraw)"; mkpath(folraw) end
    if !isdir(folana); @info "$(Dates.now()) - Creating folder $(folana)"; mkpath(folana) end
    if !isdir(folimg); @info "$(Dates.now()) - Creating folder $(folimg)"; mkpath(folimg) end
    if emod["actionID"] == 1
        if !isdir(foltmp); @info "$(Dates.now()) - Creating folder $(foltmp)"; mkpath(foltmp) end
    end

    return Dict("reg"=>folreg,"var"=>folvar,"raw"=>folraw,
                "tmp"=>foltmp,"ana"=>folana,"img"=>folimg);

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
