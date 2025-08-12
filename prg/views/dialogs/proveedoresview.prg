#include "FiveWin.Ch"
#include "Factu.ch" 

CLASS ProveedoresView FROM Activate
  
   DATA oGetProvincia
   DATA oGetPoblacion
   DATA oGetPais

   METHOD Activate()

   METHOD Activating()

   METHOD getDireccionesController()   INLINE ( ::oController:oDireccionesController )

   METHOD validateFields()

END CLASS

//---------------------------------------------------------------------------//

METHOD Activating() CLASS TercerosView

   if ::oController:isAppendOrDuplicateMode()
      ::oController:oModel:hBuffer()
   end if 

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD Activate() CLASS TercerosView

   local oGetDni

   DEFINE DIALOG  ::oDialog ;
      RESOURCE    "AGENTE" ;
      TITLE       ::LblTitle() + "proveedor"

   REDEFINE BITMAP ::oBitmap ;
      ID          900 ;
      RESOURCE    "gc_user2_48" ;
      TRANSPARENT ;
      OF          ::oDialog

   REDEFINE SAY   ::oMessage ;
      ID          800 ;
      FONT        getBoldFont() ;
      OF          ::oDialog

   /*REDEFINE GET   ::oController:oModel:hBuffer[ "nombre" ] ;
      ID          100 ;
      WHEN        ( ::oController:isNotZoomMode() ) ;
      VALID       ( ::oController:validate( "nombre" ) ) ;
      OF          ::oDialog

   REDEFINE GET   oGetDni VAR ::oController:oModel:hBuffer[ "dni" ] ;
      ID          110 ;
      WHEN        ( ::oController:isNotZoomMode() ) ;
      VALID       ( CheckCif( oGetDni ) );
      OF          ::oDialog

   REDEFINE GET   ::oController:oModel:hBuffer[ "comision" ] ;
      ID          120 ;
      WHEN        ( ::oController:isNotZoomMode() ) ;
      PICTURE     "@E 999.99" ;
      OF          ::oDialog

   REDEFINE GET   ::getDireccionesController():oModel:hBuffer[ "direccion" ] ;
      ID          130 ;
      WHEN        ( ::getDireccionesController():isNotZoomMode() ) ;
      OF          ::oDialog

   REDEFINE GET   ::getDireccionesController():oModel:hBuffer[ "codigo_postal" ] ;
      ID          140 ;
      WHEN        ( ::getDireccionesController():isNotZoomMode() ) ;
      VALID       ( ::validateFields ) ;
      OF          ::oDialog 

   REDEFINE GET   ::oGetPoblacion VAR ::getDireccionesController():oModel:hBuffer[ "poblacion" ] ;
      ID          150 ;
      WHEN        ( ::getDireccionesController():isNotZoomMode() ) ;
      OF          ::oDialog

   REDEFINE GET   ::oGetProvincia VAR ::getDireccionesController():oModel:hBuffer[ "provincia" ] ;
      ID          160 ;
      IDTEXT      161 ;
      WHEN        ( ::getDireccionesController():isNotZoomMode() ) ;
      BITMAP      "LUPA" ;
      VALID       ( ::validateFields() ) ;
      OF          ::oDialog

   REDEFINE GET   ::oGetPais VAR ::getDireccionesController():oModel:hBuffer[ "codigo_pais" ] ;
      ID          200 ;
      IDTEXT      201 ;
      WHEN        ( ::getDireccionesController():isNotZoomMode() ) ;
      VALID       ( ::validateFields() ) ;
      BITMAP      "LUPA" ;
      OF          ::oDialog

   ::oGetPais:bHelp  := {|| ::oController:oPaisesController:getSelectorPais( ::oGetPais ), ::validateFields() }

   REDEFINE GET   ::getDireccionesController():oModel:hBuffer[ "telefono" ] ;
      ID          170 ;
      WHEN        ( ::getDireccionesController():isNotZoomMode() ) ;
      OF          ::oDialog

   REDEFINE GET   ::getDireccionesController():oModel:hBuffer[ "movil" ] ;
      ID          180 ;
      WHEN        ( ::getDireccionesController():isNotZoomMode() ) ;
      OF          ::oDialog

   REDEFINE GET   ::getDireccionesController():oModel:hBuffer[ "email" ] ;
      ID          190 ;
      WHEN        ( ::getDireccionesController():isNotZoomMode() ) ;
      VALID       ( ::getDireccionesController():validate( "email" ) ) ;
      OF          ::oDialog*/

   REDEFINE BUTTON ;
      ID          IDOK ;
      OF          ::oDialog ;
      WHEN        ( ::oController:isNotZoomMode() ) ;
      ACTION      ( if( validateDialog( ::oDialog ), ::oDialog:end( IDOK ), ) )

   REDEFINE BUTTON ;
      ID          IDCANCEL ;
      OF          ::oDialog ;
      CANCEL ;
      ACTION      ( ::oDialog:end() )

   if ::oController:isNotZoomMode() 
      ::oDialog:AddFastKey( VK_F5, {|| if( validateDialog( ::oDialog ), ::oDialog:end( IDOK ), ) } )
   end if

   ::oDialog:bStart := {|| ::validateFields() }

   ACTIVATE DIALOG ::oDialog CENTER

   ::oBitmap:end()

RETURN ( ::oDialog:nResult )

//---------------------------------------------------------------------------//

METHOD validateFields() CLASS TercerosView

RETURN ( .t. )

//---------------------------------------------------------------------------//