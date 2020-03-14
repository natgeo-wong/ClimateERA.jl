function queryeaction()

    @info "$(Dates.now()) - The following actions are possible in ClimateERA.jl ..."
    act = [1 "Download" ; 2 "Analysis"]; head = ["aID","Action"];
    pretty_table(act,head;alignment=:c)

end

function queryedataset()

    @info "$(Dates.now()) - The following ECMWF datasets can be manipulated with ClimateERA.jl ..."
    dset = [1 "ERA5" ; 2 "ERA-Interim"]; head = ["dID","Dataset"];
    pretty_table(dset,head;alignment=:c)

end

function queryemodule()

    @info "$(Dates.now()) - The following modules are available in ClimateERA.jl ..."
    mset = [ "dsfc" "."^10 "dry" "surface";
             "dpre" "."^10 "dry" "pressure";
             "msfc" "."^10 "moist / water" "surface" ;
             "mpre" "."^10 "moist / water" "pressure" ;
             "csfc" "."^10 "calculated" "surface" ;
             "cpre" "."^10 "calculated" "pressure" ];
    head = ["modID","","variable type","level(s)"];
    pretty_table(mset,head;tf=borderless,alignment=:c)

end

function queryemodule(moduleID::AbstractString)

    @info "$(Dates.now()) - The following modules are available in ClimateERA.jl ..."
    mset = [ "dsfc" "dry" "surface";
             "dpre" "dry" "pressure";
             "msfc" "moist / water" "surface" ;
             "mpre" "moist / water" "pressure" ;
             "csfc" "calculated" "surface" ;
             "cpre" "calculated" "pressure" ];
    head = ["modID","variable type","level(s)"];
    pretty_table(mset,head;alignment=:c)

end

function queryeparameter(parameterID::AbstractString)

    allparams = readdlm(joinpath(@__DIR__,"eraparameters.txt"),',',comments=true);

end

function queryeparameter(parameterID::AbstractString, moduleID::AbstractString)

end
