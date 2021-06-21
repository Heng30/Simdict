#include "process.h"

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
    QString program = "xclip";
    QStringList arguments = {"-o", "-sel"};

    m_process->start(program, arguments);

    connect(m_process.data(), SIGNAL(errorOccurred(QProcess::ProcessError)),
            this, SLOT(showError(QProcess::ProcessError)));
    connect(m_process.data(), SIGNAL(readyReadStandardOutput()),
            this, SLOT(readStdout()));
}
