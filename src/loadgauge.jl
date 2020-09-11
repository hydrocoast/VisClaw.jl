#################################
"""
    gauges = loadgauge(dirname::AbstractString; eta0::Float64=0.0, labelhead::AbstractString="Gauge ", loadeta::Bool=true, loadvel::Bool=false)

gauge*.txt reader
"""
function loadgauge(dirname::AbstractString, gaugeid::AbstractVector{Int64}=0:0;
                   eta0=0.0, labelhead::AbstractString="Gauge ", loadeta::Bool=true, loadvel::Bool=false)
    # check args
    if !isdir(dirname); error("$dirname is not found or directory"); end
    files = readdir(dirname)
    filter!(x->occursin(r"^gauge\d+\.txt$", x), files)
    if isempty(files); println("No gauge file"); return nothing end;
    nf = length(files)

    gaugeid == 0:0 ? (gaugeid = 1:nf) : nothing

    nfload = length(gaugeid)

    # preallocate
    gauges = Vector{VisClaw.Gauge}(undef,nf)
    for k in gaugeid
        filename=joinpath(dirname,files[k])

        # read header
        f = open(filename,"r")
        header1 = readline(f)
        close(f)
        id = parse(Int64,header1[13:17])
        loc = [parse(Float64,header1[30:46]), parse(Float64,header1[48:64])]

        # read time-series of vars in the certain colmns
        ###dataorg = readdlm(filename, skipstart=2)
        dataorg = readdlm(filename, skipstart=3) # v5.7.0
        AMRlevel = convert.(Int64,dataorg[:,1])
        time = convert.(Float64,dataorg[:,2])
        D = convert.(Float64,dataorg[:,3])

        nt = length(time)
        if loadvel
            u = convert.(Float64,dataorg[:,4])./D
            v = convert.(Float64,dataorg[:,5])./D
        else
            u = v = empty([0.0])
        end
        if loadeta
            eta = convert.(Float64,dataorg[:,6])
            eta[D.<=1e-3] .= 0.0
            eta = eta.-eta0
        else
            eta = empty([0.0])
        end

        # label
        label = labelhead*@sprintf("%d",id)

        # instance
        gauges[k] = VisClaw.Gauge(label,id,nt,loc,AMRlevel,time,eta,u,v)
    end

    return gauges
end
#################################


loadgauge(dirname::AbstractString, gaugeid::Integer; eta0=0.0, labelhead::AbstractString="Gauge ", loadeta::Bool=true, loadvel::Bool=false) =
loadgauge(dirname, gaugeid:gaugeid; eta0=eta0, labelhead=labelhead, loadeta=loadeta, loadvel=loadvel)
