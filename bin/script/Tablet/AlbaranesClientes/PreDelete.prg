#include "Factu.ch" 
#include "FiveWin.ch"

//---------------------------------------------------------------------------//

Function PreDelete( oSender )

	if !Empty( ( D():AlbaranesClientes( oSender:nView ) )->cNumDoc )
		DelAlbCli( ( D():AlbaranesClientes( oSender:nView ) )->cNumDoc, , .t. )
	end if

Return ( nil )

//---------------------------------------------------------------------------//