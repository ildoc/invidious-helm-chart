{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "invidious.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "invidious.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "invidious.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "invidious.labels" -}}
helm.sh/chart: {{ include "invidious.chart" . }}
{{ include "invidious.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "invidious.selectorLabels" -}}
app.kubernetes.io/name: {{ include "invidious.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Initialize default values and validate database configuration
*/}}
{{- define "invidious.init-defaults" -}}
    {{/* When using existingSecret, set dummy values to pass validation */}}
    {{- if .Values.existingSecret }}
        {{- if .Values.companion.enabled }}
            {{- if not .Values.config.invidious_companion_key }}
                {{- $_ := set .Values.config "invidious_companion_key" "FROM_EXISTING_SECRET" }}
            {{- end }}
        {{- end }}
        {{- if not .Values.config.hmac_key }}
            {{- $_ := set .Values.config "hmac_key" "FROM_EXISTING_SECRET" }}
        {{- end }}
        {{- if not .Values.config.db.password }}
            {{- $_ := set .Values.config.db "password" "FROM_EXISTING_SECRET" }}
        {{- end }}
    {{- end }}

    {{/* Set default PostgreSQL host if using in-chart PostgreSQL */}}
    {{- if .Values.postgresql.enabled }}
        {{- if not .Values.config.db.host }}
        {{- $_ := set .Values.config.db "host" (printf "%s-postgresql" .Release.Name) }}
        {{- end }}
    {{- else }}
    {{/* Fail if external database host is not provided when in-chart PostgreSQL is disabled */}}
        {{- if not .Values.config.db.host }}
        {{- fail "config.db.host must be set when postgresql.enabled is false" }}
        {{- end }}
    {{- end }}

    {{/* Set companion URL if companion is enabled */}}
    {{- if .Values.companion.enabled }}
        {{- if not (index .Values.config.invidious_companion 0).private_url }}
        {{- $serviceName := printf "%s-companion" (include "invidious.fullname" .) }}
        {{- $servicePort := .Values.companion.service.port | default 8282 | int }}
        {{- $companionUrl := printf "http://%s:%d/companion" $serviceName $servicePort }}
        {{- $_ := set (index .Values.config.invidious_companion 0) "private_url" $companionUrl }}
        {{- end }}
        
        {{/* Validate companion key is provided ONLY if not using existingSecret */}}
        {{- if not .Values.existingSecret }}
            {{- if not .Values.config.invidious_companion_key }}
            {{- fail "invidious_companion_key must be set when companion.enabled is true (via existingSecret or config.invidious_companion_key)" }}
            {{- end }}
        {{- end }}
    {{- end }}

    {{/* Validate required secrets ONLY if not using existingSecret */}}
    {{- if not .Values.existingSecret }}
        {{/* Validate HMAC key for production */}}
        {{- if not .Values.config.hmac_key }}
        {{- fail "hmac_key should be set for production use (via existingSecret or config.hmac_key)" }}
        {{- end }}
        
        {{/* Validate database password */}}
        {{- if not .Values.config.db.password }}
        {{- fail "config.db.password must be set when not using existingSecret" }}
        {{- end }}
    {{- end }}

    {{/* Validate that Gateway and Ingress are not both enabled */}}
    {{- if and .Values.gateway.enabled .Values.ingress.enabled }}
    {{- fail "Cannot enable both gateway.enabled and ingress.enabled at the same time. Choose one routing method." }}
    {{- end }}
{{- end -}}
