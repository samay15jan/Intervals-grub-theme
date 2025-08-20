#!/usr/bin/env bash

GREEN='\033[1;32m'
RESET='\033[0m'

log_info() {
  echo -e "${GREEN}[I]${RESET} $1"
}

WALL="$1"

wal -i "$WALL"
. "${HOME}/.cache/wal/colors.sh"

log_info "image: Resizing and centering image..."
magick "$WALL" -resize 1920x1080^ -gravity center -extent 1920x1080 temp_wall.png

log_info "background: Blurring the background..."
magick temp_wall.png -blur 0x8 -modulate 70,100,100 blurred.png

log_info "foreground: Cropping and formatting foreground..."
magick temp_wall.png -gravity center -crop 60%x60%+0+0 +repage cropped.png

log_info "foreground: Resizing cropped image..."
magick cropped.png -resize x800 cropped.png

log_info "foreground: Adding rounded corners..."
magick cropped.png \
  \( +clone  -alpha extract \
    -draw 'fill black polygon 0,0 0,80 80,0 fill white circle 80,80 80,0' \
    \( +clone -flip \) -compose Multiply -composite \
    \( +clone -flop \) -compose Multiply -composite \
  \) -alpha off -compose CopyOpacity -composite rounded.png

log_info "foreground: Applying final adjustments..."
magick rounded.png -modulate 80,100,100 rounded.png

log_info "overlay: Creating solid background block..."
magick -size 800x800 xc:$color1 solid.png
magick solid.png -modulate 60,100,100 solid.png

log_info "overlay: Combining solid block with foreground..."
magick -size 1280x800 xc:none solid.png -geometry +0+0 -composite rounded.png -geometry +640 -composite combined.png

log_info "overlay: Applying shadow..."
magick combined.png \
  \( +clone -background black -shadow 60x12+0+0 \) \
  +swap -background none -layers merge +repage combined.png

# magick combined.png -fill "rgba(255,255,255,0.2)" -draw "polygon 975,245 1575,245 1275,695" combined.png

log_info "final: Compositing final image..."
magick blurred.png combined.png -gravity center -composite output.png
echo "feh --bg-scale $WALL" > /home/samay15jan/.config/i3/scripts/wallpaper

log_info "final: Reducing image size..."
magick output.png -strip output.png
magick output.png -colors 256 -strip output.png
magick output.png -strip -colors 64 PNG8:output.png
magick output.png output.jpg

log_info "final: Copying files..."
mv output.jpg /home/samay15jan/Downloads/Intervals-grub-theme/backgrounds/backgrounds/background-window.jpg
/home/samay15jan/Downloads/Intervals-grub-theme/install.sh -t window -s 1080p

log_info "cleanup: Removing temporary files..."
rm blurred.png combined.png cropped.png rounded.png solid.png temp_wall.png

log_info "Finshed: Task completed"

