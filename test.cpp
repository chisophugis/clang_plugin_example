#include <iostream>
#include <vector>

int main(int argc, char *argv[]) {
  (void)argc; (void)argv;
  std::vector<int> v = {0, 1, 2, 3, 4};
  for (auto x : v) {
    std::cout << x << "\n";
  }
}
