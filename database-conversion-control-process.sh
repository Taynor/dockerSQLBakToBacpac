#!/bin/bash
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '#P455w0rd#' -i /var/opt/sqlserver/create-database.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '#P455w0rd#' -i /var/opt/sqlserver/restore-database.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '#P455w0rd#' -i /var/opt/sqlserver/drop-database-objects.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '#P455w0rd#' -i /var/opt/sqlserver/database-name.sql -o /var/opt/sqlserver/dbname.txt
/var/opt/sqlserver/database-cleanup.sh
/var/opt/sqlserver/database-cleanup-utility.sh
sleep 10s
/var/opt/sqlserver/database-export.sh