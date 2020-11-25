#ifndef SQLCONTACTMODEL_H
#define SQLCONTACTMODEL_H
#include <QSqlQueryModel>

class SqlContactModel : public QSqlQueryModel
{
    Q_OBJECT
public:
    SqlContactModel(QObject *parent = nullptr);
    Q_INVOKABLE bool addContact(const QString &username);
};

#endif // SQLCONTACTMODEL_H
