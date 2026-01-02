{{/*
=============================================================================
Helm Template Helpers
=============================================================================
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "guestbook.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "guestbook.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "guestbook.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "guestbook.labels" -}}
helm.sh/chart: {{ include "guestbook.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: maria-guestbook
{{- end }}

{{/*
Backend labels
*/}}
{{- define "guestbook.backend.labels" -}}
{{ include "guestbook.labels" . }}
app.kubernetes.io/name: maria-backend
app.kubernetes.io/component: backend
{{- end }}

{{/*
Backend selector labels
*/}}
{{- define "guestbook.backend.selectorLabels" -}}
app.kubernetes.io/name: maria-backend
{{- end }}

{{/*
Frontend labels
*/}}
{{- define "guestbook.frontend.labels" -}}
{{ include "guestbook.labels" . }}
app.kubernetes.io/name: maria-frontend
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Frontend selector labels
*/}}
{{- define "guestbook.frontend.selectorLabels" -}}
app.kubernetes.io/name: maria-frontend
{{- end }}

{{/*
Redis labels
*/}}
{{- define "guestbook.redis.labels" -}}
{{ include "guestbook.labels" . }}
app.kubernetes.io/name: maria-redis
app.kubernetes.io/component: cache
{{- end }}

{{/*
Redis selector labels
*/}}
{{- define "guestbook.redis.selectorLabels" -}}
app.kubernetes.io/name: maria-redis
{{- end }}

{{/*
Image pull secrets
*/}}
{{- define "guestbook.imagePullSecrets" -}}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ .name }}
{{- end }}
{{- end }}
{{- end }}
