#!/bin/bash
AUR_PACKAGE_NAME="printnotes-git"

# Clone yay repository
git clone https://aur.archlinux.org/yay.git
cd yay || exit 1

# Build and install yay
makepkg -si --noconfirm

# Install flutter-bin
yay -S --noconfirm flutter-bin

cd ..

# Get the current version and pkgrel from local PKGBUILD
current_version=$(grep "^pkgver=" PKGBUILD | cut -d'=' -f2)
current_pkgrel=$(grep "^pkgrel=" PKGBUILD | cut -d'=' -f2)

echo "Current local version: $current_version"
echo "Current local pkgrel: $current_pkgrel"

# Fetch the latest version and pkgrel from AUR
echo "Fetching latest version and pkgrel from AUR..."
aur_content=$(curl -s "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$AUR_PACKAGE_NAME")
aur_version=$(echo "$aur_content" | grep "^pkgver=" | cut -d'=' -f2)
aur_pkgrel=$(echo "$aur_content" | grep "^pkgrel=" | cut -d'=' -f2)

if [ -z "$aur_version" ]; then
    echo "Error: Could not fetch version from AUR for package $AUR_PACKAGE_NAME"
    exit 1
fi

echo "Latest AUR version: $aur_version"
echo "Latest AUR pkgrel: $aur_pkgrel"

# Compare versions and pkgrel
if [ "$current_version" = "$aur_version" ] && [ "$current_pkgrel" = "$aur_pkgrel" ]; then
    echo "No changes in version or pkgrel, exiting..."
    rm -f .SRCINFO
    rm -f PKGBUILD
    exit 0
else
    echo "Changes detected:"
    if [ "$current_version" != "$aur_version" ]; then
        echo "- Version changed from $current_version to $aur_version"
    fi
    if [ "$current_pkgrel" != "$aur_pkgrel" ]; then
        echo "- Pkgrel changed from $current_pkgrel to $aur_pkgrel"
    fi
    
    # Update .SRCINFO if version or pkgrel changed
    makepkg --printsrcinfo > .SRCINFO
    
    # Create backup of original PKGBUILD before making changes
    cp PKGBUILD PKGBUILD.backup
    
    echo "New PKGBUILD and .SRCINFO files updated"
    
    # Optional: Commit changes to git (if this is a git repository)
    if git status --porcelain > /dev/null 2>&1; then
        echo "Git repository detected, committing changes..."
        git add PKGBUILD .SRCINFO
        git commit -m "Update PKGBUILD: version $current_version → $aur_version, pkgrel $current_pkgrel → $aur_pkgrel"
        echo "Changes committed successfully"
    fi
    
    echo "New version $aur_version-pkgrel-$aur_pkgrel is ready for publishing"
    
    # Create tag
    if command -v git &> /dev/null; then
        git tag -a "v$aur_version-pkgrel-$aur_pkgrel" -m "Release version $aur_version-pkgrel-$aur_pkgrel"
        echo "Tag created: v$aur_version-pkgrel-$aur_pkgrel"
    fi
    
    # Clean up backup file
    rm -f PKGBUILD.backup
fi

echo "Script completed successfully"