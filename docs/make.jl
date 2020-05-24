using Documenter
using ClimateERA

makedocs(
    modules  = [ClimateERA],
    doctest  = false,
    format   = Documenter.HTML(
        collapselevel = 1,
        prettyurls    = false
    ),
    authors  = "Nathanael Wong",
    sitename = "ClimateERA.jl",
    pages    = [
        "Home"      => "index.md",
        # "Tutorials" => [
        #     "Initilization"        => "tutorials/initialize.md",
        #     "Data Downloads"       => "tutorials/downloads.md",
        #     "Using GeoRegions"     => "tutorials/georegions.md",
        #     "Region Extraction"    => "tutorials/extract.md",
        #     "Preliminary Analysis" => "tutorials/analysis.md"
        # ]
    ]
)

deploydocs(
    repo = "github.com/natgeo-wong/ClimateERA.jl.git",
)
