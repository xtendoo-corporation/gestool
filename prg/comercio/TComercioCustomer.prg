#include "FiveWin.Ch" 
#include "Struct.ch"
#include "Factu.ch" 
#include "Ini.ch"
#include "MesDbf.ch" 

//---------------------------------------------------------------------------//

CLASS TComercioCustomer FROM TComercioConector

   DATA  TComercio

   DATA  idCustomergestool
  
   METHOD New( TComercio )                         CONSTRUCTOR

   METHOD isCustomerIngestool( oQueryCustomer )
   METHOD isNotCustomerIngestool( oQueryCustomer ) INLINE ( !( ::isCustomerIngestool( oQueryCustomer ) ) )                  

   METHOD isAddressIngestool( idAddress ) 
   METHOD isNotAddressIngestool( idAddress )       INLINE ( !( ::isAddressIngestool( idAddress ) ) )                  

   METHOD insertCustomerIngestoolIfNotExist( oQuery ) 

   METHOD getCustomerFromPrestashop()
      METHOD appendCustomerIngestool()

   METHOD createAddressIngestool()    
   METHOD getAddressFromPrestashop()
      METHOD appendAddressIngestool()
      METHOD assertAddressIngestoolCustomer()

   METHOD getState( idState ) 
   METHOD getPaymentgestool( module ) 

   METHOD setCustomergestool( idCustomergestool )  INLINE ( ::idCustomergestool := padr( idCustomergestool, 12 ) )
   METHOD getCustomergestool()                     INLINE ( padr( ::idCustomergestool, 12 ) )

   METHOD getCustomerName( oQuery )                INLINE ( if ( ::TComercioConfig():isInvertedNameFormat(),;
                                                               upper( oQuery:fieldGetbyName( "lastname" ) ) + ", " + upper( oQuery:fieldGetByName( "firstname" ) ),;
                                                               upper( oQuery:fieldGetbyName( "firstname" ) ) + space( 1 ) + upper( oQuery:fieldGetByName( "lastname" ) ) ) )

   // facades------------------------------------------------------------------

   METHOD TPrestashopId()                          INLINE ( ::TComercio:TPrestashopId )
   METHOD TComercioConfig()                        INLINE ( ::TComercio:TComercioConfig )
   METHOD getCurrentWebName()                      INLINE ( ::TComercio:getCurrentWebName() )

   METHOD writeText( cText )                       INLINE ( ::TComercio:writeText( cText ) )

   METHOD oCustomerDatabase()                      INLINE ( ::TComercio:oCli )
   METHOD oAddressDatabase()                       INLINE ( ::TComercio:oObras )
   METHOD oPaymentDatabase()                       INLINE ( ::TComercio:oFPago )

END CLASS

//---------------------------------------------------------------------------//

METHOD New( TComercio ) CLASS TComercioCustomer

   ::TComercio          := TComercio

Return ( Self )

//---------------------------------------------------------------------------//

METHOD isCustomerIngestool( oQuery ) CLASS TComercioCustomer

   local email
   local idCustomer
   local idCustomergestool     

   if oQuery:recCount() > 0

      email                := oQuery:fieldGetByName( 'email' )
      idCustomer           := oQuery:fieldGetByName( 'id_customer' )

      idCustomergestool    := ::TPrestashopId():getgestoolCustomer( idCustomer, ::getCurrentWebName() ) 

      if !empty( idCustomergestool )
         ::setCustomergestool( idCustomergestool )
         Return ( .t. )
      end if 

      /*if D():gotoCliente( idCustomer, ::getView() ) 
         ::setCustomergestool( idCustomergestool )
         Return ( .t. )
      end if

      if !empty( email ) .and. ( ClientesModel():existEmail( email ) )
         ::setCustomergestool( ( D():Clientes( ::getView() ) )->Cod )
         Return ( .t. )
      end if */

   end if 

Return ( .f. )

//---------------------------------------------------------------------------//

METHOD isAddressIngestool( idAddress ) CLASS TComercioCustomer                  

   local idAddressIngestool   

   idAddressIngestool         := ::TPrestashopId():getgestoolAddress( idAddress, ::getCurrentWebName() )

   if empty( idAddressIngestool )
      Return ( .f. )
   end if 

   if ( D():gotoIdClientesDirecciones( idAddressIngestool, ::getView() ) )  
      ::writeText( "La dirección " + idAddressIngestool + " ya exite en las direcciones" )    
      Return ( .t. )
   end if 

   ::writeText( "La dirección " + idAddressIngestool + " no exite en las direcciones" )    

Return ( .f. )

//---------------------------------------------------------------------------//

