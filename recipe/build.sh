mkdir build
cd build

QMAKE_EXTRA_ARGS=

if [[ ${HOST} =~ .*linux.* ]]; then
  if [[ "$ARCH" == "64" ]]; then
    export PLATFORM=linux-g++-64;
  else
    export PLATFORM=linux-g++-32;
  fi

  # Link against libGL from the CDT sysroot when it is available there.
  GL_SYSROOT_LIB=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64/libGL.so
  if [[ -f ${GL_SYSROOT_LIB} ]]; then
    echo "QMAKE_LIBS_OPENGL=${GL_SYSROOT_LIB}" >> ../leocad.pro
  fi

  # Missing g++ workaround.
  ln -s ${GXX} g++ || true
  chmod +x g++
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
