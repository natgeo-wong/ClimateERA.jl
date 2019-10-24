"""
Temporary file for setting up of ClimateERA time modules before shoving everything into the
erainitialize module.

"""

function eratime(timeID::Int64,init::Dict)
    if timeID == 0; fin = Dates.year(Dates.now())-1;
        return Dict("Begin"=>1979,"End"=>fin);
        @info "$(Dates.now()) - User has chosen to $(init["action"]) $(init["dataset"]) datasets from 1979 to $(fin)."
    else
        return Dict("Begin"=>timeID,"End"=>timeID)
        @info "$(Dates.now()) - User has chosen to $(init["action"]) $(init["dataset"]) datasets in $(timeID)."
    end
end

function eratime(timeID::Array,init::Dict)
    beg = minimum(timeID); fin = maximum(timeID)
    return Dict("Begin"=>beg,"End"=>fin)
    @info "$(Dates.now()) - User has chosen to $(init["action"]) $(init["dataset"]) datasets from $(beg) to $(fin)."
end
