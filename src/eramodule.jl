"""
Temporary file for setting up of ClimateERA reanalysis modules before shoving everything
into the erainitialize module.

"""

function eramoduledisp(init)

    if init["actionID"] == 1; len = 6; elseif init["actionID"] == 2; len = 4; end
    @info "$(Dates.now()) - There are $(len) types of modules that ClimateERA can $(init["action"])."

    @info "$(Dates.now()) - 1) Dry Surface Modules    (e.g. Surface Winds)"
    @info "$(Dates.now()) - 2) Dry Pressure Modules   (e.g. Winds at Pressure Height)"
    @info "$(Dates.now()) - 3) Moist Surface Modules  (e.g. Rainfall, Total Column Water)"
    @info "$(Dates.now()) - 4) Moist Pressure Modules (e.g. Humidity at Pressure Height)"

    if init["actionID"] == 2
        @info "$(Dates.now()) - 5) Calc Surface Modules   (e.g. PI)"
        @info "$(Dates.now()) - 6) Calc Pressure Modules  (e.g. Eddy Kinetic Energy, Psi)"
    end

    return len

end

function eramodule(init,moduleID)

    init["moduleID"] = moduleID; len = eramoduledisp(init["actionID"]);
    if !(moduleID in 1:len); @error "$(Dates.now()) - Module ID $(moduleID) not defined for action '$(init["action"])'."  end;

    if     moduleID == 1; init["moduletype"] = "dsfc"; init["modulename"] = "dry surface";
    elseif moduleID == 2; init["moduletype"] = "dpre"; init["modulename"] = "dry pressure";
    elseif moduleID == 3; init["moduletype"] = "msfc"; init["modulename"] = "moist surface";
    elseif moduleID == 4; init["moduletype"] = "mpre"; init["modulename"] = "moist pressure";
    elseif moduleID == 5; init["moduletype"] = "csfc"; init["modulename"] = "calc surface";
    elseif moduleID == 6; init["moduletype"] = "cpre"; init["modulename"] = "calc pressure";
    end

    if init["actionID"] == 1 && init["datasetID"] == 1
        if     moduleID in [1,3]; init["moduleprint"] = "reanalysis-era5-single-levels";
        elseif moduleID in [2,4]; init["moduleprint"] = "reanalysis-era5-pressure-levels";
        end
    end

    return init

end
