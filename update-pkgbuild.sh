#!/bin/bash

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