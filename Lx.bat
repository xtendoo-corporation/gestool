cd \fwh1801\gestool\

taskkill /F /IM rptapolo.exe

del \fwh1801\gestool\obj\rptgal.obj

\BCC582\BIN\MAKE -S -fLX.MAK -D__GST__

cd \fwh1801\gestool\bin

RptApolo.exe 0000 999 

cd \fwh1801\gestool\
