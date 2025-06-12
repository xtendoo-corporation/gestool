cd \
cd %~1
MYSQLdump --host=%~3 --user=%~4 --password=%~5 --databases %~6 > %~2