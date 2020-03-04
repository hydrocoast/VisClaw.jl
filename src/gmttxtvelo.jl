###################################################
"""
Make txt file for psvelo (vector field)
"""
function txtvelo_center(txtfile::String,
                        LON, LAT, Ux, Uy;
                        skip::Int64=1,
                        offset1::Int64=0, offset2::Int64=offset1)

    ## count the element
    numel = length(vec(LON[1+offset1:skip:end-offset2, 1+offset1:skip:end-offset2]))

    ## round
    Ux = round.(Ux, digits=2)
    Uy = round.(Uy, digits=2)

    ## matrix
    outdat = hcat(
    vec(LON[1+offset1:skip:end-offset2, 1+offset1:skip:end-offset2]),
    vec(LAT[1+offset1:skip:end-offset2, 1+offset1:skip:end-offset2]),
    vec(Ux[1+offset1:skip:end-offset2, 1+offset1:skip:end-offset2]) ,
    vec(Uy[1+offset1:skip:end-offset2, 1+offset1:skip:end-offset2]) ,
    repeat([0.0 0.0 1.0], inner=(numel,4)) )

    ## output to file
    isfile(txtfile) ? mode="a" : mode="w"
    open(txtfile, mode) do file
        mode=="a" ? print(file,"\n") : nothing
        Base.print_array(file, outdat)
    end
    ## return
    return nothing
end
###################################################

###################################################
"""
Make txt file for scale (psvelo)
"""
function txtveloscale(txtfile, X,Y,Uscale; unit::String="m/s")
    #      Long. Lat. Evel Nvel Esig Nsig CorEN SITE
    outdat = "$X $Y $Uscale 0.0  0.0 0.0 0.0 $Uscale $unit"
    open(txtfile, "w") do file
        @printf(file, "%s",outdat)
    end

    return nothing
end
###################################################
