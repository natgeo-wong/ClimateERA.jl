

function eramkroot(eroot::AbstractString)

    eiroot = joinpath(eroot,"erai");
    if !isdir(eiroot)
        mkpath(eiroot); @info "$(Dates.now()) - Created root folder for ERA-Interim reanalysis data $(eiroot)."
    else;               @info "$(Dates.now()) - Root folder for ERA-Interim reanalysis data $(eiroot) exists."
    end

    e5root = joinpath(eroot,"era5");
    if !isdir(e5root)
        mkpath(e5root); @info "$(Dates.now()) - Created root folder for ERA5 reanalysis data $(e5root)."
    else;               @info "$(Dates.now()) - Root folder for ERA5 reanalysis data $(e5root) exists."
    end

    eproot = joinpath(eroot,"plot");
    if !isdir(eproot)
        mkpath(eproot); @info "$(Dates.now()) - Created root folder for ERA plotting data $(eproot)."
    else;               @info "$(Dates.now()) - Root folder for ERA plotting data $(eproot) exists."
    end

    return Dict("erai"=>eiroot,"era5"=>e5root,"plot"=>eproot);

end

function eraaction(actionID::Integer)
    if     actionID == 1; return Dict("ID"=>1,"name"=>"download");
    elseif actionID == 2; return Dict("ID"=>2,"name"=>"analyse");
    end
end

function eradataset(datasetID::Integer)
    if     datasetID == 1; return Dict("ID"=>1,"short"=>"era5","name"=>"ERA5");
    elseif datasetID == 2; return Dict("ID"=>2,"short"=>"erai","name"=>"ERA-Interim");
    end
end

# Startup ClimateERA

function erastartup(;
    aID::Integer,dID::Integer,
    path::AbstractString="",
    welcome::Bool=true
)

    if welcome; erawelcome(); end

    if !(aID in [1,2])
        error("$(Dates.now()) - Please input a valid action-type.  Call queryeaction() for more details.")
    end
    if !(dID in [1,2])
        error("$(Dates.now()) - Please input a valid dataset-type.  Call queryedataset() for more details.")
    end

    if path == ""; eroot = eraroot(aID); else; eroot = eraroot(path,aID); end

    if     dID == 1; eroot["era"]=eroot["era5"]; delete!(eroot,["era5","erai"]);
    elseif dID == 2; eroot["era"]=eroot["erai"]; delete!(eroot,["era5","erai"]);
    end

    action = eraaction(aID); dataset = eradataset(dID);
    @info "$(Dates.now()) - This script will $(action["name"]) $(dataset["name"]) data."
    init = Dict("actionID"=>aID,"action"=>action["name"],
                "datasetID"=>dID,"dataset"=>dataset["name"],
                "prefix"=>dataset["short"])
    
    return init,eroot

end

function erawelcome()

    ftext = joinpath(@__DIR__,"../extra/erawelcome.txt");
    lines = readlines(ftext); count = 0; nl = length(lines);
    for l in lines; count += 1;
       if any(count .== [1,2]); print(Crayon(bold=true),"$l\n");
       elseif count == nl;      print(Crayon(bold=false),"$l\n\n");
       else;                    print(Crayon(bold=false),"$l\n");
       end
    end

end
