#include "https.h"

#include <QDebug>

Https::Https(QObject *parent)
    : QObject(parent),
      m_url(""),
      m_networkManager(new QNetworkAccessManager(this))
{
    m_userAgent = QString("Mozilla/5.0 (Windows NT 10.0; Win64; x64) ")
            + "AppleWebKit/537.36 (KHTML, like Gecko) "
            + "Chrome/90.0.4430.212 Safari/537.36 "
            + "Edg/90.0.818.62";

}

void Https::setUserAgent(const QString &userAgent)
{
    m_userAgent = userAgent;
}

void Https::setUrl(const QString &url)
{
    m_url = url;
}

void Https::get()
{
    QNetworkRequest request;
    request.setRawHeader("User-Agent", m_userAgent.toLatin1());
    request.setUrl(m_url);
    QNetworkReply *reply = m_networkManager->get(request);

    connect(reply, SIGNAL(finished()), this, SLOT(onGetFinished()));
    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)),
            this, SLOT(onError(QNetworkReply::NetworkError)));

}

void Https::onGetFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    QByteArray replyContent = reply->readAll();
    reply->deleteLater();
    emit getContent(replyContent);
}


void Https::onError(QNetworkReply::NetworkError errorCode)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    qDebug() << QString::number(errorCode) + ":" + reply->errorString();
    reply->deleteLater();
}
