#include "LectureExample_privateAPI.hpp"

#include <iostream>

namespace LectureLib {

void MyPublicAPI() {
    std::cout << "[LectureExample] MyPublicAPI() called" << std::endl;

    // Lógica interna delegada a la API privada.
    MyPrivateAPI();
}

void MyPrivateAPI() {
    std::cout << "[LectureExample] MyPrivateAPI() internal work" << std::endl;
}

} // namespace LectureLib
