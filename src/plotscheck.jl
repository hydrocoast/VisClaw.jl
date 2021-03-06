##############################################################################
"""
    plt = plotscheck("simlation/path/_output"::AbstractString; vartype::Symbol=:surface, AMRlevel=[], runup=true, region="", kwargs...)

Quick checker of the spatial distribution
"""
function plotscheck(simdir::AbstractString; vartype::Symbol=:surface, AMRlevel=[], runup::Bool=true, region="", testplot::Bool=false, kwargs...)

    !any([vartype==s for s in [:surface, :storm, :current]]) && error("Invalid input argument vartype: $vartype")
    ## define the filepath & filename
    if vartype==:surface
        fnamekw = r"^fort\.q\d+$"
        loadfunction = VisClaw.loadsurface
        kwargs_load = Dict([(:runup, runup)])
    elseif vartype==:current
        fnamekw = r"^fort\.q\d+$"
        loadfunction = VisClaw.loadcurrent
        kwargs_load = Dict([])
    elseif vartype==:storm
        fnamekw = r"^fort\.a\d+$"
        loadfunction = VisClaw.loadstorm
        kwargs_load = Dict([])
    end

    ## parse keyword args
    kwdict = KWARG(kwargs)
    ## xlims, ylims
    xlims, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_xlims, (-Inf,Inf))
    ylims, kwdict = VisClaw.kwarg_default(kwdict, VisClaw.parse_ylims, (-Inf,Inf))
    ## set range
    if isa(region, VisClaw.AbstractTopo); xlims=extrema(region.x); ylims=extrema(region.y); end
    if isa(region, VisClaw.Region); xlims=region.xlims; ylims=region.ylims; end

    ## make a list
    isdir(simdir) || error("Not found: directory $simdir")
    flist = readdir(simdir)
    filter!(x->occursin(fnamekw, x), flist)
    isempty(flist) && error("File named $fnamekw was not found")

    ## load geoclaw.data
    params = VisClaw.geodata(simdir)

    ## the number of files
    nfile = length(flist)

    ### draw figures until nothing or invalid number is input
    println(">> Press ENTER with a blank to finish")
    println(">> Input a file sequence number you want to plot:")
    ex=0 # initial value
    cnt=0
    while ex==0
        ## accept input the step number of interest
        @printf("checkpoint time (1 to %d) = ", nfile)
        i = testplot ? "1" : readline(stdin)
        if testplot; ex=1; end

        ## check whether the input is integer
        if isempty(i); ex=1; continue; end;
        ## parse to interger
        i = try; parse(Int64,i)
        catch; "cannot be parsed to integer"; ex=1; continue;
        end
        ## check whether the input is valid number
        if ( (i>nfile) || (i<1) ); println("Invalid number"); ex=1; continue; end

        ## load data
        amrs = loadfunction(simdir, i; AMRlevel=AMRlevel, xlims=xlims, ylims=ylims, kwargs_load...)
        runup && (coarsegridmask!(amrs))

        ## draw figure
        plt = VisClaw.plotsamr2d(amrs.amr[1]; AMRlevel=AMRlevel, xlims=xlims, ylims=ylims, kwdict...)
        plt = Plots.plot!(plt, title=@sprintf("%8.1f",amrs.timelap[1])*" s")

        ## show
        #plt = Plots.plot!(plt, show=true)
        display(plt)
        cnt += 1
    end

    ## if no plot is done
    if cnt==0; plt = nothing; end

    ## return value
    return plt
end
##############################################################################
