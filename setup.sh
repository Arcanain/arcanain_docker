#!/usr/bin/env bash
set -euo pipefail

# Auto-set env vars and run docker compose so new folks don't need to export them each time
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Track whether user explicitly set ROS_PROJECT_PATH
USER_SET_ROS_PROJECT_PATH="${ROS_PROJECT_PATH+yes}"

# Defaults (can be overridden by existing env)
export ROS_DEV_CONTAINER_NAME="${ROS_DEV_CONTAINER_NAME:-ros2_dev_container2}"
# Default workspace under /home/<user>/ros2_docker (overridable via env)
export ROS_PROJECT_PATH="${ROS_PROJECT_PATH:-/home/${USER:-user}/ros2_docker}"
USE_GPU="${USE_GPU:-auto}"

# Normalize to absolute path if possible (tolerate missing path)
if command -v realpath >/dev/null 2>&1; then
  export ROS_PROJECT_PATH="$(realpath -m "${ROS_PROJECT_PATH}")"
fi

if [[ ! -d "${ROS_PROJECT_PATH}" ]]; then
  if [[ -z "${USER_SET_ROS_PROJECT_PATH}" ]]; then
    echo "Creating default workspace at ${ROS_PROJECT_PATH}"
    mkdir -p "${ROS_PROJECT_PATH}"
  else
    echo "ROS_PROJECT_PATH does not exist: ${ROS_PROJECT_PATH}" >&2
    exit 1
  fi
fi

GPU_COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.gpu.yml"
CPU_COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.cpu.yml"
GPU_DETECTED="no"
COMPOSE_MODE="CPU"

if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; then
  GPU_DETECTED="yes"
fi

case "${USE_GPU}" in
  1|true|TRUE|yes|YES)
    COMPOSE_FILE="${GPU_COMPOSE_FILE}"
    COMPOSE_MODE="GPU"
    ;;
  0|false|FALSE|no|NO)
    COMPOSE_FILE="${CPU_COMPOSE_FILE}"
    ;;
  *)
    if [[ "${GPU_DETECTED}" == "yes" ]]; then
      COMPOSE_FILE="${GPU_COMPOSE_FILE}"
      COMPOSE_MODE="GPU"
    else
      COMPOSE_FILE="${CPU_COMPOSE_FILE}"
    fi
    ;;
esac

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "Compose file not found: ${COMPOSE_FILE}" >&2
  exit 1
fi

echo "Using ROS_DEV_CONTAINER_NAME=${ROS_DEV_CONTAINER_NAME}"
echo "Using ROS_PROJECT_PATH=${ROS_PROJECT_PATH}"
echo "GPU detected: ${GPU_DETECTED} (override with USE_GPU=1/0)"
echo "Compose mode: ${COMPOSE_MODE}"
echo "Compose file: ${COMPOSE_FILE}"

exec docker compose -f "${COMPOSE_FILE}" "$@"
