{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "milvus.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "milvus.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified standalone name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "milvus.standalone.fullname" -}}
{{ template "milvus.fullname" . }}-standalone
{{- end -}}

{{/*
Create a default fully qualified Root Coordinator name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "milvus.rootcoord.fullname" -}}
{{ template "milvus.fullname" . }}-rootcoord
{{- end -}}

{{/*
Create a default fully qualified Proxy name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "milvus.proxy.fullname" -}}
{{ template "milvus.fullname" . }}-proxy
{{- end -}}

{{/*
Create a default fully qualified Query Coordinator name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "milvus.querycoord.fullname" -}}
{{ template "milvus.fullname" . }}-querycoord
{{- end -}}

{{/*
Create a default fully qualified Query Node name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "milvus.querynode.fullname" -}}
{{ template "milvus.fullname" . }}-querynode
{{- end -}}

{{/*
Create a default fully qualified Index Coordinator name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "milvus.indexcoord.fullname" -}}
{{ template "milvus.fullname" . }}-indexcoord
{{- end -}}

{{/*
Create a default fully qualified Index Node name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "milvus.indexnode.fullname" -}}
{{ template "milvus.fullname" . }}-indexnode
{{- end -}}

{{/*
Create a default fully qualified Data Coordinator name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "milvus.datacoord.fullname" -}}
{{ template "milvus.fullname" . }}-datacoord
{{- end -}}

{{/*
Create a default fully qualified Data Node name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "milvus.datanode.fullname" -}}
{{ template "milvus.fullname" . }}-datanode
{{- end -}}

{{/*
Create a default fully qualified Mixture Coordinator name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "milvus.mixcoord.fullname" -}}
{{ template "milvus.fullname" . }}-mixcoord
{{- end -}}

{{/*
Create a default fully qualified Streaming Node name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "milvus.streamingnode.fullname" -}}
{{ template "milvus.fullname" . }}-streamingnode
{{- end -}}

{{/*
Create a default fully qualified pulsar name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "milvus.pulsar.fullname" -}}
{{- $name := .Values.pulsar.name -}}
{{- if contains $name .Release.Name -}}
{{ .Release.Name }}
{{- else -}}
{{ .Release.Name }}-pulsar
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified attu name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "milvus.attu.fullname" -}}
{{ template "milvus.fullname" . }}-attu
{{- end -}}

{{/*
  Create the name of the service account to use for the Milvus components
  */}}
  {{- define "milvus.serviceAccount" -}}
  {{- if .Values.serviceAccount.create -}}
      {{ default "milvus" .Values.serviceAccount.name }}
  {{- else -}}
      {{ default "default" .Values.serviceAccount.name }}
  {{- end -}}
  {{- end -}}

