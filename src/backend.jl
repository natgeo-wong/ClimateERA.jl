## DateString Aliasing

yrmo2dir(date::TimeType) = Dates.format(date,dateformat"yyyy/mm")
yrmo2str(date::TimeType) = Dates.format(date,dateformat"yyyymm")
yr2str(date::TimeType)   = Dates.format(date,dateformat"yyyy")
ymd2str(date::TimeType)  = Dates.format(date,dateformat"yyyymmdd")
mo2str(date::TimeType)   = Dates.format(date,dateformat"mm")

yrmo2str(yr::Integer,mo::Integer) = @sprintf("%04d%02d",yr,mo)
mo2str(mo::Integer) = @sprintf("%02d",mo)
dy2str(dy::Integer) = @sprintf("%02d",dy)
