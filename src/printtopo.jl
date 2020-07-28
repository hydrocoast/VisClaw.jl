############################################
"""
    printtopoESRI(topo::VisClaw.Topo, filename::String; nodatavalue::Int64=-9999, center::Bool=true)

print topo data as a file (ESRI ASCII format)
"""
function printtopoESRI(topo::VisClaw.Topo, filename::String="topo.asc"; nodatavalue::Int64=-9999, center::Bool=true)
    nrows, ncols = size(topo.elevation)
    ## print
    open(filename, "w") do fileIO
        ## header
        @printf(fileIO, "%d    ncols\n", ncols)
        @printf(fileIO, "%d    nrows\n", nrows)
        if center
            @printf(fileIO, "%e    xllcenter\n", topo.x[1])
            @printf(fileIO, "%e    yllcenter\n", topo.y[1])
        else
            @printf(fileIO, "%e    xllcorner\n", topo.x[1])
            @printf(fileIO, "%e    yllcorner\n", topo.y[1])
        end
        @printf(fileIO, "%e    cellsize\n", topo.dx)
        @printf(fileIO, "%d    nodatavalue\n", nodatavalue)
        ## elevation
        [(if j != ncols
              @printf(fileIO, "%14.6e ", topo.elevation[i,j])
          else
              @printf(fileIO, "%14.6e\n", topo.elevation[i,j])
          end) for j=1:ncols, i=nrows:-1:1]
    end ## close
    return nothing
end
############################################
const printtopo = printtopoESRI

############################################
"""
    printdtopo(dtopo::VisClaw.DTopo, filename::String; center::Bool=true)

print dtopo data as a topotype-3-file
"""
function printdtopo(dtopo::VisClaw.DTopo, filename::String="dtopo.asc"; center::Bool=true)
    ## print
    open(filename, "w") do fileIO
        ## header
        @printf(fileIO, "%d    mx\n", dtopo.mx)
        @printf(fileIO, "%d    my\n", dtopo.my)
        @printf(fileIO, "%d    mt\n", dtopo.mt)
        if center
            @printf(fileIO, "%e    xllcenter\n", dtopo.x[1])
            @printf(fileIO, "%e    yllcenter\n", dtopo.y[1])
        else
            @printf(fileIO, "%e    xllcorner\n", dtopo.x[1])
            @printf(fileIO, "%e    yllcorner\n", dtopo.y[1])
        end
        @printf(fileIO, "%e    t0\n", dtopo.t0)
        @printf(fileIO, "%e    dx\n", dtopo.dx)
        @printf(fileIO, "%e    dy\n", dtopo.dy)
        @printf(fileIO, "%e    dt\n", dtopo.dt)
        ## dtopo
        if dtopo.mt == 1
            [(if j != dtopo.mx
                  @printf(fileIO, "%14.6e ", dtopo.deform[i,j])
              else
                  @printf(fileIO, "%14.6e\n", dtopo.deform[i,j])
              end) for j=1:dtopo.mx, i=dtopo.my:-1:1]
        else
            [(if j != dtopo.mx
                  @printf(fileIO, "%14.6e ", dtopo.deform[i,j,k])
              else
                  @printf(fileIO, "%14.6e\n", dtopo.deform[i,j,k])
              end) for j=1:dtopo.mx, i=dtopo.my:-1:1, k=1:dtopo.mt]
        end
    end ## close
    return nothing
end
############################################
