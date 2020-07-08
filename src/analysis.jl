"""
This file initializes the ClimateERA module by setting and determining the
ECMWF reanalysis parameters to be analyzed and the regions upon which the data
are to be extracted from.  Functionalities include:
    - Setting up of reanalysis module type
    - Setting up of reanalysis parameters to be analyzed
    - Setting up of time steps upon which data are to be downloaded
    - Setting up of region of analysis based on ClimateEasy

"""

function erananmean(data)
    dataii = @view data[.!isnan.(data)]
    if dataii != []; return mean(dataii); else; return NaN; end
end

function eraanalysis(
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
          for p in plvls; epar["level"] = p; eraanalysis(emod,epar,ereg,etime,eroot); end
    else; epar["level"] = plvls; eraanalysis(emod,epar,ereg,etime,eroot);
    end

end

function eraanalysis(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict, eroot::Dict
)

    for yr = etime["Begin"] : etime["End"]; eraanalysis(emod,epar,ereg,yr,eroot); end

end

function eraanalysis(
    emod::Dict, epar::Dict, ereg::Dict,
    yr::Integer, eroot::Dict
)

    nhr = hrindy(emod); nlon = ereg["size"][1]; nlat = ereg["size"][2]; nt = nhr+1;

    @info "$(Dates.now()) - Preallocating arrays ..."

    davg = zeros(Float32,nlon,nlat,nt+1,13); dstd = zeros(Float32,nlon,nlat,nt+1,13);
    dmax = zeros(Float32,nlon,nlat,nt+1,13); dmin = zeros(Float32,nlon,nlat,nt+1,13);

    zavg = zeros(Float32,nlat,nt+1,13); zstd = zeros(Float32,nlat,nt+1,13);
    zmax = zeros(Float32,nlat,nt+1,13); zmin = zeros(Float32,nlat,nt+1,13);

    mavg = zeros(Float32,nlon,nt+1,13); mstd = zeros(Float32,nlon,nt+1,13);
    mmax = zeros(Float32,nlon,nt+1,13); mmin = zeros(Float32,nlon,nt+1,13);

    for mo = 1 : 12; ndy = daysinmonth(yr,mo)

        @info "$(Dates.now()) - Analyzing $(uppercase(emod["dataset"])) $(epar["name"]) data in $(gregionfullname(ereg["region"])) (Horizontal Resolution: $(ereg["step"])) during $(Dates.monthname(mo)) $yr ..."

        rds,rvar = erarawread(emod,epar,ereg,eroot,Date(yr,mo));
        raw = rvar[:]*1; close(rds); raw[ismissing.(raw)] .= NaN;
        raw = reshape(Float32.(raw),nlon,nlat,(nt-1),ndy);

        @debug "$(Dates.now()) - Extracting hourly information for each month ..."
        davg[:,:,1:nt-1,mo] = mean(raw,dims=4);
        dstd[:,:,1:nt-1,mo] = std(raw,dims=4);
        dmax[:,:,1:nt-1,mo] = maximum(raw,dims=4);
        dmin[:,:,1:nt-1,mo] = minimum(raw,dims=4);

        @debug "$(Dates.now()) - Permuting days and hours dimensions ..."
        raw = permutedims(raw,(1,2,4,3)); dmn = mean(raw,dims=4);
        drg = maximum(raw,dims=4)/2 - minimum(raw,dims=4)/2;

        @debug "$(Dates.now()) - Extracting information on monthly climatology ..."
        davg[:,:,nt,mo] = mean(dmn,dims=3);
        dstd[:,:,nt,mo] = std(dmn,dims=3);
        dmax[:,:,nt,mo] = maximum(dmn,dims=3);
        dmin[:,:,nt,mo] = minimum(dmn,dims=3);

        @debug "$(Dates.now()) - Extractinginformation on monthly diurnal variability ..."
        davg[:,:,nt+1,mo] = mean(drg,dims=3);
        dstd[:,:,nt+1,mo] = std(drg,dims=3);
        dmax[:,:,nt+1,mo] = maximum(drg,dims=3);
        dmin[:,:,nt+1,mo] = minimum(drg,dims=3);

    end

    @info "$(Dates.now()) - Calculating yearly climatology for $(uppercase(emod["dataset"])) $(epar["name"]) data in $(gregionfullname(ereg["region"])) (Horizontal Resolution: $(ereg["step"])) during $yr ..."
    davg[:,:,:,end] = mean(davg[:,:,:,1:12],dims=4);
    dstd[:,:,:,end] = mean(dstd[:,:,:,1:12],dims=4);
    dmax[:,:,:,end] = maximum(dmax[:,:,:,1:12],dims=4);
    dmin[:,:,:,end] = minimum(dmin[:,:,:,1:12],dims=4);

    @info "$(Dates.now()) - Calculating zonal-averaged climatology for $(uppercase(emod["dataset"])) $(epar["name"]) data in $(gregionfullname(ereg["region"])) (Horizontal Resolution: $(ereg["step"])) during $yr ..."
    for ilat = 1 : nlat, it = 1 : nt+1, imo = 1 : 13
        zavg[ilat,it,imo] = erananmean(@view davg[:,ilat,it,imo]);
        zstd[ilat,it,imo] = erananmean(@view dstd[:,ilat,it,imo]);
        zmax[ilat,it,imo] = erananmean(@view dmax[:,ilat,it,imo]);
        zmin[ilat,it,imo] = erananmean(@view dmin[:,ilat,it,imo]);
    end

    @info "$(Dates.now()) - Calculating meridional-averaged climatology for $(uppercase(emod["dataset"])) $(epar["name"]) data in $(gregionfullname(ereg["region"])) (Horizontal Resolution: $(ereg["step"])) during $yr ..."
    for imo = 1 : 13, it = 1 : nt+1, ilon = 1 : nlon;
        mavg[ilon,it,imo] = erananmean(@view davg[ilon,:,it,imo]);
        mstd[ilon,it,imo] = erananmean(@view dstd[ilon,:,it,imo]);
        mmax[ilon,it,imo] = erananmean(@view dmax[ilon,:,it,imo]);
        mmin[ilon,it,imo] = erananmean(@view dmin[ilon,:,it,imo]);
    end

    eraanasave([davg,dstd,dmax,dmin],[zavg,zstd,zmax,zmin],[mavg,mstd,mmax,mmin],
               emod,epar,ereg,yr,eroot)

end

function eraanasave(
    data::Array{Array{Float32,4},1},
    zdata::Array{Array{Float32,3},1},
    mdata::Array{Array{Float32,3},1},
    emod::Dict, epar::Dict, ereg::Dict,
    yr::Integer, eroot::Dict
)

    @info "$(Dates.now()) - Saving analysed $(uppercase(emod["dataset"])) $(epar["name"]) data in $(gregionfullname(ereg["region"])) (Horizontal Resolution: $(ereg["step"])) for the year $yr ..."

    afol = eraanafolder(epar,ereg,eroot); fana = eraananame(emod,epar,ereg,Date(yr));
    afnc = joinpath(afol,fana);

    if isfile(afnc)
        @info "$(Dates.now()) - Stale NetCDF file $(afnc) detected.  Overwriting ..."
        rm(afnc);
    end

    @debug "$(Dates.now()) - Creating NetCDF file $(afnc) for analyzed $(emod["dataset"]) $(epar["name"]) data in $yr ..."

    ds = Dataset(afnc,"c"); nt = hrindy(emod);
    ds.dim["longitude"] = ereg["size"][1];
    ds.dim["latitude"] = ereg["size"][2];
    ds.dim["hour"] = nt;
    ds.dim["month"] = 12;

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

    attr_var = Dict(
        "long_name" => epar["era5"],
        "full_name" => epar["name"],
        "units"     => epar["unit"],
        "level"     => epar["level"],
    );

    @debug "$(Dates.now()) - Saving analyzed $(uppercase(emod["dataset"])) $(epar["name"]) data for $yr to NetCDF file $(afnc) ..."

    v = defVar(ds,"domain_yearly_mean_climatology",Float32,
               ("longitude","latitude"),attrib=attr_var);
    v[:] = data[1][:,:,nt+1,end];

    v = defVar(ds,"domain_yearly_std_climatology",Float32,
               ("longitude","latitude"),attrib=attr_var);
    v[:] = data[2][:,:,nt+1,end];

    v = defVar(ds,"domain_yearly_maximum_climatology",Float32,
               ("longitude","latitude"),attrib=attr_var);
    v[:] = data[3][:,:,nt+1,end];

    v = defVar(ds,"domain_yearly_minimum_climatology",Float32,
               ("longitude","latitude"),attrib=attr_var);
    v[:] = data[4][:,:,nt+1,end];


    v = defVar(ds,"domain_yearly_mean_hourly",Float32,
               ("longitude","latitude","hour"),attrib=attr_var);
    v[:] = data[1][:,:,1:nt,end];

    v = defVar(ds,"domain_yearly_std_hourly",Float32,
           ("longitude","latitude","hour"),attrib=attr_var);
    v[:] = data[2][:,:,1:nt,end];

    v = defVar(ds,"domain_yearly_maximum_hourly",Float32,
               ("longitude","latitude","hour"),attrib=attr_var);
    v[:] = data[3][:,:,1:nt,end];

    v = defVar(ds,"domain_yearly_minimum_hourly",Float32,
               ("longitude","latitude","hour"),attrib=attr_var);
    v[:] = data[4][:,:,1:nt,end];


    v = defVar(ds,"domain_yearly_mean_diurnalvariance",Float32,
           ("longitude","latitude"),attrib=attr_var);
    v[:] = data[1][:,:,nt+2,end];

    v = defVar(ds,"domain_yearly_std_diurnalvariance",Float32,
               ("longitude","latitude"),attrib=attr_var);
    v[:] = data[2][:,:,nt+2,end];

    v = defVar(ds,"domain_yearly_maximum_diurnalvariance",Float32,
               ("longitude","latitude"),attrib=attr_var);
    v[:] = data[3][:,:,nt+2,end];

    v = defVar(ds,"domain_yearly_minimum_diurnalvariance",Float32,
           ("longitude","latitude"),attrib=attr_var);
    v[:] = data[4][:,:,nt+2,end];


    v = defVar(ds,"domain_monthly_mean_climatology",Float32,
               ("longitude","latitude","month"),attrib=attr_var);
    v[:] = data[1][:,:,nt+1,1:12];

    v = defVar(ds,"domain_monthly_std_climatology",Float32,
               ("longitude","latitude","month"),attrib=attr_var);
    v[:] = data[2][:,:,nt+1,1:12];

    v = defVar(ds,"domain_monthly_maximum_climatology",Float32,
               ("longitude","latitude","month"),attrib=attr_var);
    v[:] = data[3][:,:,nt+1,1:12];

    v = defVar(ds,"domain_monthly_minimum_climatology",Float32,
               ("longitude","latitude","month"),attrib=attr_var);
    v[:] = data[4][:,:,nt+1,1:12];


    v = defVar(ds,"domain_monthly_mean_hourly",Float32,
               ("longitude","latitude","hour","month"),attrib=attr_var);
    v[:] = data[1][:,:,1:nt,1:12];

    v = defVar(ds,"domain_monthly_std_hourly",Float32,
               ("longitude","latitude","hour","month"),attrib=attr_var);
    v[:] = data[2][:,:,1:nt,1:12];

    v = defVar(ds,"domain_monthly_maximum_hourly",Float32,
               ("longitude","latitude","hour","month"),attrib=attr_var);
    v[:] = data[3][:,:,1:nt,1:12];

    v = defVar(ds,"domain_monthly_minimum_hourly",Float32,
               ("longitude","latitude","hour","month"),attrib=attr_var);
    v[:] = data[4][:,:,1:nt,1:12];


    v = defVar(ds,"domain_monthly_mean_diurnalvariance",Float32,
               ("longitude","latitude","month"),attrib=attr_var);
    v[:] = data[1][:,:,nt+2,1:12];

    v = defVar(ds,"domain_monthly_std_diurnalvariance",Float32,
               ("longitude","latitude","month"),attrib=attr_var);
    v[:] = data[2][:,:,nt+2,1:12];

    v = defVar(ds,"domain_monthly_maximum_diurnalvariance",Float32,
               ("longitude","latitude","month"),attrib=attr_var);
    v[:] = data[3][:,:,nt+2,1:12];

    v = defVar(ds,"domain_monthly_minimum_diurnalvariance",Float32,
               ("longitude","latitude","month"),attrib=attr_var);
    v[:] = data[4][:,:,nt+2,1:12];


    v = defVar(ds,"zonalavg_yearly_mean_climatology",Float32,
               ("latitude",),attrib=attr_var);
    v[:] = zdata[1][:,nt+1,end];

    v = defVar(ds,"zonalavg_yearly_std_climatology",Float32,
               ("latitude",),attrib=attr_var);
    v[:] = zdata[2][:,nt+1,end];

    v = defVar(ds,"zonalavg_yearly_maximum_climatology",Float32,
               ("latitude",),attrib=attr_var);
    v[:] = zdata[3][:,nt+1,end];

    v = defVar(ds,"zonalavg_yearly_minimum_climatology",Float32,
               ("latitude",),attrib=attr_var);
    v[:] = zdata[4][:,nt+1,end];


    v = defVar(ds,"zonalavg_yearly_mean_hourly",Float32,
               ("latitude","hour"),attrib=attr_var);
    v[:] = zdata[1][:,1:nt,end];

    v = defVar(ds,"zonalavg_yearly_std_hourly",Float32,
               ("latitude","hour"),attrib=attr_var);
    v[:] = zdata[2][:,1:nt,end];

    v = defVar(ds,"zonalavg_yearly_maximum_hourly",Float32,
               ("latitude","hour"),attrib=attr_var);
    v[:] = zdata[3][:,1:nt,end];

    v = defVar(ds,"zonalavg_yearly_minimum_hourly",Float32,
               ("latitude","hour"),attrib=attr_var);
    v[:] = zdata[4][:,1:nt,end];


    v = defVar(ds,"zonalavg_yearly_mean_diurnalvariance",Float32,
               ("latitude",),attrib=attr_var);
    v[:] = zdata[1][:,nt+2,end];

    v = defVar(ds,"zonalavg_yearly_std_diurnalvariance",Float32,
               ("latitude",),attrib=attr_var);
    v[:] = zdata[2][:,nt+2,end];

    v = defVar(ds,"zonalavg_yearly_maximum_diurnalvariance",Float32,
               ("latitude",),attrib=attr_var);
    v[:] = zdata[3][:,nt+2,end];

    v = defVar(ds,"zonalavg_yearly_minimum_diurnalvariance",Float32,
               ("latitude",),attrib=attr_var);
    v[:] = zdata[4][:,nt+2,end];


    v = defVar(ds,"zonalavg_monthly_mean_climatology",Float32,
               ("latitude","month"),attrib=attr_var);
    v[:] = zdata[1][:,nt+1,1:12];

    v = defVar(ds,"zonalavg_monthly_std_climatology",Float32,
               ("latitude","month"),attrib=attr_var);
    v[:] = zdata[2][:,nt+1,1:12];

    v = defVar(ds,"zonalavg_monthly_maximum_climatology",Float32,
               ("latitude","month"),attrib=attr_var);
    v[:] = zdata[3][:,nt+1,1:12];

    v = defVar(ds,"zonalavg_monthly_minimum_climatology",Float32,
               ("latitude","month"),attrib=attr_var);
    v[:] = zdata[4][:,nt+1,1:12];


    v = defVar(ds,"zonalavg_monthly_mean_hourly",Float32,
               ("latitude","hour","month"),attrib=attr_var);
    v[:] = zdata[1][:,1:nt,1:12];

    v = defVar(ds,"zonalavg_monthly_std_hourly",Float32,
               ("latitude","hour","month"),attrib=attr_var);
    v[:] = zdata[2][:,1:nt,1:12];

    v = defVar(ds,"zonalavg_monthly_maximum_hourly",Float32,
               ("latitude","hour","month"),attrib=attr_var);
    v[:] = zdata[3][:,1:nt,1:12];

    v = defVar(ds,"zonalavg_monthly_minimum_hourly",Float32,
               ("latitude","hour","month"),attrib=attr_var);
    v[:] = zdata[4][:,1:nt,1:12];


    v = defVar(ds,"zonalavg_monthly_mean_diurnalvariance",Float32,
               ("latitude","month"),attrib=attr_var);
    v[:] = zdata[1][:,nt+2,1:12];

    v = defVar(ds,"zonalavg_monthly_std_diurnalvariance",Float32,
               ("latitude","month"),attrib=attr_var);
    v[:] = zdata[2][:,nt+2,1:12];

    v = defVar(ds,"zonalavg_monthly_maximum_diurnalvariance",Float32,
               ("latitude","month"),attrib=attr_var);
    v[:] = zdata[3][:,nt+2,1:12];

    v = defVar(ds,"zonalavg_monthly_minimum_diurnalvariance",Float32,
               ("latitude","month"),attrib=attr_var);
    v[:] = zdata[4][:,nt+2,1:12];


    v = defVar(ds,"meridionalavg_yearly_mean_climatology",Float32,
               ("longitude",),attrib=attr_var);
    v[:] = mdata[1][:,nt+1,end];

    v = defVar(ds,"meridionalavg_yearly_std_climatology",Float32,
               ("longitude",),attrib=attr_var);
    v[:] = mdata[2][:,nt+1,end];

    v = defVar(ds,"meridionalavg_yearly_maximum_climatology",Float32,
               ("longitude",),attrib=attr_var);
    v[:] = mdata[3][:,nt+1,end];

    v = defVar(ds,"meridionalavg_yearly_minimum_climatology",Float32,
               ("longitude",),attrib=attr_var);
    v[:] = mdata[4][:,nt+1,end];


    v = defVar(ds,"meridionalavg_yearly_mean_hourly",Float32,
               ("longitude","hour"),attrib=attr_var);
    v[:] = mdata[1][:,1:nt,end];

    v = defVar(ds,"meridionalavg_yearly_std_hourly",Float32,
               ("longitude","hour"),attrib=attr_var);
    v[:] = mdata[2][:,1:nt,end];

    v = defVar(ds,"meridionalavg_yearly_maximum_hourly",Float32,
               ("longitude","hour"),attrib=attr_var);
    v[:] = mdata[3][:,1:nt,end];

    v = defVar(ds,"meridionalavg_yearly_minimum_hourly",Float32,
               ("longitude","hour"),attrib=attr_var);
    v[:] = mdata[4][:,1:nt,end];


    v = defVar(ds,"meridionalavg_yearly_mean_diurnalvariance",Float32,
               ("longitude",),attrib=attr_var);
    v[:] = mdata[1][:,nt+2,end];

    v = defVar(ds,"meridionalavg_yearly_std_diurnalvariance",Float32,
               ("longitude",),attrib=attr_var);
    v[:] = mdata[2][:,nt+2,end];

    v = defVar(ds,"meridionalavg_yearly_maximum_diurnalvariance",Float32,
               ("longitude",),attrib=attr_var);
    v[:] = mdata[3][:,nt+2,end];

    v = defVar(ds,"meridionalavg_yearly_minimum_diurnalvariance",Float32,
               ("longitude",),attrib=attr_var);
    v[:] = mdata[4][:,nt+2,end];


    v = defVar(ds,"meridionalavg_monthly_mean_climatology",Float32,
               ("longitude","month"),attrib=attr_var);
    v[:] = mdata[1][:,nt+1,1:12];

    v = defVar(ds,"meridionalavg_monthly_std_climatology",Float32,
               ("longitude","month"),attrib=attr_var);
    v[:] = mdata[2][:,nt+1,1:12];

    v = defVar(ds,"meridionalavg_monthly_maximum_climatology",Float32,
               ("longitude","month"),attrib=attr_var);
    v[:] = mdata[3][:,nt+1,1:12];

    v = defVar(ds,"meridionalavg_monthly_minimum_climatology",Float32,
               ("longitude","month"),attrib=attr_var);
    v[:] = mdata[4][:,nt+1,1:12];


    v = defVar(ds,"meridionalavg_monthly_mean_hourly",Float32,
               ("longitude","hour","month"),attrib=attr_var);
    v[:] = mdata[1][:,1:nt,1:12];

    v = defVar(ds,"meridionalavg_monthly_std_hourly",Float32,
               ("longitude","hour","month"),attrib=attr_var);
    v[:] = mdata[2][:,1:nt,1:12];

    v = defVar(ds,"meridionalavg_monthly_maximum_hourly",Float32,
               ("longitude","hour","month"),attrib=attr_var);
    v[:] = mdata[3][:,1:nt,1:12];

    v = defVar(ds,"meridionalavg_monthly_minimum_hourly",Float32,
               ("longitude","hour","month"),attrib=attr_var);
    v[:] = mdata[4][:,1:nt,1:12];


    v = defVar(ds,"meridionalavg_monthly_mean_diurnalvariance",Float32,
               ("longitude","month"),attrib=attr_var);
    v[:] = mdata[1][:,nt+2,1:12];

    v = defVar(ds,"meridionalavg_monthly_std_diurnalvariance",Float32,
               ("longitude","month"),attrib=attr_var);
    v[:] = mdata[2][:,nt+2,1:12];

    v = defVar(ds,"meridionalavg_monthly_maximum_diurnalvariance",Float32,
               ("longitude","month"),attrib=attr_var);
    v[:] = mdata[3][:,nt+2,1:12];

    v = defVar(ds,"meridionalavg_monthly_minimum_diurnalvariance",Float32,
               ("longitude","month"),attrib=attr_var);
    v[:] = mdata[4][:,nt+2,1:12];

    close(ds);

    @info "$(Dates.now()) - Analysed $(uppercase(emod["dataset"])) $(epar["name"]) for the year $yr in $(gregionfullname(ereg["region"])) (Horizontal Resolution: $(ereg["step"])) has been saved into file $(afnc) and moved to the data directory $(afol)."

end
