#include <LectureExample_publicAPI.hpp>
#include "../src/LectureExample_privateAPI.hpp"

#include <cassert>

/**
 * @brief Pruebas mínimas de ejemplo para la implementación del profesor.
 *
 * Más adelante, si usas un framework (Catch2, doctest, GoogleTest),
 * este archivo puede migrarse fácilmente.
 */
int main() {
    // Verificamos que las funciones se pueden invocar sin fallar.
    LectureLib::MyPublicAPI();
    LectureLib::MyPrivateAPI();

    // Placeholder de aserción.
    assert(1 == 1);

    return 0;
}
