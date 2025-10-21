{{- define "woodpecker.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "woodpecker.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := include "woodpecker.name" . -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "woodpecker.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "woodpecker.labels" -}}
helm.sh/chart: {{ include "woodpecker.chart" . }}
{{ include "woodpecker.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "woodpecker.selectorLabels" -}}
app.kubernetes.io/name: {{ include "woodpecker.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "woodpecker.headlessServiceName" -}}
{{- $root := index . 0 -}}
{{- printf "%s-headless" (include "woodpecker.fullname" $root) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "woodpecker.minioAddress" -}}
{{- if .Values.minio.address -}}
{{- .Values.minio.address -}}
{{- else -}}
{{- printf "%s-minio.%s.svc.cluster.local" .Release.Name .Release.Namespace -}}
{{- end -}}
{{- end -}}
