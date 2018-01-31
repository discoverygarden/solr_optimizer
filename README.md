# solr_optimizer

We need to ensure that Solr's optimizations procedure periodically runs on all servers we maintain.

The plan is to schedule this script to run weekly as a crontab task.

Example:

```
# Optimize solr index every Sunday at 3:15 am
15 3 * * 0 /root/bin/solr_optimizer.sh
```