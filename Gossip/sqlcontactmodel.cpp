#include "sqlcontactmodel.h"
#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>

static void createTable()
{
    if (QSqlDatabase::database().tables().contains(QStringLiteral("Contacts")))
    {
        // The table already exists; we don't need to do anything.
        return;
    }

    QSqlQuery query;
    if (!query.exec(
        "CREATE TABLE IF NOT EXISTS 'Contacts' ("
        "   'name' TEXT NOT NULL,"
        "   PRIMARY KEY(name)"
        ")")) {
        qFatal("Failed to query database: %s", qPrintable(query.lastError().text()));
    }
}

SqlContactModel::SqlContactModel(QObject *parent) :QSqlQueryModel(parent)
{
    createTable();
    QSqlQuery query;
    if (!query.exec("SELECT * FROM Contacts")) qFatal("Contacts SELECT query failed: %s", qPrintable(query.lastError().text()));
    setQuery(query);
    if (lastError().isValid()) qFatal("Cannot set query on SqlContactModel: %s", qPrintable(lastError().text()));
}

bool SqlContactModel::addContact(const QString &username)
{
    if(username.isEmpty()) return false;
    QSqlQuery query;
    QString queryString=QString("INSERT INTO Contacts VALUES('%1')").arg(username);
    if (!query.exec(queryString))
    {
        return false;
    }
    setQuery(QSqlQuery("SELECT * from Contacts"));
    return true;
}