METHOD insertCustomerIngestoolIfNotExist( oQuery ) CLASS TComercioCustomer

   local idCustomer           := oQuery:FieldGetByName( "id_customer" )
   local idAddressDelivery    := oQuery:FieldGetByName( "id_address_delivery" )
   local idAddressInvoice     := oQuery:FieldGetByName( "id_address_invoice" ) 

   local oQueryCustomer       := ::getCustomerFromPrestashop( idCustomer )      

   if ::isNotCustomerIngestool( oQueryCustomer )
      ::appendCustomerIngestool( oQueryCustomer )
   end if 

   oQueryCustomer:free()

   if ::isNotAddressIngestool( idAddressDelivery ) 
      ::createAddressIngestool( idAddressDelivery )
   end if 

   if ::isNotAddressIngestool( idAddressDelivery ) 
      ::createAddressIngestool( idAddressInvoice )
   end if 

Return ( Self )

//---------------------------------------------------------------------------//

METHOD getCustomerFromPrestashop( idCustomer ) CLASS TComercioCustomer

   local cQuery
   local oQuery 

   cQuery            := "SELECT * FROM " + ::TComercio:cPrefixTable( "customer" ) + " WHERE id_customer = " + alltrim( str( idCustomer ) ) 
   oQuery            := TMSQuery():New( ::TComercio:oCon, cQuery )

   if oQuery:Open() 
      Return ( oQuery )   
   end if 

Return ( nil )

//---------------------------------------------------------------------------//

METHOD appendCustomerIngestool( oQuery ) CLASS TComercioCustomer

   ::setCustomergestool( nextkey( dbLast( D():Clientes( ::getView() ), 1 ), D():Clientes( ::getView() ), "0", retnumcodcliemp() ) )

   ( D():Clientes( ::getView() ) )->( dbAppend() )
   
   ( D():Clientes( ::getView() ) )->Cod        := ::getCustomergestool()
   ( D():Clientes( ::getView() ) )->Titulo     := ::getCustomerName( oQuery )
   ( D():Clientes( ::getView() ) )->nTipCli    := 3
   ( D():Clientes( ::getView() ) )->CopiasF    := 1
   ( D():Clientes( ::getView() ) )->Serie      := ::TComercioConfig():getOrderSerie()
   ( D():Clientes( ::getView() ) )->nRegIva    := 1
   ( D():Clientes( ::getView() ) )->nTarifa    := 1
   ( D():Clientes( ::getView() ) )->cMeiInt    := oQuery:fieldGetByName( "email" ) //email
   ( D():Clientes( ::getView() ) )->lChgPre    := .t.
   ( D():Clientes( ::getView() ) )->lSndInt    := .t.
   ( D():Clientes( ::getView() ) )->CodPago    := ::getPaymentgestool( oQuery:FieldGetByName( "module" ) )
   ( D():Clientes( ::getView() ) )->cCodAlm    := ::TComercioConfig():getStore()
   ( D():Clientes( ::getView() ) )->dFecChg    := GetSysDate()
   ( D():Clientes( ::getView() ) )->cTimChg    := Time()
   ( D():Clientes( ::getView() ) )->lWeb       := .t.

   if !( D():Clientes( ::getView() ) )->( neterr() )

      ( D():Clientes( ::getView() ) )->( dbcommit() )
      ( D():Clientes( ::getView() ) )->( dbunlock() )
      
      ::TPrestashopId():setValueCustomer( ::getCustomergestool(), ::getCurrentWebName(), oQuery:fieldGet( 1 ) ) 

      ::writeText( "Cliente " + ::getCustomerName( oQuery ) + " introducido con el código " + alltrim( ::getCustomergestool() ), 3 )

   else
      
      ::writeText( "Error al guardar el cliente en gestool : " + ::getCustomerName( oQuery ), 3 )
      
      Return ( .f. )

   end if

Return ( .t. )

//---------------------------------------------------------------------------//
 
METHOD createAddressIngestool( idAddress ) CLASS TComercioCustomer

   local oQuery 
  
   oQuery      := ::getAddressFromPrestashop( idAddress )

   if empty( oQuery )
      Return ( Self )
   end if 

   if oQuery:recCount() > 0 
      ::appendAddressIngestool( oQuery )
      ::assertAddressIngestoolCustomer( oQuery )
   end if 

   oQuery:Free()

Return ( Self )

//---------------------------------------------------------------------------//

METHOD getAddressFromPrestashop( idAddress ) CLASS TComercioCustomer

   local cQuery   := "SELECT * FROM " + ::TComercio:cPrefixTable( "address" ) + " WHERE id_address = " + alltrim( str( idAddress ) ) 
   local oQuery   := TMSQuery():New( ::TComercio:oCon, cQuery )

   if oQuery:Open() 
      Return ( oQuery )   
   end if 

Return ( nil )

//---------------------------------------------------------------------------//

