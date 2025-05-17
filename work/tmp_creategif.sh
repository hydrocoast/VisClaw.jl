#!/bin/bash

fps=3

ffmpeg -i chile%03d.png -vf palettegen palette.png -y
ffmpeg -r $fps -i chile%03d.png -i palette.png -filter_complex paletteuse example.gif -y
