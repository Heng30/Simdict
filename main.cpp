#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>

#include "https.h"
#include "qglobalshortcut.h"
#include "globalshortcutforward.h"


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QGlobalShortcut gs;
    gs.setKey(QKeySequence("Alt+S"));
    GlobalShortcutForward gsf;
    QObject::connect(&gs, SIGNAL(activated()), &gsf, SLOT(onAlt2S()));

    QQmlApplicationEngine engine;
    engine.setOfflineStoragePath(app.applicationDirPath());

    QQmlContext *context = engine.rootContext();
    context->setContextProperty("gsf", &gsf);
    context->setContextProperty("https", new Https());

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
