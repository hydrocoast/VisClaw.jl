"""
    amr = loadfortq(filename::AbstractString, ncol::Integer; vartype::Symbol=:surface,
                    geoparams::VisClaw.GeoParam=VisClaw.GeoParam(), runup::Bool=true,
                    xlims=(-Inf,Inf), ylims=(-Inf,Inf), region="", AMRlevel=[])

Function: fort.qxxxx reader.
"""
function loadfortq(filename::AbstractString, ncol::Integer;
                   vartype::Symbol=:surface,
                   clawparams::VisClaw.ClawParam=VisClaw.ClawParam(), 
                   geoparams::VisClaw.GeoParam=VisClaw.GeoParam(), 
                   runup::Bool=true,
                   xlims=(-Inf,Inf), ylims=(-Inf,Inf), region="", AMRlevel=[])
    ## check
    !any(map(sym -> vartype == sym, [:surface, :current, :storm])) && error("kwarg 'vartype' is invalid")

    output_format = clawparams.output_format
    ngh = clawparams.num_ghost
    neq = clawparams.num_eqn
    ## output_format
    if output_format < 1 && output_format > 3
        error("kwarg 'output_format' must be 1, 2, or 3")
    end
    if output_format == 2; dtype = Float32
    elseif output_format == 3; dtype = Float64
    end

    ## unsupported combination of vartype and output_format
    if vartype==:storm && (output_format == 2 || output_format == 3)
        error("vartype=:storm is currently not supported for binary output format")
    end

    ## set range
    if isa(region, VisClaw.AbstractTopo); xlims=extrema(region.x); ylims=extrema(region.y); end
    if isa(region, VisClaw.Region); xlims=region.xlims; ylims=region.ylims; end

    ## file open
    f = open(filename,"r")
    txtorg = readlines(f)
    close(f) #close
    ## file open if binary
    if output_format == 2 || output_format == 3
        filename_bin = replace(filename, "fort.q" => "fort.b")
        fbin = open(filename_bin, "r")
    end

    ## count the number of lines and grids
    nlineall = length(txtorg)
    idx = occursin.("grid_number",txtorg)
    ngrid = length(txtorg[idx])

    if vartype==:surface
        amr = Array{VisClaw.SurfaceHeight}(undef,ngrid) ## preallocate
    elseif vartype==:current
        amr = Array{VisClaw.Velocity}(undef,ngrid)
    elseif vartype==:storm
        amr = Array{VisClaw.Storm}(undef,ngrid)
    end

    l = 1
    i = 1
    while l < nlineall
        ## read header
        #header = txtorg[1:8]
        header = txtorg[l:l+7]
        header = map(strip,header)
        gridnumber = parse(Int64, split(header[1],r"\s+")[1])
        AMRlevel_load = parse(Int64, split(header[2],r"\s+")[1])
        mx = parse(Int64, split(header[3],r"\s+")[1])
        my = parse(Int64, split(header[4],r"\s+")[1])
        xlow = parse(Float64, split(header[5],r"\s+")[1])
        ylow = parse(Float64, split(header[6],r"\s+")[1])
        dx = parse(Float64, split(header[7],r"\s+")[1])
        dy = parse(Float64, split(header[8],r"\s+")[1])

        if output_format == 1
            ## read variables
            body = txtorg[l+9:l+9+(mx+1)*my-1]

            # the next tile
            l = l+9+(mx+1)*my
            ## check AMRlevel
            if !isempty(AMRlevel); if isempty(findall(AMRlevel .== AMRlevel_load)); i += 1; continue; end; end
            ## check whether the tile is on the domain
            if (xlow+dx*mx < xlims[1]) | (xlims[2] < xlow); i += 1; continue; end
            if (ylow+dy*my < ylims[1]) | (ylims[2] < ylow); i += 1; continue; end

            if vartype==:surface
                elev = [parse(Float64, body[(i-1)*(mx+1)+j][26*(ncol-1)+1:26*ncol]) for i=1:my, j=1:mx]
                depth = [parse(Float64, body[(i-1)*(mx+1)+j][1:26]) for i=1:my, j=1:mx]
                # wet condition
                land = (elev-depth) .>= geoparams.dmin

                # sea surface anomaly
                (geoparams.eta0 != 0.0) && (elev[.!land] = elev[.!land].-geoparams.eta0)

                # inundation depth if wet
                runup && (elev[land] = depth[land])

                # NaN if dry
                elev[depth.<=0.0] .= NaN

                ## array
                amr[i] = VisClaw.SurfaceHeight(gridnumber,AMRlevel_load,mx,my,xlow,ylow,dx,dy,elev)

            elseif vartype==:current
                ucol = ncol
                vcol = ncol+1
                # read
                depth = [parse(Float64, body[(i-1)*(mx+1)+j][1:26]) for i=1:my, j=1:mx]
                u = [parse(Float64, body[(i-1)*(mx+1)+j][26*(ucol-1)+1:26*ucol]) for i=1:my, j=1:mx]
                v = [parse(Float64, body[(i-1)*(mx+1)+j][26*(vcol-1)+1:26*vcol]) for i=1:my, j=1:mx]
                # replace to NaN
                mask = depth.<=0.0
                depth[mask] .= NaN
                u[mask] .= NaN
                v[mask] .= NaN
                # calc
                u = u./depth
                v = v./depth
                vel = sqrt.(u.^2 .+ v.^2)
                ## array
                amr[i] = VisClaw.Velocity(gridnumber,AMRlevel_load,mx,my,xlow,ylow,dx,dy,u,v,vel)

            elseif vartype==:storm
                ucol = ncol
                vcol = ncol+1
                pcol = ncol+2
                u = [parse(Float64, body[(i-1)*(mx+1)+j][26*(ucol-1)+1:26*ucol]) for i=1:my, j=1:mx]
                v = [parse(Float64, body[(i-1)*(mx+1)+j][26*(vcol-1)+1:26*vcol]) for i=1:my, j=1:mx]
                p = [parse(Float64, body[(i-1)*(mx+1)+j][26*(pcol-1)+1:26*pcol]) for i=1:my, j=1:mx]
                p = p./1e+2

                # u[(abs.(u).<=1e-2) .& (abs.(v).<=1e-2)] .= NaN
                # v[(abs.(u).<=1e-2) .& (abs.(v).<=1e-2)] .= NaN

                ## array
                amr[i] = VisClaw.Storm(gridnumber,AMRlevel_load,mx,my,xlow,ylow,dx,dy,u,v,p)
            end
            ## print
            #@printf("%d, ",gridnumber)

        else # output_format == 2 || output_format == 3
            # the next tile
            l += 9

            nall = (neq+1)*(mx+2ngh)*(my+2ngh)
            dat = Vector{dtype}(undef, nall)
            for k = 1:nall
                dat[k] = read(fbin, dtype)
            end

            ## check AMRlevel
            if !isempty(AMRlevel); if isempty(findall(AMRlevel .== AMRlevel_load)); i += 1; continue; end; end
            ## check whether the tile is on the domain
            if (xlow+dx*mx < xlims[1]) | (xlims[2] < xlow); i += 1; continue; end
            if (ylow+dy*my < ylims[1]) | (ylims[2] < ylow); i += 1; continue; end


            ## assign to the AMR array
            dat = permutedims(reshape(dat, (neq+1, mx+2ngh, my+2ngh)), (1, 3, 2))  # (var, y, x)
            depth = dat[1, :, :]  # total water depth
            if vartype==:surface
                elev = dat[neq+1, :, :]  # just take the second variable

                # wet condition
                land = (elev-depth) .>= geoparams.dmin

                # sea surface anomaly
                (geoparams.eta0 != 0.0) && (elev[.!land] = elev[.!land].-geoparams.eta0)

                # inundation depth if wet
                runup && (elev[land] = depth[land])

                # NaN if dry
                elev[depth.<=0.0] .= NaN

                ## remove ghost cells
                elev = elev[ngh+1:ngh+my, ngh+1:ngh+mx]

                ## array
                amr[i] = VisClaw.SurfaceHeight(gridnumber,AMRlevel_load,mx,my,xlow,ylow,dx,dy,elev)

            elseif vartype==:current
                u = dat[2, :, :]  # just take the second variable
                v = dat[3, :, :]  # just take the third variable

                # replace to NaN
                mask = depth.<=0.0
                depth[mask] .= NaN
                u[mask] .= NaN
                v[mask] .= NaN
                # calc
                u = u./depth
                v = v./depth

                ## remove ghost cells
                u = u[ngh+1:ngh+my, ngh+1:ngh+mx]
                v = v[ngh+1:ngh+my, ngh+1:ngh+mx]

                vel = sqrt.(u.^2 .+ v.^2) # velocity magnitude
                ## array
                amr[i] = VisClaw.Velocity(gridnumber,AMRlevel_load,mx,my,xlow,ylow,dx,dy,u,v,vel)
            #=
            elseif vartype==:storm
                u = dat[2, :, :]  # just take the second variable
                v = dat[3, :, :]  # just take the third variable
                p = dat[4, :, :]  # just take the fourth variable
                p = p./1e+2  # convert to hPa
            =#
            end
        end

        ## counter; go to the next grid
        i += 1
    end

    ## file open if binary
    if output_format == 2 || output_format == 3
        close(fbin) #close
    end

    amr = amr[filter(i -> isassigned(amr, i), 1:length(amr))]
    ## return
    return amr
