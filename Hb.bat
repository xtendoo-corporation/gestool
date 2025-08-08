cd \fwh1801\gestool\

taskkill /F /IM gestool.exe

\BCC582\BIN\MAKE -S -fHB.MAK -D__GST__ TARGET=gestool

cd \fwh1801\gestool\bin\

if "%1"=="" goto NOPASSWORD

   gestool.exe %1 /NOPASSWORD

goto EXIT

:NOPASSWORD
   gestool.exe /NOPASSWORD

:EXIT
   cd \fwh1801\gestool\
