include("../src/VisClaw.jl")
using .VisClaw
using GMT: GMT
using Revise
using Printf

# -----------------------------
# ike
# -----------------------------
simdir = joinpath(VisClaw.CLAW,"geoclaw/examples/storm-surge/ike/_output")
using Dates: Dates
timeorigin = Dates.DateTime(2008, 9, 13, 7)

## load topo
topo = VisClaw.loadtopo(simdir)

## makecpt
cpt = GMT.makecpt(C=:jet, T="0.0/2.0", D=true)
cpttopo = GMT.makecpt(C=:earth, D=true)

## load water surface
amrall = VisClaw.loadsurface(simdir)
VisClaw.coarsegridmask!(amrall)
VisClaw.converttodatetime!(amrall, timeorigin)
## time in string
time_str = Dates.format.(amrall.timelap, "yyyy/mm/dd HH:MM")

region = VisClaw.getR(amrall.amr[1])
proj = VisClaw.getJ("M10", topo)

## masking
landmask_txt = VisClaw.landmask_asc(topo)

## land-masked surface grids
G = VisClaw.tilegrd_mask(amrall, 5, landmask_txt; length_unit="d")
Gtopo = VisClaw.geogrd(topo)

## projection and region GMT
#GMT.grdview(Gtopo, J=proj, JZ="0.5c", R=VisClaw.getR(topo), B="", C=cpttopo, Q=(surface=true,), view=(155,40), savefig="topo.ps")
#run(`gmt psconvert -A -Tg topo.ps`)
GMT.grdview(Gtopo, J=proj, JZ="0.1c", R=VisClaw.getR(topo), B="", C=cpttopo, Q=(surface=true,), view=(155,40))
map(g -> GMT.grdview!(g, J=proj, JZ="0.5c", B="", R=region, C=cpt, Q=(surface=true,)), G)
#GMT.colorbar!(B="xa0.1f0.1 y+l(m)", D="jBR+w10.0/0.3+o-1.5/0.0", font="12p,Helvetica-Bold", frame=true)



#gmt grdview @HI_topo_04.nc -I+a0+nt0.75 -R195/210/18/25/-6/4 -JZ8c -p60/30 -C@topo_04.cpt \
#		-N-6+glightgray -Qc100 -B2 -Bz2+l"Topo (km)" -Y5c -BneswZ+t"H@#awaiian@# R@#idge@#" \
#		--FONT_TITLE=50p,ZapfChancery-MediumItalic --MAP_TITLE_OFFSET=-3.5c