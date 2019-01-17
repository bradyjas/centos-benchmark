#!/usr/bin/env bash

# Command Line Arguments
POSITIONAL=()
MAXTHREADS=64
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
      -t|--max-threads)
        MAXTHREADS="$2"
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
i=1
THREADSEQ=()
while [ $i -lt ${MAXTHREADS} ]; do
  THREADSEQ+=(${i})
  i=$((i*2))
done
THREADSEQ+=(${MAXTHREADS})

# Run the tests
RESULTS=()
for threads in ${THREADSEQ[*]}; do
  printf "Running CPU Benchmark: %2d Thread(s)..." ${threads}
  OUTPUT=$(sysbench --threads=${threads} --cpu-max-prime=20000 cpu run)
  RESULTS+=($(echo $OUTPUT | grep -oP '\s+total number of events:\s+\K([0-9.]+)'))
  printf "  %'9d Events\n" $(echo $OUTPUT | grep -oP '\s+total number of events:\s+\K([0-9.]+)')
done
printf '\nCPU Benchmarks complete!\n\n  Spreadsheet copy: '
printf '%d ' ${RESULTS[@]} | cut -d " " -f 1-${#RESULTS[@]}
