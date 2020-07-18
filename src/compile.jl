

function eracompile(
    init::Dict, eroot::Dict;
    modID::AbstractString, parID::AbstractString,
    regID::AbstractString="GLB", timeID::Union{Integer,Vector}=0,
    gres::Real=0, plvls::Union{AbstractString,Integer,Vector{<:Real}}
)

    emod,epar,ereg,etime = erainitialize(
        init;
        modID=modID,parID=parID,regID=regID,timeID=timeID,
        gres=gres
    );

    if typeof(plvls) <: Array
          for p in plvls; epar["level"] = p; eracompile(emod,epar,ereg,etime,eroot); end
    else; epar["level"] = plvls; eracompile(emod,epar,ereg,etime,eroot);
    end

end

function eracompile(
    emod::AbstractDict, epar::AbstractDict, ereg::AbstractDict, etime::AbstractDict,
    eroot::AbstractDict
)

    @info "$(Dates.now()) - Preallocating arrays ..."
    nlon,nlat = ereg["size"]; nt = etime["End"] + 1 - etime["Begin"]; it = 0;
    eavg = zeros(nlon,nlat,nt); erng = zeros(nlon,nlat,nt);
    edhr = zeros(nlon,nlat,nt); eitr = zeros(nlon,nlat,nt); esea = zeros(nlon,nlat,nt);

    @info "$(Dates.now()) - Extracting preliminarily-analyzed reanalysis data ..."
    for yr = etime["Begin"] : etime["End"]; it = it + 1;

        eds,evar = eraanaread(
            "domain_yearly_mean_climatology",
            emod,epar,ereg,eroot,Date(yr)
        )
        eavg[:,:,it] = evar[:]
        close(eds)

        ds1,emax = eraanaread(
            "domain_yearly_maximum_climatology",
            emod,epar,ereg,eroot,Date(yr)
        )
        ds2,emin = eraanaread(
            "domain_yearly_minimum_climatology",
            emod,epar,ereg,eroot,Date(yr)
        )
        erng[:,:,it] = emax[:] .- emin[:]
        close(ds1); close(ds2)

        eds,evar = eraanaread(
            "domain_monthly_mean_climatology",
            emod,epar,ereg,eroot,Date(yr)
        )
        esea[:,:,it] = maximum(evar[:],dims=3) .- minimum(evar[:],dims=3)
        close(eds)

        ds1,emax = eraanaread(
            "domain_monthly_maximum_climatology",
            emod,epar,ereg,eroot,Date(yr)
        )
        ds2,emin = eraanaread(
            "domain_monthly_minimum_climatology",
            emod,epar,ereg,eroot,Date(yr)
        )
        eitr[:,:,it] = mean(emax[:] .- emin[:],dims=3)
        close(ds1); close(ds2)

        eds,evar = eraanaread(
            "domain_yearly_mean_diurnalvariance",
            emod,epar,ereg,eroot,Date(yr)
        )
        edhr[:,:,it] = evar[:]
        close(eds)

        erng[:,:,it] = erng[:,:,it] .- (esea[:,:,it] .+ eitr[:,:,it])

    end

    @info "$(Dates.now()) - Calculating yearly mean, and diurnal, seasonal and interannual variability ..."
    eian = dropdims(maximum(eavg,dims=3) .- minimum(eavg,dims=3),dims=3)
    eavg = dropdims(mean(eavg,dims=3),dims=3); eitr = dropdims(mean(eitr,dims=3),dims=3);
    esea = dropdims(mean(esea,dims=3),dims=3); edhr = dropdims(mean(edhr,dims=3),dims=3)
    
    eracmpsave(eavg,edhr,eitr,esea,eian,emod,epar,ereg,eroot)

end

function eracmpsave(
    eavg::Array{<:Real,2}, edhr::Array{<:Real,2},
    eitr::Array{<:Real,2}, esea::Array{<:Real,2}, eian::Array{<:Real,2},
    emod::Dict, epar::Dict, ereg::Dict, eroot::Dict
)

    @info "$(Dates.now()) - Saving compiled $(uppercase(emod["dataset"])) $(epar["name"]) data in $(gregionfullname(ereg["region"])) (Horizontal Resolution: $(ereg["step"])) for the year $yr ..."

    cfol = eraanafolder(epar,ereg,eroot); fcmp = eracmpname(emod,epar,ereg);
    cfnc = joinpath(cfol,fcmp);

    if isfile(cfnc)
        @info "$(Dates.now()) - Stale NetCDF file $(cfnc) detected.  Overwriting ..."
        rm(cfnc);
    end

    @debug "$(Dates.now()) - Creating NetCDF file $(afnc) for compiled $(emod["dataset"]) $(epar["name"]) data ..."

    ds = Dataset(cfnc,"c");
    ds.dim["longitude"] = ereg["size"][1]
    ds.dim["latitude"]  = ereg["size"][2]

    nclon = defVar(ds,"longitude",Float64,("longitude",),attrib = Dict(
        "units"     => "degrees_east",
        "long_name" => "longitude",
    ))

    nclat = defVar(ds,"latitude",Float64,("latitude",),attrib = Dict(
        "units"     => "degrees_north",
        "long_name" => "latitude",
    ))

    nclon[:] = ereg["lon"];
    nclat[:] = ereg["lat"];

    ncavg = defVar(ds,"average",Float32,("longitude","latitude"),
        attrib = Dict(
            "long_name" => epar["era5"],
            "full_name" => epar["name"],
            "units"     => epar["unit"],
            "level"     => epar["level"],
    ))

    ncian = defVar(ds,"variability_interannual",Float32,("longitude","latitude"),
        attrib = Dict(
            "long_name" => epar["era5"],
            "full_name" => epar["name"],
            "units"     => epar["unit"],
            "level"     => epar["level"],
    ))

    ncsea = defVar(ds,"variability_seasonal",Float32,("longitude","latitude"),
        attrib = Dict(
            "long_name" => epar["era5"],
            "full_name" => epar["name"],
            "units"     => epar["unit"],
            "level"     => epar["level"],
    ))

    ncitr = defVar(ds,"variability_intraseasonal",Float32,("longitude","latitude"),
        attrib = Dict(
            "long_name" => epar["era5"],
            "full_name" => epar["name"],
            "units"     => epar["unit"],
            "level"     => epar["level"],
    ))

    ncdhr = defVar(ds,"variability_diurnal",Float32,("longitude","latitude"),
        attrib = Dict(
            "long_name" => epar["era5"],
            "full_name" => epar["name"],
            "units"     => epar["unit"],
            "level"     => epar["level"],
    ))

    ncavg[:] = eavg; ncian[:] = eian; ncsea[:] = esea; ncitr[:] = eitr; ncdhr[:] = edhr

    @info "$(Dates.now()) - Compiled $(uppercase(emod["dataset"])) $(epar["name"]) for the year $yr in $(gregionfullname(ereg["region"])) (Horizontal Resolution: $(ereg["step"])) has been saved into file $(cfnc) and moved to the data directory $(cfol)."

end
