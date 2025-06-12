#include "FiveWin.Ch"
#include "Factu.ch"

/*
Hay que crear los campos extra necesarios para este script---------------------
*/

Function PruebaStock( nView )                  
         
   local oPruebaStock    := TPruebaStock():New( nView )

   oPruebaStock:Run()

Return nil

//---------------------------------------------------------------------------//  

CLASS TPruebaStock

   DATA oDialog
   DATA nView

   DATA oArticulo
   DATA cArticulo

   DATA oAlmacen
   DATA cAlmacen

   DATA oLote
   DATA cLote

   DATA oSayStock
   DATA cSayStock

   DATA oSayTime
   DATA cSayTime

   DATA oSayTotStock
   DATA cSayTotStock

   DATA oSayTotTime
   DATA cSayTotTime

   METHOD New()

   METHOD Run()

   METHOD SetResources()      INLINE ( SetResources( fullcurdir() + "Script\Articulos\pruebastock.dll" ) )

   METHOD FreeResources()     INLINE ( FreeResources() )

   METHOD Resource() 

   METHOD Process()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView ) CLASS TPruebaStock

   ::nView                    := nView

   ::cArticulo                := Space( 18 )
   ::cAlmacen                 := Space( 16 )
   ::cLote                    := Space( 14 )
   ::cSayStock                := Space( 1 )
   ::cSayTime                 := Space( 1 )

Return ( Self )

//----------------------------------------------------------------------------//

METHOD Run() CLASS TPruebaStock

   ::SetResources()

   ::Resource()

   ::FreeResources()

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD Resource() CLASS TPruebaStock

   DEFINE DIALOG ::oDialog RESOURCE "PRUEBASTOCKS" 

   REDEFINE GET ::oArticulo ;
      VAR      ::cArticulo ;
      ID       100 ;
      OF       ::oDialog

   REDEFINE GET ::oAlmacen ;
      VAR      ::cAlmacen ;
      ID       120 ;
      OF       ::oDialog

   REDEFINE GET ::oLote ;
      VAR      ::cLote ;
      ID       130 ;
      OF       ::oDialog

   REDEFINE SAY ::oSayStock;
      VAR      ::cSayStock ;
      ID       140 ;
      OF       ::oDialog

   REDEFINE SAY ::oSayTime;
      VAR      ::cSayTime ;
      ID       150 ;
      OF       ::oDialog

   REDEFINE SAY ::oSayTotStock;
      VAR      ::cSayTotStock ;
      ID       160 ;
      OF       ::oDialog

   REDEFINE SAY ::oSayTotTime;
      VAR      ::cSayTotTime ;
      ID       170 ;
      OF       ::oDialog

   REDEFINE BUTTON ;
      ID          IDOK ;
      OF          ::oDialog ;
      ACTION      ( ::Process() )

   REDEFINE BUTTON ;
      ID          IDCANCEL ;
      OF          ::oDialog ;
      ACTION      ( ::oDialog:End( IDCANCEL ) )

   ::oDialog:AddFastKey( VK_F5, {|| ::Process() } )

   ::oDialog:bStart := {|| ::oArticulo:SetFocus() }

   ACTIVATE DIALOG ::oDialog CENTER

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD Process() CLASS TPruebaStock

   local nSec
   local nResult
   local nTime

   ::cArticulo                := Padr( ::cArticulo , 18 )
   ::cAlmacen                 := Padr( ::cAlmacen , 18 )
   ::cLote                    := Padr( ::cLote , 18 )

   nSec     := seconds()
   nRetult  := StocksModel():nSQLStockActual( ::cArticulo, ::cAlmacen, , , , , ::cLote )
   nSec     := seconds() - nSec

   ::oSayStock:SetText( "Stock por lote: " + Trans( nRetult, "@E 999,999.999" ) )
   ::oSayTime:SetText( "Tiempo: " + Str( nSec ) )

   SysRefresh()

   nSec     := seconds()
   nRetult  := StocksModel():nSQLGlobalStockActual( ::cArticulo, ::cAlmacen )
   nSec     := seconds() - nSec

   ::oSayTotStock:SetText( "Stock del almacén: " + Trans( nRetult, "@E 999,999.999" ) )
   ::oSayTotTime:SetText( "Tiempo: " + Str( nSec ) )

   SysRefresh()

Return ( .t. )

//---------------------------------------------------------------------------//