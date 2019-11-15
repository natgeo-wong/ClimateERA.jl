"""
This file initializes the ClimateERA module by setting and determining the
ECMWF reanalysis parameters to be analyzed and the regions upon which the data
are to be extracted from.  Functionalities include:
    - Setting up of reanalysis module type
    - Setting up of reanalysis parameters to be analyzed
    - Setting up of time steps upon which data are to be downloaded
    - Setting up of region of analysis based on ClimateEasy

"""

function eraancread(fnc::AbstractArray,epar::Dict,nhr::Integer,ii::Integer,yr::Integer)

    nhr = daysinyear(yr-1) * nhr;

    dyr1 = erancread(fnc[ii],epar); dim = size(dyr1)

    if !(ii==1); d2 = erancread(fnc[ii-1],epar);
    else;        d2 = ones(dim[1],dim[2],nh) * NaN;
    end

    return cat(d2,d1,dims=3);

end

function eraayrseamo(data::Array,nlon::Integer,nlat::Integer,nhr::Integer,yrii::Integer)

    dt = convert(Array,Dates.Date(yr-1,1,1):Day(1):Dates.Date(yr+1,1,1)); pop!(dt);
    yr = Dates.year.(dt); mo = Dates.month.(dt)
    data = reshape(data,nlon,nlat,nhr,:); data = mean(data,3);
    data = reshape(data,nlon,nlat,:);

    yrdata = data[:,:,yr==yrii];
    yrmn = mean(yrdata,dims=3); yrsd = std(yrdata,dims=3);
    yrrg = max(yrdata,[],dims=3) - min(yrdata,[],dims=3);

end

function eraanalyze(emod::Dict,epar::Dict,ereg::Dict,time::Dict,eroot::Dict)

    prelist = emod["levels"]; modID = emod["moduleID"];
    nlon = ereg["size"][1]; nlat = ereg["size"][2];
    if emod["datasetID"] == 1; nhr = 24; else; nhr = 4; end

    for preii in prelist; epar["level"] = preii;

        fol = erafolder(emod,epar,ereg,eroot);
        cd(tol["raw"]); fnc = glob("*.nc"); lf = size(fnc,1);s

        for ii = 1 : lf;

            fpart = split(fnc[ii],"-"); yr = parse(Int,replace(fpart[end],".nc"=>""));
            fdata = eraancread(fnc,epar,nhr,ii,yr)
            dysm  = eraayrseamo(data,nlon,nlat,nhr,yr))
            ddhr  = eraadiurnal(data,nlon,nlat,nhr,yr)
            dvar  = eraavariance(data,nlon,nlat,nhr,yr)
            feraa = eraancsave(dysm,ddhr,dvar,fnc,dataID,nlon,nlat,jj)
            mv(feraa,joinpath(fol["ana"],feraa),force=true);

        end

        cd(eroot["era"])

    end

end
