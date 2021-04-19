#include <iostream>
#include <cassert>
#include <curl/curl.h>
int main(int argc, const char* argv[]) {
    std::cout << "arguments are:" << std::endl;
    for (int i = 0; i < argc; i++) {
        std::cout << (i + 1) << ": " << argv[i] << std::endl;
    }
    CURL* c = curl_easy_init();
    curl_easy_setopt(c, CURLOPT_URL, "http://example.com");
    // too lazy to do cert stuff
    curl_easy_setopt(c, CURLOPT_SSL_VERIFYPEER, false);
    assert(curl_easy_perform(c) == CURLE_OK);
    curl_easy_cleanup(c);
    return 0;
}