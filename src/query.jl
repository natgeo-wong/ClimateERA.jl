

function queryeaction(;parID::AbstractString="")

    if parID != ""

        allepar = readdlm(eraparametercopy(),',',comments=true);
        @info "$(Dates.now()) - Printing available actions for the given parID $(parID) ..."

        parIDs = allepar[:,2]; modIDs = allepar[:,1];
        if any(parIDs .== parID); modID = modIDs[parIDs .== parID]
            print(reset(),"$(parID) is a valid parID.  You can")
            if any(["csfc","cpre"] .== modID);
                  print(bold()," only analyse ")
            else; print(bold()," either download or analyse ")
            end
            print(reset(),"data for this variable.  If you are unsure as to how to proceed, please call the function",bold()," queryaction() ",reset(),"for more information.")
        end

    else

        @info "$(Dates.now()) - Printing basic help information for ClimateERA.jl ..."

        ftext = joinpath(@__DIR__,"../extra/actiontext.txt");
        lines = readlines(ftext); count = 0; nl = length(lines);
        for l in lines; count += 1;
           if count == nl; print(reset(),"$l\n\n");
           else;           print(reset(),"$l\n");
           end
        end

    end

end

function queryedataset()

    @info "$(Dates.now()) - The following datasets can be downloaded / manipulated with ClimateERA.jl ..."

    ftext = joinpath(@__DIR__,"../extra/datasettext.txt");
    lines = readlines(ftext); count = 0; nl = length(lines);
    for l in lines; count += 1;
       if any(count .== [1,13]); print(bold(),"$l\n");
       elseif count == nl;       print(reset(),"$l\n\n");
       else;                     print(reset(),"$l\n");
       end
    end

end

function queryemod(;modID::AbstractString="")

    mset = ["dsfc","dpre","msfc","mpre","csfc","cpre"]

    if modID != ""

        if any(mset .== modID)

            @info "$(Dates.now()) - $(uppercase(modID)) is a valid module in ClimateERA.jl.  Printing module information ...\n"

            ftext = joinpath(@__DIR__,"../extra/moduletext/$(modID).txt");
            lines = readlines(ftext); count = 0; nl = length(lines);
            for l in lines; count += 1;
               if count == 1;      print(bold(),"$l\n");
               elseif count == nl; print(reset(),"$l\n\n");
               else;               print(reset(),"$l\n");
               end
            end

        else
            @warn "$(Dates.now()) - $(uppercase(modID)) is not a valid module in ClimateERA.jl.  Please query a valid module."
        end

    else

        @info "$(Dates.now()) - The following are the modules available in ClimateERA.jl ...\n"

        for modID in mset
            ftext = joinpath(@__DIR__,"../extra/moduletext/$(modID).txt");
            lines = readlines(ftext); count = 0; nl = length(lines);
            for l in lines; count += 1;
               if count == 1;      print(bold(),"$l\n");
               elseif count == nl; print(reset(),"$l\n\n");
               else;               print(reset(),"$l\n");
               end
            end
        end

    end

end

function queryepar(;parID::AbstractString="",modID::AbstractString="")

    if parID=="" & modID==""; queryeparlist()
    elseif parID=="";         queryeparlist(modID);
    elseif modID=="";         queryeparinfo(parID);
    else;                     queryeparmod(parID,modID);
    end
end

function queryeparinfo(parID::AbstractString)

    allepar = readdlm(eraparametercopy(),',',comments=true);

    parIDs = allepar[:,2]
    if any(parIDs .== parID); parinfo = allepar[parIDs .== parID,:];

        @info "$(Dates.now()) - $(parID) is defined.  Printing variable information ...\n"

        print("    - ",bold(),"Full Name: ",reset(),"$(parinfo[:,6][1])\n");
        print("    - ",bold(),"Units: ",reset(),"$(parinfo[:,7][1])\n");
        print("    - ",bold(),"Module ID: ",reset(),"$(parinfo[:,1][1])\n");
        print("    - ",bold(),"ERA5 ID: ",reset(),"$(parinfo[:,4][1])\n");
        print("    - ",bold(),"ERA-Interim ID: ",reset(),"$(parinfo[:,5][1])\n\n");

    else

        @warn "$(Dates.now()) - $(parID) is not currently defined.  You may add it using the function addepar()."

    end

end

function queryeparmod(parID::AbstractString, modID::AbstractString)

    allepar = readdlm(eraparametercopy(),',',comments=true);

    parIDs = allepar[:,2]
    if any(parIDs .== parID); pmodID = allepar[parIDs .== parID,1][1];

        if pmodID == modID
              @info "$(Dates.now()) - $(parID) is a variable found in $(uppercase(modID))."
        else; @warn "$(Dates.now()) - $(uppercase(modID)) does not contain $(parID)."
        end

    else

        @warn "$(Dates.now()) - $(parID) is not currently defined.  You may add it using the function addepar()."

    end

end

function queryeparlist(modID::AbstractString)

    allepar = readdlm(eraparametercopy(),',',comments=true);
    mset = ["dsfc","dpre","msfc","mpre","csfc","cpre"]
    if any(mset .== modID)

        @info "$(Dates.now()) - $(uppercase(modID)) is a valid module in ClimateERA.jl.  Retrieving parameter information table ...\n"



    else
        @warn "$(Dates.now()) - $(uppercase(modID)) is not a valid module in ClimateERA.jl.  Please query a valid module."
    end

end

## Query ERA Dataset Timestep

hrstep(emod::Dict) = if emod["datasetID"] == 1; return 1; else; return 6 end
hrindy(emod::Dict) = if emod["datasetID"] == 1; return 24; else; return 4 end