end
#################################
"""
    amr = loadforta(filename::AbstractString, ncol::Integer; kwargs...)

Function: fort.axxxx reader. See also [`loadfortq`](@ref).
"""
loadforta(filename::AbstractString, ncol::Integer; kwargs...) = loadfortq(filename, ncol; vartype=:storm, kwargs...)
#################################

#################################
"""
    timelaps = loadfortt(filename::AbstractString)

Function: fort.txxxx reader.
"""
function loadfortt(filename::AbstractString)
    ## file open
    f = open(filename,"r")
    txtorg = readlines(f)
    close(f) #close
    ## parse timelaps from the 1st line
    timelaps = parse(Float64, txtorg[1][1:18])
    ## return
    return timelaps
end
#################################

#######################################
"""
    amrs = loadsurface(outputdir::AbstractString, filesequence::AbstractVector; kwargs...)
    amrs = loadsurface(outputdir::AbstractString, fileid::Integer; kwargs...)

Function: load time-series of water surface.
          The keyword arguments follow [`loadfortq`](@ref).
          See also: [`loadfortt`](@ref).
"""
function loadsurface(outputdir::AbstractString, filesequence::AbstractVector=0:0; vartype::Symbol=:surface, kwargs...)

    # check
    !any(map(sym -> vartype == sym, [:surface, :current, :storm])) && error("kwarg 'vartype' is invalid")

    ## define the filepath & filename
    if vartype==:surface
        fnamekw = r"^fort\.q\d+$"
        col=4
    elseif vartype==:current
        fnamekw = r"^fort\.q\d+$"
        col=2
    elseif vartype==:storm
        fnamekw = r"^fort\.a\d+$"
        col=5
    end

    ## make a list
    isdir(outputdir) || error("Directory $outputdir doesn't exist")
    flist = readdir(outputdir)
    filter!(x->occursin(fnamekw, x), flist)
    isempty(flist) && error("File named $fnamekw was not found")

    # load geoclaw.data
    #geoparams = VisClaw.geodata(outputdir)
    clawparams = VisClaw.clawdata(outputdir)

    ## the number of files
    nfile = length(flist)

    # file sequence to be loaded
    if filesequence==0:0; filesequence = 1:nfile; end
    (any(filesequence .< 1) || any(filesequence .> nfile)) && error("Incorrect file sequence was specified. (This must be from 1 to $nfile)")


    ## the number of files (to be loaded)
    nfile = length(filesequence)

    ## preallocate
    if vartype==:surface
        amr = Vector{AbstractVector{VisClaw.SurfaceHeight}}(undef,nfile)
    elseif vartype==:current
        amr = Vector{AbstractVector{VisClaw.Velocity}}(undef,nfile)
    elseif vartype==:storm
        amr = Vector{AbstractVector{VisClaw.Storm}}(undef,nfile)
    end

    ## load all files
    tlap = vec(zeros(nfile,1))
    cnt = 0
    for it = filesequence
        cnt += 1
        if vartype==:surface
            amr[cnt] = VisClaw.loadfortq(joinpath(outputdir,flist[it]), col; vartype=vartype, clawparams=clawparams, kwargs...)
        elseif vartype==:current
            amr[cnt] = VisClaw.loadfortq(joinpath(outputdir,flist[it]), col; vartype=vartype, clawparams=clawparams, kwargs...)
        elseif vartype==:storm
            amr[cnt] = VisClaw.loadforta(joinpath(outputdir,flist[it]), col; clawparams=clawparams, kwargs...)
        end
        tlap[cnt] = VisClaw.loadfortt(joinpath(outputdir,replace(flist[it],r"\.." => ".t")))
    end

    ## AMR Array
    amrs = VisClaw.AMR(nfile,tlap,amr)

    ## return value
    return amrs
