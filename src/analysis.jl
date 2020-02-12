"""
This file initializes the ClimateERA module by setting and determining the
ECMWF reanalysis parameters to be analyzed and the regions upon which the data
are to be extracted from.  Functionalities include:
    - Setting up of reanalysis module type
    - Setting up of reanalysis parameters to be analyzed
    - Setting up of time steps upon which data are to be downloaded
    - Setting up of region of analysis based on ClimateEasy

"""

function erananmean(data::Vector{Float32})
    iNaN = data .!= NaN32
    if sum(iNaN) != 0; return mean(data[iNaN]); else; return NaN32; end
end

function eraanalysis(
    emod::Dict, epar::Dict, ereg::Dict,
    yr::Integer, pre::Integer,
    eroot::Dict
)

    modID = emod["moduleID"]; if emod["datasetID"] == 1; nhr = 24; else; nhr = 4; end
    epar["level"] = pre; nlon = ereg["size"][1]; nlat = ereg["size"][2]; nt = nhr+1;

    rfol = erarawfol(epar,ereg,eroot); fraw = erarawname(emod,epar,ereg,Date(yr,1));
    rfnc = joinpath(rfol,"$(yr)",fraw); ds = Dataset(rfnc,"r"); attr = Dict();
    attr["lon"] = ds["longitude"].attrib; attr["lat"] = ds["latitude"].attrib;
    try; attr["var"] = erancread(fncr,epar).attrib; catch; attr["var"] = Dict(); end
    if haskey(attr["var"],"scale_factor"); delete!(attr["var"],"scale_factor"); end
    if haskey(attr["var"],"add_offset"); delete!(attr["var"],"add_offset"); end

    davg = zeros(Float32,nlon,nlat,nt+1,13); dstd = zeros(Float32,nlon,nlat,nt+1,13);
    dmax = zeros(Float32,nlon,nlat,nt+1,13); dmin = zeros(Float32,nlon,nlat,nt+1,13);

    zavg = zeros(Float32,nlat,nt+1,13); zstd = zeros(Float32,nlat,nt+1,13);
    zmax = zeros(Float32,nlat,nt+1,13); zmin = zeros(Float32,nlat,nt+1,13);

    mavg = zeros(Float32,nlon,nt+1,13); mstd = zeros(Float32,nlon,nt+1,13);
    mmax = zeros(Float32,nlon,nt+1,13); mmin = zeros(Float32,nlon,nt+1,13);

    for mo = 1 : 12; ndy = daysinmonth(yr,mo)

        @info "$(Dates.now()) - Analyzing $(emod["dataset"]) $(epar["name"]) data in $(regionfullname(region)) during $(Dates.monthname(mo)) $yr ..."

        fraw = erarawname(emod,epar,ereg,Date(yr,mo));
        fncr = joinpath(rawfol,"$(yr)",fraw); ds = Dataset(fncr,"r"); vds = ds[varname];
        raw  = vds[:].*1.0; raw[ismissing.(raw)] .= NaN;
        raw  = reshape(Float32.(raw),nlon,nlat,(nt-1),ndy);

        @debug "$(Dates.now()) - Extracting monthly diurnal climatological information ..."
        davg[:,:,1:nt-1,mo] = mean(raw,dims=4);
        dstd[:,:,1:nt-1,mo] = std(raw,dims=4);
        dmax[:,:,1:nt-1,mo] = maximum(raw,dims=4);
        dmin[:,:,1:nt-1,mo] = minimum(raw,dims=4);

        @debug "$(Dates.now()) - Extracting monthly averaged climatological information ..."
        davg[:,:,nt,mo] = mean(davg[:,:,1:nt-1,mo],dims=3);
        dstd[:,:,nt,mo] = mean(dstd[:,:,1:nt-1,mo],dims=3);
        dmax[:,:,nt,mo] = maximum(dmax[:,:,1:nt-1,mo],dims=3);
        dmin[:,:,nt,mo] = minimum(dmin[:,:,1:nt-1,mo],dims=3);

        @debug "$(Dates.now()) - Permuting days and hours dimensions ..."
        raw = permutedims(raw,(1,2,4,3));
        tmp = maximum(raw,dims=4)/2 - minimum(raw,dims=4)/2;

        @debug "$(Dates.now()) - Extracting monthly diurnal variability information ..."
        davg[:,:,nt+1,mo] = mean(tmp,dims=3);
        dstd[:,:,nt+1,mo] = std(tmp,dims=3);
        dmax[:,:,nt+1,mo] = maximum(tmp,dims=3);
        dmin[:,:,nt+1,mo] = minimum(tmp,dims=3);

    end

    @info "$(Dates.now()) - Calculating yearly climatology for $(emod["dataset"]) $(epar["name"]) data in $(regionfullname(region)) during $yr ..."
    davg[:,:,:,end] = mean(davg[:,:,:,1:12],dims=4);
    dstd[:,:,:,end] = mean(dstd[:,:,:,1:12],dims=4);
    dmax[:,:,:,end] = maximum(dmax[:,:,:,1:12],dims=4);
    dmin[:,:,:,end] = minimum(dmin[:,:,:,1:12],dims=4);

    for ilat = 1 : nlat, it = 1 : nt+1, imo = 1 : 13
        zavg[ilat,it,imo] = erananmean(davg[:,ilat,it,imo]);
        zstd[ilat,it,imo] = erananmean(dstd[:,ilat,it,imo]);
        zmax[ilat,it,imo] = erananmean(dmax[:,ilat,it,imo]);
        zmin[ilat,it,imo] = erananmean(dmin[:,ilat,it,imo]);
    end

    for imo = 1 : 13, it = 1 : nt+1, ilon = 1 : nlon;
        mavg[ilon,it,imo] = erananmean(davg[ilon,:,it,imo]);
        mstd[ilon,it,imo] = erananmean(dstd[ilon,:,it,imo]);
        mmax[ilon,it,imo] = erananmean(dmax[ilon,:,it,imo]);
        mmin[ilon,it,imo] = erananmean(dmin[ilon,:,it,imo]);
    end

    eraanasave([davg,dstd,dmax,dmin],[zavg,zstd,zmax,zmin],[mavg,mstd,mmax,mmin],attr,
               emod,epar,ereg,eroot)

