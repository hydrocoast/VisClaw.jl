###################################
"""
    fgoutgrids = fgoutdata("simlation/path/_output"::AbstractString)
    fgoutgrids = fgoutdata("simlation/path/_output/fgout_grids.data"::AbstractString)

Function: fgout_grids.data reader
"""
function fgoutdata(outdir::AbstractString)
    ## definition of filename
    fname = occursin("fgout_grids.data", basename(outdir)) ? outdir : joinpath(outdir, "fgout_grids.data")

    ## check
    isfile(fname) || error("File $fname is not found.")
    ## read all lines
    open(fname,"r") do f
        global txt = readlines(f)
    end

    ## parse parameters
    num_fgout_grids = parse(Int64, split(txt[occursin.("num_fgout_grids",txt)][1],r"\s+")[1])

    ## preallocate
    fg = Vector{VisClaw.FixedGrid}(undef, num_fgout_grids)
    ## load
    global baseline = 10
    for i = 1:num_fgout_grids
        txt_fg = txt[baseline:baseline+10]
        ## parse parameters
        FGid = parse(Int64, split(txt_fg[occursin.("fgno",txt_fg)][1],r"\s+")[1])
        point_style = parse(Int64, split(txt_fg[occursin.("point_style",txt_fg)][1],r"\s+")[1])
        ## check point style
        (point_style !== 2) && error("point_style $point_style is not supported yet.")

        ## 0
        if point_style == 0
            error("point_style $point_style is not supported yet.")
        ## 1
        elseif point_style == 1
            error("point_style $point_style is not supported yet.")
        ## 2
        elseif point_style == 2
            nx, ny = parse.(Int64, split(txt_fg[occursin.("nx,ny",txt_fg)][1],r"\s+")[1:2])
            x1, y1 = parse.(Float64, split(txt_fg[occursin.("x1, y1",txt_fg)][1],r"\s+")[1:2])
            x2, y2 = parse.(Float64, split(txt_fg[occursin.("x2, y2",txt_fg)][1],r"\s+")[1:2])
            num_fgout_val = length(split(replace(txt_fg[occursin.("# q_out_vars",txt_fg)][1], "# q_out_vars" => ""), r"\s+") )-1
            # instance
            fg[i] = VisClaw.FixedGrid(FGid, point_style, num_fgout_val, nx, ny, (x1,x2), (y1,y2))
            baseline += 12

        ## 3
        elseif point_style == 3
            error("point_style $point_style is not supported yet.")
        ## 4
        elseif point_style == 4
            error("point_style $point_style is not supported yet.")
        end
    end

    ## return
    return fg
end
