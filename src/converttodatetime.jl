#################################
"""
    converttodatetime!(fgmax::VisClaw.FGmax, t0::Dates.DateTime)
    converttodatetime!(gauge::VisClaw.Gauge, unit::Dates.DateTime)
    converttodatetime!(amrs::VisClaw.AMR, unit::Dates.DateTime)
    converttodatetime!(track::VisClaw.Track, unit::Dates.DateTime)

Time unit converter to Dates.DateTime
"""
function converttodatetime!(fgmax::VisClaw.FGmax, t0::Dates.DateTime)
    ## return if already converted
    isa(fgmax.unittime, Dates.DateTime) && (return fgmax)

    ## factor
    ratio = timedict[fgmax.unittime]

    ## (temporal) to avoid NaN convert error
    fgmax.tD[isnan.(fgmax.tD)] .= 0.0
    fgmax.tarrival[isnan.(fgmax.tarrival)] .= 0.0
    fgmax.tv[isnan.(fgmax.tv)] .= 0.0
    fgmax.tM[isnan.(fgmax.tM)] .= 0.0
    fgmax.tMflux[isnan.(fgmax.tMflux)] .= 0.0
    fgmax.tDmin[isnan.(fgmax.tDmin)] .= 0.0

    ## convert
    fgmax.unittime = :DateTime
    fgmax.tD = @. t0 + Dates.Second(round(ratio*fgmax.tD))
    fgmax.tarrival = @. t0 + Dates.Second(round(ratio*fgmax.tarrival))
    if !isempty(fgmax.tv)
        fgmax.tv = @. t0 + Dates.Second(round(ratio*fgmax.tv))
    end
    if !isempty(fgmax.tM)
        fgmax.tM = @. t0 + Dates.Second(round(ratio*fgmax.tM))
        fgmax.tMflux = @. t0 + Dates.Second(round(ratio*fgmax.tMflux))
        fgmax.tDmin = @. t0 + Dates.Second(round(ratio*fgmax.tDmin))
    end
    return fgmax
end
#################################

#################################
function converttodatetime!(gauge::VisClaw.Gauge, t0::Dates.DateTime)
    ## return if already converted
    isa(gauge.unittime, Dates.DateTime) && (return gauge)

    ## factor
    ratio = timedict[gauge.unittime]

    ## convert
    gauge.unittime = :DateTime
    gauge.time = @. t0 + Dates.Second(round(ratio*gauge.time))
    # return value
    return gauge
end
#################################

#################################
function converttodatetime!(amrs::VisClaw.AMR, t0::Dates.DateTime)
    ## return if already converted
    isa(amrs.unittime, Dates.DateTime) && (return amrs)

    ## factor
    ratio = timedict[amrs.unittime]

    ## convert
    amrs.unittime = :DateTime
    amrs.timelap = @. t0 + Dates.Second(round(ratio*amrs.timelap))
    # return value
    return amrs
end
#################################

#################################
function converttodatetime!(track::VisClaw.Track, t0::Dates.DateTime)
    ## return if already converted
    isa(track.unittime, Dates.DateTime) && (return track)

    ## factor
    ratio = timedict[track.unittime]

    ## convert
    track.unittime = :DateTime
    track.timelap = @. t0 + Dates.Second(round(ratio*track.timelap))
    # return value
    return track
end
#################################
