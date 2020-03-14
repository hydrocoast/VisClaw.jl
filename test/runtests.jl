using VisClaw
using Test
using Printf

# make a list
exdir = joinpath(dirname(pathof(VisClaw)), "../example")
filelist = readdir(exdir)
filter!(x->occursin(".jl", x), filelist)
map(s->filter!(x->!occursin(s, x), filelist), ["check", "fgmax", "run_examples", "GMT"])

# number
nf = length(filelist)
println(@sprintf("%d", nf)*" files are going to be tested...")

using GR: GR
GR.inline("pdf")

scratchdir = joinpath(CLAW, "geoclaw/scratch")
@testset "VisClaw.jl" begin
    # Write your own tests here. 
    # for loop
    for f in filelist
        println(f)
        try 
            #include(joinpath(exdir,f))
            @test_nowarn include(joinpath(exdir,f))
        catch e
            println("Failed "*f)

            bt = backtrace()
            msg = sprint(showerror, e, bt)
            println(msg)

            println()
            continue
        end
    end
end
