#include "process.h"

#ifdef Q_O_LINUX
#include "xclip.h"
#endif

#include <QStringList>
#include <QDebug>

Process::Process(QObject *parent)
    : QObject(parent)
{
    QScopedPointer<QProcess> process(new QProcess(this));
    m_process.swap(process);
}

void Process::showError(QProcess::ProcessError error)
{
    qDebug() << error;
}

void Process::readStdout()
{
    QByteArray data = m_process->readAllStandardOutput();
    QString word = QString::fromUtf8(data);
    if (word.isEmpty()) return ;
    emit xclip_o_sel_finished(word);
}

void Process::xclip_o_sel()
{
#ifdef Q_O_WINDOW
    qDebug() << "no implementation";
#elif defined (Q_O_LINUX)

#ifndef NO_XCLIP_PROGRAM
    QString program = "xclip";
    QStringList arguments = {"-o", "-sel"};

    m_process->start(program, arguments);

    connect(m_process.data(), SIGNAL(errorOccurred(QProcess::ProcessError)),
            this, SLOT(showError(QProcess::ProcessError)));
    connect(m_process.data(), SIGNAL(readyReadStandardOutput()),
            this, SLOT(readStdout()));
#else
    char buf[1024] = {0};
    size_t len = xclipSel(buf, 1024);
    QString word = QString::fromUtf8(buf, len);
    emit xclip_o_sel_finished(word);
#endif // Q_O_LINUX

#endif //Q_O_WINDOW
}
