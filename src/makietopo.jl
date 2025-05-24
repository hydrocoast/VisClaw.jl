### ======================================
### topo
### ======================================
"""
    ax = makietopo(topo::VisClaw.Topo; kwargs...)
    makietopo!(ax, topo::VisClaw.Topo; kwargs...)

Function: variables of AMR grids in heatmap plot
Arguments:
- `ax`: the axis to plot on
- `topo`: topography data
"""
function makietopo!(ax, topo::VisClaw.Topo; kwargs...)
    # Create a heatmap with the specified parameters
    CairoMakie.heatmap!(ax, topo.x, topo.y, topo.elevation'; kwargs...)
    return ax
end
"""
$(@doc makietopo!)
"""
makietopo(topo::VisClaw.Topo; kwargs...) = 
makietopo!(CairoMakie.Axis(CairoMakie.Figure()), topo; kwargs...)



### ======================================
### dtopo
### ======================================
"""
    ax = makiedtopo(topo::VisClaw.DTopo, itime::Integer=0; kwargs...)
    makiedtopo!(ax, topo::VisClaw.DTopo, itime::Integer=0; kwargs...)

Function: variables of AMR grids in heatmap plot
Arguments:
- `ax`: the axis to plot on
- `topo`: topography data
- `itime`: time step
"""
function makiedtopo!(ax, dtopo::VisClaw.DTopo, itime=0; kwargs...)
    ( (itime < 0) || (dtopo.mt < itime) ) && error("Invalid time")
    if dtopo.mt==1;     z = dtopo.deform
    elseif  itime == 0; z = dtopo.deform[:,:,end]
    else;               z = dtopo.deform[:,:,itime]
    end
    CairoMakie.heatmap!(ax, dtopo.x, dtopo.y, z'; kwargs...)
    return ax
end
"""
$(@doc makiedtopo!)
"""
makiedtopo(dtopo::VisClaw.Topo, itime=0; kwargs...) = 
makiedtopo!(CairoMakie.Axis(CairoMakie.Figure()), dtopo, itime; kwargs...)



