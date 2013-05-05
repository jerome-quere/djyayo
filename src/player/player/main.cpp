#include <sys/signal.h>

#include "Application.hpp"
#include "Config.hpp"

#include "Logger.hpp"

Spdj::Application* g_app;


void onSig(int)
{
  g_app->stop();
}

int main(int argc, char *argv[])
{
  Spdj::Config config(argc, argv);
  Spdj::Application app(config);

  signal(SIGINT, &onSig);
  g_app = &app;
  app.run();
  return 0;
}
