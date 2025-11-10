#!/bin/bash

# Clone yay repository
git clone https://aur.archlinux.org/yay.git
cd yay || exit 1

# Build and install yay
makepkg -si --noconfirm

cd ..

git clone https://aur.archlinux.org/flutter.git
cd flutter || exit 1

makepkg -si --noconfirm

cd ..

# Get current version and pkgrel from local PKGBUILD
current_version=$(grep "^pkgver=" PKGBUILD | cut -d'=' -f2)
current_pkgrel=$(grep "^pkgrel=" PKGBUILD | cut -d'=' -f2)

echo "Current version: $current_version, pkgrel: $current_pkgrel"

# Get the AUR version and pkgrel
aur_url="https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=printnotes-git"
aur_pkgs=$(curl -s "$aur_url")

aur_version=$(echo "$aur_pkgs" | grep "^pkgver=" | cut -d'=' -f2)
aur_pkgrel=$(echo "$aur_pkgs" | grep "^pkgrel=" | cut -d'=' -f2)

echo "AUR version: $aur_version, pkgrel: $aur_pkgrel"

# Check if AUR version is newer or if pkgrel has changed
if [ "$aur_version" = "$current_version" ] && [ "$aur_pkgrel" = "$current_pkgrel" ]; then
    echo "No changes in version, exiting..."
    rm -f PKGBUILD .SRCINFO
    exit 0
elif [ "$aur_version" != "$current_version" ]; then
    echo "New version available locally: $current_version (current: $aur_version)"
    # Update the PKGBUILD with new version
    # Build the package
    if ! makepkg -sfcC --noconfirm; then
        echo "Build failed"
        exit 1
    fi
    
    # Update .SRCINFO
    makepkg --printsrcinfo > .SRCINFO
    echo "Package build to version $current_version"
elif [ "$aur_pkgrel" != "$current_pkgrel" ]; then
    echo "Package rel changed in AUR: $current_pkgrel (current: $aur_pkgrel)"
    
    # Build the package
    if ! makepkg -sfcC --noconfirm; then
        echo "Build failed"
        exit 1
    fi
    
    # Update .SRCINFO
    makepkg --printsrcinfo > .SRCINFO
    echo "Package rel build to $current_pkgrel"
fi

# Clean up temporary files if they exist
rm -f .SRCINFO
rm -f PKGBUILD