end
#######################################
loadsurface(outputdir::AbstractString, fileid::Integer; kwargs...) =
loadsurface(outputdir, fileid:fileid; kwargs...)
#######################################

######################################
"""
    amrs = loadstorm(outputdir::AbstractString, filesequence::AbstractVector=0:0; kwargs...)
    amrs = loadstorm(outputdir::AbstractString, fileid::Integer; kwargs...)

Function: load time-series of storm data.
          The keyword arguments follow [`loadfortq`](@ref).
          See also: [`loadfortt`](@ref).
"""
loadstorm(outputdir::AbstractString, filesequence::AbstractVector=0:0; kwargs...) =
loadsurface(outputdir, filesequence; vartype=:storm, kwargs...)
#######################################
loadstorm(outputdir::AbstractString, fileid::Integer; kwargs...) =
loadsurface(outputdir, fileid:fileid; vartype=:storm, kwargs...)
#######################################

#######################################
"""
    amrs = loadcurrent(outputdir::AbstractString, filesequence::AbstractVector=0:0; kwargs...)
    amrs = loadcurrent(outputdir::AbstractString, fileid::Integer; kwargs...)

Function: load time-series of ocean current data.
          The keyword arguments follow [`loadfortq`](@ref).
          See also: [`loadfortt`](@ref).
"""
loadcurrent(outputdir::AbstractString, filesequence::AbstractVector=0:0; kwargs...) =
loadsurface(outputdir, filesequence, vartype=:current, kwargs...)
#######################################
loadcurrent(outputdir::AbstractString, fileid::Integer; kwargs...) =
loadsurface(outputdir, fileid:fileid; vartype=:current, kwargs...)
#######################################
