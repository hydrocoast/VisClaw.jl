#############################################
"""
    eta_uniformgrid = interpsurface(amrgrid::Vector{VisClaw.AMRGrid}, topo::VisClaw.Topo)
    eta_uniformgrid = interpsurface(amr::VisClaw.AMR, topo::VisClaw.Topo)

Convert AMR tile data into uniform grid data using the SciPy scattered interpolation.\n
Interpolation of inundation height (land) is not supported. \n
"""
function interpsurface(amrgrid::Vector{VisClaw.AMRGrid}, topo::VisClaw.Topo)
    ## import
    scipyinterpolate = PyCall.pyimport("scipy.interpolate")

    ## make grid data from topo
    xmesh_all = repeat(topo.x', inner=(topo.nrows,1))
    ymesh_all = repeat(topo.y , inner=(1,topo.ncols))
    land = topo.elevation .>= 0.0

    ## get lims of the designated region
    xmin, xmax = extrema(topo.x)
    ymin, ymax = extrema(topo.y)

    ## scattered x y data
    ntile = length(amrgrid)
    x_all = empty([0.0])
    y_all = empty([0.0])
    z_all = empty([0.0])
    for i_tile = 1:ntile
        tile = amrgrid[i_tile]

        x1, x2, y1, y2 = VisClaw.getlims(tile)
        x2 < xmin && (continue)
        xmax < x1 && (continue)
        y2 < ymin && (continue)
        ymax < y1 && (continue)

        xmesh, ymesh = VisClaw.meshtile(tile)
        ind = isnan.(tile.eta)
        push!(x_all, xmesh[.!ind]...)
        push!(y_all, ymesh[.!ind]...)
        push!(z_all, tile.eta[.!ind]...)
    end

    ## nodata
    if length(z_all) == 0
        v_all = zeros(topo.nrows,topo.ncols)
    else
        v_all = scipyinterpolate.griddata([x_all y_all], z_all, (xmesh_all,ymesh_all), method="cubic")
    end

    v_all[land] .= NaN

    return v_all

end
#############################################

#############################################
function interpsurface(amrall::VisClaw.AMR, topo::VisClaw.Topo; timestep=1:amrall.nstep)
    eta_uniformgrid = [interpsurface(amrall.amr[k], topo) for k=timestep]
    eta_uniformgrid = cat(eta_uniformgrid...; dims=3)
    return eta_uniformgrid
end
