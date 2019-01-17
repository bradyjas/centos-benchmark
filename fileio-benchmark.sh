#!/usr/bin/env bash

# Command Line Arguments
POSITIONAL=()
MAXTHREADS=1
FILESIZE=8G
FILENUM=64
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
      -t|--max-threads)
        MAXTHREADS="$2"
        shift; shift
      ;;
      -s|--file-size)
        FILESIZE="$2"
        shift; shift
      ;;
      -n|--file-num)
        FILENUM="$2"
        shift; shift
      ;;
      *)  # Unknown option
      POSITIONAL+=("$1") # Save it in an array for later
      shift
      ;;
  esac
done
set -- "${POSITIONAL[@]}" # Restore positional parameters

# Calculate threads to test
RESULTS=()
THREADSEQ=(1)
if [ ${MAXTHREADS} -gt 1 ]; then
  THREADSEQ+=(${MAXTHREADS})
fi

# Run the tests
for block in 4 16; do
  for threads in ${THREADSEQ}; do
    for mode in 'seqrd' 'seqwr' 'rndrd' 'rndwr' 'rndrw'; do
      printf "Preparing test files... (this may take some time)\n"
      sysbench --threads=${MAXTHREADS} --file-total-size=${FILESIZE} --file-num=${FILENUM} fileio prepare > /dev/null
      printf "Running FileIO Benchmark: %2dK blocks, %2d Thread(s), '%s' mode...\n" ${block} ${threads} ${mode}
      OUTPUT=$(sysbench --file-total-size=${FILESIZE} --file-num=${FILENUM} --time=20 \
        --threads=${threads} --file-test-mode=${mode} --file-block-size=${block}K \
        fileio run)
      RESULT=(
        $(echo $OUTPUT | grep -oP '\s+reads\/s:\s+\K([0-9.]+)') \
        $(echo $OUTPUT | grep -oP '\s+read, MiB\/s:\s+\K([0-9.]+)') \
        $(echo $OUTPUT | grep -oP '\s+writes\/s:\s+\K([0-9.]+)') \
        $(echo $OUTPUT | grep -oP '\s+written, MiB\/s:\s+\K([0-9.]+)') \
        $(echo $OUTPUT | grep -oP '\s+total number of events:\s+\K([0-9.]+)'))
      RESULTS+=("${RESULT[*]}")
      printf "  File reads:     %'15.2f\n" ${RESULT[0]}
      printf "  Read speed:     %'15.2f MiB/s\n" ${RESULT[1]}
      printf "  File writes:    %'15.2f\n" ${RESULT[2]}
      printf "  Write speed:    %'15.2f MiB/s\n" ${RESULT[3]}
      printf "  Total events:   %'12d\n" ${RESULT[4]}
      done
    done
  done
printf "Cleaning up test files...\n"
sysbench fileio cleanup > /dev/null
printf '\nFileIO Benchmarks complete!\n\n  Spreadsheet copy:\n'
printf "%s\n" "${RESULTS[@]}"
