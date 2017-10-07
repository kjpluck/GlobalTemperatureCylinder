

ffmpeg -v warning -i %1 -vf "palettegen" -y palette.png
ffmpeg -v warning -i %1 -i palette.png -lavfi "paletteuse" -y Out.gif