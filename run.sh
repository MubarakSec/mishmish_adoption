#!/usr/bin/env bash

# ==============================================================================
# Mishmish Adoption Project Manager (run.sh)
# Single script to start, stop, and manage Laravel API + Flutter app.
#
# Usage:
#   ./run.sh          -> Auto-starts everything (Backend + ADB reverse + Flutter)
#   ./run.sh start    -> Same as default
#   ./run.sh stop     -> Stops Laravel backend and frees port 8000
#   ./run.sh status   -> Displays system, API, and device connectivity status
#   ./run.sh restart  -> Stops and then restarts everything
# ==============================================================================

set -e

# Base directories
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_DIR="$BASE_DIR/mishmish-api"
FLUTTER_DIR="$BASE_DIR/mishmish"
PID_FILE="$BASE_DIR/.laravel.pid"
LOG_FILE="$BASE_DIR/laravel_serve.log"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${CYAN}${BOLD}[INFO]${NC} $1"
}

log_ok() {
    echo -e "${GREEN}${BOLD}[✓ OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}${BOLD}[WARN]${NC} $1"
}

log_err() {
    echo -e "${RED}${BOLD}[ERROR]${NC} $1"
}

is_port_in_use() {
    ss -tulpn 2>/dev/null | grep -q ":8000 "
}

is_backend_running() {
    if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            return 0
        fi
    fi
    is_port_in_use
}

stop_backend() {
    log_info "Stopping Laravel backend and cleaning up port 8000..."
    
    if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            kill "$pid" 2>/dev/null || true
            sleep 1
        fi
        rm -f "$PID_FILE"
    fi

    # Kill anything still holding port 8000
    if is_port_in_use; then
        log_info "Freeing port 8000 using fuser/lsof..."
        fuser -k 8000/tcp 2>/dev/null || true
        sleep 1
    fi

    if is_port_in_use; then
        log_warn "Port 8000 still busy, attempting force kill..."
        lsof -ti:8000 | xargs -r kill -9 2>/dev/null || true
        sleep 1
    fi

    if is_port_in_use; then
        log_err "Could not free port 8000. Please check manually."
        return 1
    else
        log_ok "Laravel backend stopped and port 8000 freed."
    fi
}

start_backend() {
    if is_backend_running; then
        log_ok "Laravel backend is already running on http://127.0.0.1:8000"
        return 0
    fi

    log_info "Starting Laravel backend on http://0.0.0.0:8000..."
    cd "$API_DIR"
    nohup php artisan serve --host=0.0.0.0 --port=8000 > "$LOG_FILE" 2>&1 &
    local new_pid=$!
    echo "$new_pid" > "$PID_FILE"
    cd "$BASE_DIR"

    # Wait for server to become responsive
    log_info "Waiting for Laravel API to respond..."
    local attempts=0
    local max_attempts=15
    while [ $attempts -lt $max_attempts ]; do
        if curl -s -m 2 http://127.0.0.1:8000/api/kittens > /dev/null 2>&1; then
            log_ok "Laravel API is UP and running! (PID: $new_pid)"
            return 0
        fi
        sleep 0.5
        attempts=$((attempts + 1))
    done

    if is_port_in_use; then
        log_ok "Laravel server started on port 8000 (PID: $new_pid)."
    else
        log_err "Failed to start Laravel backend. Check logs: $LOG_FILE"
        cat "$LOG_FILE" | tail -n 15
        return 1
    fi
}

setup_adb() {
    if ! command -v adb > /dev/null 2>&1; then
        log_warn "adb command not found. Skipping Android port forwarding."
        return 0
    fi

    # Find attached devices
    local devices
    devices=$(adb devices | grep -w "device" | awk '{print $1}')
    
    if [ -n "$devices" ]; then
        for dev in $devices; do
            log_info "Setting up adb reverse for device: ${BOLD}$dev${NC}..."
            adb -s "$dev" reverse tcp:8000 tcp:8000 2>/dev/null && \
                log_ok "Reverse port forwarding active on $dev (phone can reach 127.0.0.1:8000)" || \
                log_warn "Failed to set reverse port forwarding on $dev"
        done
    else
        log_info "No physical Android device currently detected via adb."
    fi
}

status_all() {
    echo -e "${BOLD}${BLUE}=== Mishmish System Status ===${NC}"
    
    # Backend Status
    if is_backend_running; then
        local pid="unknown"
        [ -f "$PID_FILE" ] && pid=$(cat "$PID_FILE")
        echo -e "Laravel Backend:  ${GREEN}${BOLD}RUNNING${NC} (PID: $pid, URL: http://127.0.0.1:8000)"
        if curl -s -m 2 http://127.0.0.1:8000/api/kittens > /dev/null 2>&1; then
            echo -e "API Endpoint:     ${GREEN}${BOLD}HEALTHY (200 OK)${NC}"
        else
            echo -e "API Endpoint:     ${YELLOW}PORT OPEN BUT API TIMEOUT${NC}"
        fi
    else
        echo -e "Laravel Backend:  ${RED}${BOLD}STOPPED${NC}"
    fi

    # ADB Devices
    echo -e "\n${BOLD}ADB Devices:${NC}"
    adb devices 2>/dev/null || echo "adb not available"

    # Flutter Devices
    echo -e "\n${BOLD}Flutter Devices:${NC}"
    cd "$FLUTTER_DIR"
    flutter devices --timeout 3 2>/dev/null || echo "Unable to list devices"
    cd "$BASE_DIR"
}

start_all() {
    echo -e "${BOLD}${CYAN}===================================================${NC}"
    echo -e "${BOLD}${CYAN}          🐱 Launching Mishmish App 🐱             ${NC}"
    echo -e "${BOLD}${CYAN}===================================================${NC}"

    start_backend
    setup_adb

    # Detect devices
    local android_dev
    android_dev=$(adb devices 2>/dev/null | grep -w "device" | awk '{print $1}' | head -n 1 || true)

    cd "$FLUTTER_DIR"

    if [ -n "$android_dev" ]; then
        log_info "Targeting connected Android device: ${BOLD}$android_dev${NC}"
        flutter run -d "$android_dev" "$@"
    else
        log_info "No Android phone attached via USB. Running default flutter device selector..."
        flutter run "$@"
    fi
}

# ------------------------------------------------------------------------------
# Action Routing
# ------------------------------------------------------------------------------
ACTION="${1:-}"

case "$ACTION" in
    stop)
        stop_backend
        ;;
    start)
        shift || true
        start_all "$@"
        ;;
    restart)
        stop_backend
        sleep 1
        shift || true
        start_all "$@"
        ;;
    status)
        status_all
        ;;
    help|--help|-h)
        echo "Usage: ./run.sh [start|stop|restart|status]"
        echo "  (Running without any argument automatically starts backend & app)"
        ;;
    *)
        # Default: No flag needed! Just run it!
        start_all "$@"
        ;;
esac
