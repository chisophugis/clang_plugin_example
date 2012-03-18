#include <iostream>

int main(int argc, char *argv[]) {
  (void)argc; (void)argv;
  for (unsigned x = 0; x != 5; ++x) {
    std::cout << x << "\n";
  }
  return 0;
}
