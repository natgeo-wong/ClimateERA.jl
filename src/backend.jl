## DateString Aliasing

yrmo2dir(date::TimeType) = Dates.format(date,dateformat"yyyy/mm") end
yrmo2str(date::TimeType) = Dates.format(date,dateformat"yyyymm") end
yr2str(date::TimeType)   = Dates.format(date,dateformat"yyyy") end
ymd2str(date::TimeType)  = Dates.format(date,dateformat"yyyymmdd") end
