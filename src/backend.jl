## DateString Aliasing

function yrmo2dir(date::TimeType) = Dates.format(date,dateformat"yyyy/mm") end
function yrmo2str(date::TimeType) = Dates.format(date,dateformat"yyyymm") end
function yr2str(date::TimeType)   = Dates.format(date,dateformat"yyyy") end
function ymd2str(date::TimeType)  = Dates.format(date,dateformat"yyyymmdd") end
