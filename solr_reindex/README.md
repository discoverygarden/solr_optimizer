# Parallel Solr re-indexing

The shell scripts in this directory allow for the parallelization of re-indexing.  This allows the process to happen much quicker than normal.

## Requirements

GNU Parallel provides official packages for quite the variety of flavors of Linux.

On Redhat flavored OSes building from source may be required and that can be done by doing the following:
```
wget http://ftp.gnu.org/gnu/parallel/parallel-latest.tar.bz2
yum install -y perl bzip2
tar -xf parallel-latest.tar.bz2
cd parallel-*
./configure
make install
```

Depending on the environments configuration adding `--jobs` with a number may be needed to ensure that Parallel does not become greedy and eat all the processor time.

### Usage

The provided `reindex.sh` shell script takes no arguments and will attempt to sniff out the user, password and URL from the `fedoragsearch.properties` file. If the `$GSEARCH_CONFIG` environment variable is set it will use that, otherwise the user will be prompted for the path.

Example:
```
./reindex.sh
Enter the path to the FedoraGSearch configuration (ex: /usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/fgsconfigFinal)

/usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/fgsconfigFinal

Re-indexing islandora%3Aroot
...
Re-indexing islandora%3AcollectionCModel
```

