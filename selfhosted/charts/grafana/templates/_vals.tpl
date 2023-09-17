{{- define "labels" -}}
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
{{ include "selectorLabels" . }}
{{- end }}

{{- define "selectorLabels" -}}
app.kubernetes.io/name: "{{ .Chart.Name }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
{{- end }}
