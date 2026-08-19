set -e

VERSION=4.13.0
SRC_DIR=x86          # wherever the 5 debs currently live
OUT_DEB=OpenCV-${VERSION}-x86_64.deb
STAGE=/tmp/opencv-merged

rm -rf "$STAGE"
mkdir -p "$STAGE/DEBIAN"

# Extract every component's payload into the same staging root
for f in "$SRC_DIR"/*.deb; do
    dpkg-deb -x "$f" "$STAGE"
done

# Write one merged control file
cat > "$STAGE/DEBIAN/control" <<EOF
Package: opencv
Version: ${VERSION}
Architecture: amd64
Maintainer: CU Robotics <robotics@colorado.edu>
Section: libs
Priority: optional
Description: OpenCV ${VERSION} (merged dev/libs/main/scripts/licenses)
EOF

# Build the single combined deb
dpkg-deb --build --root-owner-group "$STAGE" "$OUT_DEB"