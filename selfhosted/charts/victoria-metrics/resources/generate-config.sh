#!/bin/sh

cat <<EOF > /config/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
EOF

for i in $(seq 0 99); do
  entry=$(eval echo "\$PROMETHEUS_SCRAPE_$i")
  if [ -z "$entry" ]; then
    continue
  fi

  name=$(echo "$entry" | cut -d '=' -f 1)
  address=$(echo "$entry" | cut -d '=' -f 2)

  echo "  - job_name: \"$name\"" >> /config/prometheus.yml
  echo "    static_configs:" >> /config/prometheus.yml
  echo "      - targets: [\"$address\"]" >> /config/prometheus.yml

  labels=$(eval echo "\$PROMETHEUS_LABELS_$i")
  if [ -n "$labels" ]; then
    echo "        labels:" >> /config/prometheus.yml
    for label in $(echo "$labels" | tr ";" "\n"); do
      label_name=$(echo "$label" | cut -d "=" -f 1)
      label_value=$(echo "$label" | cut -d "=" -f 2)
      echo "          \"$label_name\": \"$label_value\"" >> /config/prometheus.yml
    done
  fi
done

cat <<EOF > /config/relabel.yml
- action: labelmap
  if: "xray_sent_bytes_total"
  regex: "email"
  replacement: "user_name"
- action: labelmap
  if: "xray_received_bytes_total"
  regex: "email"
  replacement: "user_name"
EOF
