mkdir build
cd build

QMAKE_EXTRA_ARGS=

if [[ "$(uname)" == "Linux" ]]; then
  if [[ "$ARCH" == "64" ]]; then
    export PLATFORM=linux-g++-64;
  else
    export PLATFORM=linux-g++-32;
  fi

  # Link against libGL from the CDT sysroot when it is available there.
  GL_SYSROOT_LIB=$(find ${BUILD_PREFIX} -name libGL.so 2>/dev/null | head -n 1)
  if [[ -n ${GL_SYSROOT_LIB} ]]; then
    echo "QMAKE_LIBS_OPENGL=${GL_SYSROOT_LIB}" >> ../leocad.pro
  fi

  # Missing g++ workaround.
  ln -s "$(command -v ${CXX})" g++ || true
  chmod +x g++ || true
  export PATH=${PWD}:${PATH}
fi

if [[ "$(uname)" == "Darwin" ]]; then
  # Build a plain executable installed into the prefix instead of an app bundle.
  QMAKE_EXTRA_ARGS="DISABLE_MACOS_BUNDLE=1"
fi

# Default the POV-Ray executable to the one in this conda prefix instead of
# /usr/bin/povray, so the render dialog works out of the box when povray is
# installed in the same environment. Still overridable via the POVRay/Path
# preference. Same approach as LDRAW_LIBRARY_PATH below.
sed -i.bak "s|\"/usr/bin/povray\"|\"${PREFIX}/bin/povray\"|" ../common/lc_profile.cpp

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
