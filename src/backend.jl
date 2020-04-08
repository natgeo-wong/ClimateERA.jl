## DateString Aliasing

yrmo2dir(date::TimeType) = Dates.format(date,dateformat"yyyy/mm")
yrmo2str(date::TimeType) = Dates.format(date,dateformat"yyyymm")
yr2str(date::TimeType)   = Dates.format(date,dateformat"yyyy")
ymd2str(date::TimeType)  = Dates.format(date,dateformat"yyyymmdd")
mo2str(date::TimeType)   = Dates.format(date,dateformat"mm")

yrmo2str(yr::Integer,mo::Integer) = @sprintf("%04d%02d",yr,mo)
mo2str(mo::Integer) = @sprintf("%02d",mo)
dy2str(dy::Integer) = @sprintf("%02d",dy)

function extractdate(startdate::TimeType,finish::TimeType);

    yrs = Dates.year(start);  mos = Dates.month(start);  dys = Dates.day(start);
    yrf = Dates.year(finish); mof = Dates.month(finish); dyf = Dates.day(finish);
    ndy = Dates.value((finish-start)/Dates.day(1));
    dvecs = Date(yrs,mos); dvecf = Date(yrf,mof);

    dvec = collect(dvecs:Month(1):dvecf);

    return dvec,dys,dyf,ndy

end

bold() = Crayon(bold=true)
reset() = Crayon(reset=true)

function checkegrid(step::Rational)

    if rem(360,step) == 0
          return true
    else; return false
    end

end
