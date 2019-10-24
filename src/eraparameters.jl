"""
Temporary file for setting up of ClimateERA reanalysis parameters before shoving everything
into the erainitialize module.

"""

function eraparametersload(eramod::Dict)

    @debug "$(Dates.now()) - Loading information on parameters used in ERA reanalysis."
    allparams = readdlm(joinpath(@__DIR__,"eraparameters.txt"),',',comments=true);

    @debug "$(Dates.now()) - Filtering out for parameters in the $(eramod["name"]) module."
    parmods = allparams[:,1]; return allparams[(parmods.==eramod["type"]),:];

end

function eraparametersdisp(parlist::AbstractArray,eramod::Dict)
    @info "$(Dates.now()) - The following variables are offered in the $(eramod["name"]) module:"
    for ii = 1 : size(erapar,1); @info "$(Dates.now()) - $(ii)) $(parlist[ii,6])" end
end

# Load ECMWF Reanalysis Parameter Details

function eraparameters(parameterID::Int64,eramod::Dict)

    parlist = eraparametersload(eramod); eraparametersdisp(parlist,eramod)
    npar = size(parlist,1);

    if !(parameterID in 1:npar); @error "$(Dates.now()) - Invalid parameter choice for $(eramod["name"])."  end;

    parinfo = parlist[parameterID,:];
    @info "$(Dates.now()) - ClimateERA will $(eramod["name"]) $(parinfo[:,6]) data."
    return Dict("ID"  =>parinfo[:,2],"IDnc"=>parinfo[:,3],
                "era5"=>parinfo[:,4],"erai"=>parinfo[:,5],
                "name"=>parinfo[:,6],"unit"=>parinfo[:,7]);

end
