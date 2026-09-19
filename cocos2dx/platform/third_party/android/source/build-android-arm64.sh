#!/bin/bash
# Rebuild third-party static libs for arm64-v8a with the modern NDK.
# Fetches upstream sources on demand, builds, and copies the .a files into
# ../prebuilt/<lib>/libs/arm64-v8a/
set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
NDK="${ANDROID_NDK_HOME:-/opt/homebrew/share/android-ndk}"
ABI=arm64-v8a
API=21
JOBS=$(sysctl -n hw.ncpu)

fetch() {
    local dir="$1" url="$2" tarball="$3"
    if [ -d "$dir" ]; then return; fi
    if [ ! -f "$tarball" ]; then
        echo "Fetching $url"
        curl -sSL -o "$tarball" "$url"
    fi
    case "$tarball" in
        *.tar.xz) tar xJf "$tarball" ;;
        *.tar.gz) tar xzf "$tarball" ;;
    esac
    rm -f "$tarball"
}

fetch libpng-1.6.47      https://github.com/pnggroup/libpng/archive/refs/tags/v1.6.47.tar.gz libpng.tar.gz
fetch libjpeg-turbo-3.0.4 https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/3.0.4.tar.gz libjpeg-turbo.tar.gz
fetch libxml2-2.9.14     https://download.gnome.org/sources/libxml2/2.9/libxml2-2.9.14.tar.xz libxml2.tar.xz
fetch tiff-4.7.0         https://download.osgeo.org/libtiff/tiff-4.7.0.tar.gz tiff.tar.gz
fetch curl-7.88.1        https://curl.se/download/curl-7.88.1.tar.gz curl.tar.gz

COMMON=(-G "Unix Makefiles"
        -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake"
        -DANDROID_ABI="$ABI"
        -DANDROID_PLATFORM="android-$API"
        -DCMAKE_BUILD_TYPE=Release
        -DANDROID_STL=c++_static
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5)

cd "$SRC_DIR"

build_one() {
    local name="$1" src="$2" out="$3" libname="$4"; shift 4
    echo "=== $name ==="
    cmake -S "$src" -B "build-$name" "${COMMON[@]}" "$@" > "build-$name.log" 2>&1 || { tail -30 "build-$name.log"; exit 1; }
    make -C "build-$name" -j"$JOBS" >> "build-$name.log" 2>&1 || { tail -30 "build-$name.log"; exit 1; }
    mkdir -p "../prebuilt/$name/libs/$ABI"
    cp "build-$name/$out" "../prebuilt/$name/libs/$ABI/$libname"
    echo "OK -> ../prebuilt/$name/libs/$ABI/$libname"
}

build_one libpng libpng-1.6.47 libpng16.a libpng.a \
    -DPNG_SHARED=OFF -DPNG_TESTS=OFF -DPNG_TOOLS=OFF

build_one libjpeg libjpeg-turbo-3.0.4 libjpeg.a libjpeg.a \
    -DWITH_JPEG8=1 -DENABLE_SHARED=OFF -DENABLE_STATIC=ON

build_one libxml2 libxml2-2.9.14 libxml2.a libxml2.a \
    -DLIBXML2_WITH_ICONV=OFF -DLIBXML2_WITH_ZLIB=OFF -DLIBXML2_WITH_PYTHON=OFF \
    -DLIBXML2_WITH_LZMA=OFF -DLIBXML2_WITH_ZSTD=OFF \
    -DLIBXML2_WITH_TESTS=OFF -DLIBXML2_WITH_PROGRAMS=OFF -DBUILD_SHARED_LIBS=OFF

build_one libtiff tiff-4.7.0 libtiff/libtiff.a libtiff.a \
    -DBUILD_SHARED_LIBS=OFF -Dtiff-tools=OFF -Dtiff-tests=OFF \
    -Dtiff-contrib=OFF -Dtiff-docs=OFF -Dcxx=OFF

build_one libcurl curl-7.88.1 lib/libcurl.a libcurl.a \
    -DBUILD_SHARED_LIBS=OFF -DBUILD_CURL_EXE=OFF -DCURL_ENABLE_SSL=OFF \
    -DCURL_DISABLE_LDAP=ON -DCURL_DISABLE_LDAPS=ON -DCURL_ZLIB=OFF

echo "ALL DONE"