end

function eraanasave(
    data::Array{Array{Float32,4},1},
    zdata::Array{Array{Float32,3},1},
    mdata::Array{Array{Float32,3},1},
    attr::Dict, emod::Dict, epar::Dict, ereg::Dict, eroot::Dict
)

    @info "$(Dates.now()) - Saving analysed $(emod["dataset"]) $(epar["name"]) data in $(regionfullname(region)) for the year $yr ..."

    afol = eraanafol(epar,ereg,eroot); fana = eraananame(emod,epar,ereg,Date(yr));
    afnc = joinpath(afol,fana);

    if isfile(afnc)
        @info "$(Dates.now()) - Stale NetCDF file $(afnc) detected.  Overwriting ..."
        rm(afnc);
    end

    @debug "$(Dates.now()) - Creating NetCDF file $(afnc) for analyzed $(emod["dataset"]) $(epar["name"]) data in $yr ..."

    ds = Dataset(afnc,"c");
    ds.dim["longitude"] = ereg["size"][1]; ds.dim["latitude"] = ereg["size"][2];
    if emod["datasetID"] == 1; nhr = 24; else; nhr = 4; end; ds.dim["hour"] = nhr;
    ds.dim["month"] = 12;

    defVar(ds,"longitude",rlon,("longitude",),attrib=attr["lon"])
    defVar(ds,"latitude",rlat,("latitude",),attrib=attr["lat"])

    @debug "$(Dates.now()) - Saving analyzed $(emod["dataset"]) $(epar["name"]) data for $yr to NetCDF file $(afnc) ..."

    defVar(ds,"domain_yearly_mean_climatology",data[1][:,:,nt+1,end],
           ("longitude","latitude"),attrib=attr["var"]);
    defVar(ds,"domain_yearly_std_climatology",data[2][:,:,nt+1,end],
           ("longitude","latitude"),attrib=attr["var"]);
    defVar(ds,"domain_yearly_maximum_climatology",data[3][:,:,nt+1,end],
           ("longitude","latitude"),attrib=attr["var"]);
    defVar(ds,"domain_yearly_minimum_climatology",data[4][:,:,nt+1,end],
           ("longitude","latitude"),attrib=attr["var"]);

    defVar(ds,"domain_yearly_mean_hourly",data[1][:,:,1:nt,end],
           ("longitude","latitude","hour"),attrib=attr["var"]);
    defVar(ds,"domain_yearly_std_hourly",data[2][:,:,1:nt,end],
           ("longitude","latitude","hour"),attrib=attr["var"]);
    defVar(ds,"domain_yearly_maximum_hourly",data[3][:,:,1:nt,end],
           ("longitude","latitude","hour"),attrib=attr["var"]);
    defVar(ds,"domain_yearly_minimum_hourly",data[4][:,:,1:nt,end],
           ("longitude","latitude","hour"),attrib=attr["var"]);

    defVar(ds,"domain_yearly_mean_diurnalvariance",data[1][:,:,nt+2,end],
           ("longitude","latitude"),attrib=attr["var"]);
    defVar(ds,"domain_yearly_std_diurnalvariance",data[2][:,:,nt+2,end],
           ("longitude","latitude"),attrib=attr["var"]);
    defVar(ds,"domain_yearly_maximum_diurnalvariance",data[3][:,:,nt+2,end],
           ("longitude","latitude"),attrib=attr["var"]);
    defVar(ds,"domain_yearly_minimum_diurnalvariance",data[4][:,:,nt+2,end],
           ("longitude","latitude"),attrib=attr["var"]);

    defVar(ds,"domain_monthly_mean_climatology",data[1][:,:,nt+1,1:12],
           ("longitude","latitude","month"),attrib=attr["var"]);
    defVar(ds,"domain_monthly_std_climatology",data[2][:,:,nt+1,1:12],
           ("longitude","latitude","month"),attrib=attr["var"]);
    defVar(ds,"domain_monthly_maximum_climatology",data[3][:,:,nt+1,1:12],
           ("longitude","latitude","month"),attrib=attr["var"]);
    defVar(ds,"domain_monthly_minimum_climatology",data[4][:,:,nt+1,1:12],
           ("longitude","latitude","month"),attrib=attr["var"]);

    defVar(ds,"domain_monthly_mean_hourly",data[1][:,:,1:nt,1:12],
           ("longitude","latitude","hour","month"),attrib=attr["var"]);
    defVar(ds,"domain_monthly_std_hourly",data[2][:,:,1:nt,1:12],
           ("longitude","latitude","hour","month"),attrib=attr["var"]);
    defVar(ds,"domain_monthly_maximum_hourly",data[3][:,:,1:nt,1:12],
           ("longitude","latitude","hour","month"),attrib=attr["var"]);
    defVar(ds,"domain_monthly_minimum_hourly",data[4][:,:,1:nt,1:12],
           ("longitude","latitude","hour","month"),attrib=attr["var"]);

    defVar(ds,"domain_monthly_mean_diurnalvariance",data[1][:,:,nt+2,1:12],
           ("longitude","latitude","month"),attrib=attr["var"]);
    defVar(ds,"domain_monthly_std_diurnalvariance",data[2][:,:,nt+2,1:12],
           ("longitude","latitude","month"),attrib=attr["var"]);
    defVar(ds,"domain_monthly_maximum_diurnalvariance",data[3][:,:,nt+2,1:12],
           ("longitude","latitude","month"),attrib=attr["var"]);
    defVar(ds,"domain_monthly_minimum_diurnalvariance",data[4][:,:,nt+2,1:12],
           ("longitude","latitude","month"),attrib=attr["var"]);


    defVar(ds,"zonalavg_yearly_mean_climatology",zdata[1][:,nt+1,end],
           ("latitude",),attrib=attr["var"]);
    defVar(ds,"zonalavg_yearly_std_climatology",zdata[2][:,nt+1,end],
           ("latitude",),attrib=attr["var"]);
    defVar(ds,"zonalavg_yearly_maximum_climatology",zdata[3][:,nt+1,end],
           ("latitude",),attrib=attr["var"]);
    defVar(ds,"zonalavg_yearly_minimum_climatology",zdata[4][:,nt+1,end],
           ("latitude",),attrib=attr["var"]);

    defVar(ds,"zonalavg_yearly_mean_hourly",zdata[1][:,1:nt,end],
           ("latitude","hour"),attrib=attr["var"]);
    defVar(ds,"zonalavg_yearly_std_hourly",zdata[2][:,1:nt,end],
           ("latitude","hour"),attrib=attr["var"]);
    defVar(ds,"zonalavg_yearly_maximum_hourly",zdata[3][:,1:nt,end],
           ("latitude","hour"),attrib=attr["var"]);
    defVar(ds,"zonalavg_yearly_minimum_hourly",zdata[4][:,1:nt,end],
           ("latitude","hour"),attrib=attr["var"]);

    defVar(ds,"zonalavg_yearly_mean_diurnalvariance",zdata[1][:,nt+2,end],
           ("latitude",),attrib=attr["var"]);
    defVar(ds,"zonalavg_yearly_std_diurnalvariance",zdata[2][:,nt+2,end],
           ("latitude",),attrib=attr["var"]);
    defVar(ds,"zonalavg_yearly_maximum_diurnalvariance",zdata[3][:,nt+2,end],
           ("latitude",),attrib=attr["var"]);
    defVar(ds,"zonalavg_yearly_minimum_diurnalvariance",zdata[4][:,nt+2,end],
           ("latitude",),attrib=attr["var"]);

    defVar(ds,"zonalavg_monthly_mean_climatology",zdata[1][:,nt+1,1:12],
           ("latitude","month"),attrib=attr["var"]);
    defVar(ds,"zonalavg_monthly_std_climatology",zdata[2][:,nt+1,1:12],
           ("latitude","month"),attrib=attr["var"]);
    defVar(ds,"zonalavg_monthly_maximum_climatology",zdata[3][:,nt+1,1:12],
           ("latitude","month"),attrib=attr["var"]);
    defVar(ds,"zonalavg_monthly_minimum_climatology",zdata[4][:,nt+1,1:12],
           ("latitude","month"),attrib=attr["var"]);

    defVar(ds,"zonalavg_monthly_mean_hourly",zdata[1][:,1:nt,1:12],
           ("latitude","hour","month"),attrib=attr["var"]);
    defVar(ds,"zonalavg_monthly_std_hourly",zdata[2][:,1:nt,1:12],
           ("latitude","hour","month"),attrib=attr["var"]);
    defVar(ds,"zonalavg_monthly_maximum_hourly",zdata[3][:,1:nt,1:12],
           ("latitude","hour","month"),attrib=attr["var"]);
    defVar(ds,"zonalavg_monthly_minimum_hourly",zdata[4][:,1:nt,1:12],
           ("latitude","hour","month"),attrib=attr["var"]);

    defVar(ds,"zonalavg_monthly_mean_diurnalvariance",zdata[1][:,nt+2,1:12],
           ("latitude","month"),attrib=attr["var"]);
    defVar(ds,"zonalavg_monthly_std_diurnalvariance",zdata[2][:,nt+2,1:12],
           ("latitude","month"),attrib=attr["var"]);
    defVar(ds,"zonalavg_monthly_maximum_diurnalvariance",zdata[3][:,nt+2,1:12],
           ("latitude","month"),attrib=attr["var"]);
    defVar(ds,"zonalavg_monthly_minimum_diurnalvariance",zdata[4][:,nt+2,1:12],
           ("latitude","month"),attrib=attr["var"]);


    defVar(ds,"meridionalavg_yearly_mean_climatology",mdata[1][:,nt+1,end],
           ("longitude",),attrib=attr["var"]);
    defVar(ds,"meridionalavg_yearly_std_climatology",mdata[2][:,nt+1,end],
           ("longitude",),attrib=attr["var"]);
    defVar(ds,"meridionalavg_yearly_maximum_climatology",mdata[3][:,nt+1,end],
           ("longitude",),attrib=attr["var"]);
    defVar(ds,"meridionalavg_yearly_minimum_climatology",mdata[4][:,nt+1,end],
           ("longitude",),attrib=attr["var"]);

    defVar(ds,"meridionalavg_yearly_mean_hourly",mdata[1][:,1:nt,end],
           ("longitude","hour"),attrib=attr["var"]);
    defVar(ds,"meridionalavg_yearly_std_hourly",mdata[2][:,1:nt,end],
           ("longitude","hour"),attrib=attr["var"]);
    defVar(ds,"meridionalavg_yearly_maximum_hourly",mdata[3][:,1:nt,end],
           ("longitude","hour"),attrib=attr["var"]);
    defVar(ds,"meridionalavg_yearly_minimum_hourly",mdata[4][:,1:nt,end],
           ("longitude","hour"),attrib=attr["var"]);

    defVar(ds,"meridionalavg_yearly_mean_diurnalvariance",mdata[1][:,nt+2,end],
           ("longitude",),attrib=attr["var"]);
    defVar(ds,"meridionalavg_yearly_std_diurnalvariance",mdata[2][:,nt+2,end],
           ("longitude",),attrib=attr["var"]);
    defVar(ds,"meridionalavg_yearly_maximum_diurnalvariance",mdata[3][:,nt+2,end],
           ("longitude",),attrib=attr["var"]);
    defVar(ds,"meridionalavg_yearly_minimum_diurnalvariance",mdata[4][:,nt+2,end],
           ("longitude",),attrib=attr["var"]);

    defVar(ds,"meridionalavg_monthly_mean_climatology",mdata[1][:,nt+1,1:12],
           ("longitude","month"),attrib=attr["var"]);
    defVar(ds,"meridionalavg_monthly_std_climatology",mdata[2][:,nt+1,1:12],
           ("longitude","month"),attrib=attr["var"]);
    defVar(ds,"meridionalavg_monthly_maximum_climatology",mdata[3][:,nt+1,1:12],
           ("longitude","month"),attrib=attr["var"]);
    defVar(ds,"meridionalavg_monthly_minimum_climatology",mdata[4][:,nt+1,1:12],
           ("longitude","month"),attrib=attr["var"]);

    defVar(ds,"meridionalavg_monthly_mean_hourly",mdata[1][:,1:nt,1:12],
           ("longitude","hour","month"),attrib=attr["var"]);
    defVar(ds,"meridionalavg_monthly_std_hourly",mdata[2][:,1:nt,1:12],
           ("longitude","hour","month"),attrib=attr["var"]);
    defVar(ds,"meridionalavg_monthly_maximum_hourly",mdata[3][:,1:nt,1:12],
           ("longitude","hour","month"),attrib=attr["var"]);
    defVar(ds,"meridionalavg_monthly_minimum_hourly",mdata[4][:,1:nt,1:12],
           ("longitude","hour","month"),attrib=attr["var"]);

    defVar(ds,"meridionalavg_monthly_mean_diurnalvariance",mdata[1][:,nt+2,1:12],
           ("longitude","month"),attrib=attr["var"]);
    defVar(ds,"meridionalavg_monthly_std_diurnalvariance",mdata[2][:,nt+2,1:12],
           ("longitude","month"),attrib=attr["var"]);
    defVar(ds,"meridionalavg_monthly_maximum_diurnalvariance",mdata[3][:,nt+2,1:12],
           ("longitude","month"),attrib=attr["var"]);
    defVar(ds,"meridionalavg_monthly_minimum_diurnalvariance",mdata[4][:,nt+2,1:12],
           ("longitude","month"),attrib=attr["var"]);

    close(ds);

    @info "$(Dates.now()) - Analysed $(emod["dataset"]) $(epar["name"]) for the year $yr in $(regionfullname(region)) has been saved into file $(afnc) and moved to the data directory $(afol)."

end
