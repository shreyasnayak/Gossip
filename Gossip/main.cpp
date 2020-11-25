#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "sqlcontactmodel.h"
#include "sqlconversationmodel.h"
#include "connect.cpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    qmlRegisterType<SqlContactModel>("com.github.shreyasnayak.ChatDbModel", 1, 0, "SqlContactModel");
    qmlRegisterType<SqlConversationModel>("com.github.shreyasnayak.ChatDbModel", 1, 0, "SqlConversationModel");

    connectToDatabase("chat-database.sqlite3");
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    return app.exec();
}
