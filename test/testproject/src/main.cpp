#include <iostream>
#include <fstream>
#include <cassert>
#include <curl/curl.h>
size_t write_callback(char* pointer, size_t size, size_t nmemb, std::ofstream* file) {
    (*file) << std::string(pointer, size * nmemb);
    return nmemb;
}
int main(int argc, const char* argv[]) {
    std::cout << "arguments are:" << std::endl;
    for (int i = 0; i < argc; i++) {
        std::cout << (i + 1) << ": " << argv[i] << std::endl;
    }
    CURL* c = curl_easy_init();
    curl_easy_setopt(c, CURLOPT_URL, "http://example.com");
    // too lazy to do cert stuff
    curl_easy_setopt(c, CURLOPT_SSL_VERIFYPEER, false);
    // print http://example.com to a file
    std::ofstream file("example.html");
    curl_easy_setopt(c, CURLOPT_WRITEDATA, &file);
    curl_easy_setopt(c, CURLOPT_WRITEFUNCTION, write_callback);
    // pull data
    assert(curl_easy_perform(c) == CURLE_OK);
    curl_easy_cleanup(c);
    file.close();
    return 0;
}