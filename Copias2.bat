cd \

cd C:\Program Files (x86)\MariaDB 10.2\bin\

MYSQLdump --host=localhost --user=root --password=root --databases gestool > C:\Gestool\COPIASQL\gestoolbackup.sql
 
cd \
cd C:\Gestool\COPIASQL
SET fecha=%date:~6,4%%date:~3,2%%date:~0,2%
 
set hora=%TIME:~,2%
set min=%TIME:~3,2%
set seg=%TIME:~6%
 
echo %hor% : %min% : %seg%
echo %fecha%
 
ren gestoolbackup.sql %fecha%_%hora%%min%_gestoolbackup.sql