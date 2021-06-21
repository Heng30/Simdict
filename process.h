#ifndef PROCESS_H
#define PROCESS_H

#include <QObject>
#include <QProcess>
#include <QScopedPointer>

class Process : public QObject
{
    Q_OBJECT
public:
    explicit Process(QObject *parent = nullptr);
    Q_INVOKABLE void xclip_o_sel();

signals:
    void xclip_o_sel_finished(const QString &word);

private slots:
    void showError(QProcess::ProcessError error);
    void readStdout();

private:
    QScopedPointer<QProcess> m_process;
};

#endif // PROCESS_H
