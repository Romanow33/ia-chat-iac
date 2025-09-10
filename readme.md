# 🚀 FastAPI + Ollama (Infra as Code Demo)

Este proyecto muestra cómo desplegar una **“lambda local” con FastAPI** que se conecta a una instancia de **Ollama** corriendo en tu máquina.  
La idea es tener un flujo de **Infra as Code (IaC)** usando `docker-compose`, que:

1. Verifica que Ollama esté corriendo.
2. Comprueba que el modelo definido en `.env` existe (y si no, lo descarga).
3. Levanta la aplicación FastAPI que expone un endpoint `/chat`.

---

## ✨ Características
- **Infra as Code** con `docker-compose`.
- **Init script** que asegura la disponibilidad del modelo Ollama (`ensure_model.sh`).
- **FastAPI** para exponer endpoints (`/chat` y `/healthz`).
- Configurable vía archivo `.env`.

---

## 📂 Estructura del proyecto
```
.
├─ app/
│  ├─ main.py
│  ├─ requirements.txt
│  └─ Dockerfile
├─ scripts/
│  └─ ensure_model.sh
├─ docker-compose.yml
├─ .env
```

---

## 🔧 Requisitos
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Ollama](https://ollama.ai) corriendo en tu host (`ollama serve`)
- Un modelo descargado (ej: `tinyllama`)

```bash
ollama list
ollama pull tinyllama
```

---

## ⚙️ Configuración

Archivo **.env**:

```env
USE_OLLAMA=1
OLLAMA_URL=http://host.docker.internal:11434
OLLAMA_MODEL=tinyllama:latest
```

---

## ▶️ Levantar el sistema

(Asegurese de que Docker este corriendo en el sistema)

```bash
ollama serve
docker compose up -d --build
```

Ver logs del init:

```bash
docker logs ensure-model --tail=100
```

---

## ✅ Probar la API

Healthcheck:

```bash
curl http://localhost:9000/healthz
```

Chat con el modelo:

```bash
curl -s -X POST http://localhost:9000/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"¿Qué es IaC en una línea?"}'
```

Ejemplo de respuesta:

```json
{"reply":"IaC es gestionar infraestructura con código declarativo."}
```

---

## 🛠️ Desarrollo local

Instalar dependencias:

```bash
pip install -r app/requirements.txt
```

Correr FastAPI local:

```bash
uvicorn app.main:app --reload --port 8000
```

---

## 🧩 Troubleshooting

- **Ollama no responde**  
  Asegurate de que `ollama serve` esté corriendo en el host.

- **Modelo no encontrado**  
  Actualiza `.env` con el nombre exacto que aparece en `ollama list`.

- **Problemas en Windows con CRLF**  
  Guarda `.env` y scripts en formato LF.

---

## 📌 Próximos pasos
- Agregar métricas (Prometheus/Grafana)
- Montar despliegue en Kubernetes (kind/minikube)
- Extender a OKD/OpenShift

---

## 📝 Licencia
MIT – libre para usar y modificar.