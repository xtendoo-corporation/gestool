#include "Factu.ch" 
#include "FiveWin.ch"

//---------------------------------------------------------------------------//

Function ValidPrecio( oSender, oGetPrecio )

   local oValid

   oValid      := oValidPrecio():new( oSender, oGetPrecio )

Return oValid:run()

//---------------------------------------------------------------------------//

CLASS oValidPrecio

	DATA oSender

	DATA oGetPrecio

	DATA nPrecioNuevo

	DATA nPrecioNormal

	DATA nPorcentaje

	METHOD new( oSender, oGetPrecio )

   	METHOD run()

END CLASS

//---------------------------------------------------------------------------//

METHOD new( oSender, oGetPrecio ) CLASS oValidPrecio

   	::oSender      	:= oSender
   	::oGetPrecio   	:= oGetPrecio

	::nPrecioNuevo 	:= oGetPrecio:VarGet()
   	::nPrecioNormal := nRetPreArt( 	::oSender:hGetDetail( "NumeroTarifa" ),;
   								 	::oSender:hGetMaster( "Divisa" ),;
   								 	::oSender:hGetMaster( "ImpuestosIncluidos" ),;
   								 	D():Articulos( ::oSender:getView() ),;
   								 	D():Divisas( ::oSender:getView() ),;
   								 	D():Kit( ::oSender:getView() ),;
   								 	D():TiposIva( ::oSender:getView() ) )

   	::nPorcentaje  	:= 50

Return ( self )

//---------------------------------------------------------------------------//

METHOD run() CLASS oValidPrecio

   	local nPor 		          := 0
   	local lReturn  	       := .t.
      local nPrecioReducido     := 0

   	if ::nPrecioNormal == ::nPrecioNuevo
   		Return lReturn
   	end if

   	//nPor 			:= ( ( ::nPrecioNuevo * 100 ) / ::nPrecioNormal )

      nPrecioReducido    := ::nPrecioNormal / ( 1 + ( ::nPorcentaje / 100 ) )

   	lReturn 		:= !( ::nPrecioNormal > nPrecioReducido )

   	if !lReturn
   		ApoloMsgStop( "No puede bajar el precio por debajo de un " + AllTrim( Str( ::nPorcentaje ) ) + "%", "¡Atención!" )
   		::oGetPrecio:SetFocus()
   	end if

Return ( lReturn )

//---------------------------------------------------------------------------//