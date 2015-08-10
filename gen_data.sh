#!/bin/bash

while getopts ":T:C:S:s:t:" opt; do
  case $opt in
    T)
      T=$OPTARG
      ;;
    C)
      C=$OPTARG
      ;;
    S)
      S=$OPTARG
      ;;
    s)
      s=$OPTARG
      ;;
    t)
      t=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR

# Use fifo to avoid writing to disk
mkfifo "$t"

# Start background job
(cat "$t" | gzip -9 -f) &
pid=$!

# Generate data
./dbgen -T "$T" -C "$C" -S "$S" -s "$s" -f > /dev/null 2>&1

# Wait for all records to be written to fifo & stdout
wait "$pid"

# Remove fifo
rm "$t"
