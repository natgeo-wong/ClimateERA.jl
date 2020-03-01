## DateString Aliasing

yrmo2dir(date::TimeType) = Dates.format(date,dateformat"yyyy/mm")
yrmo2str(date::TimeType) = Dates.format(date,dateformat"yyyymm")
yr2str(date::TimeType)   = Dates.format(date,dateformat"yyyy")
ymd2str(date::TimeType)  = Dates.format(date,dateformat"yyyymmdd")
