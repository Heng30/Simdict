#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QVector>

#include "https.h"
#include "qglobalshortcut.h"
#include "globalshortcutforward.h"
#include "process.h"
#include "youdaoapi.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    GlobalShortcutForward gsf;
    QGlobalShortcut gs_S, gs_A, gs_Z;
    gs_S.setKey(QKeySequence("Alt+S")); // show
    gs_A.setKey(QKeySequence("Alt+A")); // clipboard
    gs_Z.setKey(QKeySequence("Alt+Z")); // under cursor world
    QObject::connect(&gs_S, SIGNAL(activated()), &gsf, SLOT(onAlt2S()));
    QObject::connect(&gs_A, SIGNAL(activated()), &gsf, SLOT(onAlt2A()));
    QObject::connect(&gs_Z, SIGNAL(activated()), &gsf, SLOT(onAlt2Z()));

    QQmlApplicationEngine engine;
    engine.setOfflineStoragePath(app.applicationDirPath());

    QQmlContext *context = engine.rootContext();
    context->setContextProperty("gsf", &gsf);
    context->setContextProperty("https", new Https());
    context->setContextProperty("process", new Process());
    context->setContextProperty("youdaoapi", YoudaoAPI::instance());

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
