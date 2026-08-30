#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"
APP_URL="$(terraform -chdir="${TF_DIR}" output -raw application_url)"

echo "Checking frontend at ${APP_URL}"
curl --fail --silent --show-error "${APP_URL}" | grep -q '<div id="root"></div>'
echo "Frontend: PASS"

echo "Checking Express API through Nginx"
[[ "$(curl --fail --silent --show-error "${APP_URL}/hello")" == "Hello World!" ]]
echo "Backend: PASS"

echo "Checking trip endpoint and MongoDB connectivity"
curl --fail --silent --show-error "${APP_URL}/trip/" >/dev/null
echo "MongoDB path: PASS"
