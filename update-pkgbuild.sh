#!/bin/bash
 
# Clone yay repository
git clone https://aur.archlinux.org/yay.git
cd yay || exit 1

# Build and install yay
makepkg -si --noconfirm

yay -S --noconfirm flutter-bin

cd ..

# Get the current version from PKGBUILD
current_version=$(grep "^pkgver=" PKGBUILD | cut -d'=' -f2)

# Build the package
# Check if build was successful
if ! makepkg -sfcC --noconfirm; then
    echo "Build failed"
    exit 1
fi

# Get the new version from the built package (if applicable)
new_version=$(grep "^pkgver=" PKGBUILD | cut -d'=' -f2)

# Compare versions
if [ "$current_version" = "$new_version" ]; then
    echo "No changes in versione, exiting..."
    exit 1
else
    # Update .SRCINFO if version changed
    makepkg --printsrcinfo > .SRCINFO
fi