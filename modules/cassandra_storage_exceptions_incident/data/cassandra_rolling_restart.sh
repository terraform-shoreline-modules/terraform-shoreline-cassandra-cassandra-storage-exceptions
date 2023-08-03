

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