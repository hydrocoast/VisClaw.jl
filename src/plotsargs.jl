"""
This function is based on find_in_dict() in GMT.
See if D contains any of the symbols in SYMBS.
If yes, return corresponding value
"""
function parse_from_keys(d::Dict, symbs)
	for symb in symbs
        if haskey(d, symb)
            val = d[symb]
		    delete!(d,symb)
		    return val, d
		end
	end
	# return if nothing
	return nothing, d
end

# Plots
# -----------------------------
"""
key: seriestype
To parse a value of the key in kwargs
"""
parse_seriestype(d::Dict) =
parse_from_keys(d, [:seriestype, :st, :t, :typ, :linetype, :lt])
# -----------------------------
parse_seriescolor(d::Dict) =
parse_from_keys(d, [:seriescolor, :c, :color, :colour])
# -----------------------------
parse_clims(d::Dict) =
parse_from_keys(d, [:clims, :clim, :cbarlims, :cbar_lims, :climits, :color_limits])
# -----------------------------
parse_bgcolor_inside(d::Dict) =
parse_from_keys(d, [:background_color_inside, :bg_inside, :bginside,
                    :bgcolor_inside, :bg_color_inside, :background_inside,
                    :background_colour_inside, :bgcolour_inside, :bg_colour_inside])
# -----------------------------
parse_xlims(d::Dict) =
parse_from_keys(d, [:xlims, :xlim, :xlimit, :xlimits])
# -----------------------------
parse_ylims(d::Dict) =
parse_from_keys(d, [:ylims, :ylim, :ylimit, :ylimits])
# -----------------------------
parse_colorbar_title(d::Dict) =
parse_from_keys(d, [:colorbar_title])
# -----------------------------
parse_linewidth(d::Dict) =
parse_from_keys(d, [:linewidth, :w, :width, :lw])
# -----------------------------
parse_linestyle(d::Dict) =
parse_from_keys(d, [:linestyle, :style, :s, :ls])
# -----------------------------
parse_linecolor(d::Dict) =
parse_from_keys(d, [:linecolor, :lc, :lcolor, :lcolour, :linecolour])
# -----------------------------
