// Building an application just with a DialogBox

#include "FiveWin.ch"

//----------------------------------------------------------------------------//

function Main()

	local oDlg
	local oSerialNum
	local oDesprotec
	local cSerialNum	:= Space( 100 )
	local nDesprotec	:= 0

	DEFINE DIALOG oDlg FROM 1, 1 TO 20, 60;
		TITLE "Modulo Desprotector de Gestool2021"

	@ 2, 2 GET oSerialNum VAR cSerialNum ;
		OF oDlg ;
		SIZE 150, 15 ;
		RIGHT ;
		VALID GetSerial( Val( AllTrim( cSerialNum ) ), oDesprotec )

	@ 4, 2 GET oDesprotec VAR nDesprotec ;
		OF oDlg ;
		SIZE 150, 15 ;
		RIGHT

	@ 6, 2 BUTTON "&Bye!";
		OF oDlg;
		ACTION oDlg:End()

	ACTIVATE DIALOG oDlg CENTERED

return nil

//----------------------------------------------------------------------------//

STATIC FUNCTION GetSerial( nSerialNum, oDesprotec )

    oDesprotec:varPut( nXor( nSerialNum, 12345677654321 ) ) 
	oDesprotec:refresh()

RETURN .T.

//----------------------------------------------------------------------------//