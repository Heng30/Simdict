#include "globalshortcutforward.h"
#include <QtDebug>

GlobalShortcutForward::GlobalShortcutForward(QObject *parent)
    : QObject(parent)
{
    // do nothing
}

// show the application
void GlobalShortcutForward::onAlt2S()
{
    emit this->alt4S();
}

// copy clipboard
void GlobalShortcutForward::onAlt2A()
{
    emit this->alt4A();
}

// under cursor
void GlobalShortcutForward::onAlt2Z()
{
    emit this->alt4Z();
}
