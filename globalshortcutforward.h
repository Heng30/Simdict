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

public slots:
    void onAlt2S();
};

#endif // GLOBALSHORTCUTFORWARD_H
