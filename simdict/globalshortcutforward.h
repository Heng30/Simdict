#ifndef GLOBALSHORTCUTFORWARD_H
#define GLOBALSHORTCUTFORWARD_H

#include <QObject>

class GlobalShortcutForward: public QObject
{
    Q_OBJECT

public:
    GlobalShortcutForward(QObject *parent = nullptr);

signals:
    void alt4S();
    void alt4A();
    void alt4Z();

public slots:
    void onAlt2S();
    void onAlt2A();
    void onAlt2Z();
};

#endif // GLOBALSHORTCUTFORWARD_H
