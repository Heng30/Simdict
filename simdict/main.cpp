#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QString>
#include <QVector>

#include "https.h"

int main(int argc, char *argv[]) {
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    auto searchContent = QString("%1").arg(argc < 2 ? "" : argv[1]);

    QQmlApplicationEngine engine;
    engine.setOfflineStoragePath(app.applicationDirPath());

    QQmlContext *context = engine.rootContext();
    context->setContextProperty("https", new Https(nullptr, searchContent));

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
