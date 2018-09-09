#!/bin/bash

set -e
if [ -d mcpe-build ]; then
  rm -rf mcpe-build
fi
mkdir mcpe-build
cd mcpe-build
mkdir -p deb/usr/bin
mkdir out
THREADS=16

DEPENDS=("libssl-dev" "libcurl4-openssl-dev" "qtbase5-dev" "qtwebengine5-dev" "g++-multilib" "libpng-dev:i386" "libx11-dev:i386" "libxi-dev:i386" "libcurl4-openssl-dev:i386" "libudev-dev:i386" "libevdev-dev:i386" "libegl1-mesa-dev:i386" "libasound2:i386" "libssl-dev" "libcurl4-openssl-dev" "libuv1-dev" "libzip-dev" "libprotobuf-dev" "protobuf-compiler" "qtbase5-dev" "qtwebengine5-dev" "qtdeclarative5-dev" "qml-module-qtquick2" "qml-module-qtquick-layouts" "qml-module-qtquick-controls" "qml-module-qtquick-controls2" "qml-module-qtquick-window2" "qml-module-qtquick-dialogs" "qml-module-qt-labs-settings" "qml-module-qt-labs-folderlistmodel")

join() {
  local d=$1
  shift
  echo -n "$1"
  shift
  printf "%s" "${@/#/$d}"
}
DEPENDS_STR=$(join ' ' "${DEPENDS[@]}")

cp -r ../deb/* deb
sed -i -e 's/%ARCH%/'"$(dpkg-architecture -qDEB_HOST_ARCH)"'/g' deb/DEBIAN/control

package() {
  for i in *; do
    if [ -d $i ]; then
      if [ -e $i/$i ]; then
        mkdir ../../out/$i
        cp -r ../../deb/* ../../out/$i
        sed -i -e 's/%NAME%/'"$i"'/g' ../../out/$i/DEBIAN/control
        local files=($(ldd $i/$i | grep '=' | cut -d ' ' -f 3))
        local libs=()
        for k in "${files[@]}"; do
          libs+=($(dpkg-query -S $k | awk -F ': ' '{print $1}'))
        done
        local depends=$(join ', ' "${libs[@]}")
        sed -i -e 's/%DEPENDS%/'"${depends}"'/g' ../../out/$i/DEBIAN/control
        cp $i/$i ../../out/$i/usr/bin
        dpkg-deb --build ../../out/$i
        rm -rf ../../out/$i
      fi
    fi
  done
}

# Prerequirements
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y git cmake pkg-config ${DEPENDS_STR}

# Compiling the MSA dependency (required for Xbox Live)

# Build instructions
git clone --recursive https://github.com/minecraft-linux/msa-manifest.git msa
cd msa && mkdir -p build && cd build
cmake -DENABLE_MSA_QT_UI=ON ..
make -j${THREADS}
package
cd ../../

# Compiling the launcher

# Build instructions
git clone --recursive https://github.com/minecraft-linux/mcpelauncher-manifest.git core
cd core && mkdir -p build && cd build
cmake -DDEV_EXTRA_PATHS="/opt/mcpelauncher-bin" ..
make -j${THREADS}
package
cd ../../

# Setting it up

# Build instructions
git clone --recursive https://github.com/minecraft-linux/mcpelauncher-ui-manifest.git ui
cd ui && mkdir -p build && cd build
cmake ..
make -j${THREADS}
package
cd ../../

# Build Natives Packages
native() {
  mkdir out/$1
  cp -r deb/* out/$1
  sed -i -e 's/%NAME%/'"$1"'/g' out/$1/DEBIAN/control
  sed -i -e 's/%DEPENDS%//g' out/$1/DEBIAN/control
  echo "Conflicts: $2" >> out/$1/DEBIAN/control
  mkdir -p out/$1/opt/mcpelauncher-bin
  cp -r core/$1/* out/$1/opt/mcpelauncher-bin
  dpkg-deb --build out/$1
  rm -rf out/$1
}
native mcpelauncher-linux-bin mcpelauncher-mac-bin
native mcpelauncher-mac-bin mcpelauncher-linux-bin

# Create Icon Package
mkdir out/mcpelauncher-ui-qt-icon
cp -r deb/* out/mcpelauncher-ui-qt-icon
sed -i -e 's/%NAME%/mcpelauncher-ui-qt-icon/g' out/mcpelauncher-ui-qt-icon/DEBIAN/control
sed -i -e 's/%DEPENDS%//g' out/mcpelauncher-ui-qt-icon/DEBIAN/control
mkdir -p out/mcpelauncher-ui-qt-icon/usr/share/icons/hicolor/1024x1024/apps
cp ui/mcpelauncher-ui-qt/Resources/proprietary/mcpelauncher-icon.png out/mcpelauncher-ui-qt-icon/usr/share/icons/hicolor/1024x1024/apps/
mkdir -p out/mcpelauncher-ui-qt-icon/usr/share/applications
cp -r ../icon/* out/mcpelauncher-ui-qt-icon/usr/share/applications
dpkg-deb --build out/mcpelauncher-ui-qt-icon
rm -rf out/mcpelauncher-ui-qt-icon
