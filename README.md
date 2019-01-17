# centos-benchmark

This is a collection of a few scripts that will benchmark a CentOS system and
report the results.

## Setup
[`sysbench`](https://github.com/akopytov/sysbench) is the required application
that does the actual benchmarking. Perform the following commands to install
`sysbench`:

```shell
# These commands are from the README.md in the `sysbench` GitHub repository
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | sudo bash
sudo yum -y install sysbench
```

## cpu-benchmark

The CPU benchmark takes an optional argument of the maximum number of threads
to run the test on. The default is 64 threads. Other arguments are ignored.

```shell
# Default argument values are used
./cpu-benchmark.sh --max-threads 64
```

The results output will show the number of operations the benchmarks was able
to perform. The output also contains a string for easy pasting into a
spreadsheet.

## fileio-benchmark

The File I/O benchmark takes optional arguments that changes size and number of
files used during the test, and the maximum thread count for tests. Defaults
to 64 files totaling 8 gigabytes. Tests will be run on 1 thread and the maximum
threads you specified.

```shell
# Default argument values are used
./fileio-benchmark.sh --max-threads 1 --file-size 8G --file-num 64
```

The results output will show the number of file operations for each mode, and
well as the data throughput. The output also contains a multi-line string for
easy pasting into a spreadsheet.