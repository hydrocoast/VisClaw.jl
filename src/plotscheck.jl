##############################################################################
"""
Quick checker of the spatial distribution
"""
function plotscheck(simdir::String, AMRlevel::AbstractVector{Int64}=empI; vartype::Symbol=:surface, runup=true, kwargs...)

    ## define the filepath & filename
    if vartype==:surface
        fnamekw = "fort.q0"
        loadfunction = VisClaw.loadsurface
        kwargs_load = Dict([(:runup, runup)])
    elseif vartype==:current
        fnamekw = "fort.q0"
        loadfunction = VisClaw.loadcurrent
        kwargs_load = Dict([])
    elseif vartype==:storm
        fnamekw = "fort.a0"
        loadfunction = VisClaw.loadstorm
        kwargs_load = Dict([])
    else
        error("Invalid input argument vartype: $vartype")
    end
    # parse keyword args
    kwdict = KWARG(kwargs)
    # xlims, ylims
    xlims, kwdict = VisClaw.parse_xlims(kwdict)
    ylims, kwdict = VisClaw.parse_ylims(kwdict)
    if xlims == nothing; xlims_load = (-Inf,Inf); end
    if ylims == nothing; ylims_load = (-Inf,Inf); end

    ## make a list
    if !isdir(simdir); error("Directory $simdir doesn't exist"); end
    flist = readdir(simdir)
    idx = occursin.(fnamekw,flist)
    if sum(idx)==0; error("File named $fnamekw was not found"); end
    flist = flist[idx]

    # load geoclaw.data
    params = VisClaw.geodata(simdir)

    ## the number of files
    nfile = length(flist)

    ### draw figures until nothing or invalid number is input
    println(">> Press ENTER with a blank to finish")
    println(">> Input a file sequence number you want to plot:")
    ex=0 # initial value
    cnt=0
    while ex==0
        # accept input the step number of interest
        @printf("checkpoint time (1 to %d) = ", nfile)
        i = readline(stdin)
        # check whether the input is integer
        if isempty(i); ex=1; continue; end;
        i=try
             parse(Int64,i)
          catch
             "input $s cannot be parsed to integer"
          end
        if isa(i,String); ex=1; println(i); continue; end;
        # check whether the input is valid number
        if (i>nfile) || (i<1)
            println("Invalid number")
            ex=1
            continue
        end

        amrs = loadfunction(simdir, i; xlims=xlims_load, ylims=ylims_load, kwargs_load...)

        # draw figure
        plt = VisClaw.plotsamr2d(amrs.amr[1], AMRlevel; xlims=xlims, ylims=ylims, kwdict...)
        plt = Plots.plot!(plt, title=@sprintf("%8.1f",amrs.timelap[1])*" s")

        # show
        #plt = Plots.plot!(plt, show=true)
        display(plt)
        cnt += 1
    end

    # if no plot is done
    if cnt==0
        plt = nothing
    end
    # return value
    return plt
end
##############################################################################
plotscheck(simdir::String, AMRlevel::Int64; kwargs...) =
plotscheck(simdir, AMRlevel:AMRlevel; kwargs...)
