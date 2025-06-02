"""
    quickview(simdir::AbstractString; vartype::Symbol=:surface, AMRlevel=[], kwargs...)

Visualize the surface, storm, or wind data from a GeoClaw simulation.
The function reads the data files from the specified simulation directory and creates a heatmap visualization using CairoMakie.
"""
function quickview(simdir::AbstractString; vartype::Symbol=:surface, AMRlevel=[], kwargs...)

    !any([vartype==s for s in [:surface, :storm, :wind, :current]]) && error("Invalid input argument vartype: $vartype")
    ## define the filepath & filename
    if vartype==:surface
        fnamekw = r"^fort\.q\d+$"
        loadfunction = VisClaw.loadsurface
    elseif vartype==:current
        fnamekw = r"^fort\.q\d+$"
        loadfunction = VisClaw.loadcurrent
    elseif vartype==:storm || vartype==:wind
        fnamekw = r"^fort\.a\d+$"
        loadfunction = VisClaw.loadstorm
    end
    TFwind = vartype==:wind ? true : false

    ## make a list
    isdir(simdir) || error("Not found: directory $simdir")
    flist = readdir(simdir)
    filter!(x->occursin(fnamekw, x), flist)
    isempty(flist) && error("File named $fnamekw was not found")

    ## the number of files
    nfile = length(flist)

    if haskey(kwargs, :colormap)
        cmap = kwargs[:colormap]
        filter!(p -> first(p)!==:colormap, kwargs)
    else
        cmap = :viridis # default colormap
    end
    if haskey(kwargs, :colorrange)
        colorrange = kwargs[:colorrange]
        filter!(p -> first(p)!==:colorrange, kwargs)
    else
        if vartype==:surface
            colorrange = (-0.5, 0.5) # default color range for surface
        elseif vartype==:current
            colorrange = (0.0, 0.20) # default color range for current
        elseif vartype==:storm
            colorrange = (980.0, 1020.0) # default color range for storm pressure
        elseif vartype==:wind
            colorrange = (0.0, 30.0) # default color range for wind speed
        end
    end

    ## parameters (output format and number of ghost cells)
    clawparams = VisClaw.clawdata(simdir)

    fig = CairoMakie.Figure()
    ### draw figures until nothing or invalid number is input
    println(">> Press ENTER with a blank to finish")
    println(">> Input a file sequence number you want to plot:")
    ex=0 # initial value
    while ex==0
        ## accept input the step number of interest
        @printf("checkpoint time (1 to %d) = ", nfile)
        i = readline(stdin)

        ## check whether the input is integer
        if isempty(i); ex=1; continue; end;
        ## parse to interger
        i = try; parse(Int64,i)
        catch; "cannot be parsed to integer"; ex=1; continue;
        end
        ## check whether the input is valid number
        if ( (i>nfile) || (i<1) ); println("Invalid number"); ex=1; continue; end

        ## load data
        amrs = loadfunction(simdir, i; AMRlevel=AMRlevel, clawparams=clawparams, kwargs...)

        ## plot
        CairoMakie.empty!(fig)
        ax = CairoMakie.Axis(fig[1,1], title=@sprintf("%8.1f s",amrs.timelap[1]))
        VisClaw.makieheatmap!(ax, amrs.amr[1]; colorrange=colorrange, wind=TFwind, kwargs...)
        CairoMakie.Colorbar(fig[1,2], limits=colorrange, colormap=cmap, flipaxis=true)

        ## show the figure
        CairoMakie.display(fig)
    end

    ## return value
    return fig
end
##############################################################################


function quickviewfgout(simdir::AbstractString, fgno::Integer=1; kwargs...)

    fg = VisClaw.fgoutdata(simdir)
    num_fg = length(fg)
    fgno > num_fg && error("The number of fgout is $num_fg, but you requested $fgno")
    fgno < 1 && error("The number of fgout must be greater than 0, but you requested $fgno")
    fg = fg[fgno]
    
    ## kwargs defaults
    if haskey(kwargs, :colormap)
        cmap = kwargs[:colormap]
        filter!(p -> first(p)!==:colormap, kwargs)
    else
        cmap = :viridis # default colormap
    end
    if haskey(kwargs, :colorrange)
        colorrange = kwargs[:colorrange]
        filter!(p -> first(p)!==:colorrange, kwargs)
    else
        colorrange = (-0.5, 0.5) # default color range for surface
    end

    ## load fgout and plot
    fig = CairoMakie.Figure()
    ### draw figures until nothing or invalid number is input
    println(">> Press ENTER with a blank to finish")
    println(">> Input a file sequence number you want to plot:")
    ex=0 # initial value
    while ex==0
         ## accept input the step number of interest
        @printf("checkpoint time (1 to %d) = ", fg.nout)
        i = readline(stdin)

        ## check whether the input is integer
        if isempty(i); ex=1; continue; end;
        ## parse to interger
        i = try; parse(Int64,i)
        catch; "cannot be parsed to integer"; ex=1; continue;
        end
        ## check whether the input is valid number
        if ( (i>fg.nout) || (i<1) ); println("Invalid number"); ex=1; continue; end

        ## load data
        fgout = loadfgout(simdir, fg, i)

        ## plot
        CairoMakie.empty!(fig)
        ax = CairoMakie.Axis(fig[1,1], title=@sprintf("fgout no.%d,  %03d/%03d",fg.id, i, fg.nout))
        VisClaw.makieheatmap!(ax, fg, fgout; colorrange=colorrange, colormap=cmap, kwargs...)
        CairoMakie.Colorbar(fig[1,2], limits=colorrange, colormap=cmap, flipaxis=true)

        ## show the figure
        CairoMakie.display(fig)
    end

    ## return value
    return fig

end