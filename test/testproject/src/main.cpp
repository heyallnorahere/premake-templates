#include <iostream>
int main(int argc, const char* argv[]) {
    std::cout << "arguments are:" << std::endl;
    for (int i = 0; i < argc; i++) {
        std::cout << (i + 1) << ": " << argv[i] << std::endl;
    }
    return 0;
}