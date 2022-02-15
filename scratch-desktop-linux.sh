#!/bin/sh

# Copyright (C) 2021 Gaëtan LE HEURT-FINOT
# This file is part of scratch-desktop-linux <https://github.com/gaetanlhf/scratch-desktop-linux>.
#
# scratch-desktop-linux is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# scratch-desktop-linux is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with scratch-desktop-linux.  If not, see <http://www.gnu.org/licenses/>.

# Create some variables
ROOT_FOLDER=$(pwd)
MAKE_FOLDER=$(pwd)/.build
EXTRACT_FOLDER=$MAKE_FOLDER/scratch-desktop
PACKAGES_FOLDER=$(pwd)/packages
SCRATCH_VERSION=3.28.0
ELECTRON_VERSION=15.3.1


# Clean and create some folders
rm -rf "$MAKE_FOLDER"
mkdir "$MAKE_FOLDER"
rm -rf "$PACKAGES_FOLDER"
mkdir "$PACKAGES_FOLDER"

cd "$MAKE_FOLDER" || exit

# Install npm dependencies
npm install electron@$ELECTRON_VERSION --save-dev
npm install electron-installer-debian
npm install electron-installer-redhat

# Download the latest version of Scratch Desktop for Microsoft Windows and extract it
wget https://downloads.scratch.mit.edu/desktop/Scratch%20$SCRATCH_VERSION%20Setup.exe -O scratch-desktop.exe
7za x -aoa -y "$MAKE_FOLDER"/scratch-desktop.exe -o"$EXTRACT_FOLDER"

# Create electron app
cp -rf "$MAKE_FOLDER"/node_modules/electron/dist/* "$EXTRACT_FOLDER"
ln -fsr "$EXTRACT_FOLDER"/electron "$EXTRACT_FOLDER"/scratch-desktop

# Fix permissions
chmod 755 -R "$EXTRACT_FOLDER"

# Get application icon
cp "$ROOT_FOLDER"/Icon.svg "$EXTRACT_FOLDER"/resources/Icon.svg

# Remove Microsoft Windows executables
rm "$EXTRACT_FOLDER"/"Scratch 3.exe"
rm "$EXTRACT_FOLDER"/resources/elevate.exe

# Create packages
"$MAKE_FOLDER"/node_modules/.bin/electron-installer-debian --src "$EXTRACT_FOLDER" --dest "$PACKAGES_FOLDER" --arch amd64 --icon "$EXTRACT_FOLDER"/resources/Icon.svg --config "$ROOT_FOLDER"/config.json
"$MAKE_FOLDER"/node_modules/.bin/electron-installer-redhat --src "$EXTRACT_FOLDER" --dest "$PACKAGES_FOLDER" --arch x86_64 --icon "$EXTRACT_FOLDER"/resources/Icon.svg --config "$ROOT_FOLDER"/config.json