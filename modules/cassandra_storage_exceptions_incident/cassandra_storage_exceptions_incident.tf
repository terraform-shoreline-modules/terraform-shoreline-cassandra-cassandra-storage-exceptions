resource "shoreline_notebook" "cassandra_storage_exceptions_incident" {
  name       = "cassandra_storage_exceptions_incident"
  data       = file("${path.module}/data/cassandra_storage_exceptions_incident.json")
  depends_on = [shoreline_action.invoke_cassandra_rolling_restart]
}

resource "shoreline_file" "cassandra_rolling_restart" {
  name             = "cassandra_rolling_restart"
  input_file       = "${path.module}/data/cassandra_rolling_restart.sh"
  md5              = filemd5("${path.module}/data/cassandra_rolling_restart.sh")
  description      = "Try restarting the Cassandra service to see if the issue resolves itself. If restarting the service does not work, consider performing a rolling restart of Cassandra across the cluster."
  destination_path = "/agent/scripts/cassandra_rolling_restart.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_cassandra_rolling_restart" {
  name        = "invoke_cassandra_rolling_restart"
  description = "Try restarting the Cassandra service to see if the issue resolves itself. If restarting the service does not work, consider performing a rolling restart of Cassandra across the cluster."
  command     = "`chmod +x /agent/scripts/cassandra_rolling_restart.sh && /agent/scripts/cassandra_rolling_restart.sh`"
  params      = []
  file_deps   = ["cassandra_rolling_restart"]
  enabled     = true
  depends_on  = [shoreline_file.cassandra_rolling_restart]
}

