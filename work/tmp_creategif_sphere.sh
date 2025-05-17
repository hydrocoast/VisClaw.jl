#!/bin/bash

fps=3

ffmpeg -i chile%03d_sphere.png -vf palettegen palette.png -y
ffmpeg -r $fps -i chile%03d_sphere.png -i palette.png -filter_complex paletteuse chile2020_surf_sphere.gif -y
