# ClimateERA.jl
*Download and analyze ECMWF Reanalysis Datasets using Julia!*

`ClimateERA.jl` aims to streamline the basic processing of ECMWF Reanalysis data for climate applications and research.  This includes:
* Creating relevant pythong scripts to download ERA5 and ERA-Interim datasets
* Preliminary analysis of downloaded reanalysis data, including
  * Yearly and monthly `mean`, `std`, `maximum` and `minimum` of daily averages
  * Yearly and monthly `mean`, `std`, `maximum` and `minimum` of sub-daily raw data (where available)
  * All of the above in the 2D-spatial domain, as well as meridional-averaged and zonal-averaged domains.
* Packing downloaded data into `Int16` format to save disk-space
* Extraction of data for specific geographic regions (GeoRegions)
  * See [`GeoRegions.jl`](https://github.com/JuliaClimate/GeoRegions.jl) for more information

## Installation
`ClimateERA.jl` can be installed using Julia's built-in package manager as follows:

```
julia> ]
(@v1.4) pkg> add ClimateERA
```

You can update `ClimateERA.jl` to the latest version using
```
(@v1.4) pkg> update ClimateERA
```

And if you want to get the latest release without waiting for me to update the Julia Registry (although this generally isn't necessary since I make a point to release patch versions as soon as I find bugs or add new working features), you may fix the version to the `master` branch of the GitHub repository:
```
(@v1.4) pkg> add ClimateERA#master
```

## Documentation

The documentation for `ClimateERA.jl` is divided into three components:
1. Tutorials - meant as an introduction to the package
2. How-to Examples - geared towards those looking for specific examples of what can be done
3. API Reference - comprehensive summary of all exported functionalities

!!! tip "A Note on the Examples:"
    All the output for the coding examples were produced using my computer with key security information (such as login info) omitted.  The examples cannot be run online because the file size requirements are too big.  Copying and pasting the code examples (with relevant directory and login information changes) should produce the same results.

## Getting help
If you are interested in using `ClimateERA.jl` or are trying to figure out how to use it, please feel free to ask me questions and get in touch!  Please feel free to [open an issue](https://github.com/natgeo-wong/ClimateERA.jl/issues/new) if you have any questions, comments, suggestions, etc!
