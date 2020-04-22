"""
    gmax = gaugemax(gauge::VisClaw.Gauge)

Maximal values and their occurrence times in a gauge
"""
function gaugemax(gauge::VisClaw.Gauge)

    max_AMRlevel = findmax(gauge.AMRlevel)[1]
    if !isempty(gauge.eta)
        max_eta, tind = findmax(gauge.eta)
        t_eta = gauge.time[tind]
    else
        max_eta = NaN
        t_eta = NaN
    end

    if !isempty(gauge.u)
        vel = sqrt.( (gauge.u).^2 + (gauge.v).^2 )
        vel[isnan.(vel)] .= 0.0
        max_vel, tind = findmax(vel)
        t_vel = gauge.time[tind]
    else
        max_vel = NaN
        t_vel = NaN
    end

    gmax = VisClaw.Gaugemax(gauge.label, gauge.id, gauge.loc,
                            max_AMRlevel, max_eta, max_vel,
                            t_eta, t_vel,
                            gauge.unittime)
    return  gmax
end
