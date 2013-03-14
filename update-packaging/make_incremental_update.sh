#!/bin/bash

. $(dirname "$0")/common.sh

print_usage() {
  notice "Usage: $(basename $0) [OPTIONS] ARCHIVE FROMDIR TODIR"
  notice ""
  notice "The differences between FROMDIR and TODIR will be stored in ARCHIVE."
  notice ""
  notice "Options:"
  notice "  -h  show this help text"
  notice "  -f  clobber this file in the installation"
  notice "      Must be a path to a file to clobber in the partial update."
  notice ""
}

check_for_forced_update() {
  force_list="$1"
  forced_file_chk="$2"

  local f

  if [ "$forced_file_chk" = "precomplete" ]; then
    return 0;
  fi

  if [ "${forced_file_chk##*.}" = "chk" ]
  then
    return 0;
  fi

  for f in $force_list; do
    if [ "$forced_file_chk" = "$f" ]; then
      return 0;
    fi
  done
  return 1;
}

if [ $# = 0 ]; then
  print_usage
  exit 1
fi

requested_forced_updates='Contents/MacOS/firefox'

while getopts "hf:" flag
do
   case "$flag" in
      h) print_usage; exit 0
      ;;
      f) requested_forced_updates="$requested_forced_updates $OPTARG"
      ;;
      ?) print_usage; exit 1
      ;;
   esac
done

let arg_start=$OPTIND-1
shift $arg_start

archive="$1"
olddir="$2"
newdir="$3"
if [ $(echo "$newdir" | grep -c '\/$') = 1 ]; then
  newdir=$(echo "$newdir" | sed -e 's:\/$::')
fi
workdir="$newdir.work"
updatemanifestv1="$workdir/update.manifest"
updatemanifestv2="$workdir/updatev2.manifest"
archivefiles="update.manifest updatev2.manifest"

mkdir -p "$workdir"

pushd "$olddir"
if test $? -ne 0 ; then
  exit 1
fi

list_files oldfiles
list_dirs olddirs

popd

pushd "$newdir"
if test $? -ne 0 ; then
  exit 1
fi

if [ ! -f "precomplete" ]; then
  notice "precomplete file is missing!"
  exit 1
fi

list_dirs newdirs
list_files newfiles

popd

notice ""
notice "Adding file patch and add instructions to file 'update.manifest'"
> "$updatemanifestv1"

num_oldfiles=${#oldfiles[*]}
remove_array=
num_removes=0

for ((i=0; $i<$num_oldfiles; i=$i+1)); do
  f="${oldfiles[$i]}"

  if [ "$f" = "readme.txt" ]; then
    continue 1
  fi

  if [ "`basename $f`" = "removed-files" ]; then
    continue 1
  fi

  if [ -f "$newdir/$f" ]; then

    if check_for_forced_update "$requested_forced_updates" "$f"; then
      mkdir -p "`dirname "$workdir/$f"`"
      $BZIP2 -cz9 "$newdir/$f" > "$workdir/$f"
      copy_perm "$newdir/$f" "$workdir/$f"
      make_add_instruction "$f" 1 >> "$updatemanifestv1"
      archivefiles="$archivefiles \"$f\""
      continue 1
    fi

    if ! diff "$olddir/$f" "$newdir/$f" > /dev/null; then
      dir=$(dirname "$workdir/$f")
      mkdir -p "$dir"
      $MBSDIFF "$olddir/$f" "$newdir/$f" "$workdir/$f.patch"
      $BZIP2 -z9 "$workdir/$f.patch"
      $BZIP2 -cz9 "$newdir/$f" > "$workdir/$f"
      copy_perm "$newdir/$f" "$workdir/$f"
      patchfile="$workdir/$f.patch.bz2"
      patchsize=$(get_file_size "$patchfile")
      fullsize=$(get_file_size "$workdir/$f")

      if [ $patchsize -lt $fullsize ]; then
        make_patch_instruction "$f" >> "$updatemanifestv1"
        mv -f "$patchfile" "$workdir/$f.patch"
        rm -f "$workdir/$f"
        archivefiles="$archivefiles \"$f.patch\""
      else
        make_add_instruction "$f" >> "$updatemanifestv1"
        rm -f "$patchfile"
        archivefiles="$archivefiles \"$f\""
      fi
    fi
  else
    remove_array[$num_removes]=$f
    (( num_removes++ ))
  fi
done

notice ""
notice "Adding file add instructions to file 'update.manifest'"
num_newfiles=${#newfiles[*]}

for ((i=0; $i<$num_newfiles; i=$i+1)); do
  f="${newfiles[$i]}"
  if [ "`basename $f`" = "removed-files" ]; then
    continue 1
  fi

  for ((j=0; $j<$num_oldfiles; j=$j+1)); do
    if [ "$f" = "${oldfiles[j]}" ]; then
      continue 2
    fi
  done

  dir=$(dirname "$workdir/$f")
  mkdir -p "$dir"

  $BZIP2 -cz9 "$newdir/$f" > "$workdir/$f"
  copy_perm "$newdir/$f" "$workdir/$f"

  make_add_instruction "$f" >> "$updatemanifestv1"
  archivefiles="$archivefiles \"$f\""
done

notice ""
notice "Adding file remove instructions to file 'update.manifest'"
for ((i=0; $i<$num_removes; i=$i+1)); do
  f="${remove_array[$i]}"
  notice "     remove: $f"
  echo "remove \"$f\"" >> "$updatemanifestv1"
done

notice ""
notice "Adding type instruction to file 'updatev2.manifest'"
> "$updatemanifestv2"
notice "       type: partial"
echo "type \"partial\"" >> "$updatemanifestv2"

notice ""
notice "Concatenating file 'update.manifest' to file 'updatev2.manifest'"
cat "$updatemanifestv1" >> "$updatemanifestv2"

notice ""
notice "Adding file and directory remove instructions from file 'removed-files'"
append_remove_instructions "$newdir" "$updatemanifestv1" "$updatemanifestv2"

notice ""
notice "Adding directory remove instructions for directories that no longer exist"
num_olddirs=${#olddirs[*]}

for ((i=0; $i<$num_olddirs; i=$i+1)); do
  f="${olddirs[$i]}"
  if [ ! -d "$newdir/$f" ]; then
    notice "      rmdir: $f/"
    echo "rmdir \"$f/\"" >> "$updatemanifestv2"
  fi
done

$BZIP2 -z9 "$updatemanifestv1" && mv -f "$updatemanifestv1.bz2" "$updatemanifestv1"
$BZIP2 -z9 "$updatemanifestv2" && mv -f "$updatemanifestv2.bz2" "$updatemanifestv2"

eval "$MAR -C \"$workdir\" -c output.mar $archivefiles"
mv -f "$workdir/output.mar" "$archive"

rm -fr "$workdir"

notice ""
notice "Finished"
