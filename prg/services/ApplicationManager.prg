#include "FiveWin.Ch"
#include "Factu.ch" 

static oApplication

//----------------------------------------------------------------------------//

CLASS ApplicationManager

   DATA uuidDelegacion     INIT ""
   DATA codigoDelegacion   INIT ""

   DATA uuidCaja           INIT ""
   DATA codigoCaja         INIT ""

   DATA uuidAlmacen        INIT ""
   DATA codigoAlmacen      INIT ""

   DATA oCajon
   DATA cCajon             INIT ""

   METHOD New()

   METHOD setDelegacion( uuidDelegacion, codigoDelegacion )
   METHOD getDelegacion()

   METHOD setCaja( uuidCaja, codigoCaja )
   METHOD getCaja()

   METHOD setAlmacen( uuidAlmacen, codigoAlmacen )
   METHOD getAlmacen()

   METHOD setCajon()

   METHOD openDirectCajon()      INLINE ( if( !Empty( ::oCajon ), ::oCajon:open(), ) )

END CLASS

//--------------------------------------------------------------------------//

METHOD New()

   ::getDelegacion()

   ::getCaja()

   ::getAlmacen()

   ::setCajon()

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD setCajon()

   ::cCajon      := CajasModel():getCajonUuidFromCodigo( ::codigoCaja )

   if !Empty( ::cCajon )

      ::oCajon       := TCajon():New(  CajonesModel():getField( "cCodAper", "cCodCaj", ::cCajon ),;
                                       CajonesModel():getField( "cPrinter", "cCodCaj", ::cCajon ) )
   end if

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD setDelegacion( uuidDelegacion, codigoDelegacion )

   ::uuidDelegacion        := if( hb_isnil( uuidDelegacion ), "", uuidDelegacion )
   ::codigoDelegacion      := if( hb_isnil( codigoDelegacion ), "", codigoDelegacion )

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD getDelegacion()

   local delegacion        

   ::setDelegacion()

   delegacion              := UsuariosModel():getUsuarioDelegacionExclusiva( Auth():Uuid() )

   if !empty( delegacion )
      ::setDelegacion( DelegacionesModel():getField( "cCodDlg", "Uuid", delegacion ), delegacion )
      RETURN ( self )
   end if 

   delegacion              := uFieldEmpresa( "cSufDoc" )

   if !empty( delegacion )
      ::setDelegacion( DelegacionesModel():getField( "Uuid", "cCodDlg", delegacion ), delegacion )
      RETURN ( self )
   end if 

   if empty( delegacion )
      ::setDelegacion( DelegacionesModel():getField( "Uuid", "cCodDlg", "00" ), "00" )
      RETURN ( self )
   end if

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD setCaja( uuidCaja, codigoCaja )

   ::uuidCaja              := if( hb_isnil( uuidCaja ), "", uuidCaja )
   ::codigoCaja            := if( hb_isnil( codigoCaja ), "", codigoCaja )

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD getCaja()

   local caja

   ::setCaja()
   
   caja                    := UsuariosModel():getUsuarioCajaExclusiva( Auth():Uuid() )

   if !empty( caja )
      ::setCaja( CajasModel():getField( "cCodCaj", "Uuid", caja ), caja )
      RETURN ( self )
   end if 

   caja                    := uFieldEmpresa( "cDefCaj" )

   if !empty( caja )
      ::setCaja( CajasModel():getField( "Uuid", "cCodCaj", caja ), caja )
      RETURN ( self )
   end if

   if empty( caja )
      ::setCaja( CajasModel():getField( "Uuid", "cCodCaj", "000" ), "000" )
      RETURN ( self )
   end if 

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD setAlmacen( uuidAlmacen, codigoAlmacen )

   ::uuidAlmacen           := if( hb_isnil( uuidAlmacen ), "", uuidAlmacen )
   ::codigoAlmacen         := if( hb_isnil( codigoAlmacen ), "", codigoAlmacen )

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD getAlmacen()

   local almacen

   ::setAlmacen()
   
   almacen                 := UsuariosModel():getUsuarioAlmacenExclusivo( Auth():Uuid() )

   if !empty( almacen )
      ::setAlmacen( AlmacenesModel():getField( "cCodAlm", "Uuid", almacen ), almacen )
      RETURN ( self )
   end if 

   almacen                 := uFieldEmpresa( "cDefAlm" )

   if !empty( almacen )
      ::setAlmacen( AlmacenesModel():getField( "cCodAlm", "Uuid", almacen ), almacen )
      RETURN ( self )
   end if 

   if empty( almacen )
      ::setAlmacen( AlmacenesModel():getField( "cCodAlm", "Uuid", "000" ), "000" )
      RETURN ( self )
   end if 

RETURN ( self )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

FUNCTION Application()

   if empty( oApplication )
      oApplication   := ApplicationManager():New()
   end if

RETURN ( oApplication )

//---------------------------------------------------------------------------//

FUNCTION ApplicationLoad()

   if !empty( oApplication )
      oApplication   := nil
   end if

RETURN ( Application() )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

