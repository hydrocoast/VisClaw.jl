function run_examples(directory=dirname(pathof(VisClaw))*"/../example"; kw_exclude=["check", "fgmax"], kw_include=[""])
    if !isdir(directory); println("$directory is not found"); end

    filelist = readdir(directory)
    filter!(x->occursin(".jl", x), filelist)
    filter!(x->!occursin("run_examples.jl", x), filelist)
    map(s->filter!(x->!occursin(s, x), filelist), kw_exclude)
    map(s->filter!(x->occursin(s, x), filelist), kw_include)

    nf = length(filelist)
    println(@sprintf("%d", nf)*" files are found")

    global num_failed = 0
    global errorfile = []

    for i = 1:nf
        println("$i/$nf   run "*filelist[i]*" ...")
        try
            @time include(joinpath(directory, filelist[i]))
            println()
        catch e
            println("Failed "*filelist[i])

            num_failed = num_failed + 1
            push!(errorfile, filelist[i])

            bt = backtrace()
            msg = sprint(showerror, e, bt)
            println(msg)

            println()
            continue
        end
    end

    if num_failed == 0
        println("pass")
        return nothing
    else
        println("$num_failed files failed")
        return errorfile
    end

end
