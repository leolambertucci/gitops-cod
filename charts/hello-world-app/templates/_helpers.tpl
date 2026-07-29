{{- define "hello-world-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "hello-world-app.fullname" -}}
{{- include "hello-world-app.name" . -}}
{{- end -}}

{{- define "hello-world-app.labels" -}}
app.kubernetes.io/name: {{ include "hello-world-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}