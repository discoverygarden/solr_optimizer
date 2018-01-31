#!/bin/bash

# This script will check the version of solr installed on the server and use
# curl to optimize the index by hitting the correct end point.
# We can schedule it with a crontab

# {{{ Set some vars

solrManifest=$CATALINA_HOME/webapps/solr/META-INF/MANIFEST.MF
solr3OptimizeURL='http://localhost:8080/solr/update?stream.body="<optimize/>"'
solr4OptimizeURL='http://localhost:8080/solr/collection1/update?optimize=true'
myPid=$(echo $$)
pidFile=/var/run/solr_optimizer.pid

# }}}
# {{{ checkSafe()

checkSafe()
{
  if [ "$1" -ne "0" ]; then
    if [ "$2" == "" ]; then
      echo "Failed."
      else
        echo $2
    fi
    exit 1
  fi
}

# }}}
# {{{ sanityCheck()

sanityCheck()
{
  # Check how we were called and re-run script as sudo if we were not already
  if [ -z "$SUDO_COMMAND" ]
  then
    sudo -E $0 $*
    exit
  fi

  # If we find an existing pidFile we check to see if a previous optimize is
  # stil running by doing a ps listing for that pid
  if [ -f $pidFile ]; then
    ps -p $(cat $pidFile) > /dev/null
    checkSafe $(( $?-1 )) "another optimize is still running"
  fi

  # Ensure we can find curl
  which curl > /dev/null
  checkSafe $? "can't find curl"

  # Check for solr where we think it is normallu installed
  if [ ! -f $solrManifest ]; then
    checkSafe 1 "can not find solr"
  fi
}

# }}}
#{{{ writePid()

writeClearPid()
{
  if [ "$1" -eq "0" ]; then
    rm -rf $pidFile
  else
  # This will overwrite an old file if present. That's ok though.
    echo $myPid > $pidFile
    checkSafe $? "can not write pid"
  fi
}

# }}}
# {{{ getSolrVerion()

getSolrVersion()
{
  solrVersion=$(cat $solrManifest | grep Specification-Version | cut -d" " -f2)
  solrMajorVersion=$(echo $solrVersion | cut -d. -f1)
}

# }}}
# {{{ hitTheButton()

hitTheButton()
{
  case $solrMajorVersion in
    3)
      curl -s $solr3OptimizeURL > /dev/null
      ;;
    4)
      curl -s $solr4OptimizeURL > /dev/null
      ;;
    *)
      checkSafe 1 "unknown solr version - time to update this script"
      ;;
  esac
}

# }}}

sanityCheck
writeClearPid 1
getSolrVersion
hitTheButton
writeClearPid 0
