#ifndef HTTPS_H
#define HTTPS_H

#include <QObject>
#include <QByteArray>
#include <QScopedPointer>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QString>

class Https: public QObject
{
    Q_OBJECT

public:
    explicit Https(QObject *parent = nullptr, const QString &content = QString());
    Q_INVOKABLE void setUrl(const QString &url);
    Q_INVOKABLE void setUserAgent(const QString &userAgent);
    Q_INVOKABLE void get();

    Q_INVOKABLE QString getSearchContent();

signals:
    void getContent(QByteArray content);

private slots:
    void onGetFinished();
    void onError(QNetworkReply::NetworkError errorCode);

private:
    QString m_url;
    QString m_userAgent;
    QString m_searchContent;
    QScopedPointer<QNetworkAccessManager> m_networkManager;
};

#endif // HTTPS_H
