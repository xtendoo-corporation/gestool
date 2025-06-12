#include "hbclass.ch"

//---------------------------------------------------------------------------//

FUNCTION AsignarCliente( nView )

   local oClientReciept    := ClientReciept():New()

   if !( BrwClient( oClientReciept ) )
      RETURN ( nil )
   end if 
   
   if !( D():gotoCliente( oClientReciept:cCodigo, nView ) )
      msgStop( "Cliente " + alltrim( oClientReciept:cCodigo ) + " no encontrado" )
      RETURN ( nil )
   end if 

   if dbLock( D():Tikets( nView ) )
      ( D():Tikets( nView ) )->cCliTik    := ( D():Clientes( nView ) )->Cod
      ( D():Tikets( nView ) )->CNOMTIK    := ( D():Clientes( nView ) )->Titulo 
      ( D():Tikets( nView ) )->CDIRCLI    := ( D():Clientes( nView ) )->Domicilio
      ( D():Tikets( nView ) )->CPOBCLI    := ( D():Clientes( nView ) )->Poblacion
      ( D():Tikets( nView ) )->CTLFCLI    := ( D():Clientes( nView ) )->Telefono
      ( D():Tikets( nView ) )->CPRVCLI    := ( D():Clientes( nView ) )->Provincia
      ( D():Tikets( nView ) )->CPOSCLI    := ( D():Clientes( nView ) )->CodPostal
      ( D():Tikets( nView ) )->CDNICLI    := ( D():Clientes( nView ) )->Nif
      ( D():Tikets( nView ) )->CCODGRP    := ( D():Clientes( nView ) )->cCodGrp
      ( D():Tikets( nView ) )->( dbunlock() )
   end if 

   sysrefresh()

RETURN ( nil )

//---------------------------------------------------------------------------//

CLASS ClientReciept

   DATA cCodigo               

   METHOD New()

   METHOD cText( cCodigo )    INLINE ( ::cCodigo := cCodigo )
   METHOD varGet()            INLINE ( ::cCodigo )

   METHOD lValid()            VIRTUAL
   METHOD SetFocus()          VIRTUAL

END CLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS ClientReciept

   ::cCodigo                  := Space( 12 )

RETURN ( Self )

//---------------------------------------------------------------------------//
