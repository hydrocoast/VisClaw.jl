#########################################################
"""
    varname_x, varname_y, varname_z = getvarname_nctopo(ncfilename::String)
"""
function getvarname_nctopo(ncfilename::String)
    nc = NetCDF.open(ncfilename)
    vardict = nc.vars

    ## var X
    varname_x = nothing
    varname_x = varnameset(vardict, "lon", varname_x)
    varname_x = varnameset(vardict, "Lon", varname_x)
    varname_x = varnameset(vardict, "LON", varname_x)
    varname_x = varnameset(vardict, "longitude", varname_x)
    varname_x = varnameset(vardict, "Longitude", varname_x)
    varname_x = varnameset(vardict, "LONGITUDE", varname_x)
    varname_x = varnameset(vardict, "x", varname_x)
    varname_x = varnameset(vardict, "X", varname_x)
    ## check
    varname_x == nothing && error("Variable X/LON was not found in $(ncfilename)")

    ## var Y
    varname_y = nothing
    varname_y = varnameset(vardict, "lat", varname_y)
    varname_y = varnameset(vardict, "Lat", varname_y)
    varname_y = varnameset(vardict, "LAT", varname_y)
    varname_y = varnameset(vardict, "latitude", varname_y)
    varname_y = varnameset(vardict, "Latitude", varname_y)
    varname_y = varnameset(vardict, "LATITUDE", varname_y)
    varname_y = varnameset(vardict, "y", varname_y)
    varname_y = varnameset(vardict, "Y", varname_y)
    ## check
    varname_y == nothing && error("Variable Y/LAT was not found in $(ncfilename)")

    ## var Z
    varname_z = nothing
    varname_z = varnameset(vardict, "elevation", varname_z)
    varname_z = varnameset(vardict, "Elevation", varname_z)
    varname_z = varnameset(vardict, "ELEVATION", varname_z)
    varname_z = varnameset(vardict, "z", varname_z)
    varname_z = varnameset(vardict, "Z", varname_z)
    varname_z = varnameset(vardict, "band1", varname_z)
    varname_z = varnameset(vardict, "Band1", varname_z)
    varname_z = varnameset(vardict, "BAND1", varname_z)
    ## check
    varname_z == nothing && error("Variable Z/ELEVATION was not found in $(ncfilename)")

    ## return
    return varname_x, varname_y, varname_z
end
#########################################################
