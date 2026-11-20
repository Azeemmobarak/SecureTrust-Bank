#!/usr/bin/env bash

set -uo pipefail

# ============================================================
# SecureTrust Bank - Docker Image Build Script
# Sequential builds, parallel builds and Docker Hub push.
# ============================================================

# ---------------- CONFIGURATION -----------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_DIR="${SCRIPT_DIR}/.build-logs"

DEFAULT_SERVICES=(configserver accounts loans cards gatewayserver)

DOCKER_NAMESPACE="azeem650"
DEFAULT_IMAGE_TAG="v4"

PARALLEL=false
PUSH=false
SERVICES=()

# ------------------------------------------------------------
# Parse arguments
# ------------------------------------------------------------

usage() {
    cat <<EOF
Usage:
  ./build-images.sh
  ./build-images.sh accounts cards
  ./build-images.sh --parallel
  ./build-images.sh -p accounts cards
  ./build-images.sh --push
  ./build-images.sh -p --push cards

Options:
  -p, --parallel    Build services concurrently
  --push            Push images to Docker Hub
  -h, --help        Display this help
EOF
}

for arg in "$@"; do
    case "$arg" in
        --parallel|-p)
            PARALLEL=true
            ;;
        --push)
            PUSH=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            SERVICES+=("$arg")
            ;;
    esac
done

