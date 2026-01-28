#!/usr/bin/env bash
set -e

# --- helper: execute silently ---
run_quiet() {
  "$@" >/dev/null 2>&1
}

# Base folders
BUILD_DIR="build"
TMP_DIR="tmp"
COVERAGE_SITE_DIR="site/coverage"
TESTS_SITE_DIR="site/tests"

echo "- Preparing directories..."
mkdir -p "${TMP_DIR}" "${COVERAGE_SITE_DIR}" "${TESTS_SITE_DIR}"

echo "- Cleaning previous build..."
rm -rf "${BUILD_DIR}"

echo "- Configuring CMake (tests + coverage)..."
run_quiet cmake -S . -B "${BUILD_DIR}" \
  -DENABLE_TESTING=ON \
  -DENABLE_COVERAGE=ON \
  -DCMAKE_BUILD_TYPE=Debug \
  --log-level=ERROR

echo "- Building project..."
run_quiet cmake --build "${BUILD_DIR}" --parallel

echo "- Running unit tests..."
if ! ctest --test-dir "${BUILD_DIR}" \
           --output-junit "../${TMP_DIR}/ctest.xml" \
           --output-on-failure >/dev/null 2>&1; then
  echo ""
  echo "Tests FAILED — showing full output:"
  ctest --test-dir "${BUILD_DIR}" --output-on-failure
  exit 1
fi

echo "- Capturing coverage (lcov)..."
run_quiet lcov --quiet \
  --directory "${BUILD_DIR}" \
  --capture \
  --output-file "${TMP_DIR}/coverage.raw.info" \
  --rc derive_function_end_line=0 \
  --ignore-errors inconsistent,unsupported,format,unused

echo "- Filtering coverage..."
run_quiet lcov --quiet \
  --remove "${TMP_DIR}/coverage.raw.info" \
    '/usr/*' \
    '*/_deps/*' \
    '*/course/tests/*' \
    '*/student/tests/*' \
  --output-file "${TMP_DIR}/coverage.filtered.info" \
  --ignore-errors unused

echo "- Extracting course-related coverage..."
run_quiet lcov --quiet \
  --extract "${TMP_DIR}/coverage.filtered.info" \
    '*course/src/*' \
    '*course/include/*' \
    '*student/src/*' \
    '*student/include/*' \
  --output-file "${TMP_DIR}/coverage.final.info" \
  --ignore-errors unused

echo "- Generating HTML coverage report..."
run_quiet genhtml "${TMP_DIR}/coverage.final.info" \
  --output-directory "${COVERAGE_SITE_DIR}" \
  --quiet
echo "✔ Coverage generated at ${COVERAGE_SITE_DIR}/index.html"

echo "- Generating HTML test report..."
run_quiet python3 scripts/private/render_ctest_report.py \
  "${TMP_DIR}/ctest.xml" \
  "${TESTS_SITE_DIR}/index.html"
echo "✔ Test report generated at ${TESTS_SITE_DIR}/index.html"

echo "- Updating site index..."
cat << 'EOF' > site/index.html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8" />
  <title>Curso C++</title>
</head>
<body>
  <h1>Curso C++</h1>
  <ul>
    <li><a href="coverage/index.html">Cobertura de código</a></li>
    <li><a href="tests/index.html">Reporte de tests</a></li>
    <li><a href="docs/html/index.html">Documentación Doxygen</a></li>
  </ul>
</body>
</html>
EOF

echo "- Running Doxygen..."
run_quiet doxygen docs/Doxyfile
echo "✔ Doxygen documentation generated"

echo "- Cleaning temporary files..."
rm -rf "${TMP_DIR}"

echo ""
echo "Full CI pipeline completed successfully."
