/*
* This file belongs to the DebugOsax target.
* The DebugOsax target builds an application in order to facilitate debugging.
*
* You should not need to change this file.
*/
#include <Carbon/Carbon.h>
extern "C" void InstallEventDebug(); /* implemented in Osax.cpp */
extern CFBundleRef additionBundle;

int main(int argc, char* argv[]){
	additionBundle=CFBundleGetMainBundle();
    InstallEventDebug();
    RunApplicationEventLoop();
    return 0;
}