if [[ ${#SERVICES[@]} -eq 0 ]]; then
    SERVICES=("${DEFAULT_SERVICES[@]}")
fi

ACTION="built"
if [[ "$PUSH" == true ]]; then
    ACTION="built and pushed"
fi

# ------------------------------------------------------------
# Validate prerequisites
# ------------------------------------------------------------

validate_environment() {

    if ! command -v mvn >/dev/null 2>&1; then
        echo "ERROR: Maven is not installed or not in PATH."
        return 1
    fi

    if ! command -v docker >/dev/null 2>&1; then
        echo "ERROR: Docker is not installed or not in PATH."
        return 1
    fi

    if ! docker info >/dev/null 2>&1; then
        echo "ERROR: Docker daemon is not running."
        return 1
    fi

    if [[ "$PUSH" == true ]]; then
        if ! docker info 2>/dev/null | grep -q "Username:"; then
            echo "WARNING: Docker login could not be confirmed."
            echo "Make sure you have run: docker login"
        fi
    fi

    return 0
}

# ------------------------------------------------------------
# Validate service names and POM files
# ------------------------------------------------------------

validate_services() {

    local service
    local valid

    for service in "${SERVICES[@]}"; do

        valid=false

        for known in "${DEFAULT_SERVICES[@]}"; do
            if [[ "$service" == "$known" ]]; then
                valid=true
                break
            fi
        done

        if [[ "$valid" != true ]]; then
            echo "ERROR: Unknown service: $service"
            return 1
        fi

        if [[ ! -f "${PROJECT_ROOT}/${service}/pom.xml" ]]; then
            echo "ERROR: POM not found for ${service}"
            return 1
        fi
    done

    return 0
}

# ------------------------------------------------------------
# Resolve Maven properties
# ------------------------------------------------------------

resolve_property() {

    local service="$1"
    local property="$2"
    local value

    value="$(
        cd "${PROJECT_ROOT}/${service}" &&
        mvn -q help:evaluate \
            -Dexpression="${property}" \
            -DforceStdout \
            -Dstyle.color=never 2>/dev/null
    )" || return 1

    # Remove empty lines and Maven output noise.
    value="$(printf '%s\n' "$value" | sed '/^[[:space:]]*$/d' | tail -n 1)"

    if [[ -z "$value" || "$value" == "null" || "$value" == *'${'* ]]; then
        return 1
    fi

    printf '%s' "$value"
}

# ------------------------------------------------------------
# Resolve Docker image reference
# ------------------------------------------------------------

image_ref() {

    local service="$1"
    local image
    local tag
    local artifact

    artifact="$(resolve_property "$service" "project.artifactId")" || {
        echo "ERROR: Cannot resolve artifactId for ${service}" >&2
        return 1
    }

    image="$(resolve_property "$service" "docker.image.name")" || image=""
    tag="$(resolve_property "$service" "docker.image.tag")" || tag=""

    # Use configured defaults if the optional properties are absent.
    [[ -n "$tag" ]] || tag="$DEFAULT_IMAGE_TAG"

    # If the POM defines docker.image.name, use it.
    # Otherwise use the configured Docker namespace and artifact ID.
    if [[ -z "$image" ]]; then
        image="${DOCKER_NAMESPACE}/${artifact}"
    fi

    # Avoid adding a tag twice.
    if [[ "$image" == *:* ]]; then
        printf '%s' "$image"
    else
        printf '%s:%s' "$image" "$tag"
    fi
}

# ------------------------------------------------------------
# Build and optionally push one service
# ------------------------------------------------------------

build_service() {

    local service="$1"
    local image

    echo "Building ${service}..."

    if ! (
        cd "${PROJECT_ROOT}/${service}" &&
        mvn compile jib:dockerBuild
    ); then
        echo "ERROR: Maven/Jib build failed for ${service}"
        return 1
    fi

    if [[ "$PUSH" == true ]]; then

        image="$(image_ref "$service")" || return 1

        echo "Pushing ${image}..."

        if ! docker push "$image"; then
            echo "ERROR: Docker push failed for ${service}"
            return 1
        fi
    fi

    echo "SUCCESS: ${service}"
    return 0
}

# ------------------------------------------------------------
# Display final summary
# ------------------------------------------------------------

success_summary() {

    echo
    echo "============================================================"
    echo "       ALL IMAGES BUILT AND PUSHED SUCCESSFULLY"
    echo "============================================================"
    echo

    local service

    for service in "${SUCCEEDED[@]}"; do
        echo "[OK] ${service}"
    done

    echo
    echo "Docker namespace : ${DOCKER_NAMESPACE}"
    echo "Default image tag: ${DEFAULT_IMAGE_TAG}"

    if [[ "$PARALLEL" == true ]]; then
        echo "Build mode       : Parallel"
    else
        echo "Build mode       : Sequential"
    fi

    if [[ "$PUSH" == true ]]; then
        echo "Push status      : Completed"
    else
        echo "Push status      : Skipped"
    fi

    echo
    echo "BUILD SUCCESS"
    echo
}

failure_summary() {

    echo
    echo "============================================================"
    echo "                    BUILD FAILED"
    echo "============================================================"
    echo

    if [[ ${#SUCCEEDED[@]} -gt 0 ]]; then
        echo "Successful services: ${SUCCEEDED[*]}"
    fi

    if [[ ${#FAILED[@]} -gt 0 ]]; then
        echo "Failed services: ${FAILED[*]}"
    fi

    echo
    echo "Check individual logs:"
    echo "${LOG_DIR}"
    echo
}

# ============================================================
# MAIN EXECUTION
# ============================================================

echo
echo "============================================================"
echo "SecureTrust Bank - Docker Image Builder"
echo "============================================================"
echo "Project root : ${PROJECT_ROOT}"
echo "Docker Hub   : ${DOCKER_NAMESPACE}"
echo "Default tag  : ${DEFAULT_IMAGE_TAG}"
echo "Services     : ${SERVICES[*]}"
echo "Parallel     : ${PARALLEL}"
echo "Push         : ${PUSH}"
echo "============================================================"
echo

if ! validate_environment; then
    exit 1
fi

if ! validate_services; then
    exit 1
fi

mkdir -p "$LOG_DIR" || {
    echo "ERROR: Cannot create log directory."
    exit 1
}

SUCCEEDED=()
FAILED=()

# ------------------------------------------------------------
# PARALLEL EXECUTION
# ------------------------------------------------------------

if [[ "$PARALLEL" == true ]]; then

    pids=()
    names=()

    for service in "${SERVICES[@]}"; do

        echo "==> Starting build for ${service}"
        echo "    Log: .build-logs/${service}.log"

        build_service "$service" > "${LOG_DIR}/${service}.log" 2>&1 &

        pids+=("$!")
        names+=("$service")
    done

    for i in "${!pids[@]}"; do

        if wait "${pids[$i]}"; then
            SUCCEEDED+=("${names[$i]}")
        else
            FAILED+=("${names[$i]}")
        fi
    done

# ------------------------------------------------------------
# SEQUENTIAL EXECUTION
# ------------------------------------------------------------

else

    for service in "${SERVICES[@]}"; do

        echo
        echo "============================================================"
        echo "Building image for ${service}"
        echo "============================================================"

        if build_service "$service" 2>&1 | tee "${LOG_DIR}/${service}.log"; then
            SUCCEEDED+=("$service")
        else
            FAILED+=("$service")
            echo "Continuing with remaining services..."
        fi
    done

fi

# ------------------------------------------------------------
# FINAL RESULT
# ------------------------------------------------------------

if [[ ${#FAILED[@]} -eq 0 ]]; then
    success_summary
    exit 0
else
    failure_summary
    exit 1
fi