{{/*
Create milvus attu env name.
*/}}
{{- define "milvus.attu.env" -}}
- name: MILVUS_URL
  value: http://{{ template "milvus.fullname" .}}:19530
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "milvus.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Helm required labels */}}
{{- define "milvus.labels" -}}
helm.sh/chart: {{ include "milvus.chart" . }}
{{ include "milvus.matchLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/* labels defined by user*/}}
{{- define "milvus.ud.labels" -}}
{{- if .Values.labels }}
{{- toYaml .Values.labels }}
{{- end -}}
{{- end -}}

{{/* annotations defined by user*/}}
{{- define "milvus.ud.annotations" -}}
{{- if .Values.annotations }}
{{- toYaml .Values.annotations }}
{{- end -}}
{{- end -}}

{{/* matchLabels */}}
{{- define "milvus.matchLabels" -}}
app.kubernetes.io/name: {{ include "milvus.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* define rootcoord activeStandby */}}
{{- define "milvus.rootcoord.activeStandby" -}}
{{- if or .Values.rootCoordinator.activeStandby.enabled (and .Values.mixCoordinator.enabled .Values.mixCoordinator.activeStandby.enabled) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/* define querycoord activeStandby */}}
{{- define "milvus.querycoord.activeStandby" -}}
{{- if or .Values.queryCoordinator.activeStandby.enabled (and .Values.mixCoordinator.enabled .Values.mixCoordinator.activeStandby.enabled) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/* define indexcoord activeStandby */}}
{{- define "milvus.indexcoord.activeStandby" -}}
{{- if or .Values.indexCoordinator.activeStandby.enabled (and .Values.mixCoordinator.enabled .Values.mixCoordinator.activeStandby.enabled) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/* define datacoord activeStandby */}}
{{- define "milvus.datacoord.activeStandby" -}}
{{- if or .Values.dataCoordinator.activeStandby.enabled (and .Values.mixCoordinator.enabled .Values.mixCoordinator.activeStandby.enabled) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/* define milvus.standalone.messageQueue */}}
{{- define "milvus.standalone.messageQueue" -}}
{{/* first time deploy or specified non default mq in values, use it directly */}}
{{- $inputStandaloneMQ := .Values.standalone.messageQueue -}}
{{- if or (ne "woodpecker" $inputStandaloneMQ) (eq .Release.Revision 1) -}}
{{ $inputStandaloneMQ }}
{{- else -}}
    {{- $standaloneDeployName := include "milvus.standalone.fullname" . -}}
    {{- $standaloneDeploy := (lookup "apps/v1" "Deployment" .Release.Namespace $standaloneDeployName) -}}
    {{- if not $standaloneDeploy -}}
      {{ $inputStandaloneMQ }}
    {{- else -}}
      {{- $standaloneMQAnnotation := get $standaloneDeploy.metadata.annotations "milvus.io/message-queue" -}}
      {{- if and $standaloneMQAnnotation (ne "" $standaloneMQAnnotation) -}}
        {{ $standaloneMQAnnotation }}
      {{- else -}}
        "rocksmq"
      {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified Woodpecker name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "milvus.woodpecker.fullname" -}}
{{ template "milvus.fullname" . }}-woodpecker
{{- end -}}

{{/*
Woodpecker headless service name
*/}}
{{- define "milvus.woodpecker.headlessServiceName" -}}
{{ include "milvus.woodpecker.fullname" . }}-headless
{{- end -}}

{{/*
Woodpecker seed list - Generate a comma-separated list of woodpecker seed addresses
Parameters:
  - port (required): The port number to use for the seed list
    - Use .Values.woodpecker.ports.gossip for gossip/cluster communication
    - Use .Values.woodpecker.ports.service for client connections
Usage examples:
  - For gossip communication (cluster membership):
    {{ include "milvus.woodpecker.seedList" (merge (dict "port" .Values.woodpecker.ports.gossip) .) }}
  - For service/client connections:
    {{ include "milvus.woodpecker.seedList" (merge (dict "port" .Values.woodpecker.ports.service) .) }}
  - With custom port:
    {{ include "milvus.woodpecker.seedList" (merge (dict "port" 8080) .) }}
Output format:
  woodpecker-0.woodpecker-headless:PORT,woodpecker-1.woodpecker-headless:PORT,...
*/}}
{{- define "milvus.woodpecker.seedList" -}}
{{- $replicas := int .Values.woodpecker.replicaCount -}}
{{- $headless := include "milvus.woodpecker.headlessServiceName" . -}}
{{- $fullname := include "milvus.woodpecker.fullname" . -}}
{{- $port := int .port -}}
{{- $seedList := "" -}}
{{- range $i, $_ := until $replicas }}
  {{- if eq $seedList "" -}}
    {{- $seedList = printf "%s-%d.%s:%d" $fullname $i $headless $port -}}
  {{- else -}}
    {{- $seedList = printf "%s,%s-%d.%s:%d" $seedList $fullname $i $headless $port -}}
  {{- end -}}
{{- end -}}
{{- $seedList -}}
{{- end -}}

{{/*
Woodpecker MinIO address
*/}}
{{- define "milvus.woodpecker.minioAddress" -}}
{{- if .Values.woodpecker.minio.address -}}
{{- .Values.woodpecker.minio.address -}}
{{- else if .Values.externalS3.enabled -}}
{{- .Values.externalS3.host -}}
{{- else if .Values.minio.enabled -}}
{{- if contains .Values.minio.name .Release.Name -}}
{{- printf "%s.%s.svc.cluster.local" .Release.Name .Release.Namespace -}}
{{- else -}}
{{- printf "%s-%s.%s.svc.cluster.local" .Release.Name .Values.minio.name .Release.Namespace -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Woodpecker MinIO access key
*/}}
{{- define "milvus.woodpecker.minioAccessKey" -}}
{{- if .Values.woodpecker.minio.accessKey -}}
{{- .Values.woodpecker.minio.accessKey -}}
{{- else if .Values.externalS3.enabled -}}
{{- .Values.externalS3.accessKey -}}
{{- else if .Values.minio.accessKey -}}
{{- .Values.minio.accessKey -}}
{{- else -}}
minioadmin
{{- end -}}
{{- end -}}

{{/*
Woodpecker MinIO secret key
*/}}
{{- define "milvus.woodpecker.minioSecretKey" -}}
{{- if .Values.woodpecker.minio.secretKey -}}
{{- .Values.woodpecker.minio.secretKey -}}
{{- else if .Values.externalS3.enabled -}}
{{- .Values.externalS3.secretKey -}}
{{- else if .Values.minio.secretKey -}}
{{- .Values.minio.secretKey -}}
{{- else -}}
minioadmin
{{- end -}}
{{- end -}}

{{/*
Woodpecker MinIO bucket name
*/}}
{{- define "milvus.woodpecker.minioBucketName" -}}
{{- if .Values.woodpecker.minio.bucketName -}}
{{- .Values.woodpecker.minio.bucketName -}}
{{- else if .Values.externalS3.enabled -}}
{{- .Values.externalS3.bucketName -}}
{{- else if .Values.minio.bucketName -}}
{{- .Values.minio.bucketName -}}
{{- else -}}
milvus-bucket
{{- end -}}
{{- end -}}

{{/*
Check if external (non-embedded) Woodpecker is enabled
Returns "true" if woodpecker is enabled and not embedded, "false" otherwise
*/}}
{{- define "milvus.woodpecker.external.enabled" -}}
{{- if and (eq (.Values.streaming.woodpecker.embedded) false) (.Values.woodpecker.enabled) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}
