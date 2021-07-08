#!/bin/bash

head="Content-Type: application/json"
user="admin:q1w2E#R$"



curl -X POST --insecure -H "$head" -d @dash.json --user $user  "https://aks.vv.devops4.fun/grafana/api/dashboards/db/"
