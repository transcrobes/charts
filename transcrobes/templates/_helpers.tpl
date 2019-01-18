{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "transcrobes.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "transcrobes.fullname" -}}
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
Create unified labels for transcrobes components
*/}}
{{- define "transcrobes.common.matchLabels" -}}
app: {{ template "transcrobes.name" . }}
release: {{ .Release.Name }}
{{- end -}}

{{- define "transcrobes.common.metaLabels" -}}
chart: {{ .Chart.Name }}-{{ .Chart.Version }}
heritage: {{ .Release.Service }}
{{- end -}}

{{- define "transcrobes.ankrobes.labels" -}}
{{ include "transcrobes.ankrobes.matchLabels" . }}
{{ include "transcrobes.common.metaLabels" . }}
{{- end -}}

{{- define "transcrobes.ankrobes.matchLabels" -}}
component: {{ .Values.ankrobes.name | quote }}
{{ include "transcrobes.common.matchLabels" . }}
{{- end -}}

{{- define "transcrobes.corenlp.labels" -}}
{{ include "transcrobes.corenlp.matchLabels" . }}
{{ include "transcrobes.common.metaLabels" . }}
{{- end -}}

{{- define "transcrobes.corenlp.matchLabels" -}}
component: {{ .Values.corenlp.name | quote }}
{{ include "transcrobes.common.matchLabels" . }}
{{- end -}}

{{- define "transcrobes.transcrobes.labels" -}}
{{ include "transcrobes.transcrobes.matchLabels" . }}
{{ include "transcrobes.common.metaLabels" . }}
{{- end -}}

{{- define "transcrobes.transcrobes.matchLabels" -}}
component: {{ .Values.transcrobes.name | quote }}
{{ include "transcrobes.common.matchLabels" . }}
{{- end -}}

{{/*
Create a fully qualified ankrobes name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "transcrobes.ankrobes.fullname" -}}
{{- if .Values.ankrobes.fullnameOverride -}}
{{- .Values.ankrobes.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.ankrobes.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.ankrobes.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the ankrobes component
*/}}
{{- define "transcrobes.serviceAccountName.ankrobes" -}}
{{- if .Values.serviceAccounts.ankrobes.create -}}
    {{ default (include "transcrobes.ankrobes.fullname" .) .Values.serviceAccounts.ankrobes.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccounts.ankrobes.name }}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified transcrobes name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "transcrobes.transcrobes.fullname" -}}
{{- if .Values.transcrobes.fullnameOverride -}}
{{- .Values.transcrobes.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.transcrobes.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.transcrobes.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the transcrobes component
*/}}
{{- define "transcrobes.serviceAccountName.transcrobes" -}}
{{- if .Values.serviceAccounts.transcrobes.create -}}
    {{ default (include "transcrobes.transcrobes.fullname" .) .Values.serviceAccounts.transcrobes.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccounts.transcrobes.name }}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified corenlp name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "transcrobes.corenlp.fullname" -}}
{{- if .Values.corenlp.fullnameOverride -}}
{{- .Values.corenlp.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.corenlp.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.corenlp.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the corenlp component
*/}}
{{- define "transcrobes.serviceAccountName.corenlp" -}}
{{- if .Values.serviceAccounts.ankrobes.create -}}
    {{ default (include "transcrobes.corenlp.fullname" .) .Values.serviceAccounts.corenlp.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccounts.corenlp.name }}
{{- end -}}
{{- end -}}

{{- define "transcrobes.publichosts" -}}
{{- join "," .Values.transcrobes.hosts }}
{{- end -}}

{{- define "transcrobes.transcrobes.reallyFullname" -}}
{{- $fullname := include "transcrobes.transcrobes.fullname" . -}}
{{- printf "%s.%s.%s" $fullname .Release.Namespace "svc.cluster.local" -}}
{{- end -}}
