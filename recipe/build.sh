mkdir build
cd build

if [[ ${HOST} =~ .*linux.* ]]; then
  if [[ "$ARCH" == "64" ]]; then
    export PLATFORM=linux-g++-64;
  else
    export PLATFORM=linux-g++-32;
  fi

  echo "QMAKE_LIBS_OPENGL=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64/libGL.so" >> ../leocad.pro
  # Missing g++ workaround.
  ln -s ${GXX} g++ || true
  chmod +x g++
  export PATH=${PWD}:${PATH}
fi

if [[ "$(uname)" == "Darwin" ]]; then
  # Build a plain binary instead of an app bundle: the qmake install rules
  # (INSTALLS) only apply to unix:!macx, so we install the executable manually.
  QMAKE_EXTRA_ARGS="CONFIG-=app_bundle"
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

if [[ "$(uname)" == "Darwin" ]]; then
  make -j${CPU_COUNT}
  mkdir -p ${PREFIX}/bin
  cp build/release/LeoCAD ${PREFIX}/bin/leocad
else
  make install
fi
