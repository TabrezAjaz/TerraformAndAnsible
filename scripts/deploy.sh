#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"
SECRET_DIR="${ROOT_DIR}/.secrets"

for command in terraform ansible-playbook ansible-galaxy openssl curl; do
  command -v "${command}" >/dev/null || { echo "Missing required command: ${command}" >&2; exit 1; }
done

[[ -f "${TF_DIR}/terraform.tfvars" ]] || {
  echo "Create terraform/terraform.tfvars from terraform.tfvars.example first." >&2
  exit 1
}

mkdir -p "${SECRET_DIR}"
chmod 700 "${SECRET_DIR}"
for name in mongodb_admin_password mongodb_app_password; do
  if [[ ! -s "${SECRET_DIR}/${name}" ]]; then
    openssl rand -base64 36 | tr -d '/+=' | head -c 32 > "${SECRET_DIR}/${name}"
    chmod 600 "${SECRET_DIR}/${name}"
  fi
done

export MONGODB_ADMIN_PASSWORD="$(<"${SECRET_DIR}/mongodb_admin_password")"
export MONGODB_APP_PASSWORD="$(<"${SECRET_DIR}/mongodb_app_password")"

terraform -chdir="${TF_DIR}" init
terraform -chdir="${TF_DIR}" fmt -check -recursive
terraform -chdir="${TF_DIR}" validate
terraform -chdir="${TF_DIR}" apply

ansible-galaxy collection install -r "${ROOT_DIR}/ansible/requirements.yml"
ANSIBLE_CONFIG="${ROOT_DIR}/ansible/ansible.cfg" \
  ansible-playbook "${ROOT_DIR}/ansible/site.yml"

APP_URL="$(terraform -chdir="${TF_DIR}" output -raw application_url)"
curl --fail --retry 12 --retry-delay 5 "${APP_URL}/hello"
echo
echo "Deployment complete: ${APP_URL}"
