### Define Structs
abstract type AbstractAMR end
abstract type AMRGrid <: VisClaw.AbstractAMR end

###################################
"""
Struct:
 storm data
"""
mutable struct Storm <: VisClaw.AMRGrid
    gridnumber::Integer
    AMRlevel::Integer
    mx::Integer
    my::Integer
    xlow::Float64
    ylow::Float64
    dx::Float64
    dy::Float64
    u::AbstractArray{Float64,2}
    v::AbstractArray{Float64,2}
    slp::AbstractArray{Float64,2}
    # Constructor
    VisClaw.Storm(gridnumber, AMRlevel, mx, my, xlow, ylow, dx, dy, u, v, slp) =
    new(gridnumber, AMRlevel, mx, my, xlow, ylow, dx, dy, u, v, slp)
end
###################################

###################################
"""
Struct: Water veloccity
"""
mutable struct Velocity <: VisClaw.AMRGrid
    gridnumber::Integer
    AMRlevel::Integer
    mx::Integer
    my::Integer
    xlow::Float64
    ylow::Float64
    dx::Float64
    dy::Float64
    u :: AbstractArray{Float64,2}
    v :: AbstractArray{Float64,2}
    vel :: AbstractArray{Float64,2}
    # Constructor
    VisClaw.Velocity(gridnumber, AMRlevel, mx, my, xlow, ylow, dx, dy, u, v, vel) =
    new(gridnumber, AMRlevel, mx, my, xlow, ylow, dx, dy, u, v, vel)
end
###################################

###################################
"""
Struct: Sea Surface Height
"""
mutable struct SurfaceHeight <: VisClaw.AMRGrid
    gridnumber::Integer
    AMRlevel::Integer
    mx::Integer
    my::Integer
    xlow::Float64
    ylow::Float64
    dx::Float64
    dy::Float64
    eta::AbstractArray{Float64,2}
    # Constructor
    VisClaw.SurfaceHeight(gridnumber, AMRlevel, mx, my, xlow, ylow, dx, dy, eta) =
    new(gridnumber, AMRlevel, mx, my, xlow, ylow, dx, dy, eta)
end
###################################

###################################
"""
Struct:
 time-seies of AMR data
"""
mutable struct AMR <: VisClaw.AbstractAMR
    nstep::Integer
    timelap::AbstractVector
    amr :: AbstractVector{Vector{VisClaw.AMRGrid}}
    unittime :: Symbol
    # Constructor
    VisClaw.AMR(nstep, timelap, amr) = new(nstep, timelap, amr, :second)
end
###################################

abstract type AbstractTopo end
###################################
"""
Struct:
 topography and bathymetry
"""
struct Topo <: AbstractTopo
    ncols :: Integer
    nrows :: Integer
    x :: AbstractVector
    y :: AbstractVector
    dx :: Float64
    dy :: Float64
    elevation :: AbstractArray{Float64,2}
    # Constructor
    VisClaw.Topo(ncols, nrows, x, y, dx, dy, elevation) =
             new(ncols, nrows, x, y, dx, dy, elevation)
end
###################################

##########################################################
"""
Struct:
 seafloor deformation for tsunami computation
"""
struct DTopo <: AbstractTopo
    mx :: Integer
    my :: Integer
    x :: AbstractVector
    y :: AbstractVector
    dx :: Float64
    dy :: Float64
    mt :: Integer
    t0 :: Float64
    dt :: Float64
    deform :: AbstractArray{Float64}
    # Constructor
    VisClaw.DTopo(mx,my,x,y,dx,dy,mt,t0,dt,deform) = new(mx,my,x,y,dx,dy,mt,t0,dt,deform)
end
##########################################################

########################################
"""
Struct: parameters in geoclaw.data
"""
struct GeoParam
    cs :: Integer # coordinate system
    p0:: Float64 # ambient pressure
    R :: Float64 # earth radious
    eta0 :: Float64 # sea level
    n ::Float64 # manning coafficient
    dmin :: Float64 # dry tolerance
    # Constructor
    VisClaw.GeoParam() = new(2,101300.0,6367500.0,0.0,0.025,0.001)
    VisClaw.GeoParam(cs,p0,R,eta0,n,dmin) = new(cs,p0,R,eta0,n,dmin)
end
########################################

########################################
"""
Struct: parameters in surge.data
"""
struct SurgeParam
    windindex::Integer
    slpindex::Integer
    stormtype::Integer
    # Constructor
    VisClaw.SurgeParam() = new(5,7,1)
    VisClaw.SurgeParam(windindex,slpindex,stormtype) = new(windindex,slpindex,stormtype)
end
########################################

