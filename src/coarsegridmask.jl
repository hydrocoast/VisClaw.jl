###############################################
"""
    poly = tilepolygon(tile::VisClaw.AMRGrid)

generate a polygon data of a tile
"""
function tilepolygon(tile::VisClaw.AMRGrid)
    x1, x2, y1, y2 = VisClaw.getlims(tile)
    ll = GeometricalPredicates.Point(x1, y1)
    lr = GeometricalPredicates.Point(x2, y1)
    ur = GeometricalPredicates.Point(x2, y2)
    ul = GeometricalPredicates.Point(x1, y2)
    poly = GeometricalPredicates.Polygon(ll, lr, ur, ul)
    return poly
end

###############################################
"""
    coarsegridmask!(tiles::Vector{VisClaw.AMRGrid})
    coarsegridmask!(amrs::VisClaw.AMR)

replace values at coarser grids (lower levels) into NaN
"""
function coarsegridmask!(tiles::Vector{VisClaw.AMRGrid})
    ## return if single tile
    length(tiles)==1 && (return tiles)
    ## levels
    level_tiles = getfield.(tiles, :AMRlevel)
    maxlevel = maximum(level_tiles)

    for tl in tiles
        tl.AMRlevel == maxlevel && (continue)

        ## generate point data for all points in the target tile
        x_target, y_target = VisClaw.meshtile(tl)
        cellp = GeometricalPredicates.Point.(x_target, y_target)
        ## get the corners of the target tile
        xl, xr, yb, yt = VisClaw.getlims(tl)

        ## find tiles: one level finer
        ind_fine = tl.AMRlevel+1 .== level_tiles
        tile_fine = tiles[ind_fine]
        nfine = length(tile_fine)
        isempty(tile_fine) && (continue)

        ## fine tiles: inside of the target tiles
        ind_inside = trues(nfine)
        for j = 1:nfine
            x1, x2, y1, y2 = VisClaw.getlims(tile_fine[j])
            if x2 < xl || xr < x1 || y2 < yb || yt < y1
                ind_inside[j] = false
            end
        end
        tile_fine = tile_fine[ind_inside]
        nfine = length(tile_fine)
        isempty(tile_fine) && (continue)

        ## find grid where finer grids are assigned
        for j = 1:nfine
            poly = VisClaw.tilepolygon(tile_fine[j])
            inside = [GeometricalPredicates.inpolygon(poly, cellp[irow, jcol]) for irow=1:tl.my, jcol=1:tl.mx]
            if isa(tl, VisClaw.Velocity)
                tl.u[inside] .= NaN
                tl.v[inside] .= NaN
                tl.vel[inside] .= NaN
            elseif isa(tl, VisClaw.Storm)
                tl.u[inside] .= NaN
                tl.v[inside] .= NaN
                tl.slp[inside] .= NaN
            elseif isa(tl, VisClaw.SurfaceHeight)
                tl.eta[inside] .= NaN
            end
        end
    end
    return tiles
end
###############################################
function coarsegridmask!(amrs::VisClaw.AMR)
    amrs.amr = map(coarsegridmask!, amrs.amr)
    return amrs
end
###############################################