METHOD appendAddressIngestool( oQuery ) CLASS TComercioCustomer

   local idAddressgestool        := "@" + alltrim( str( oQuery:fieldGet( 1 ) ) ) 

   ( D():ClientesDirecciones( ::getView() ) )->( dbappend() )
   
   ( D():ClientesDirecciones( ::getView() ) )->cCodObr  := idAddressgestool
   ( D():ClientesDirecciones( ::getView() ) )->cCodCli  := ::getCustomergestool()
   ( D():ClientesDirecciones( ::getView() ) )->cNomObr  := ::getCustomerName( oQuery )
   ( D():ClientesDirecciones( ::getView() ) )->cDirObr  := oQuery:fieldGetByName( "address1" ) + " " + oQuery:fieldGetByName( "address2" ) 
   ( D():ClientesDirecciones( ::getView() ) )->cPobObr  := oQuery:fieldGetByName( "city" )           
   ( D():ClientesDirecciones( ::getView() ) )->cPosObr  := oQuery:fieldGetByName( "postcode" )       
   ( D():ClientesDirecciones( ::getView() ) )->cTelObr  := oQuery:fieldGetByName( "phone" )          
   ( D():ClientesDirecciones( ::getView() ) )->cMovObr  := oQuery:fieldGetByName( "phone_mobile" )   
   ( D():ClientesDirecciones( ::getView() ) )->cPrvObr  := ::getState( oQuery:fieldGetbyName( "id_state" ) )

   if !( D():ClientesDirecciones( ::getView() ) )->( neterr() )

      ( D():ClientesDirecciones( ::getView() ) )->( dbcommit() )   
      ( D():ClientesDirecciones( ::getView() ) )->( dbunlock() )      

      ::TPrestashopId():setValueAddress( ::getCustomergestool() + idAddressgestool, ::getCurrentWebName(), oQuery:fieldGet( 1 ) ) 

      ::writeText( "Dirección de cliente " + ::getCustomerName( oQuery ) + " introducida correctamente", 3 )

   else
      
      ::writeText( "Error al guardar la dirección del cliente en gestool " + ::getCustomerName( oQuery ), 3 )
      
      Return ( .f. )
   
   end if 

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD assertAddressIngestoolCustomer ( oQuery ) class TComercioCustomer

   if !( D():gotoCliente( ::getCustomergestool(), ::getView() ) ) 
      ::writeText( "Cliente con el código " + alltrim( ::getCustomergestool() ) + " no encontrado, imposible asignar dirección." )
      Return ( .f. )
   end if 

   if empty( ( D():Clientes( ::getView() ) )->Domicilio )
      ( D():Clientes( ::getView() ) )->( dbrlock() )
      ( D():Clientes( ::getView() ) )->Nif           := oQuery:FieldGetByName( "dni" ) 
      ( D():Clientes( ::getView() ) )->Domicilio     := oQuery:fieldGetByName( "address1" ) + " " + oQuery:fieldGetByName( "address2" )  
      ( D():Clientes( ::getView() ) )->Poblacion     := oQuery:fieldGetByName( "city" )           
      ( D():Clientes( ::getView() ) )->CodPostal     := oQuery:fieldGetByName( "postcode" ) 
      ( D():Clientes( ::getView() ) )->Provincia     := ::getState( oQuery:fieldGetbyName( "id_state" ) )  
      ( D():Clientes( ::getView() ) )->Telefono      := oQuery:fieldGetByName( "phone" )  
      ( D():Clientes( ::getView() ) )->Movil         := oQuery:fieldGetByName( "phone_mobile" )          
      ( D():Clientes( ::getView() ) )->( dbcommit() )
      ( D():Clientes( ::getView() ) )->( dbunlock() )
   end if 

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD getState( idState ) CLASS TComercioCustomer
             
   local cQuery
   local oQuery
   local cState      := ""

   cQuery            := "SELECT * FROM " + ::TComercio:cPrefixTable( "state" ) + " WHERE id_state = " + alltrim( str( idState ) )
   oQuery            := TMSQuery():New( ::TComercio:oCon, cQuery )

   if oQuery:Open() .and. oQuery:RecCount() > 0
      cState         := oQuery:fieldGetbyName( "name" )
      oQuery:free()
   end if   

Return ( cState )

//---------------------------------------------------------------------------//

METHOD getPaymentgestool( cPrestashopModule ) CLASS TComercioCustomer

   local paymentgestool    := cDefFpg()

   if empty( cPrestashopModule )
      Return ( paymentgestool )
   end if 

   if ::oPaymentDatabase():seekInOrd( upper( cPrestashopModule ), "cCodWeb" )
      paymentgestool       := ::oPaymentDatabase():cCodPago 
   end if 

Return ( paymentgestool )

//---------------------------------------------------------------------------//

