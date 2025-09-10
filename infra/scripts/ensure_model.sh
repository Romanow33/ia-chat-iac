#!/bin/sh
set -euo pipefail

MODEL_RAW="${OLLAMA_MODEL:-tinyllama}"
BASE="${OLLAMA_URL:-http://host.docker.internal:11434}"

# Normalizar por si el .env viene con CRLF (Windows)
MODEL_RAW="$(printf '%s' "$MODEL_RAW" | tr -d '\r')"
BASE="$(printf '%s' "$BASE" | tr -d '\r')"

echo "Usando OLLAMA_URL=$BASE"
echo "Modelo deseado: $MODEL_RAW"

check_model() {
  # devuelve 0 si el modelo existe en Ollama
  curl -fsS -X POST "$BASE/api/show" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"$1\"}" >/dev/null 2>&1
}

# 1) Esperar que Ollama responda (hasta 60s)
echo "Chequeando Ollama..."
for i in $(seq 1 60); do
  if curl -fsS "$BASE/api/version" >/dev/null 2>&1; then
    echo "Ollama OK."
    break
  fi
  sleep 1
  [ "$i" -eq 60 ] && { echo "ERROR: Ollama no responde en $BASE"; exit 1; }
done

# 2) ¿El modelo ya está?
if check_model "$MODEL_RAW"; then
  echo "Modelo presente: $MODEL_RAW"
  exit 0
fi

# 3) Probar variante :latest si no la incluiste
MODEL_LATEST="${MODEL_RAW%:latest}:latest"
if [ "$MODEL_LATEST" != "$MODEL_RAW" ] && check_model "$MODEL_LATEST"; then
  echo "Modelo presente como: $MODEL_LATEST"
  exit 0
fi

# 4) No existe: pull
TO_PULL="$MODEL_RAW"
echo "Modelo NO encontrado. Haciendo pull de: $TO_PULL"
curl -fsS -X POST "$BASE/api/pull" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$TO_PULL\"}" || true

# 5) Esperar hasta que exista (máx ~10 min)
echo "Esperando a que el modelo esté disponible..."
for i in $(seq 1 600); do
  if check_model "$TO_PULL" || check_model "$MODEL_LATEST"; then
    echo "Modelo listo."
    exit 0
  fi
  sleep 1
done

echo "ERROR: no se pudo preparar el modelo a tiempo."
exit 1
