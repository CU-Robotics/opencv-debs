set -e
OPENCV_VERSION=4.13.0

if [ -f opencv.zip ]; then
    echo "==> opencv.zip already exists, skipping download"
else
    echo "==> Downloading opencv.zip"
    wget -O opencv.zip "https://github.com/opencv/opencv/archive/refs/tags/${OPENCV_VERSION}.zip"
fi

if [ -f opencv_contrib.zip ]; then
    echo "==> opencv_contrib.zip already exists, skipping download"
else
    echo "==> Downloading opencv_contrib.zip"
    wget -O opencv_contrib.zip "https://github.com/opencv/opencv_contrib/archive/refs/tags/${OPENCV_VERSION}.zip"
fi

if [ -d "opencv-${OPENCV_VERSION}" ]; then
    echo "==> opencv-${OPENCV_VERSION} already extracted, skipping unzip"
else
    echo "==> Extracting opencv.zip"
    unzip -q opencv.zip
fi

if [ -d "opencv_contrib-${OPENCV_VERSION}" ]; then
    echo "==> opencv_contrib-${OPENCV_VERSION} already extracted, skipping unzip"
else
    echo "==> Extracting opencv_contrib.zip"
    unzip -q opencv_contrib.zip
fi

PACKAGING_FILE="opencv-${OPENCV_VERSION}/cmake/OpenCVPackaging.cmake"
if grep -q 'OPENCV_VCSVERSION' "$PACKAGING_FILE" 2>/dev/null; then
echo "==> Patching OpenCVPackaging.cmake to pin CPACK_PACKAGE_VERSION"
sed -i "s/set(CPACK_PACKAGE_VERSION \"\${OPENCV_VCSVERSION}\")/set(CPACK_PACKAGE_VERSION \"${OPENCV_VERSION}\")/" "$PACKAGING_FILE"
fi

mkdir -p build && cd build

cmake -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_INSTALL_PREFIX=/usr \
  -D OPENCV_VCSVERSION:STRING=${OPENCV_VERSION} \
  -D CPACK_PACKAGE_VERSION:STRING=${OPENCV_VERSION} \
  -D CPACK_BINARY_DEB=ON \
  -D BUILD_TESTS=OFF \
  -D BUILD_PERF_TESTS=OFF \
  -D BUILD_EXAMPLES=OFF \
  -D BUILD_opencv_python_tests=OFF \
  -D WITH_FFMPEG=OFF \
  -D WITH_CUDA=ON \
  -D CUDA_FAST_MATH=ON \
  -D ENABLE_FAST_MATH=ON \
  -D WITH_CUDNN=ON \
  -D OPENCV_DNN_CUDA=ON \
  -D CUDA_ARCH_PTX=7.0 \
  -D CUDA_ARCH_BIN=8.7 \
  -D CMAKE_LIBRARY_PATH=/usr/local/cuda/lib64 \
  -D WITH_NVCUVID=OFF \
  -D WITH_NVCUVENC=OFF \
  -D WITH_OPENGL=OFF \
  -D OPENCV_GENERATE_PKGCONFIG=ON \
  -D WITH_QT=OFF -DWITH_GTK=OFF \
  -D WITH_WIN32UI=OFF \
  -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib-4.13.0/modules ../opencv-4.13.0

cmake --build . -j$(nproc)

cpack -G DEB
