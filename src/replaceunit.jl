
#################################
function replaceunit!(fgmax::VisClaw.FGmaxValue, unit::Symbol)
    if !haskey(timedict, unit)
        error("Invalid specification of unit")
    end
    if !haskey(timedict, fgmax.unittime)
        error("Invalid symbol in fgmax")
    end

    ratio = timedict[fgmax.unittime]/timedict[unit]
    if abs(ratio - 1.0) < 1e-5; return fgmax; end

    # convert
    fgmax.unittime = unit

    fgmax.th = ratio.*fgmax.th
    if !isempty(fgmax.tv)
        fgmax.tv = ratio.*fgmax.tv
    end
    if !isempty(fgmax.tM)
        fgmax.tM = ratio.*fgmax.tM
        fgmax.tMflux = ratio.*fgmax.tMflux
        fgmax.thmin = ratio.*fgmax.thmin
    end
    return fgmax
end
#################################

#################################
function replaceunit!(gauge::VisClaw.Gauge, unit::Symbol)
    !haskey(timedict, unit) && error("Invalid specification: unit")
    !haskey(timedict, gauge.unittime) && error("Invalid symbol in gauge")

    ratio = timedict[gauge.unittime]/timedict[unit]
    if abs(ratio - 1.0) < 1e-5; return gauge; end

    # convert
    gauge.unittime = unit
    gauge.time = ratio.*gauge.time
    # return value
    return gauge
end
#################################

#################################
function replaceunit!(amrs::VisClaw.AMR, unit::Symbol)
    !haskey(timedict, unit) && error("Invalid specification: unit")
    !haskey(timedict, amrs.unittime) && error("Invalid symbol in AMR")

    ratio = timedict[amrs.unittime]/timedict[unit]
    if abs(ratio - 1.0) < 1e-5; return amrs; end

    # convert
    amrs.unittime = unit
    amrs.timelap = ratio.*amrs.timelap
    # return value
    return amrs
end
#################################
