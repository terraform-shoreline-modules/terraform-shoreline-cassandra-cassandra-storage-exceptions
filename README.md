
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Cassandra storage exceptions incident.
---

This incident type refers to an issue related to the Cassandra storage system. It indicates that there are exceptions occurring in the Cassandra storage system, which is causing problems with the functioning of the system. This can have a significant impact on the performance of the system and may require urgent attention to resolve the issue.

### Parameters
```shell
# Environment Variables

export KEYSPACE="PLACEHOLDER"

export TABLE="PLACEHOLDER"

export THREAD_POOL_NAME="PLACEHOLDER"

export CASSANDRA_NODE_IP="PLACEHOLDER"

export APPLICATION_LOG_FILE="PLACEHOLDER"

```

## Debug

### Check if Cassandra is running
```shell
systemctl status cassandra
```

### Check the Cassandra logs for any errors
```shell
tail -f /var/log/cassandra/system.log
```

### Check the status of the Cassandra cluster
```shell
nodetool status
```

### Check the disk space usage on each node in the cluster
```shell
nodetool status | awk '{print $2}' | xargs -I {} ssh {} df -h
```

### Check the status of the Cassandra storage on each node in the cluster
```shell
nodetool status | awk '{print $2}' | xargs -I {} ssh {} nodetool cfstats | grep -A 3 "Table: ${KEYSPACE}.${TABLE}"
```

### Check the metrics for the Cassandra cluster
```shell
nodetool cfstats -H
```

### Check the load on each node in the cluster
```shell
nodetool tpstats | grep "${THREAD_POOL_NAME}"
```

### Check the replication factor of the keyspace
```shell
cqlsh -e "describe keyspace ${KEYSPACE}"
```

### Check the schema of the table
```shell
cqlsh -e "describe table ${KEYSPACE}.${TABLE}"
```

## Repair

### Step 1: Analyze system logs for errors related to Cassandra storage
```shell
grep "Cassandra storage" /var/log/syslog > cassandra_errors.txt
```

### Step 2: Review Cassandra configuration settings
```shell
cat /etc/cassandra/cassandra.yaml > cassandra_config.txt
```

### Step 3: Verify network connectivity for Cassandra nodes
```shell
ping ${CASSANDRA_NODE_IP}
```

### Step 4: Check hardware resources of each Cassandra node
```shell
ssh ${CASSANDRA_NODE_IP} "free -h && cat /proc/cpuinfo"
```

### Step 5: Review query patterns and data access patterns of the application
```shell
cat ${APPLICATION_LOG_FILE} | grep "Cassandra" > cassandra_queries.txt
```

### Try restarting the Cassandra service to see if the issue resolves itself. If restarting the service does not work, consider performing a rolling restart of Cassandra across the cluster.
```shell


#!/bin/bash



# Stop Cassandra service

sudo service cassandra stop



# Wait for 30 seconds to allow Cassandra to fully stop

sleep 30



# Start Cassandra service again

sudo service cassandra start



# Wait for 30 seconds to allow Cassandra to fully start

sleep 30



# Check if Cassandra service is running

if sudo service cassandra status | grep -q "is running"; then

  echo "Cassandra service has been restarted successfully"

else

  # If Cassandra service is not running, perform a rolling restart across the cluster

  echo "Cassandra service failed to restart. Performing a rolling restart across the cluster..."



  # Get list of nodes in the cluster

  nodes="PLACEHOLDER"



  # Loop through each node and restart Cassandra service

  for node in $nodes; do

    # Stop Cassandra service on the node

    ssh $node "sudo service cassandra stop"



    # Wait for 30 seconds to allow Cassandra to fully stop

    sleep 30



    # Start Cassandra service on the node

    ssh $node "sudo service cassandra start"



    # Wait for 30 seconds to allow Cassandra to fully start

    sleep 30



    # Check if Cassandra service is running on the node

    if ssh $node "sudo service cassandra status" | grep -q "is running"; then

      echo "Cassandra service has been restarted successfully on $node"

    else

      echo "Failed to restart Cassandra service on $node"

    fi

  done



  echo "Rolling restart of Cassandra across the cluster has been completed"

fi


```