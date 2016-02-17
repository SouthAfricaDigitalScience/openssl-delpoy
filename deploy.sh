#!/bin/bash -e
# Deploy script for openssl.
. /etc/profile.d/modules.sh
echo ${SOFT_DIR}
module add deploy
echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
../config \
--prefix=${SOFT_DIR} \
--unified \
--shared
make -j2
make install
echo "Creating the modules file directory ${LIBRARIES_MODULES}"
mkdir -p ${LIBRARIES_MODULES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       OPENSSL_VERSION       $VERSION
setenv       OPENSSL_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(OPENSSL_DIR)/lib
prepend-path PATH              $::env(OPENSSL_DIR)
prepend-path LDFLAGS           "-L${OPENSSL_DIR}/lib"
MODULE_FILE
) > ${LIBRARIES_MODULES}/${NAME}/${VERSION}

# test the module
module availe ${NAME}
module add ${NAME}
which openssl