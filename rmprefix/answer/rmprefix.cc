#include <iostream>
#include <string>
#include <cstdlib>

int main()
{
    for (std::string line; std::getline(std::cin, line);)
    {
        // remove white space before input
        // https://en.cppreference.com/w/cpp/string/basic_string_view/remove_prefix
        std::string_view v = line;
        v.remove_prefix(std::min(v.find_first_not_of(' '), v.size()));
        v.remove_prefix(std::min(v.find_first_not_of('\t'), v.size()));

        // output the new input
        std::cout << v << std::endl;
    }
    exit(EXIT_SUCCESS);
}
