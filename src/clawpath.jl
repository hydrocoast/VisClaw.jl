### Define your own clawpack path ###
if haskey(ENV, "CLAW")
    const CLAW = ENV["CLAW"]
else
    ## CLAW="/path/to/top/level/clawpack"
    println("ENV[\"CLAW\"] is not defined.")
    println("Set the env like the following in your default shell:")
    println("export CLAW = \"/path/to/top/level/clawpack\" ")
    CLAW = ""
    #if !isdir(CLAW); error("CLAW=$CLAW is not correct."); end
end
