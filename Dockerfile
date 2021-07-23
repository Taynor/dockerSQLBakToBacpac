#Pull latest SQL 2019 image from Microsoft
FROM mcr.microsoft.com/mssql/server:2019-latest
#Change to Root user to download and install tools
USER root

#Download the PowerShell package for ubuntu
RUN wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb

#Install the PowerShell package
RUN apt-get update
RUN apt-get install -y powershell

#Install the unzip package needed to unzip the sqlpackage utility
RUN apt-get install unzip

#Create a directory in the image and set the owner
RUN mkdir /var/opt/sqlserver
RUN chown mssql /var/opt/sqlserver

#Copy the files to the working directory for the image
COPY . .

#The environment variables for the SQL backup, data and log files 
ENV MSSQL_BACKUP_DIR="/var/opt/sqlserver"
ENV MSSQL_DATA_DIR="/var/opt/sqlserver"
ENV MSSQL_LOG_DIR="/var/opt/sqlserver"
ENV SA_PASSWORD="#P455w0rd#"
ENV ACCEPT_EULA="Y"

#Make the conversion script an executable
RUN chmod +x entrypoint.sh
RUN chmod +x database-conversion-control-process.sh
RUN chmod +x database-cleanup.sh
RUN chmod +x database-cleanup-utility.sh
RUN chmod +x database-export.sh

#Switch back to mssql user
USER mssql 

#Execute the entrypoint shell script using bash
CMD /bin/bash /var/opt/sqlserver/entrypoint.sh