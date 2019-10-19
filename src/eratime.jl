"""
Temporary file for setting up of ClimateERA time modules before shoving everything into the
erainitialize module.

"""

function eratime(timeID::Int64)
    if timeID == 0, return Dict("Begin"=>1979,"End"=>Dates.year(Dates.now())-1);
    else            return Dict("Begin"=>timeID,"End"=>timeID)
    end
end

function eratime(init,timeID::Array)
    return Dict("Begin"=>minimum(timeID),"End"=>maximum(timeID))
end
