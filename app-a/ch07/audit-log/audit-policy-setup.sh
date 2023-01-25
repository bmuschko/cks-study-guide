#!/usr/bin/env bash

# Wait for control-plane node to transition into the "Ready" status
while true; do 
  JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' && kubectl get nodes -o jsonpath="$JSONPATH" | grep "Ready=True" | grep "Ready=True" &> /dev/null
  if [[ "$?" -ne 0 ]]; then
    sleep 5
  else
    break
  fi
done

sudo mkdir -p /etc/kubernetes/audit/rules
sudo tee -a /etc/kubernetes/audit/rules/audit-policy.yaml << END
apiVersion: audit.k8s.io/v1
kind: Policy
omitStages:
  - "RequestReceived"
rules:
  - level: RequestResponse
    resources:
    - group: ""
      resources: ["pods"]
END