#include "globalshortcutforward.h"

GlobalShortcutForward::GlobalShortcutForward(QObject *parent)
    : QObject(parent)
{
    // do nothing
}

void GlobalShortcutForward::onAlt2S()
{
    emit this->alt4S();
}
