function plotssavefig(plts, figname="visclaw.svg"; num_start::Integer=1, kwargs...)
    dn = dirname(figname)
    bn = basename(figname)

    for i=1:length(plts)
        numstr = @sprintf("%03d",(i-1)+num_start)
        bnnum = occursin(".", bn) ? replace(bn, "." => "-"*numstr*".") : bn*"-"*numstr
        Plots.savefig(plts[i], joinpath(dn,bnnum); kwargs...)
    end

end

function plotsgif(plts, gifname::AbstractString="visclaw.gif"; kwargs...)
    anim = Plots.Animation()
    map(p->Plots.frame(anim, p), plts)
    Plots.gif(anim, gifname; kwargs...)
end