########################################
"""
Struct: gauge data
"""
mutable struct Gauge
    label :: AbstractString # Name
    id :: Integer # gauge id
    nt :: Integer # number of time step
    loc :: AbstractVector{Float64} # gauge location
    AMRlevel :: AbstractVector{Integer}
    time :: AbstractVector # time
    eta :: AbstractVector{Float64} # surface
    u :: AbstractVector{Float64} # u
    v :: AbstractVector{Float64} # v
    unittime :: Symbol
    # Constructor
    VisClaw.Gauge(label,id,nt,loc,AMRlevel,time,eta) = new(label,id,nt,loc,AMRlevel,time,eta,[],[], :second)
    VisClaw.Gauge(label,id,nt,loc,AMRlevel,time,eta,u,v) = new(label,id,nt,loc,AMRlevel,time,eta,u,v, :second)
end
########################################

########################################
"""
Struct: max values at a gauge
"""
mutable struct Gaugemax
    label :: AbstractString # Name
    id :: Integer # gauge id
    loc :: AbstractVector{Float64} # gauge location
    AMRlevel :: Integer
    eta :: Float64
    vel :: Float64
    t_eta
    t_vel
    unittime :: Symbol
    # Constructor
    VisClaw.Gaugemax(label,id,loc,AMRlevel,eta,vel,t_eta,t_vel,unittime) = new(label,id,loc,AMRlevel,eta,vel,t_eta,t_vel,unittime)
end
########################################

########################################
"""
Struct: Fixed grid
"""
struct FixedGrid
    id :: Integer
    style :: Integer
    nval :: Integer
    ## point_style = 2, 4
    nx :: Integer
    ny :: Integer
    xlims :: Tuple
    ylims :: Tuple
    ## point_style = 0, 1, 4
    npts :: Integer
    x :: AbstractVector{Float64}
    y :: AbstractVector{Float64}
    ## point_style = 4
    flag :: AbstractArray

    # Constructor
    ## point_style = 0, 1
    VisClaw.FixedGrid(id,style,nval,npts,x,y) = new(id,style,nval,0,0,(NaN,NaN),(NaN,NaN),npts,x,y,[])
    ## point_style = 2
    VisClaw.FixedGrid(id,style,nval,nx,ny,xlims,ylims) = new(id,style,nval,nx,ny,xlims,ylims,0,[NaN],[NaN],[])
    ## point_style = 3
    VisClaw.FixedGrid(id,style,nval,nx,ny,xlims,ylims,npts,x,y) = new(id,style,nval,nx,ny,xlims,ylims,npts,x,y,[])
    ## point_style = 4
    VisClaw.FixedGrid(id,style,nval,nx,ny,xlims,ylims,npts,x,y,flag) = new(id,style,nval,nx,ny,xlims,ylims,npts,x,y,flag)

end
########################################

########################################
"""
Struct: fgmax values
"""
mutable struct FGmax
    topo :: AbstractArray{Float64}
    D :: AbstractArray{Float64}
    v :: AbstractArray{Float64}
    M :: AbstractArray{Float64}
    Mflux :: AbstractArray{Float64}
    Dmin :: AbstractArray{Float64}
    tD :: AbstractArray
    tv :: AbstractArray
    tM :: AbstractArray
    tMflux :: AbstractArray
    tDmin :: AbstractArray
    tarrival :: AbstractArray
    unittime :: Symbol

    # Constructor
    VisClaw.FGmax(topo,D,tD,tarrival) =
              new(topo,D,emptyF,emptyF,emptyF,emptyF,tD,emptyF,emptyF,emptyF,emptyF,tarrival,:second)
    VisClaw.FGmax(topo,D,v,tD,tv,tarrival) =
              new(topo,D,v,emptyF,emptyF,emptyF,tD,tv,emptyF,emptyF,emptyF,tarrival,:second)
    VisClaw.FGmax(topo,D,v,M,Mflux,Dmin,tD,tv,tM,tMflux,tDmin,tarrival) =
              new(topo,D,v,M,Mflux,Dmin,tD,tv,tM,tMflux,tDmin,tarrival,:second)
end
########################################


########################################
"""
Struct: track data container
"""
mutable struct Track
    timelap :: AbstractVector
    lon :: AbstractVector{Float64}
    lat :: AbstractVector{Float64}
    direction :: AbstractVector{Float64}
    unittime :: Symbol

    # Constructor
    VisClaw.Track(lon,lat) = new(empty([0.0]),lon,lat,empty([0.0]),:second)
    VisClaw.Track(timelap,lon,lat,direction) = new(timelap,lon,lat,direction,:second)
end
########################################
