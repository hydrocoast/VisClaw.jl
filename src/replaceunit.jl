
#################################
function replaceunit!(fgmax::VisClaw.FGmaxValue, unit::Symbol)
    if !haskey(timedict, unit)
        error("Invalid specification of unit")
    end
    if !haskey(timedict, fgmax.unittime)
        error("Invalid symbol in fgmax")
    end

    ratio = timedict[fgmax.unittime]/timedict[unit]
    if abs(ratio - 1.0) < 1e-5; return; end

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
end
#################################

#################################
function replaceunit!(gauge::VisClaw.Gauge, unit::Symbol)
    if !haskey(timedict, unit)
        error("Invalid specification of unit")
    end
    if !haskey(timedict, gauge.unittime)
        error("Invalid symbol in gauge")
    end

    ratio = timedict[gauge.unittime]/timedict[unit]
    if abs(ratio - 1.0) < 1e-5; return; end

    # convert
    gauge.unittime = unit
    gauge.time = ratio.*gauge.time
end
#################################

#################################
function replaceunit!(amrs::VisClaw.AMR, unit::Symbol)
    if !haskey(timedict, unit)
        error("Invalid specification of unit")
    end
    if !haskey(timedict, amrs.unittime)
        error("Invalid symbol in AMR")
    end

    ratio = timedict[amrs.unittime]/timedict[unit]
    if abs(ratio - 1.0) < 1e-5; return; end

    # convert
    amrs.unittime = unit
    amrs.timelap = ratio.*amrs.timelap
end
#################################
