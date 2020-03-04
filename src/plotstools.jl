function plotssavefig(plts, figname="visclaw.svg"; num_start::Int64=1,
                    kwargs...)
    dn = dirname(figname)
    bn = basename(figname)

    for i=1:length(plts)
        if occursin(".", bn)
            bnnum = replace(bn, "." => "-"*@sprintf("%03d",(i-1)+num_start)*".")
        else
            bnnum = bn*"-"*@sprintf("%03d",(i-1)+num_start)
        end
        Plots.savefig(plts[i], joinpath(dn,bnnum); kwargs...)
    end

end

function plotsgif(plts, gifname::String="visclaw.gif"; kwargs...)
    anim = Plots.Animation()
    map(p->Plots.frame(anim, p), plts)
    Plots.gif(anim, gifname; kwargs...)
end
