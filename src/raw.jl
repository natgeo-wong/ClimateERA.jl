

function erarawregion(
    emod::Dict, epar::Dict, ereg::Dict,
    start::TimeType, finish::TimeType;
    path::AbstractString="",
    region::AbstractString="GLB"
)

    if path == ""; eroot = eraroot(actionID); else; eroot = eraroot(path,actionID); end

    @info "$(Dates.now()) - Extracting $(uppercase(emod["dataset"])) $(epar["name"]) data for the entire $(gregionfullname(region)) region ..."

    if !isdir(eraregfolder(ereg,eroot))
        error("$(Dates.now()) - No data has been downloaded from $(uppercase(emod["dataset"])) $(epar["name"]) in the $(gregionfullname(region))")
    end

    dvec,dys,dyf,ndy = extractdate(start,finish); ndates = length(dvec);
    if emod["datasetID"] == 1; nt = 24; else; nt = 4; end

    lon = ereg["lon"]; lat = ereg["lat"]; rlon,rlat,rinfo = gregiongridvec(region,lon,lat);
    nlon = length(rlon); nlat = length(rlat); data = zeros(Float32,nlon,nlat,ndy*nt);

    for ii = 1 : ndates; dateii = dvec[ii];

        fol = erarawfolder(epar,ereg,eroot);
        if !isdir(fol)
            error("$(Dates.now()) - There is no data for $(uppercase(emod["dataset"])) $(epar["name"]) for $(yrmo2dir(dateii)).")
        end

        fnc = joinpath(fol,erarawname(emod,epar,ereg,dateii));
        ds  = Dataset(fnc,"r"); vds = ds[varname];

        if     ii == 1 && ii != ndates
            moday = daysinmonth(dateii);
            ibeg = (dys-1)*nt + 1; iend = (moday+1-dys)*nt;
            data[:,:,1:iend] = vds[:,:,ibeg:end];
        elseif ii != 1 && ii == ndates
            ibeg = iend+1; iend = dyf*nt;
            data[:,:,ibeg:end] = vds[:,:,1:iend];
        elseif ii == 1 && ii == ndates
            ibeg = (dys-1)*nt + 1; iend = dyf*nt;
            data = vds[:,:,ibeg:iend];
        else
            moday = daysinmonth(dateii);
            ibeg = iend+1; iend = ibeg-1 + moday*nt;
            data[:,:,ibeg:iend] = vds[:];
        end

    end

    @info "$(Dates.now()) - $(uppercase(emod["dataset"])) $(epar["name"]) data for the entire $(gregionfullname(region)) region has been extracted."

    return datavec,info,[rlon,rlat]

end

function erarawpoint(
    emod::Dict, epar::Dict, ereg::Dict,
    start::TimeType, finish::TimeType;
    coord::Array{<:Real,1},
    path::AbstractString="",
    region::AbstractString="GLB"
)

    if path == ""; eroot = eraroot(actionID); else; eroot = eraroot(path,actionID); end
    if length(coord) != 2
        error("$(Dates.now()) - Coordinate vector must be in the form [lon,lat]")
    end

    @info "$(Dates.now()) - Extracting $(uppercase(emod["dataset"])) $(epar["name"]) data at coordinates $(coord) ..."

    if !isdir(eraregfolder(ereg,eroot))
        error("$(Dates.now()) - No data has been downloaded from $(uppercase(emod["dataset"])) $(epar["name"]) in the $(gregionfullname(region))")
    end

    dvec,dys,dyf,ndy = extractdate(start,finish); ndates = length(dvec);
    if emod["datasetID"] == 1; nt = 24; else; nt = 4; end

    lon = ereg["lon"]; lat = ereg["lat"]; rlon,rlat,rinfo = gregiongridvec(region,lon,lat);
    plon,plat = coord; ilon,ilat = regionpoint(plon,plat,rlon,rlat);
    data = zeros(Float32,ndy*nt);

    for ii = 1 : ndates; dateii = dvec[ii];

        fol = erarawfolder(epar,ereg,eroot);
        if !isdir(fol)
            error("$(Dates.now()) - There is no data for $(uppercase(emod["dataset"])) $(epar["name"]) for $(yrmo2dir(dateii)).")
        end

        fnc = joinpath(fol,erarawname(emod,epar,ereg,dateii));
        ds  = Dataset(fnc,"r"); vds = ds[varname];

        if     ii == 1 && ii != ndates
            moday = daysinmonth(dateii);
            ibeg = (dys-1)*nt + 1; iend = (moday+1-dys)*nt;
            data[1:iend] = vds[ilon,ilat,ibeg:end];
        elseif ii != 1 && ii == ndates
            ibeg = iend+1; iend = dyf*nt;
            data[ibeg:end] = vds[ilon,ilat,1:iend];
        elseif ii == 1 && ii == ndates
            ibeg = (dys-1)*nt + 1; iend = dyf*nt;
            data = vds[ilon,ilat,ibeg:iend];
        else
            moday = daysinmonth(dateii);
            ibeg = iend+1; iend = ibeg-1 + moday*nt;
            data[ibeg:iend] = vds[ilon,ilat,:];
        end

    end

    @info "$(Dates.now()) - $(uppercase(emod["dataset"])) $(epar["name"]) data for the coordinates $(coord) has been extracted."

    return datavec,info

