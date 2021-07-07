#!/bin/bash

head="Content-Type: application/json"
user="admin:q1w2E#R$"



curl -X POST --insecure -H "$head" -d @dash.json --user $user  "http://akscluster.eastus2.cloudapp.azure.com/grafana/api/dashboards/db/"
