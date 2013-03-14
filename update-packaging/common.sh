#!/bin/bash

MAR=${MAR:-mar}
BZIP2=${BZIP2:-bzip2}
MBSDIFF=${MBSDIFF:-mbsdiff}

notice() {
  echo "$*" 1>&2
}

get_file_size() {
  info=($(ls -ln "$1"))
  echo ${info[4]}
}

copy_perm() {
  reference="$1"
  target="$2"

  if [ -x "$reference" ]; then
    chmod 0755 "$target"
  else
    chmod 0644 "$target"
  fi
}

make_add_instruction() {
  f="$1"

  # Used to log to the console
  if [ $2 ]; then
    forced=" (forced)"
  else
    forced=
  fi

  is_extension=$(echo "$f" | grep -c 'extensions/.*/')
  if [ $is_extension = "1" ]; then
    testdir=$(echo "$f" | sed 's/\(extensions\/[^\/]*\)\/.*/\1/')
    notice "     add-if: $f$forced"
    echo "add-if \"$testdir\" \"$f\""
  else
    notice "        add: $f$forced"
    echo "add \"$f\""
  fi
}

make_patch_instruction() {
  f="$1"
  is_extension=$(echo "$f" | grep -c 'extensions/.*/')
  is_search_plugin=$(echo "$f" | grep -c 'searchplugins/.*')
  if [ $is_extension = "1" ]; then
    testdir=$(echo "$f" | sed 's/\(extensions\/[^\/]*\)\/.*/\1/')
    notice "   patch-if: $f"
    echo "patch-if \"$testdir\" \"$f.patch\" \"$f\""
  elif [ $is_search_plugin = "1" ]; then
    notice "   patch-if: $f"
    echo "patch-if \"$f\" \"$f.patch\" \"$f\""
  else
    notice "      patch: $f"
    echo "patch \"$f.patch\" \"$f\""
  fi
}

append_remove_instructions() {
  dir="$1"
  filev1="$2"
  filev2="$3"
  if [ -f "$dir/removed-files" ]; then
    prefix=
    listfile="$dir/removed-files"
  elif [ -f "$dir/Contents/MacOS/removed-files" ]; then
    prefix=Contents/MacOS/
    listfile="$dir/Contents/MacOS/removed-files"
  fi
  if [ -n "$listfile" ]; then
    files=($(cat "$listfile" | tr " " "|"  | sort -r))
    num_files=${#files[*]}
    for ((i=0; $i<$num_files; i=$i+1)); do
      f=$(echo ${files[$i]} | tr "|" " " | tr -d '\r')
      f=$(echo $f)
      if [ -n "$f" ]; then
        if [ ! $(echo "$f" | grep -c '^#') = 1 ]; then
          fixedprefix="$prefix"
          if [ $prefix ]; then
            if [ $(echo "$f" | grep -c '^\.\./') = 1 ]; then
              if [ $(echo "$f" | grep -c '^\.\./\.\./') = 1 ]; then
                f=$(echo $f | sed -e 's:^\.\.\/\.\.\/::')
                fixedprefix=""
              else
                f=$(echo $f | sed -e 's:^\.\.\/::')
                fixedprefix=$(echo "$prefix" | sed -e 's:[^\/]*\/$::')
              fi
            fi
          fi
          if [ $(echo "$f" | grep -c '\/$') = 1 ]; then
            notice "      rmdir: $fixedprefix$f"
            echo "rmdir \"$fixedprefix$f\"" >> "$filev2"
          elif [ $(echo "$f" | grep -c '\/\*$') = 1 ]; then
            f=$(echo "$f" | sed -e 's:\*$::')
            notice "    rmrfdir: $fixedprefix$f"
            echo "rmrfdir \"$fixedprefix$f\"" >> "$filev2"
          else
            notice "     remove: $fixedprefix$f"
            echo "remove \"$fixedprefix$f\"" >> "$filev1"
            echo "remove \"$fixedprefix$f\"" >> "$filev2"
          fi
        fi
      fi
    done
  fi
}

list_files() {
  count=0

  find . -type f \
    ! -name "channel-prefs.js" \
    ! -name "update.manifest" \
    ! -name "updatev2.manifest" \
    ! -name "temp-dirlist" \
    ! -name "temp-filelist" \
    | sed 's/\.\/\(.*\)/\1/' \
    | sort -r > "temp-filelist"
  while read file; do
    eval "${1}[$count]=\"$file\""
    (( count++ ))
  done < "temp-filelist"
  rm "temp-filelist"
}

list_dirs() {
  count=0

  find . -type d \
    ! -name "." \
    ! -name ".." \
    | sed 's/\.\/\(.*\)/\1/' \
    | sort -r > "temp-dirlist"
  while read dir; do
    eval "${1}[$count]=\"$dir\""
    (( count++ ))
  done < "temp-dirlist"
  rm "temp-dirlist"
}