end

function erarawgrid(
    emod::Dict, epar::Dict, ereg::Dict,
    start::TimeType, finish::TimeType;
    grid::Array{<:Real,1},
    path::AbstractString="",
    region::AbstractString="GLB"
)

    if path == ""; eroot = eraroot(actionID); else; eroot = eraroot(path,actionID); end
    if length(grid) != 4
        error("$(Dates.now()) - Grid vector must be in the form [N,S,E,W]")
    end

    @info "$(Dates.now()) - Extracting $(uppercase(emod["dataset"])) $(epar["name"]) data for the [N,S,E,W] bounds $(grid) ..."

    if !isdir(eraregfolder(ereg,eroot))
        error("$(Dates.now()) - No data has been downloaded from $(uppercase(emod["dataset"])) $(epar["name"]) in the $(gregionfullname(region))")
    end

    dvec,dys,dyf,ndy = extractdate(start,finish); ndates = length(dvec);
    if emod["datasetID"] == 1; nt = 24; else; nt = 4; end

    lon = ereg["lon"]; lat = ereg["lat"]; isgridinregion(grid,region);
    rlon,rlat,rinfo = gregiongridvec(region,lon,lat);
    glon,glat,ginfo = regiongridvec(grid,rlon,rlat); iWE,iNS = ginfo["IDvec"];
    nlon = length(glon); nlat = length(glat);
    data = zeros(Float32,nlon,nlat,ndy*nt);

    for ii = 1 : ndates; dateii = dvec[ii];

        fol = erarawfolder(epar,ereg,eroot);
        if !isdir(fol)
            error("$(Dates.now()) - There is no data for $(uppercase(emod["dataset"])) $(epar["name"]) for $(yrmo2dir(dateii)).")
        end

        fnc = joinpath(fol,erarawname(emod,epar,ereg,dateii));
        ds  = Dataset(fnc,"r"); vds = ds[varname];

        if     ii == 1 && ii != ndates
            moday = daysinmonth(dateii);
            ibeg = (dys-1)*nt + 1; iend = (moday+1-dys)*nt;
            data[:,:,1:iend] = vds[iWE,iNS,ibeg:end];
        elseif ii != 1 && ii == ndates
            ibeg = iend+1; iend = dyf*nt;
            data[:,:,ibeg:end] = vds[iWE,iNS,1:iend];
        elseif ii == 1 && ii == ndates
            ibeg = (dys-1)*nt + 1; iend = dyf*nt;
            data = vds[iWE,iNS,ibeg:iend];
        else
            moday = daysinmonth(dateii);
            ibeg = iend+1; iend = ibeg-1 + moday*nt;
            data[:,:,ibeg:iend] = vds[iWE,iNS,:];
        end

    end

    @info "$(Dates.now()) - $(uppercase(emod["dataset"])) $(epar["name"]) data within the [N,S,E,W] bounds $(grid) has been extracted."

    return datavec,info,[glon,glat]
    
end
