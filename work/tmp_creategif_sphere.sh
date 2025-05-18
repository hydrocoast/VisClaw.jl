#!/bin/bash

fps=3

ffmpeg -i sphere_chile%03d.png -vf palettegen palette.png -y
ffmpeg -r $fps -i sphere_chile%03d.png -i palette.png -filter_complex paletteuse chile2020_surf_sphere.gif -y
