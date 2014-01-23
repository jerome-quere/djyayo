#include "Application.h"
#include "Config.h"

#include <iostream>
int main(int argc, char** argv)
{
    SpDj::Config::init(argc, argv);
    SpDj::Application app;

    return app.run();
}
