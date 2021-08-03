# Creates symlink clone of a SOURCE_ABS_PATH directory to DESTINATION_ABS_PATH directory
# Every directory from SOURCE_ABS_PATH will be created in DESTINATION_ABS_PATH and new files will be symlinked 
#
# Calling "./create_symlink_clone.sh /Users/myuser/test-source /Users/myuser/test-target"
# will result in /Users/myuser/test-target/test-source symlink clone

export SOURCE_ABS_PATH=$1
export DESTINATION_ABS_PATH=$2

#get the relative path of the source dir. 
export SOURCE=($(cd ${SOURCE_ABS_PATH} && basename "$PWD"))
echo "SOURCE: $SOURCE"

#get the relative path of the source dir. 
export DESTINATION=$DESTINATION_ABS_PATH #($(cd ${DESTINATION_ABS_PATH} && basename "$PWD"))
echo "DESTINATION: $DESTINATION"

#get the absolute path to the source parent
export SOURCE_PARENT_ABS_PATH=($(cd ${SOURCE_ABS_PATH}/.. && echo $PWD))
echo "SOURCE_PARENT_ABS_PATH: $SOURCE_PARENT_ABS_PATH"
export SOURCE_PARENT=$SOURCE_PARENT_ABS_PATH

echo "Changing the current directory to ${SOURCE_PARENT_ABS_PATH}"
cd $SOURCE_PARENT_ABS_PATH

find ${SOURCE} -type d -print0 | xargs -0 bash -c 'for DIR in "$@";
do
  echo "creating directory ${DESTINATION}/${DIR}"
  mkdir -p "${DESTINATION}/${DIR}"
done' -

find ${SOURCE} -type f -print0 |  xargs -0 bash -c 'for file in "$@";
do
  echo "creating a symlink ${DESTINATION}/${file} pointing to ${SOURCE_PARENT}/${file}"
  ln -sf "${SOURCE_PARENT}/${file}" "${DESTINATION}/${file}" || true
done' -

