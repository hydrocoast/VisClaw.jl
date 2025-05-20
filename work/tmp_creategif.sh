#!/bin/bash

fps=9
kw="owi_jebi_%03d_2d.png"
out="owi_jebi_2d.gif"

ffmpeg -i $kw -vf palettegen palette.png -y
ffmpeg -r $fps -i $kw -i palette.png -filter_complex paletteuse $out -y

rm -f palette.png
