
###################################################################
"""
    gmtgrdimage_tiles(G::Vector{GMT.GMTgrid}; kwargs...)
"""
function gmtgrdimage_tiles(G::Vector{GMT.GMTgrid}; kwargs...)
    kwdict = KWARG(kwargs)
    B, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_B, "")

    GMT.grdimage(G[1]; B=B, kwdict...)
    if length(G) > 1; for g in G[2:end]; GMT.grdimage!(g; kwdict...); end; end
end
###################################################################
"""
$(@doc gmtgrdimage_tiles)
"""
function gmtgrdimage_tiles!(G::Vector{GMT.GMTgrid}; kwargs...)
    kwdict = KWARG(kwargs)
    B, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_B, "")

    GMT.grdimage!(G[1]; B=B, kwdict...)
    if length(G) > 1; for g in G[2:end]; GMT.grdimage!(g; kwdict...); end; end
end
###################################################################
