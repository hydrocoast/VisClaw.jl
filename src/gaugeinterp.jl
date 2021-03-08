"""
    val_interp = gaugeinterp(gauge::VisClaw.Gauge, time_interp; varname=:eta::Symbol)

interp gauge values on a non-uniform time
"""
function gaugeinterp(gauge::VisClaw.Gauge, time_interp; varname=:eta::Symbol)    
    val = getfield(gauge,varname)
    itp = Interpolations.LinearInterpolation(gauge.time, val, extrapolation_bc=Interpolations.Flat())
    val_interp = itp(time_interp)
    return  val_interp
end
