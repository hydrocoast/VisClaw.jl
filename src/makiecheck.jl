function makiecheck(simdir::AbstractString, colorrange::Tuple=(-0.1, 0.1); vartype::Symbol=:surface, AMRlevel=[], kwargs...)

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
        amrs = loadfunction(simdir, i; AMRlevel=AMRlevel)

        ## plot
        CairoMakie.empty!(fig)
        ax = CairoMakie.Axis(fig[1,1], title=@sprintf("%8.1f s",amrs.timelap[1]))
        VisClaw.makieheatmap!(ax, amrs.amr[1]; colorrange=colorrange, wind=TFwind, kwargs...)
        CairoMakie.Colorbar(fig[1,2], limits=colorrange, flipaxis=false)

        ## show the figure
        CairoMakie.display(fig)
    end

    ## return value
    return fig
end
##############################################################################
