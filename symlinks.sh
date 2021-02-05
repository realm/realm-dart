export SOURCE=src
export SOURCE_PARENT_ABS_PATH=/Users/macaka/lubo/flutter/realm-dart/
export DESTINATION=src.links/

#/Users/macaka/lubo/flutter/test_sed/symlinks/src/src//object-store/.dockerignore

find ${SOURCE} -type d -print0 | xargs -0 bash -c 'for DIR in "$@";
do
  echo "${DESTINATION}${DIR}"
  mkdir -p "${DESTINATION}${DIR}"
  done' -


find ${SOURCE} -type f -print0 |  xargs -0 bash -c 'for file in "$@";
do
  echo "creating a symlink ${DESTINATION}${file} to ${SOURCE_ABS_PATH}${file}"
  ln -s  "${SOURCE_PARENT_ABS_PATH}${file}" "${DESTINATION}${file}"
   done' -