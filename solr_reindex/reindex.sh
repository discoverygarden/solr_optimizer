#!/bin/bash

USAGE=$(cat << EOT
USAGE: $0 [OPITONS]
  -j [# of jobs]
      Number of jobs to run (default: CPU count+1 / 2 )
EOT
)

while getopts ":j:" option; do
  case $option in
    j)
      JOBS_NUM=$OPTARG
      ;;
    \?)
      echo "$USAGE" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument" >&2
      exit 1
      ;;
  esac
done

JOBS_DEFAULT=$(expr \( $(find /sys/devices/system/cpu -maxdepth 1 -type d -regex '.*/cpu[0-9]+$' | wc -l) + 1 \) / 2)
MEM_BUFF=$(expr $(grep MemTotal /proc/meminfo | awk '{print $2}') / 10)

if ! (hash parallel 2>/dev/null); then
  echo "parallel not found"
  exit 1
fi

if [ -f /etc/debian_version ]
  then
    if [ -f "/etc/default/fedora" ]; then
      source /etc/default/fedora
    fi
elif [ -f /etc/redhat-release ]
  then
    if [ -f "/etc/profile.d/fedora.sh" ]; then
      source /etc/profile.d/fedora.sh
    fi
else
  fedora_home_default="/usr/local/fedora"
  read -p "FEDORA_HOME [${fedora_home_default}]: " FEDORA_HOME
  gsearch=${FEDORA_HOME:-$fedora_home_default}
fi

readonly JOBS=${JOBS_NUM:-$JOBS_DEFAULT}
readonly data=${FEDORA_HOME}/data
readonly namespace_dir=$data/objectStore
readonly gsearch_default="${FEDORA_HOME}/tomcat/webapps/fedoragsearch/WEB-INF/classes/fgsconfigFinal"

if [ -z "$GSEARCH_CONFIG" ]; then
  read -p "Path to the FedoraGSearch configuration [${gsearch_default}]: " gsearch
  gsearch=${gsearch:-$gsearch_default}
else
  gsearch=$GSEARCH_CONFIG
fi

if [ -f "$gsearch/fedoragsearch.properties" ]; then
  user=$(grep ^fedoragsearch.soapUser $gsearch/fedoragsearch.properties | grep -o '=\s*.*$' | sed -e 's/^=\s*//')
  pass=$(grep ^fedoragsearch.soapPass $gsearch/fedoragsearch.properties | grep -o '=\s*.*$' | sed -e 's/^=\s*//')
  url=$(grep ^fedoragsearch.soapBase $gsearch/fedoragsearch.properties | grep -o '=\s*.*$' | sed -e 's/services/rest/' | sed -e 's/^=\s*//')
  find -L $namespace_dir -type f | sed -nr 's/.*info%3Afedora%2F(.*)/\1/p' | parallel --memfree ${MEM_BUFF}K --nice 10 --jobs ${JOBS} --gnu ./reindex_a_pid.sh $url $user \"$pass\" {}
else
  echo "Unable to find the fedoragsearch.properties file given the GSsearch directory of $gsearch"
fi
