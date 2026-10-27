mkdir build
cd build

QMAKE_EXTRA_ARGS=

if [[ "$(uname)" == "Linux" ]]; then
  if [[ "$ARCH" == "64" ]]; then
    export PLATFORM=linux-g++-64;
  else
    export PLATFORM=linux-g++-32;
  fi

  # Missing g++ workaround.
  ln -s "$(command -v ${CXX})" g++ || true
  chmod +x g++ || true
  export PATH=${PWD}:${PATH}
fi

if [[ "$(uname)" == "Darwin" ]]; then
  # Build a plain executable installed into the prefix instead of an app bundle.
  QMAKE_EXTRA_ARGS="NO_BUNDLE=1"
fi

qmake \
  DISABLE_UPDATE_CHECK=1 \
  LDRAW_LIBRARY_PATH=${PREFIX}/share/ldraw \
  CONFIG+=release \
  INSTALL_PREFIX=$PREFIX \
  QMAKE_LFLAGS="${LDFLAGS}" \
  QMAKE_CXXFLAGS="${CXXFLAGS}" \
  ${QMAKE_EXTRA_ARGS} \
  ../leocad.pro

make install
