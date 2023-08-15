#!/usr/bin/python3 -u

import json
import os
import re
import subprocess

from http.server import BaseHTTPRequestHandler, HTTPServer

xray_binary = None
xray_api_server = None

class Metrics:
    received_by_user = dict()
    sent_by_user = dict()

    def format_prometheus(self):
        def serialize_metric(name, labels, value):
            labels_text = map(lambda it: f"{it[0]}=\"{it[1]}\"", labels.items())
            return f"{name}{{{','.join(labels_text)}}} {value}"

        result = ""

        result += "# HELP xray_sent_bytes_total Bytes sent to the peer\n"
        result += "# TYPE xray_sent_bytes_total counter\n"
        for email, value in self.sent_by_user.items():
            result += serialize_metric("xray_sent_bytes_total", {"email": email}, value)
            result += "\n"

        result += "\n"

        result += "# HELP xray_received_bytes_total Bytes received from the peer\n"
        result += "# TYPE xray_received_bytes_total counter\n"
        for email, value in self.received_by_user.items():
            result += serialize_metric("xray_received_bytes_total", {"email": email}, value)
            result += "\n"

        return result

class RequestHandler(BaseHTTPRequestHandler):

    def do_HEAD(self):
        self.send_response_only(200)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()

    def do_GET(self):
        try:
            metrics = self.collect_metrics()
        except Exception as e:
            print("Failed to collect metrics from Xray")
            print(e)

            self.send_response_only(500)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
        else:
            self.send_response_only(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()

            for line in metrics.format_prometheus().splitlines():
                self.wfile.write(line.encode("utf-8"))
                self.wfile.write("\r\n".encode("utf-8"))

    def collect_metrics(self):
        cmd = [xray_binary, "api", "statsquery", "-s", xray_api_server]

        result = subprocess.run(cmd, stdout=subprocess.PIPE)
        if result.returncode != 0:
            raise Exception(f"{' '.join(cmd)}: exit code={result.returncode}")

        json_data = json.loads(result.stdout)

        metrics = Metrics()
        for metric in json_data["stat"]:
            name = metric["name"]
            value = metric["value"]

            match = re.match("^user>>>(.+?)>>>traffic>>>(.+?)$", name)
            if match is not None:
                email = match.group(1)
                direction = match.group(2)

                if direction == "uplink":
                    metrics.received_by_user[email] = value
                elif direction == "downlink":
                    metrics.sent_by_user[email] = value

                continue

        return metrics

def main():
    listen_address = os.getenv("XRAY_PROMETHEUS_EXPORTER_ADDRESS", "0.0.0.0")
    listen_port = int(os.getenv("XRAY_PROMETHEUS_EXPORTER_PORT", "9686"))

    global xray_binary
    xray_binary = os.getenv("XRAY_PROMETHEUS_EXPORTER_XRAY_BINARY", "xray")
    global xray_api_server
    xray_api_server = os.getenv("XRAY_PROMETHEUS_EXPORTER_XRAY_API_SERVER", "127.0.0.1:8080")

    with HTTPServer((listen_address, listen_port), RequestHandler) as server:
        server.serve_forever()

if __name__ == "__main__":
    main()
