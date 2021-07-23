#!/bin/bash
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '#P455w0rd#' -i /var/opt/sqlserver/drop-database-objects.sql
sed 's/(.*//' /var/opt/sqlserver/dbname.txt -i
sed 's/-.*//' /var/opt/sqlserver/dbname.txt -i
cat /var/opt/sqlserver/dbname.txt | tr -d "[:space:]" > /var/opt/sqlserver/dbname-replace.txt
dbvar=$(cat /var/opt/sqlserver/dbname-replace.txt | sed '/^$/d;s/[[:blank:]]//g')
input="databasename"
sed "s/$input/${dbvar}/" /var/opt/sqlserver/database-export.sh -i