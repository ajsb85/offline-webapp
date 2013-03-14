#!/bin/bash
. $(dirname "$0")/common.sh

print_usage() {
  notice "Usage: $(basename $0) [OPTIONS] ARCHIVE DIRECTORY"
}

if [ $# = 0 ]; then
  print_usage
  exit 1
fi

if [ $1 = -h ]; then
  print_usage
  notice ""
  notice "The contents of DIRECTORY will be stored in ARCHIVE."
  notice ""
  notice "Options:"
  notice "  -h  show this help text"
  notice ""
  exit 1
fi

archive="$1"
targetdir="$2"
if [ $(echo "$targetdir" | grep -c '\/$') = 1 ]; then
  targetdir=$(echo "$targetdir" | sed -e 's:\/$::')
fi
workdir="$targetdir.work"
updatemanifestv1="$workdir/update.manifest"
updatemanifestv2="$workdir/updatev2.manifest"
targetfiles="update.manifest updatev2.manifest"

mkdir -p "$workdir"
pushd "$targetdir"
if test $? -ne 0 ; then
  exit 1
fi

if [ ! -f "precomplete" ]; then
  notice "precomplete file is missing!"
  exit 1
fi

list_files files

popd

notice ""
notice "Adding file add instructions to file 'update.manifest'"
> "$updatemanifestv1"

num_files=${#files[*]}

for ((i=0; $i<$num_files; i=$i+1)); do
  f="${files[$i]}"
    if [ "`basename $f`" = "removed-files" ]; then
    continue 1
  fi

  make_add_instruction "$f" >> "$updatemanifestv1"

  dir=$(dirname "$f")
  mkdir -p "$workdir/$dir"
  $BZIP2 -cz9 "$targetdir/$f" > "$workdir/$f"
  copy_perm "$targetdir/$f" "$workdir/$f"

  targetfiles="$targetfiles \"$f\""
done
> "$updatemanifestv2"
notice ""
notice "Adding type instruction to file 'updatev2.manifest'"
notice "       type: complete"
echo "type \"complete\"" >> "$updatemanifestv2"

notice ""
notice "Concatenating file 'update.manifest' to file 'updatev2.manifest'"
cat "$updatemanifestv1" >> "$updatemanifestv2"

notice ""
notice "Adding file and directory remove instructions from file 'removed-files'"
append_remove_instructions "$targetdir" "$updatemanifestv1" "$updatemanifestv2"

$BZIP2 -z9 "$updatemanifestv1" && mv -f "$updatemanifestv1.bz2" "$updatemanifestv1"
$BZIP2 -z9 "$updatemanifestv2" && mv -f "$updatemanifestv2.bz2" "$updatemanifestv2"

eval "$MAR -C \"$workdir\" -c output.mar $targetfiles"
mv -f "$workdir/output.mar" "$archive"

rm -fr "$workdir"

notice ""
notice "Finished"
