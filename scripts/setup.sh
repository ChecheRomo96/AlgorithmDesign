#!/usr/bin/env bash
set -e

# Detectar ruta del script y raíz del repo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

OS="$(uname -s)"

echo "▶ C++ Course Template — Setup (Unix)"
echo "   Repo root: ${REPO_ROOT}"
echo "   Detected OS: ${OS}"
echo ""

# -------- helpers --------

missing_tools=()

check_cmd() {
  local cmd="$1"
  local pretty="$2"

  if command -v "${cmd}" >/dev/null 2>&1; then
    printf "  ✔ %-10s found at %s\n" "${pretty}" "$(command -v "${cmd}")"
  else
    printf "  ❌ %-10s NOT found\n" "${pretty}"
    missing_tools+=("${cmd}")
  fi
}

print_install_hint() {
  local cmd="$1"

  echo "    → Install hint for '${cmd}':"
  case "${OS}" in
    Darwin)
      echo "      brew install ${cmd}"
      ;;
    Linux)
      echo "      # Debian/Ubuntu:"
      echo "      sudo apt-get update && sudo apt-get install ${cmd}"
      ;;
    *)
      echo "      (no automatic hint for OS=${OS}, install manually)"
      ;;
  esac
}

ensure_executable() {
  local path="$1"
  if [ -f "${path}" ] && [ ! -x "${path}" ]; then
    chmod +x "${path}"
  fi
}

echo "▶ Checking required tools..."
echo ""

# Básicos
check_cmd cmake   "cmake"
check_cmd ctest   "ctest"
check_cmd python3 "python3"
check_cmd doxygen "doxygen"

# Coverage
check_cmd lcov    "lcov"
check_cmd genhtml "genhtml"

# Compilador (aceptamos g++ o clang++)
if command -v g++ >/dev/null 2>&1; then
  printf "  ✔ %-10s found at %s\n" "C++ (g++)" "$(command -v g++)"
elif command -v clang++ >/dev/null 2>&1; then
  printf "  ✔ %-10s found at %s\n" "C++ (clang++)" "$(command -v clang++)"
else
  echo "  ❌ C++ compiler (g++ / clang++) NOT found"
  missing_tools+=("g++")
fi

echo ""
if [ ${#missing_tools[@]} -eq 0 ]; then
  echo "✅ All required tools seem to be installed."
else
  echo "⚠ Missing tools:"
  for t in "${missing_tools[@]}"; do
    echo "  - ${t}"
    print_install_hint "${t%% *}"
    echo ""
  done
fi

# -------- ensure scripts are executable --------
echo "▶ Ensuring scripts are executable..."
ensure_executable "${SCRIPT_DIR}/setup.sh"
ensure_executable "${SCRIPT_DIR}/unitTests.sh"
ensure_executable "${SCRIPT_DIR}/codeCoverage.sh"
ensure_executable "${SCRIPT_DIR}/doxygen.sh"
ensure_executable "${SCRIPT_DIR}/fullCI.sh"

echo ""
echo "Done. You can now run:"
echo "  ./scripts/unitTests.sh"
echo "  ./scripts/codeCoverage.sh"
echo "  ./scripts/doxygen.sh"
echo "  ./scripts/fullCI.sh"
