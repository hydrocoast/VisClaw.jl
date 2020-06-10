default_masktxt = "topo4mask.txt"
default_maskgrd = "topomask.grd"
tmp4grd = "tmp4grd.txt"

###################################################
"""
    filename = landmask_asc(topo::VisClaw.Topo, filename::String=default_masktxt)

output [x y z] data in txt for masking
"""
function landmask_asc(topo::VisClaw.Topo, filename::String=default_masktxt)
    xv = vec(repeat(topo.x, inner=(topo.nrows,1)))
    yv = vec(repeat(topo.y, outer=(topo.ncols,1)))
    topov = vec(topo.elevation);

    inds = topov .< 0.0 # ocean
    deleteat!(xv, inds)
    deleteat!(yv, inds)
    deleteat!(topov, inds)

    open(filename, "w") do file
        Base.print_array(file, [xv yv topov])
    end
    return filename
end
###################################################

###################################################
"""
    G = landmask_grd(txtfile::String=default_masktxt; grdfile::String="", kwargs...)

output masking grid
"""
function landmask_grd(txtfile::String=default_masktxt;
                      grdfile::String="", kwargs...)
    # check
    if !isfile(txtfile); error("Not found: $txtfile"); end

    # keyword args
    d = KWARG(kwargs)

    # (part of GMT.jl surface.jl)
    cmd = GMT.parse_common_opts(d, "", [:R :V_params :a :bi :di :e :f :h :i :r :yx])
    #println(cmd)

    # (part of GMT.jl psmask.jl)
    cmd = GMT.parse_common_opts(d, cmd, [:I :UVXY :JZ :c :e :p :r :t :yx :params], true)
    cmd = GMT.parse_these_opts(cmd, d, [[:C :end_clip_path], [:D :dump], [:F :oriented_polygons],
                    [:L :node_grid], [:N :invert], [:Q :cut_number], [:S :search_radius], [:T :tiles]])
    #println(cmd)

    if isempty(grdfile)
        grdfile = default_maskgrd
        Gout = true
    else
        Gout = false
    end

    # grid
    GMT.gmt("grdmask \"$txtfile\" $cmd -G\"$grdfile\" ")

    # return
    if Gout
        G = GMT.gmt("read -Tg $grdfile")
        rm(grdfile, force=true)
        return G
    else
        return nothing
    end
end
###################################################


###################################################
"""
    G = tilegrd(tile::VisClaw.AMRGrid; length_unit::String="", kwargs...)

make a grid file of VisClaw.AMRGrid with landmask
"""
function tilegrd(tile::VisClaw.AMRGrid; length_unit::String="", kwargs...)
    # var
    var = VisClaw.keytile(tile)
    # prameters & options
    R = VisClaw.getR_tile(tile)
    Δ = tile.dx

    xvec, yvec, zdata = VisClaw.tilez(tile, var)
    xmat = repeat(xvec, inner=(length(yvec),1))
    ymat = repeat(yvec, outer=(length(xvec),1))

    if !isempty(length_unit)
        Δ = "$(Δ)"*length_unit
        # +ue?
        R = length_unit*R
    end

    # if NaN in all
    if !any(.!isnan.(zdata[:]))
        tmp_eta = "eta_tile.grd"
        faint="tmp.txt"
        open(faint, "w") do file
            Base.print_array(file, [xmat[:] ymat[:]])
        end
        GMT.gmt("grdmask $faint -R$R -I$Δ -S$Δ -NNaN/NaN/NaN -G$tmp_eta ")
        G = GMT.gmt("read -Tg $tmp_eta")
        rm(faint, force=true)
    else
        # eta grid
        G = GMT.surface([xmat[:] ymat[:] zdata[:]]; R=R, I=Δ, kwargs...)
    end

    # return value (GMT.GMTgrid)
    return G
end
###################################################

###################################################
"""
    G = tilegrd_xyz(tile::VisClaw.AMRGrid; kwargs...)

make a grid file of VisClaw.AMRGrid
"""
function tilegrd_xyz(tile::VisClaw.AMRGrid; kwargs...)
    # var
    var = VisClaw.keytile(tile)
    # prameters & options
    R = VisClaw.getR_tile(tile)
    Δ = tile.dx

    xvec, yvec, zdata = VisClaw.tilez(tile, var)
    nx = length(xvec)
    ny = length(yvec)
    xvec = repeat(xvec, inner=(ny,1)) |> vec
    yvec = repeat(yvec, outer=(nx,1)) |> vec
    zvec = vec(zdata)
    inds = isnan.(zvec)
    deleteat!(xvec, inds)
    deleteat!(yvec, inds)
    deleteat!(zvec, inds)

    tmp4grd = "tmp4grd.txt"
    f = open(tmp4grd, "w"); Base.print_array(f, [xvec yvec zvec]); close(f)
    G = GMT.gmt("xyz2grd $(tmp4grd)  -R$(R) -I$(Δ)")
    rm(tmp4grd, force=true)

    # return value (GMT.GMTgrid)
    return G
end
###################################################

###################################################
"""
    G = tilegrd_mask(tile::VisClaw.AMRGrid, maskfile::String=""; length_unit::String="", kwargs...)

make a grid file of VisClaw.AMRGrid with landmask
"""
function tilegrd_mask(tile::VisClaw.AMRGrid, maskfile::String=""; length_unit::String="", kwargs...)
    # var
    var = VisClaw.keytile(tile)
    # prameters & options
    R = VisClaw.getR_tile(tile)
    Δ = tile.dx
    r = sqrt(2.0)Δ

    xvec, yvec, zdata = VisClaw.tilez(tile, var)
    xmat = repeat(xvec', inner=(length(yvec),1))
    ymat = repeat(yvec, outer=(length(xvec),1))

    tmp_mask = "mask_tile.grd"
    tmp_eta = "eta_tile.grd"
    eta_masked = "eta_masked.grd"

    if !isempty(length_unit)
        Δ = "$(Δ)"*length_unit
        r = "$(r)"*length_unit
        # +ue?
        R = length_unit*R
    end

    # makegrd
    # land mask grid
    VisClaw.landmask_grd(maskfile; grdfile=tmp_mask, R=R, I=Δ, S=r, N="0/0/NaN", kwargs...)


    # if NaN in all
    if !any(.!isnan.(zdata[:]))
        faint="tmp.txt"
        open(faint, "w") do file
            Base.print_array(file, [xmat[:] ymat[:]])
            #Base.print_array(file, [xmat[:] reverse(ymat, dims=1)[:]])
        end
        GMT.gmt("grdmask $faint -R$R -I$Δ -S$Δ -NNaN/NaN/NaN -G$tmp_eta ")
        rm(faint, force=true)
    else
        # eta grid
        GMT.surface([xmat[:] ymat[:] zdata[:]]; R=R, I=Δ, G=tmp_eta)
    end

    # masking
    GMT.gmt("grdmath $tmp_eta $tmp_mask OR = $eta_masked ")
    # read
    G = GMT.gmt("read -Tg $eta_masked ")

    rm(tmp_mask)
    rm(tmp_eta)
    rm(eta_masked)


    # return value (GMT.GMTgrid)
    return G
end
###################################################
