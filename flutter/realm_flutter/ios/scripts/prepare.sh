echo "prepare.sh called in $(pwd)"
echo "patching project file $1"


EchoError() {
  echo "$@" 1>&2
}

if [[ $# == 0 ]]; then
  EchoError "prepare.sh script requires a argument - the path to the xcode project file"
  exit -1
fi

AssertExists() {
  if [[ ! -e "$1" ]]; then
    if [[ -h "$1" ]]; then
      EchoError "The path $1 is a symlink to a path that does not exist"
    else
      EchoError "The path $1 does not exist"
    fi
    exit -1
  fi
  return 0
}

AssertExists $1

# system('sed', '-i.bak', "s~FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh~PROJECT_DIR/.symlinks/plugins/realm_flutter/ios/scripts/xcode_backend.sh~", project_file)
# system('sed', '-i.bak', "s~(PROJECT_DIR)/Flutter~(PROJECT_DIR)/.symlinks/plugins/realm_flutter/ios/Frameworks/Flutter~", project_file)

sed -i.bak "s~FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh~PROJECT_DIR/.symlinks/plugins/realm_flutter/ios/scripts/xcode_backend.sh~" $1
sed -i.bak "s~(PROJECT_DIR)/Flutter~(PROJECT_DIR)/.symlinks/plugins/realm_flutter/ios/Frameworks/Flutter~" $1