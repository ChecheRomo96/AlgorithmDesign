# cpp-course-template

Template para cursos de C++ con flujo Fork + Upstream, CMake, pruebas y documentación Doxygen.

## Quick start (local)
```bash
cmake -S . -B build -DENABLE_TESTING=ON
cmake --build build
ctest --test-dir build --output-on-failure
```
