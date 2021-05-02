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

{{- define "transcrobes.corenlpZh.labels" -}}
{{ include "transcrobes.corenlpZh.matchLabels" . }}
{{ include "transcrobes.common.metaLabels" . }}
{{- end -}}

{{- define "transcrobes.corenlpZh.matchLabels" -}}
component: {{ .Values.corenlpZh.name | quote }}
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


{{- define "transcrobes.asgi.labels" -}}
{{ include "transcrobes.asgi.matchLabels" . }}
{{ include "transcrobes.common.metaLabels" . }}
{{- end -}}

{{- define "transcrobes.asgi.matchLabels" -}}
component: {{ .Values.asgi.name | quote }}
{{ include "transcrobes.common.matchLabels" . }}
{{- end -}}


{{/*
Common labels statsrunner
*/}}
{{- define "transcrobes.statsrunner.labels" -}}
helm.sh/chart: {{ include "transcrobes.name" . }}
{{ include "transcrobes.statsrunner.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels statsrunner
*/}}
{{- define "transcrobes.statsrunner.selectorLabels" -}}
app.kubernetes.io/name: {{ include "transcrobes.name" . }}-statsrunner
app.kubernetes.io/instance: {{ .Release.Name }}-statsrunner
{{- end }}

{{- define "transcrobes.statsrunner.matchLabels" -}}
component: {{ .Values.statsrunner.name | quote }}
{{ include "transcrobes.common.matchLabels" . }}
{{- end -}}

{{/*
Common labels importsrunner
*/}}
{{- define "transcrobes.importsrunner.labels" -}}
helm.sh/chart: {{ include "transcrobes.name" . }}
{{ include "transcrobes.importsrunner.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels importsrunner
*/}}
{{- define "transcrobes.importsrunner.selectorLabels" -}}
app.kubernetes.io/name: {{ include "transcrobes.name" . }}-importsrunner
app.kubernetes.io/instance: {{ .Release.Name }}-importsrunner
{{- end }}

{{- define "transcrobes.importsrunner.matchLabels" -}}
component: {{ .Values.importsrunner.name | quote }}
{{ include "transcrobes.common.matchLabels" . }}
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
Create a fully qualified corenlpZh name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "transcrobes.corenlpZh.fullname" -}}
{{- if .Values.corenlpZh.fullnameOverride -}}
{{- .Values.corenlpZh.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.corenlpZh.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.corenlpZh.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the corenlpZh component
*/}}
{{- define "transcrobes.serviceAccountName.corenlpZh" -}}
{{- if .Values.serviceAccounts.corenlpZh.create -}}
    {{ default (include "transcrobes.corenlpZh.fullname" .) .Values.serviceAccounts.corenlpZh.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccounts.corenlpZh.name }}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified kafka name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "transcrobes.kafka.fullname" -}}
{{- if .Values.kafka.fullnameOverride -}}
{{- .Values.kafka.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.kafka.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.kafka.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.kafka.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Other helper functions
*/}}

{{- define "transcrobes.nodeHosts" -}}
{{- join "," .Values.transcrobes.nodeHosts }}
{{- end -}}

{{- define "transcrobes.transcrobes.reallyFullname" -}}
{{- $fullname := include "transcrobes.transcrobes.fullname" . -}}
{{- printf "%s.%s.%s" $fullname .Release.Namespace "svc.cluster.local" -}}
{{- end -}}
