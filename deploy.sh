#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

PROJECT_ID="chatbostentrecerros"
DATABASE_ID="chatbotentrecerros"
LOCATION="southamerica-west1"

echo "══════════════════════════════════════════════"
echo "  Chatbots Entre Cerros — Deploy producción"
echo "  Firestore: ${DATABASE_ID} (${LOCATION})"
echo "  Correo: Trigger Email → mail/"
echo "══════════════════════════════════════════════"

if command -v gcloud >/dev/null 2>&1; then
  if ! gcloud firestore databases describe --project="${PROJECT_ID}" --database="${DATABASE_ID}" >/dev/null 2>&1; then
    echo "→ Creando Firestore database '${DATABASE_ID}' en ${LOCATION}..."
    gcloud firestore databases create --project="${PROJECT_ID}" --database="${DATABASE_ID}" --location="${LOCATION}"
  fi
else
  echo "⚠️  gcloud no está instalado. Si falta la base, créala antes con:"
  echo "   gcloud firestore databases create --project=${PROJECT_ID} --database=${DATABASE_ID} --location=${LOCATION}"
fi

echo ""
echo "→ Dependencias Cloud Functions..."
(cd functions && npm install --omit=dev)

echo ""
echo "→ Desplegando reglas, storage, functions y hosting..."
firebase deploy --project "${PROJECT_ID}" --only firestore:rules,storage,functions,hosting

echo ""
echo "→ Estado extensiones Firebase..."
firebase ext:list --project "${PROJECT_ID}" || true

echo ""
echo "Verifica:"
echo "  1. Crea un ticket de prueba"
echo "  2. Firestore ${DATABASE_ID} → mail/TK-..."
echo "  3. Revisa delivery.state = SUCCESS"
echo "  4. Panel admin → Diagnóstico Trigger Email"
