HB                   = 	\harbour_bcc7\

HBINCLUDE            = 	\harbour_bcc7\include
FWINCLUDE            = 	\fwh1801\include
GTINCLUDE            = 	.\Include

HBLIB                = 	\harbour_bcc7\lib
FWLIB                = 	\fwh1801\lib

RESOURCE             = 	.\resource

BORLAND              = 	\bcc73
BORLANDLIB           = 	\bcc73\lib

IMG2PDFLIB           = 	\img2Pdf

OBJ                  = 	obj1801

SOURCEPRG            = 	.\Prg;
SOURCEC 		     =	.\C

PPO 				 = 	ppo1801

EXE 				 = 	protec21.exe

.path.prg      		=	.\$(SOURCEPRG)
.path.c       		=	.\$(SOURCEC)
.path.obj      		=	.\$(OBJ)

PRG            		=    													\
protecc.prg             													\

C               =       	            									\
Img2pdf.c               	            									\
Treeview.c 					               									\

OBJS            =                                  							\
protecc.obj                                       							\

.PRG.OBJ:
  	$(HB)\Bin\Harbour $< /n /p$(PPO)\$&.ppo /w /es2 /i$(FWINCLUDE) /i$(HBINCLUDE) /i$(GTINCLUDE) /o$(OBJ)\$&.c
    $(BORLAND)\Bin\Bcc32 -c -tWM -I$(HBINCLUDE) -o$(OBJ)\$& $(OBJ)\$&.c

$(EXE)                  : $( PRG:.PRG=.OBJ )

.C.OBJ:
  	$(BORLAND)\Bin\Bcc32 -c -tWM -DHB_API_MACROS -I$(HBINCLUDE);$(FWINCLUDE) -o$(OBJ)\$& $<

$(EXE)                  : $( C:.C=.OBJ )

$(EXE) 						: $(RESOURCE)\GstDialog.Res $(OBJS)
  	$(BORLAND)\Bin\iLink32 @&&|
  	-Gn -aa -Tpe -s -r -m -V4.0                              				+
(BORLAND)\lib\c0w32.obj                                     				+
$(OBJ)\protecc.obj                                         				 
$<,$*
$(FWLIB)\FiveH.lib               											+
$(FWLIB)\FiveHC.lib              											+
$(FWLIB)\libcurl.lib             											+
$(HBLIB)\hbwin.lib               											+
$(HBLIB)\gtwin.lib               											+ 
$(HBLIB)\gtgui.lib               											+ 
$(HBLIB)\hbrtl.lib               											+ 
$(HBLIB)\hbvm.lib                											+ 
$(HBLIB)\hblang.lib              											+
$(HBLIB)\hbmacro.lib             											+
$(HBLIB)\hbrdd.lib               											+ 
$(HBLIB)\rddntx.lib              											+
$(HBLIB)\rddcdx.lib              											+
$(HBLIB)\rddfpt.lib              											+
$(HBLIB)\hbsix.lib               											+ 
$(HBLIB)\hbdebug.lib             											+
$(HBLIB)\hbcommon.lib            											+
$(HBLIB)\hbpp.lib                											+ 
$(HBLIB)\hbcpage.lib             											+
$(HBLIB)\hbcplr.lib              											+
$(HBLIB)\hbct.lib                											+ 
$(HBLIB)\hbpcre.lib              											+
$(HBLIB)\xhb.lib                 											+ 
$(HBLIB)\hbziparc.lib            											+
$(HBLIB)\hbmzip.lib              											+
$(HBLIB)\hbzlib.lib              											+
$(HBLIB)\minizip.lib             											+
$(HBLIB)\png.lib                 											+ 
$(HBLIB)\hbcurl.lib 														+
$(HBLIB)\hbusrrdd.lib            											+
$(HBLIB)\hbtip.lib 															+     
$(HBLIB)\hbtipssl.lib     													+       
$(HBLIB)\hbmxml.lib            												+
$(HBLIB)\hbmisc.lib  														+
$(HBLIB)\hbsqlit3.lib            											+
$(HBLIB)\hbhttpd.lib 														+
$(HBLIB)\hbcurls.lib 														+
$(HBLIB)\hbssl.lib     														+
$(HBLIB)\hbssls.lib   														+
$(HBLIB)\libeay32.lib           											+
$(HBLIB)\ssleay32.lib           											+
$(HBLIB)\libssl32.lib            											+
$(HBLIB)\hbhpdf.lib 														+
$(HBLIB)\hbzebra.lib            											+
$(HBLIB)\libhpdf.lib 														+
$(HBLIB)\hbformat.lib 														+
$(HBLIB)\hdo.lib               												+
$(HBLIB)\mylist.lib 														+
$(HBLIB)\rdlmysql.lib 														+
$(HBLIB)\libmysql.lib            											+
$(HBLIB)\Eagle1.lib              											+
$(HBLIB)\hbcplr.lib            												+
$(HBLIB)\libssh2.lib 														+
$(IMG2PDFLIB)\Image2pdf.lib      											+
$(HBLIB)\b32\rddads.lib          											+
$(HBLIB)\ace32.lib               											+
$(BORLANDLIB)\cw32mt.lib         											+ 
$(BORLANDLIB)\uuid.lib           											+ 
$(BORLANDLIB)\import32.lib       											+ 
$(BORLANDLIB)\ws2_32.lib         											+ 
$(BORLANDLIB)\psdk\odbc32.lib    											+
$(BORLANDLIB)\psdk\nddeapi.lib   											+
$(BORLANDLIB)\psdk\iphlpapi.lib  											+
$(BORLANDLIB)\psdk\msimg32.lib   											+
$(BORLANDLIB)\psdk\psapi.lib     											+ 
$(BORLANDLIB)\psdk\rasapi32.lib  											+
$(BORLANDLIB)\psdk\gdiplus.lib   											+
$(BORLANDLIB)\psdk\urlmon.lib    											+
$(BORLANDLIB)\psdk\shell32.lib,
$(RESOURCE)\GstDialog.Res        											+
|