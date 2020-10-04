using VisClaw
using GMT: GMT
using Printf
using Dates: Dates

simdir = joinpath(CLAW,"geoclaw/examples/storm-surge/ike/_output")
timeorigin = Dates.DateTime(2008, 9, 13, 7)
truncvel = 5.0e-1
arrowscale = [-95,30,30,0] # x, y, u, v
Gus, Gvs = arrowscalegrd(arrowscale...)

## load
amrall = loadstorm(simdir; AMRlevel=1)
coarsegridmask!(amrall)
converttodatetime!(amrall, timeorigin)
## time in string
time_str = Dates.format.(amrall.timelap, "yyyy/mm/dd HH:MM")

## make cpt
cpt = GMT.makecpt(C=:wysiwyg, T="950/1020", D=true, I=true)

## projection
proj = getJ("X10d", amrall.amr[1])
region = getR(amrall.amr[1])

for i = 1:amrall.nstep
    outpng = "ike_storm-"*@sprintf("%03d", i)*".png"

    Gp = tilegrd(amrall, i; length_unit="d")
    Gu, Gv = arrowgrd(amrall, i)

    GMT.psbasemap(J=proj, R=region, B="a5f5 neSW", title=time_str[i])
    map(G -> GMT.grdimage!(G, J=proj, R=region, C=cpt), Gp)
    GMT.colorbar!(B="xa10f10 y+lhPa", D="jBR+w8.0/0.3+o-1.5/0.0")
    GMT.coast!(D=:i, W="thinnest,gray80")
    GMT.grdvector!(Gu, Gv, I=[1,1], J=proj, R=region, lw=0.5, fill=:black, S="i0.03", arrow=(len=0.15, stop=:arrow, shape=0.5, fill=:black, justify=:center))
    GMT.grdvector!(Gus, Gvs, J=proj, R=region, lw=0.5, fill=:black, S="i0.03", arrow=(len=0.15, stop=:arrow, shape=0.5, fill=:black, justify=:center), Y=1.3)
    GMT.pstext!(GMT.text_record([arrowscale[1]+3.5 arrowscale[2]], @sprintf("%0.0f", sqrt(arrowscale[3]^2+arrowscale[4]^2))*" m/s"), R=region, savefig=outpng)
end
