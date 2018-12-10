# Parallel Solr re-indexing

The shell scripts in this directory allow for the parallelization of re-indexing.  This allows the process to happen much quicker than normal.

## Requirements

The latest version of [GNU parallel](https://www.gnu.org/software/parallel/) is required.

```
# perl bzip2 are required, install these with your OS's package manager (yum or apt)

wget http://ftp.gnu.org/gnu/parallel/parallel-latest.tar.bz2
tar -xf parallel-latest.tar.bz2
cd parallel-*
./configure
make install

# run this once to access the citation agreement.
parallel --citation
```


## Usage

The provided `reindex.sh` shell script requires no arguments and will attempt to sniff out the user, password and URL from the `fedoragsearch.properties` file. If the `$GSEARCH_CONFIG` environment variable is set it will use that, otherwise the user will be prompted for the path.

By default the script will create half the number of jobs as cpu cores, this can be set manually with -j, jobs should never exceed the total number of cpu cores available.

```
root@SERVER:/opt/solr_optimizer/solr_reindex# ./reindex.sh -h
USAGE: ./reindex.sh [OPITONS]
  -j [# of jobs]
      Number of jobs to run (default: CPU count+1 / 2 )
```

## Example
```
root@SERVER:/opt/solr_optimizer/solr_reindex# ./reindex.sh
SUCCESS Re-indexing islandora%3AtransformCModel [HTTP status: 200]
SUCCESS Re-indexing islandora%3Aroot [HTTP status: 200]
SUCCESS Re-indexing islandora%3A1 [HTTP status: 200]
...
SUCCESS Re-indexing islandora%3A9999 [HTTP status: 200]
```

