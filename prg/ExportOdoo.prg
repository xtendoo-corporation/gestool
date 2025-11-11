#include "FiveWin.Ch"
#include "Factu.ch" 
#include "MesDbf.ch"

CLASS ExportOdoo

   DATA oDlg
   DATA oGet

   DATA aLgcIndices
   DATA aChkIndices
   DATA aMtrIndices
   DATA aNumIndices

   DATA cConector

   DATA cPathFac

   DATA cIncidencia

   DATA oSayProcess

   DATA aDni

   METHOD New()

   METHOD Resource()

   METHOD Exportar()

   METHOD SelectChk( lSet )

   METHOD ExportaClientes()

   METHOD ExportaBancosClientes()

   METHOD ExportaDireccionesClientes()
   METHOD ExportaGruposClientes()
   METHOD ExportaFormasPago()
   METHOD ExportaAgentes()

   METHOD ExportaArticulos()

   METHOD ExportaArticulos2()
   METHOD ExportaArticulos3()
   METHOD ExportaArticulos4()
   METHOD ExportaArticulos5()
   METHOD ExportaArticulos6()

   METHOD ExportaAtipicas()

   METHOD ExportaTickets()

   METHOD ExportaTarifas()

   METHOD ExportaFamilias()

   METHOD ExportaKits()

   METHOD ExportaPropiedades()

   METHOD cNameFile( cName )

   METHOD createFile( cMemo, cName )

   METHOD createLogFile()
   METHOD cNameLogFile()

   METHOD cClearEmail( cEmail )

   METHOD cClearStr( cStr )                     INLINE ( StrTran( AllTrim( cStr ), ",", " " ) )

   METHOD cValidDni( cDni, cTitle )

   METHOD cValidDniCliente( cDni )              INLINE ( ::cValidDni( cDni, "cliente" ) )
   METHOD cValidDniProveedor( cDni )            INLINE ( ::cValidDni( cDni, "proveedor" ) )

   METHOD bankCount( cPaisIBAN, cCtrlIBAN, cEntBnc, cSucBnc, cDigBnc, cCtaBnc )
   METHOD sanitizedBankCount( cPaisIBAN, cCtrlIBAN, cEntBnc, cSucBnc, cDigBnc, cCtaBnc )

   METHOD formatNumeric( cVal )

END CLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS ExportOdoo

   ::cPathFac     := Space( 200 )

   ::aLgcIndices  := Afill( Array( 10 ), .t. )
   ::aChkIndices  := Array( 10 )
   ::aMtrIndices  := Array( 10 )
   ::aNumIndices  := Afill( Array( 10 ), 0 )

   ::cConector    := ";"

   ::cIncidencia  := ""

   ::aDni         := {}

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Resource() CLASS ExportOdoo

   local oBmp
   
   if oWnd() != nil
      oWnd():CloseAll()
   end if

   DEFINE DIALOG ::oDlg RESOURCE "IMPODOO" OF oWnd()

      REDEFINE BITMAP oBmp RESOURCE "odoo_48" TRANSPARENT ID 600 OF ::oDlg

      REDEFINE GET ::oGet VAR ::cPathFac ID 100 BITMAP "FOLDER" OF ::oDlg
      ::oGet:bHelp   := {|| ::oGet:cText( cGetDir32( "Seleccione destino" ) ) }

      REDEFINE CHECKBOX ::aChkIndices[ 1 ] VAR ::aLgcIndices[ 1 ] ID 110 OF ::oDlg

      REDEFINE CHECKBOX ::aChkIndices[ 2 ] VAR ::aLgcIndices[ 2 ] ID 120 OF ::oDlg

      REDEFINE CHECKBOX ::aChkIndices[ 3 ] VAR ::aLgcIndices[ 3 ] ID 130 OF ::oDlg

      REDEFINE CHECKBOX ::aChkIndices[ 4 ] VAR ::aLgcIndices[ 4 ] ID 140 OF ::oDlg

      REDEFINE CHECKBOX ::aChkIndices[ 5 ] VAR ::aLgcIndices[ 5 ] ID 150 OF ::oDlg

      REDEFINE CHECKBOX ::aChkIndices[ 6 ] VAR ::aLgcIndices[ 6 ] ID 160 OF ::oDlg

      REDEFINE CHECKBOX ::aChkIndices[ 7 ] VAR ::aLgcIndices[ 7 ] ID 170 OF ::oDlg

      REDEFINE CHECKBOX ::aChkIndices[ 8 ] VAR ::aLgcIndices[ 8 ] ID 180 OF ::oDlg

      REDEFINE CHECKBOX ::aChkIndices[ 9 ] VAR ::aLgcIndices[ 9 ] ID 190 OF ::oDlg

      REDEFINE CHECKBOX ::aChkIndices[ 10 ] VAR ::aLgcIndices[ 10 ] ID 200 OF ::oDlg
      
      REDEFINE APOLOMETER ::aMtrIndices[ 1 ] ;
         VAR      ::aNumIndices[ 1 ] ;
         NOPERCENTAGE ;
         BARCOLOR nRgb( 128, 255, 0 ), nRgb( 255, 255, 255 ) ;
         ID       111 ;
         OF       ::oDlg

      REDEFINE APOLOMETER ::aMtrIndices[ 2 ] ;
         VAR      ::aNumIndices[ 2 ] ;
         NOPERCENTAGE ;
         BARCOLOR nRgb( 128, 255, 0 ), nRgb( 255, 255, 255 ) ;
         ID       121 ;
         OF       ::oDlg

      REDEFINE APOLOMETER ::aMtrIndices[ 3 ] ;
         VAR      ::aNumIndices[ 3 ] ;
         NOPERCENTAGE ;
         BARCOLOR nRgb( 128, 255, 0 ), nRgb( 255, 255, 255 ) ;
         ID       131 ;
         OF       ::oDlg

      REDEFINE APOLOMETER ::aMtrIndices[ 4 ] ;
         VAR      ::aNumIndices[ 4 ] ;
         NOPERCENTAGE ;
         BARCOLOR nRgb( 128, 255, 0 ), nRgb( 255, 255, 255 ) ;
         ID       141 ;
         OF       ::oDlg

      REDEFINE APOLOMETER ::aMtrIndices[ 5 ] ;
         VAR      ::aNumIndices[ 5 ] ;
         NOPERCENTAGE ;
         BARCOLOR nRgb( 128, 255, 0 ), nRgb( 255, 255, 255 ) ;
         ID       151 ;
         OF       ::oDlg
         
      REDEFINE APOLOMETER ::aMtrIndices[ 6 ] ;
         VAR      ::aNumIndices[ 6 ] ;
         NOPERCENTAGE ;
         BARCOLOR nRgb( 128, 255, 0 ), nRgb( 255, 255, 255 ) ;
         ID       161 ;
         OF       ::oDlg   

      REDEFINE APOLOMETER ::aMtrIndices[ 7 ] ;
         VAR      ::aNumIndices[ 7 ] ;
         NOPERCENTAGE ;
         BARCOLOR nRgb( 128, 255, 0 ), nRgb( 255, 255, 255 ) ;
         ID       171 ;
         OF       ::oDlg   

      REDEFINE APOLOMETER ::aMtrIndices[ 8 ] ;
         VAR      ::aNumIndices[ 8 ] ;
         NOPERCENTAGE ;
         BARCOLOR nRgb( 128, 255, 0 ), nRgb( 255, 255, 255 ) ;
         ID       181 ;
         OF       ::oDlg   

      REDEFINE APOLOMETER ::aMtrIndices[ 9 ] ;
         VAR      ::aNumIndices[ 9 ] ;
         NOPERCENTAGE ;
         BARCOLOR nRgb( 128, 255, 0 ), nRgb( 255, 255, 255 ) ;
         ID       191 ;
         OF       ::oDlg   

      REDEFINE APOLOMETER ::aMtrIndices[ 10 ] ;
         VAR      ::aNumIndices[ 10 ] ;
         NOPERCENTAGE ;
         BARCOLOR nRgb( 128, 255, 0 ), nRgb( 255, 255, 255 ) ;
         ID       201 ;
         OF       ::oDlg   

      REDEFINE SAY ::oSayProcess ID 700 OF ::oDlg

      REDEFINE BUTTON ID 500        OF ::oDlg ACTION ( ::SelectChk( .t. ) )
      REDEFINE BUTTON ID 501        OF ::oDlg ACTION ( ::SelectChk( .f. ) )

      REDEFINE BUTTON ID IDOK       OF ::oDlg ACTION ( ::Exportar() )
      REDEFINE BUTTON ID IDCANCEL   OF ::oDlg ACTION ( ::oDlg:end() )

   ::oDlg:AddFastKey( VK_F5, {|| ::Exportar() } )

   ACTIVATE DIALOG ::oDlg CENTER

   oBmp:End()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD SelectChk( lSet ) CLASS ExportOdoo

   local n

   for n := 1 to len( ::aLgcIndices )
      ::aLgcIndices[n] := lSet
      ::aChkIndices[n]:Refresh()
   next

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Exportar() CLASS ExportOdoo

   if Empty( ::cPathFac )
      MsgStop( "Tiene que seleccionar un directorio donde exportar los ficheros." )
      ::oGet:SetFocus()
      return .f.
   end if

   ::oDlg:Disable()

   if ::aLgcIndices[ 1 ]
      ::ExportaClientes()
      ::ExportaBancosClientes()
      ::ExportaDireccionesClientes()
   end if

   if ::aLgcIndices[ 2 ]
      ::ExportaArticulos()
      ::ExportaArticulos2()
      ::ExportaArticulos3()
      ::ExportaArticulos4()
      ::ExportaArticulos5()
      ::ExportaArticulos6()
   end if

   if ::aLgcIndices[ 3 ]
      ::ExportaFamilias()
   end if

   if ::aLgcIndices[ 4 ]
      ::ExportaAtipicas()
      ::ExportaTarifas()
   end if

   if ::aLgcIndices[ 5 ]
      ::ExportaGruposClientes()
   end if

   if ::aLgcIndices[ 6 ]
      ::ExportaFormasPago()
   end if
   
   if ::aLgcIndices[ 7 ]
      ::ExportaAgentes()
   end if

   if ::aLgcIndices[ 8 ]
      ::ExportaPropiedades()
   end if

   if ::aLgcIndices[ 9 ]
      ::ExportaTickets()
   end if

   if ::aLgcIndices[ 10 ]
      ::ExportaKits()
   end if

   ::createLogFile()

   ::oSayProcess:setText( "Exportación realizada con éxito." )

   msgInfo( "Exportación realizada con éxito." )

   ::oDlg:Enable()
   ::oDlg:end()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD ExportaClientes() CLASS ExportOdoo

   local cSqlCli              := "clientes"
   local cSqlPrv              := "proveedores"
   local cMemo                := ""
   local cNameFile
   local nCount

   /*
   Clientes--------------------------------------------------------------------
   */

   ::oSayProcess:setText( "Exportando clientes" )
   
   ClientesModel():getToOdoo( @cSqlCli )

   ( cSqlCli )->( dbGoTop() )

   ::aMtrIndices[ 1 ]:SetTotal( ( cSqlCli )->( OrdKeyCount() ) )

   while !( cSqlCli )->( Eof() )

      if !( cSqlCli )->lInaCli

         nCount                  := OdooIdsModel():getCountCliente( ( cSqlCli )->Cod )

         cMemo                   += "C" + ::cClearStr( ( cSqlCli )->Cod )                                   //Código
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCli )->Titulo )                                      //Nombre
         cMemo                   += ::cConector
         cMemo                   += ::cValidDniCliente( cSqlCli )                                           //NIF
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCli )->Domicilio )                                   //Domicilio
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCli )->Poblacion )                                   //Poblacion
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCli )->CodPostal )                                   //CodPostal
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCli )->Provincia )                                   //Provincia
         cMemo                   += ::cConector
         cMemo                   += StrTran( StrTran( StrTran( StrTran( StrTran( StrTran( AllTrim( ::cClearStr( ( cSqlCli )->Telefono ) ), " ", "" ), ".", "" ), "-", "" ), "_", "" ), "/", "" ), "\", "" )     //Telefono
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCli )->Movil )                                       //Movil
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCli )->cWebInt )                                     //web
         cMemo                   += ::cConector
         cMemo                   += ::cClearEmail( ( cSqlCli )->cMeiInt )                                   //email
         cMemo                   += ::cConector
         cMemo                   += "es_ES"                                                                 //idioma   lang
         cMemo                   += ::cConector
         cMemo                   += if( ( cSqlCli )->lBlqCli, "False", "True" )                             //active
         cMemo                   += ::cConector
         cMemo                   += "True"                                                                  //is_company
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCli )->Titulo )                                      //display_name
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCli )->NbrEst )                                      //company_name
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( PaisModel():getNombre( allTrim( ( cSqlCli )->cCodPai ) ) ) //"España"                                                                //country_id España
         cMemo                   += ::cConector
         //cMemo                   += ::cClearStr( StrTran( ( cSqlCli )->mComent, CRLF , " " ) )              //comment
         //cMemo                   += ::cConector
         cMemo                   += ::cClearStr( GrupoClientesModel():getName( ( cSqlCli )->cCodGrp ) )     //grupo
         cMemo                   += ::cConector
         cMemo                   += "1"                                                                     //customer_rank
         cMemo                   += ::cConector
         cMemo                   += "0"                                                                     //supplier_rank
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( FormasPagoModel():getName( ( cSqlCli )->CodPago ) )        //property_payment_term_id
         cMemo                   += ::cConector
         cMemo                   += ""                                                                      //property_supplier_payment_term_id
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( Upper( AgentesModel():getNombre( ( cSqlCli )->cAgente ) ) )//Agente comercial
         cMemo                   += ::cConector
         cMemo                   += AllTrim( nCount )                                                       //Código Cliente
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( Str( Val( ( cSqlCli )->cCodGrp ) ) )                       //IDgrupo
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( upper( RutasModel():getNombre( ( cSqlCli )->cCodRut ) ) )  //Ruta
         cMemo                   += CRLF

         OdooIdsModel():insertClienteToOdooId( rtrim( ( cSqlCli )->Cod ), AllTrim( nCount ) )

      end if


      ( cSqlCli )->( dbSkip() )

      ::aMtrIndices[ 1 ]:Set( ( cSqlCli )->( OrdKeyNo() ) )

   end while

   ::aMtrIndices[ 1 ]:Set( ( cSqlCli )->( 100 ) )

   /*
   Proveedores-----------------------------------------------------------------
   */

   ::oSayProcess:setText( "Exportando proveedores" )

   ProveedoresModel():getToOdoo( @cSqlPrv )

   ( cSqlPrv )->( dbGoTop() )

   ::aMtrIndices[ 1 ]:SetTotal( ( cSqlPrv )->( OrdKeyCount() ) )

   while !( cSqlPrv )->( Eof() )

      nCount                  := OdooIdsModel():getCountProveedor( ( cSqlPrv )->Cod )

      cMemo                   += "P" + ::cClearStr( ( cSqlPrv )->Cod )                                      //Código
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( ( cSqlPrv )->Titulo )                                         //Nombre
      cMemo                   += ::cConector
      cMemo                   += ::cValidDniProveedor( cSqlPrv )                                            //NIF
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( ( cSqlPrv )->Domicilio )                                      //Domicilio
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( ( cSqlPrv )->Poblacion )                                      //Poblacion
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( ( cSqlPrv )->CodPostal )                                      //CodPostal
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( ( cSqlPrv )->Provincia )                                      //Provincia
      cMemo                   += ::cConector
      cMemo                   += StrTran( StrTran( StrTran( StrTran( StrTran( StrTran( AllTrim( ::cClearStr( ( cSqlPrv )->Telefono ) ), " ", "" ), ".", "" ), "-", "" ), "_", "" ), "/", "" ), "\", "" )        //Telefono
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( ( cSqlPrv )->Movil )                                          //Movil
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( ( cSqlPrv )->cWebInt )                                        //web
      cMemo                   += ::cConector
      cMemo                   += ::cClearEmail( ( cSqlPrv )->cMeiInt )                                      //email
      cMemo                   += ::cConector
      cMemo                   += "es_ES"                                                                    //idioma
      cMemo                   += ::cConector
      cMemo                   += "True"                                                                     //activo
      cMemo                   += ::cConector
      cMemo                   += "True"                                                                     //is_company
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( ( cSqlPrv )->Titulo )                                         //display_name
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( ( cSqlPrv )->cNbrEst )                                        //company_name
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( PaisModel():getNombre( allTrim( ( cSqlPrv )->cCodPai ) ) )    //"España"                                                                   //country_id España
      cMemo                   += ::cConector
      //cMemo                   += ::cClearStr( StrTran( ( cSqlPrv )->mComent, CRLF, " " ) )                  //comment
      //cMemo                   += ::cConector
      cMemo                   += ""                                                                         //grupo
      cMemo                   += ::cConector
      cMemo                   += "0"                                                                        //customer_rank
      cMemo                   += ::cConector
      cMemo                   += "1"                                                                        //supplier_rank
      cMemo                   += ::cConector
      cMemo                   += ""                                                                         //property_payment_term_id                                                                       
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( FormasPagoModel():getName( ( cSqlPrv )->FPAGO ) )             //property_supplier_payment_term_id                                                                       
      cMemo                   += ::cConector
      cMemo                   += ""                                                                         //agente comercial
      cMemo                   += ::cConector
      cMemo                   += AllTrim( nCount )                                                          //código Proveedor
      cMemo                   += ::cConector
      cMemo                   += ""                                                                         //IDgrupo
      cMemo                   += ::cConector
      cMemo                   += ""                                                                         //Ruta
      cMemo                   += CRLF

      OdooIdsModel():insertProveedorToOdooId( rtrim( ( cSqlPrv )->Cod ), AllTrim( nCount ) )
      
      ( cSqlPrv )->( dbSkip() )

      ::aMtrIndices[ 1 ]:Set( ( cSqlPrv )->( OrdKeyNo() ) )

   end while

   ::aMtrIndices[ 1 ]:Set( ( cSqlPrv )->( 100 ) )

   ::createFile( cMemo, "Respartner" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaBancosClientes() CLASS ExportOdoo

   local cSqlCli              := "clientes"
   local cSqlPrv              := "proveedores"
   local cSqlCliBnc           := "clientes_bnc"
   local cSqlPrvBnc           := "proveedores_bnc"
   local cMemo                := ""
   local cNameFile
   local nCount

   /*
   Clientes--------------------------------------------------------------------
   */
   
   ::oSayProcess:setText( "Exportando bancos de clientes" )

   ClientesModel():getToOdoo( @cSqlCli )

   ( cSqlCli )->( dbGoTop() )

   ::aMtrIndices[ 1 ]:SetTotal( ( cSqlCli )->( OrdKeyCount() ) )

   while !( cSqlCli )->( Eof() )

      nCount                  := OdooIdsModel():getCountCliente( ( cSqlCli )->Cod )

      ClientesBancosModel():getToOdoo( @cSqlCliBnc, ( cSqlCli )->Cod )

      ( cSqlCliBnc )->( dbGoTop() )

      while !( cSqlCliBnc )->( Eof() )

         if !Empty( ( cSqlCliBnc )->cPaisIBAN ) .and.;
            !Empty( ( cSqlCliBnc )->cCtrlIBAN ) .and.;
            !Empty( ( cSqlCliBnc )->cEntBnc ) .and.;
            !Empty( ( cSqlCliBnc )->cSucBnc ) .and.;
            !Empty( ( cSqlCliBnc )->cDigBnc ) .and.;
            !Empty( ( cSqlCliBnc )->cCtaBnc ) .and.;
            Empty( ( cSqlCliBnc )->cCodBnc )

            cMemo                   += ::bankCount( ( cSqlCliBnc )->cPaisIBAN, ( cSqlCliBnc )->cCtrlIBAN, ( cSqlCliBnc )->cEntBnc, ( cSqlCliBnc )->cSucBnc, ( cSqlCliBnc )->cDigBnc, ( cSqlCliBnc )->cCtaBnc )                 //acc_number
            cMemo                   += ::cConector
            cMemo                   += ::sanitizedBankCount( ( cSqlCliBnc )->cPaisIBAN, ( cSqlCliBnc )->cCtrlIBAN, ( cSqlCliBnc )->cEntBnc, ( cSqlCliBnc )->cSucBnc, ( cSqlCliBnc )->cDigBnc, ( cSqlCliBnc )->cCtaBnc )        //sanitized_acc_number
            cMemo                   += ::cConector
            cMemo                   += ::cClearStr( ( cSqlCli )->Cod )           //AllTrim( nCount )                         //ref
            cMemo                   += ::cConector
            cMemo                   += Space(1)                                  //id_bank
            cMemo                   += ::cConector
            cMemo                   += ::cClearStr( ( cSqlCliBnc )->cCodBnc )    //name
            cMemo                   += ::cConector
            cMemo                   += strtran( ::cClearStr( ( cSqlCli )->Titulo ), ",", "." )  // Name cliente
            cMemo                   += CRLF

         end if

         ( cSqlCliBnc )->( dbSkip() )

      end while
      
      ( cSqlCli )->( dbSkip() )

      ::aMtrIndices[ 1 ]:Set( ( cSqlCli )->( OrdKeyNo() ) )

   end while

   ::aMtrIndices[ 1 ]:Set( ( cSqlCli )->( 100 ) )

   /*
   Proveedores-----------------------------------------------------------------
   */

   ::oSayProcess:setText( "Exportando bancos de proveedores" )

   ProveedoresModel():getToOdoo( @cSqlPrv )

   ( cSqlPrv )->( dbGoTop() )

   ::aMtrIndices[ 1 ]:SetTotal( ( cSqlPrv )->( OrdKeyCount() ) )

   while !( cSqlPrv )->( Eof() )

      nCount                     := OdooIdsModel():getCountProveedor( ( cSqlPrv )->Cod )

      ProveedoresBancosModel():getToOdoo( @cSqlPrvBnc, ( cSqlPrv )->Cod )

      ( cSqlPrvBnc )->( dbGoTop() )

      while !( cSqlPrvBnc )->( Eof() )

         if !Empty( ( cSqlPrvBnc )->cPaisIBAN ) .and.;
            !Empty( ( cSqlPrvBnc )->cCtrlIBAN ) .and.;
            !Empty( ( cSqlPrvBnc )->cEntBnc ) .and.;
            !Empty( ( cSqlPrvBnc )->cSucBnc ) .and.;
            !Empty( ( cSqlPrvBnc )->cDigBnc ) .and.;
            !Empty( ( cSqlPrvBnc )->cCtaBnc ) .and.;
            Empty( ( cSqlPrvBnc )->cCodBnc )

            cMemo                   += ::bankCount( ( cSqlPrvBnc )->cPaisIBAN, ( cSqlPrvBnc )->cCtrlIBAN, ( cSqlPrvBnc )->cEntBnc, ( cSqlPrvBnc )->cSucBnc, ( cSqlPrvBnc )->cDigBnc, ( cSqlPrvBnc )->cCtaBnc )                 //acc_number
            cMemo                   += ::cConector
            cMemo                   += ::sanitizedBankCount( ( cSqlPrvBnc )->cPaisIBAN, ( cSqlPrvBnc )->cCtrlIBAN, ( cSqlPrvBnc )->cEntBnc, ( cSqlPrvBnc )->cSucBnc, ( cSqlPrvBnc )->cDigBnc, ( cSqlPrvBnc )->cCtaBnc )        //sanitized_acc_number
            cMemo                   += ::cConector
            cMemo                   += "P" + ::cClearStr( ( cSqlPrv )->Cod )     //AllTrim( nCount )                         //ref
            cMemo                   += ::cConector
            cMemo                   += Space(1)                                  //id_bank
            cMemo                   += ::cConector
            cMemo                   += ::cClearStr( ( cSqlPrvBnc )->cCodBnc )    //name
            cMemo                   += ::cConector
            cMemo                   += strtran( ::cClearStr( ( cSqlPrv )->Titulo ), ",", "." )  // Name cliente
            cMemo                   += CRLF

         end if

         ( cSqlPrvBnc )->( dbSkip() )

      end while
      
      ( cSqlPrv )->( dbSkip() )

      ::aMtrIndices[ 1 ]:Set( ( cSqlPrv )->( OrdKeyNo() ) )

   end while

   ::aMtrIndices[ 1 ]:Set( 100 )

   ::createFile( cMemo, "Respartner_bank" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaDireccionesClientes()

   local cSqlCli              := "clientes"
   local cSqlCliDir           := "clientes_dir"
   local cMemo                := ""
   local cNameFile
   local nCount

   /*
   Clientes--------------------------------------------------------------------
   */
   
   ::oSayProcess:setText( "Exportando direcciones de clientes" )

   ClientesModel():getToOdoo( @cSqlCli )

   ( cSqlCli )->( dbGoTop() )

   ::aMtrIndices[ 1 ]:SetTotal( ( cSqlCli )->( OrdKeyCount() ) )

   while !( cSqlCli )->( Eof() )

      nCount                  := OdooIdsModel():getCountCliente( ( cSqlCli )->Cod )

      ClientesDireccionesModel():getToOdoo( @cSqlCliDir, ( cSqlCli )->Cod )

      ( cSqlCliDir )->( dbGoTop() )

      while !( cSqlCliDir )->( Eof() )

         cMemo                   += AllTrim( nCount )
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCliDir )->cNomObr )
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCliDir )->cDirObr )
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCliDir )->cPobObr )
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCliDir )->cPrvObr )
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCliDir )->cPosObr )
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCliDir )->cTelObr )
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCliDir )->cFaxObr )
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCliDir )->cCntObr )
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCliDir )->cMovObr )
         cMemo                   += ::cConector
         cMemo                   += ::cClearStr( ( cSqlCliDir )->Nif )
         cMemo                   += CRLF

         ( cSqlCliDir )->( dbSkip() )

      end while
      
      ( cSqlCli )->( dbSkip() )

      ::aMtrIndices[ 1 ]:Set( ( cSqlCli )->( OrdKeyNo() ) )

   end while

   ::aMtrIndices[ 1 ]:Set( 100 )

   ::createFile( cMemo, "Respartner_dir" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaGruposClientes()

   local cSql                 := "grupo_cliente"
   local cMemo                := ""
   local cNameFile
   local aClientes            := {}

   GrupoClientesModel():getToOdoo( @cSql )

   ::oSayProcess:setText( "Exportando grupos de clientes" )

   ( cSql )->( dbGoTop() )

   ::aMtrIndices[ 6 ]:SetTotal( ( cSql )->( OrdKeyCount() ) )

   while !( cSql )->( Eof() )

      cMemo                   += AllTrim( ( cSql )->cCodGrp )                          //código
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( capitalize( ( cSql )->cNomGrp ) )            //nombre
      cMemo                   += CRLF

      ( cSql )->( dbSkip() )

      ::aMtrIndices[ 6 ]:Set( ( cSql )->( OrdKeyNo() ) )

   end while

   ::aMtrIndices[ 6 ]:Set( ( cSql )->( 100 ) )

   ::createFile( cMemo, "Respartner_group" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaFormasPago() CLASS ExportOdoo

   local cSql                 := "Formas_pago"
   local cMemo                := ""
   local cNameFile

   FormasPagoModel():getToOdoo( @cSql )

   ::oSayProcess:setText( "Exportando formas de pago" )

   ( cSql )->( dbGoTop() )

   ::aMtrIndices[ 7 ]:SetTotal( ( cSql )->( OrdKeyCount() ) )

   while !( cSql )->( Eof() )

      cMemo                   += AllTrim( ( cSql )->cCodPago )                          //código
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( capitalize( ( cSql )->cDesPago ) )            //nombre
      cMemo                   += CRLF

      ( cSql )->( dbSkip() )

      ::aMtrIndices[ 7 ]:Set( ( cSql )->( OrdKeyNo() ) )

   end while

   ::aMtrIndices[ 7 ]:Set( ( cSql )->( 100 ) )

   ::createFile( cMemo, "property_payment" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaAgentes() CLASS ExportOdoo

   local cSql                 := "Agentes"
   local cMemo                := ""
   local cNameFile
   local nCount

   AgentesModel():getToOdoo( @cSql )

   ::oSayProcess:setText( "Exportando Agentes comerciales" )

   ( cSql )->( dbGoTop() )

   ::aMtrIndices[ 7 ]:SetTotal( ( cSql )->( OrdKeyCount() ) )

   while !( cSql )->( Eof() )

      nCount                  := OdooIdsModel():getCountAgente( ( cSql )->cCodAge )

      cMemo                   += AllTrim( nCount )                                                                                           //código
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( Upper( ( cSql )->cNbrAge ) ) + space(1) + ::cClearStr( Upper( ( cSql )->cApeAge ) )            //nombre
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( capitalize( ( cSql )->cDniNif ) )                                                              //Dni
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( capitalize( ( cSql )->cDirAge ) )                                                              //Domicilio
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( capitalize( ( cSql )->cPobAge ) )                                                              //Poblacion
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( capitalize( ( cSql )->cProv ) )                                                                //Provincia
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( capitalize( ( cSql )->cPtlAge ) )                                                              //Código postal
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( capitalize( ( cSql )->cTfoAge ) )                                                              //Telefono
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( capitalize( ( cSql )->cFaxAge ) )                                                              //Fax
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( capitalize( ( cSql )->cMovAge ) )                                                              //Movil
      cMemo                   += ::cConector
      cMemo                   += ::cClearStr( capitalize( ( cSql )->cMailAge ) )                                                             //Email
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( ( cSql )->nCom1 )                                                                          //Comisión
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ( cSql )->cCodAge )                                                                                //código
      cMemo                   += CRLF

      OdooIdsModel():insertAgenteToOdooId( rtrim( ( cSql )->cCodAge ), AllTrim( nCount ) )

      ( cSql )->( dbSkip() )

      ::aMtrIndices[ 7 ]:Set( ( cSql )->( OrdKeyNo() ) )

   end while

   ::aMtrIndices[ 7 ]:Set( ( cSql )->( 100 ) )

   ::createFile( cMemo, "cAgentes" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaArticulos() CLASS ExportOdoo

   local cSql                 := "articulos"
   local cMemo                := ""
   local cNameFile
   local nTipoIva             := 0

   ::oSayProcess:setText( "Exportando artículos" )

   ArticulosModel():getToOdoo( @cSql )

   ( cSql )->( dbGoTop() )

   ::aMtrIndices[ 2 ]:SetTotal( ( cSql )->( OrdKeyCount() ) )

   while !( cSql )->( Eof() )

      nTipoIva                := nIva( , ( cSql )->TIPOIVA )

      cMemo                   += AllTrim( strtran( ( cSql )->Codigo, ",", "." ) )                                 //default_code
      cMemo                   += ::cConector
      cMemo                   += "True"                                                      //active
      cMemo                   += ::cConector
      cMemo                   += AllTrim( strtran( capitalize( ( cSql )->Nombre ), ",", "." ) )     //name
      cMemo                   += ::cConector
      cMemo                   += "False"                                                     //rental
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( ( cSql )->pVenta1 )                        //list_price
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( ( cSql )->pCosto )                         //standart_price
      cMemo                   += ::cConector

      do case 
         case nTipoIva == 21
            cMemo             += "IVA 21% (Bienes)"                                          //taxes_id
            cMemo             += ::cConector
            cMemo             += "21% IVA (bienes corrientes)"                               //supplier_tax_id

         case nTipoIva == 10
            cMemo             += "IVA 10% (Bienes)"                                          //taxes_id
            cMemo             += ::cConector
            cMemo             += "10% IVA soportado (bienes corrientes)"                     //supplier_tax_id

         case nTipoIva == 4
            cMemo             += "IVA 4% (Bienes)"                                           //taxes_id
            cMemo             += ::cConector
            cMemo             += "4% IVA soportado (bienes corrientes)"                      //supplier_tax_id

         otherwise
            cMemo             += "IVA Exento Repercutido Sujeto"                             //taxes_id
            cMemo             += ::cConector
            cMemo             += "IVA Soportado exento (operaciones corrientes)"             //supplier_tax_id

      end case

      /*do case 
         case nTipoIva == 3
            cMemo             += "IGIC 3%"                                                   //taxes_id
            cMemo             += ::cConector
            cMemo             += "IGIC 3%"                                                   //supplier_tax_id

         case nTipoIva == 5
            cMemo             += "IGIC 5%"                                                   //taxes_id
            cMemo             += ::cConector
            cMemo             += "IGIC 5%"                                                   //supplier_tax_id

         case nTipoIva == 7
            cMemo             += "IGIC 7%"                                                   //taxes_id
            cMemo             += ::cConector
            cMemo             += "IGIC 7%"                                                   //supplier_tax_id

         case nTipoIva == 9.5
            cMemo             += "IGIC 9,5%"                                                   //taxes_id
            cMemo             += ::cConector
            cMemo             += "IGIC 9,5%"                                                   //supplier_tax_id

         case nTipoIva == 15
            cMemo             += "IGIC 15%"                                                   //taxes_id
            cMemo             += ::cConector
            cMemo             += "IGIC 15%"                                                   //supplier_tax_id

         case nTipoIva == 20
            cMemo             += "IGIC 20%"                                                   //taxes_id
            cMemo             += ::cConector
            cMemo             += "IGIC 20%"                                                   //supplier_tax_id

         case nTipoIva == 0
            cMemo             += "IGIC 0%"                                                   //taxes_id
            cMemo             += ::cConector
            cMemo             += "IGIC 0%"                                                   //supplier_tax_id

      end case*/

      cMemo                   += ::cConector
      cMemo                   += capitalize( AllTrim( retFamilia( ( cSql )->Familia ) ) )    //categ_id
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ArticulosCodigosBarraModel():getDefaultCodigo( ( cSql )->Codigo ) )                   //Codigo Barras
      cMemo                   += CRLF

      ( cSql )->( dbSkip() )

      ::aMtrIndices[ 2 ]:Set( ( cSql )->( OrdKeyNo() ) )

   end while

   ::aMtrIndices[ 2 ]:Set( ( cSql )->( 100 ) )

   ::createFile( cMemo, "Product" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaArticulos2() CLASS ExportOdoo

   local cSql                 := "articulos"
   local cMemo                := ""
   local cNameFile

   ::oSayProcess:setText( "Exportando artículos" )

   ArticulosModel():getToOdoo( @cSql )

   ( cSql )->( dbGoTop() )

   ::aMtrIndices[ 2 ]:SetTotal( ( cSql )->( OrdKeyCount() ) )

   while !( cSql )->( Eof() )

      cMemo                   += "AAAAAA"
      cMemo                   += ::cConector
      cMemo                   += AllTrim( strtran( ( cSql )->Codigo, ",", "." ) )            //default_code
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( ( cSql )->pVenta2 )                        //list_price
      cMemo                   += CRLF

      ( cSql )->( dbSkip() )

      ::aMtrIndices[ 2 ]:Set( ( cSql )->( OrdKeyNo() ) )

   end while

   ::aMtrIndices[ 2 ]:Set( ( cSql )->( 100 ) )

   ::createFile( cMemo, "Product2" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaArticulos3() CLASS ExportOdoo

   local cSql                 := "articulos"
   local cMemo                := ""
   local cNameFile

   ::oSayProcess:setText( "Exportando artículos" )

   ArticulosModel():getToOdoo( @cSql )

   ( cSql )->( dbGoTop() )

   ::aMtrIndices[ 2 ]:SetTotal( ( cSql )->( OrdKeyCount() ) )

   while !( cSql )->( Eof() )

      cMemo                   += "AAAAAA"
      cMemo                   += ::cConector
      cMemo                   += AllTrim( strtran( ( cSql )->Codigo, ",", "." ) )            //default_code
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( ( cSql )->pVenta3 )                        //list_price
      cMemo                   += CRLF

      ( cSql )->( dbSkip() )

      ::aMtrIndices[ 2 ]:Set( ( cSql )->( OrdKeyNo() ) )

   end while

   ::aMtrIndices[ 2 ]:Set( ( cSql )->( 100 ) )

   ::createFile( cMemo, "Product3" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaArticulos4() CLASS ExportOdoo

   local cSql                 := "articulos"
   local cMemo                := ""
   local cNameFile

   ::oSayProcess:setText( "Exportando artículos" )

   ArticulosModel():getToOdoo( @cSql )

   ( cSql )->( dbGoTop() )

   ::aMtrIndices[ 2 ]:SetTotal( ( cSql )->( OrdKeyCount() ) )

   while !( cSql )->( Eof() )

      cMemo                   += "AAAAAA"
      cMemo                   += ::cConector
      cMemo                   += AllTrim( strtran( ( cSql )->Codigo, ",", "." ) )            //default_code
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( ( cSql )->pVenta4 )                        //list_price
      cMemo                   += CRLF

      ( cSql )->( dbSkip() )

      ::aMtrIndices[ 2 ]:Set( ( cSql )->( OrdKeyNo() ) )

   end while

   ::aMtrIndices[ 2 ]:Set( ( cSql )->( 100 ) )

   ::createFile( cMemo, "Product4" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaArticulos5() CLASS ExportOdoo

   local cSql                 := "articulos"
   local cMemo                := ""
   local cNameFile

   ::oSayProcess:setText( "Exportando artículos" )

   ArticulosModel():getToOdoo( @cSql )

   ( cSql )->( dbGoTop() )

   ::aMtrIndices[ 2 ]:SetTotal( ( cSql )->( OrdKeyCount() ) )

   while !( cSql )->( Eof() )

      cMemo                   += "AAAAAA"
      cMemo                   += ::cConector
      cMemo                   += AllTrim( strtran( ( cSql )->Codigo, ",", "." ) )            //default_code
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( ( cSql )->pVenta5 )                        //list_price
      cMemo                   += CRLF

      ( cSql )->( dbSkip() )

      ::aMtrIndices[ 2 ]:Set( ( cSql )->( OrdKeyNo() ) )

   end while

   ::aMtrIndices[ 2 ]:Set( ( cSql )->( 100 ) )

   ::createFile( cMemo, "Product5" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaArticulos6() CLASS ExportOdoo

   local cSql                 := "articulos"
   local cMemo                := ""
   local cNameFile

   ::oSayProcess:setText( "Exportando artículos" )

   ArticulosModel():getToOdoo( @cSql )

   ( cSql )->( dbGoTop() )

   ::aMtrIndices[ 2 ]:SetTotal( ( cSql )->( OrdKeyCount() ) )

   while !( cSql )->( Eof() )

      cMemo                   += "AAAAAA"
      cMemo                   += ::cConector
      cMemo                   += AllTrim( strtran( ( cSql )->Codigo, ",", "." ) )            //default_code
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( ( cSql )->pVenta6 )                        //list_price
      cMemo                   += CRLF

      ( cSql )->( dbSkip() )

      ::aMtrIndices[ 2 ]:Set( ( cSql )->( OrdKeyNo() ) )

   end while

   ::aMtrIndices[ 2 ]:Set( ( cSql )->( 100 ) )

   ::createFile( cMemo, "Product6" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaFamilias()

   local cSql                 := "familias"
   local cMemo                := ""
   local cNameFile
   local aClientes            := {}

   FamiliasModel():getToOdoo( @cSql )

   ::oSayProcess:setText( "Exportando familias" )

   ( cSql )->( dbGoTop() )

   ::aMtrIndices[ 3 ]:SetTotal( ( cSql )->( OrdKeyCount() ) )

   while !( cSql )->( Eof() )

      cMemo                   += ::cClearStr( AllTrim( capitalize( ( cSql )->cNomFam ) ) )            //name
      cMemo                   += ::cConector
      cMemo                   += "All/" + ::cClearStr( AllTrim( capitalize( ( cSql )->cNomFam ) ) )   //complete_name
      cMemo                   += ::cConector
      cMemo                   += "1"                                                                  //parent_id
      cMemo                   += ::cConector
      cMemo                   += "average"                                                            //property_cost_method
      cMemo                   += ::cConector
      cMemo                   += "real_time"                                                          //property_valuation
      cMemo                   += CRLF

      ( cSql )->( dbSkip() )

      ::aMtrIndices[ 3 ]:Set( ( cSql )->( OrdKeyNo() ) )

   end while

   ::aMtrIndices[ 3 ]:Set( ( cSql )->( 100 ) )

   ::createFile( cMemo, "Category" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaAtipicas()

   local cSql                 := "atipicas"
   local cMemo                := ""
   local cNameFile
   local cCodCli              := ""

   AtipicasModel():getToOdoo( @cSql )

   ::oSayProcess:setText( "Exportando lineas atipicas" )

   ( cSql )->( dbGoTop() )

   ::aMtrIndices[ 4 ]:SetTotal( ( cSql )->( OrdKeyCount() ) )

   while !( cSql )->( Eof() )

      cCodCli                    := OdooIdsModel():getCountCliente( ( cSql )->cCodCli, .f. )

      if !Empty( ( cSql )->cCodArt ) .and. !Empty( cCodCli )

         ::oSayProcess:setText( AllTrim( cCodCli ) + "-" + AllTrim( ( cSql )->cCodArt ) +  "-" + retArticulo( ( cSql )->cCodArt ) )

         cMemo                   += "C" + AllTrim( ( cSql )->cCodCli )                  //pricelist_id
         cMemo                   += ::cConector
         cMemo                   += AllTrim( ( cSql )->cCodArt )              //product_tmpl_id
         cMemo                   += ::cConector
         cMemo                   += ::formatNumeric( ( cSql )->nPrcArt )      //fixed_price
         cMemo                   += ::cConector
         cMemo                   += ::formatNumeric( ( cSql )->nDtoArt )      //Descuento
         cMemo                   += CRLF

      end if

      ( cSql )->( dbSkip() )

      ::aMtrIndices[ 4 ]:Set( ( cSql )->( OrdKeyNo() ) ) 

   end while

   ::aMtrIndices[ 4 ]:Set( ( cSql )->( 100 ) )

   ::createFile( cMemo, "Prices_lines" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaTarifas()

   local cSql                 := "lineastarifas"
   local cMemo                := ""
   local cNameFile
   local cCodCli              := ""

   TarifasLineasModel():getToOdoo( @cSql )

   ::oSayProcess:setText( "Exportando lineas Tarifas" )

   ( cSql )->( dbGoTop() )

   ::aMtrIndices[ 4 ]:SetTotal( ( cSql )->( OrdKeyCount() ) )

   while !( cSql )->( Eof() )

      if !Empty( ( cSql )->cCodArt ) .and. !Empty( ( cSql )->cCodTar )

         ::oSayProcess:setText( AllTrim( ( cSql )->cCodTar ) + "-" + AllTrim( ( cSql )->cCodArt ) +  "-" + AllTrim( ( cSql )->cNomArt ) )

         cMemo                   += AllTrim( ( cSql )->cCodTar )
         cMemo                   += ::cConector
         cMemo                   += AllTrim( ( cSql )->cCodArt )
         cMemo                   += ::cConector
         cMemo                   += ::formatNumeric( ( cSql )->nPrcTar1 )
         cMemo                   += ::cConector
         cMemo                   += ::formatNumeric( ( cSql )->nDtoArt )
         cMemo                   += CRLF

      end if

      ( cSql )->( dbSkip() )

      ::aMtrIndices[ 4 ]:Set( ( cSql )->( OrdKeyNo() ) ) 

   end while

   ::aMtrIndices[ 4 ]:Set( ( cSql )->( 100 ) )

   ::createFile( cMemo, "tarifas_lineas" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaKits()

   local cSql                 := "lineaskits"
   local cMemo                := ""
   local cNameFile
   local cCodCli              := ""

   EscandallosArticuloModel():getToOdoo( @cSql )

   ::oSayProcess:setText( "Exportando lineas Kits" )

   ( cSql )->( dbGoTop() )

   ::aMtrIndices[ 10 ]:SetTotal( ( cSql )->( OrdKeyCount() ) )

   while !( cSql )->( Eof() )

      ::oSayProcess:setText( AllTrim( ( cSql )->cCodKit ) + "-" + AllTrim( ( cSql )->cRefKit ) )

      cMemo                   += AllTrim( ( cSql )->cCodKit )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ( cSql )->cRefKit )
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( ( cSql )->nUndKit )
      cMemo                   += CRLF

      ( cSql )->( dbSkip() )

      ::aMtrIndices[ 10 ]:Set( ( cSql )->( OrdKeyNo() ) ) 

   end while

   ::aMtrIndices[ 10 ]:Set( ( cSql )->( 100 ) )

   ::createFile( cMemo, "kits" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaTickets

   local cSql                 := "tickets"
   local cMemo                := ""
   local cNameFile
   local cCodCli              := ""

   /*Lineas de tickets*/

   TicketsClientesLineasModel():getToOdoo( @cSql )

   ::oSayProcess:setText( "Exportando lineas de tickets" )

   ( cSql )->( dbGoTop() )

   ::aMtrIndices[ 9 ]:SetTotal( ( cSql )->( OrdKeyCount() ) )

   while !( cSql )->( Eof() )

      ::oSayProcess:setText( AllTrim( ( cSql )->cSerTil ) + "/" + AllTrim( ( cSql )->cNumTil ) )

      cMemo                   += AllTrim( ( cSql )->cSerTil )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ( cSql )->cNumTil )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ( cSql )->cSufTil )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ( cSql )->paruuid )
      cMemo                   += ::cConector
      cMemo                   += "C" + ::cClearStr( TicketsClientesModel():getField( ( cSql )->cSerTil, ( cSql )->cNumTil, ( cSql )->cSufTil, "cCliTik" ) )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( dtoc( TicketsClientesModel():getField( ( cSql )->cSerTil, ( cSql )->cNumTil, ( cSql )->cSufTil, "dFecTik" ) ) )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( TicketsClientesModel():getField( ( cSql )->cSerTil, ( cSql )->cNumTil, ( cSql )->cSufTil, "cTurTik" ) )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( TicketsClientesModel():getField( ( cSql )->cSerTil, ( cSql )->cNumTil, ( cSql )->cSufTil, "cAlmTik" ) )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( TicketsClientesModel():getField( ( cSql )->cSerTil, ( cSql )->cNumTil, ( cSql )->cSufTil, "cCodAge" ) )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( TicketsClientesModel():getField( ( cSql )->cSerTil, ( cSql )->cNumTil, ( cSql )->cSufTil, "cCodRut" ) )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( TicketsClientesModel():getField( ( cSql )->cSerTil, ( cSql )->cNumTil, ( cSql )->cSufTil, "cCodObr" ) )
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( TicketsClientesModel():getField( ( cSql )->cSerTil, ( cSql )->cNumTil, ( cSql )->cSufTil, "nTotNet" ) )
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( TicketsClientesModel():getField( ( cSql )->cSerTil, ( cSql )->cNumTil, ( cSql )->cSufTil, "nTotIva" ) )
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( TicketsClientesModel():getField( ( cSql )->cSerTil, ( cSql )->cNumTil, ( cSql )->cSufTil, "nTotTik" ) )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ( cSql )->uuid )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ( cSql )->cCbaTil )
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( ( cSql )->nPvpTil )
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( ( cSql )->nUntTil )
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( ( cSql )->nIvaTil )
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( ( cSql )->nDtoLin )
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( ( cSql )->nDtoDiv )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ( cSql )->cAlmLin )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ( cSql )->cLote )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ( cSql )->cCodPr1 )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ( cSql )->cCodPr2 )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ( cSql )->cValPr1 )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ( cSql )->cValPr2 )
      cMemo                   += ::cConector
      cMemo                   += CRLF

      ( cSql )->( dbSkip() )

      ::aMtrIndices[ 9 ]:Set( ( cSql )->( OrdKeyNo() ) ) 

   end while

   ::aMtrIndices[ 9 ]:Set( ( cSql )->( 100 ) )

   ::createFile( cMemo, "tickets" ) 

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD ExportaPropiedades() CLASS ExportOdoo

   local cSql                 := "propiedades"
   local cMemo                := ""
   local cNameFile
   local cCodCli              := ""

   /*cabeceras de propiedades*/

   PropiedadesModel():getToOdoo( @cSql )

   ::oSayProcess:setText( "Exportando propiedades" )

   ( cSql )->( dbGoTop() )

   ::aMtrIndices[ 8 ]:SetTotal( ( cSql )->( OrdKeyCount() ) )

   while !( cSql )->( Eof() )

      ::oSayProcess:setText( AllTrim( ( cSql )->cDesPro ) )

      cMemo                   += AllTrim( ( cSql )->cCodPro )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ( cSql )->cDesPro )
      cMemo                   += CRLF

      ( cSql )->( dbSkip() )

      ::aMtrIndices[ 8 ]:Set( ( cSql )->( OrdKeyNo() ) ) 

   end while

   ::aMtrIndices[ 8 ]:Set( ( cSql )->( 100 ) )

   ::createFile( cMemo, "propiedades" )   

   /*Lineas de tickets*/

   cSql                 := "propiedades_lineas"

   PropiedadesLineasModel():getToOdoo( @cSql )

   ::oSayProcess:setText( "Exportando lineas de propiedades" )

   ( cSql )->( dbGoTop() )

   ::aMtrIndices[ 8 ]:SetTotal( ( cSql )->( OrdKeyCount() ) )

   while !( cSql )->( Eof() )

      ::oSayProcess:setText( AllTrim( ( cSql )->cDesTbl ) )

      cMemo                   += AllTrim( ( cSql )->cCodPro )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ( cSql )->cCodTbl )
      cMemo                   += ::cConector
      cMemo                   += AllTrim( ( cSql )->cDesTbl )
      cMemo                   += ::cConector
      cMemo                   += ::formatNumeric( ( cSql )->nColor )
      cMemo                   += CRLF

      ( cSql )->( dbSkip() )

      ::aMtrIndices[ 8 ]:Set( ( cSql )->( OrdKeyNo() ) ) 

   end while

   ::aMtrIndices[ 8 ]:Set( ( cSql )->( 100 ) )

   ::createFile( cMemo, "propiedades_lineas" ) 

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD createLogFile() CLASS ExportOdoo

   local nHand
   local cFile      := ::cNameLogFile()

   fErase( cFile )
   nHand       := fCreate( cFile )
   fWrite( nHand, ::cIncidencia )
   fClose( nHand )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD cNameLogFile() CLASS ExportOdoo

   local cPath

   cPath             := StrTran( AllTrim( ::cPathFac ), "/", "\" )  

   if right( cPath, 1 ) != "\"
      cPath          += "\"
   end if

   cPath             += "incidencias.log"

Return ( cPath )

//---------------------------------------------------------------------------//

METHOD createFile( cMemo, cName ) CLASS ExportOdoo

   local nHand
   local cFile      := ::cNameFile( cName )

   cMemo            := hb_strtoutf8( cMemo )

   fErase( cFile )
   nHand       := fCreate( cFile )
   fWrite( nHand, cMemo )
   fClose( nHand )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD cNameFile( cName ) CLASS ExportOdoo

   local cPath

   cPath             := StrTran( AllTrim( ::cPathFac ), "/", "\" )  

   if right( cPath, 1 ) != "\"
      cPath          += "\"
   end if

   cPath             += cName
   cPath             += ".csv"

Return ( cPath )

//---------------------------------------------------------------------------//

METHOD cClearEmail( cEmail ) CLASS ExportOdoo

   local nPos

   cEmail      := rTrim( cEmail )

   nPos        := at( ";", cEmail )

   if nPos != 0
      cEmail   := SubStr( cEmail, 1, nPos - 1 )
   end if

   nPos        := at( ",", cEmail )

   if nPos != 0
      cEmail   := SubStr( cEmail, 1, nPos - 1 )
   end if

Return ( cEmail )

//---------------------------------------------------------------------------//

METHOD cValidDni( cAlias, cTitle ) CLASS ExportOdoo

   local cDni           := ( cAlias )->Nif

   DEFAULT cTitle       := "cliente"

   if Empty( cDni )
      ::cIncidencia     += "Cif del " + cTitle + Space( 1 ) + AllTrim( ( cAlias )->Cod ) + ":" + AllTrim( ( cAlias )->Titulo ) + " vacío." + CRLF
      Return ( "" )
   end if

   cDni                 := AllTrim( cDni )

   cDni                 := StrTran( cDni, ".", "" )

   cDni                 := StrTran( cDni, " ", "" )

   cDni                 := StrTran( cDni, "-", "" )

   cDni                 := StrTran( cDni, "/", "" )

   cDni                 := StrTran( cDni, "\", "" )

   if len( cDni ) < 9
      ::cIncidencia     += "Cif del " + cTitle + Space( 1 ) + AllTrim( ( cAlias )->Cod ) + ":" + AllTrim( ( cAlias )->Titulo ) + " no válido." + CRLF
      Return ( "" )
   end if

   if !Empty( cDni ) .and. AllTrim( ( cAlias )->cCodPai ) == "ESP"
      cDni                 := "ES" + cDni
   end if

   if AScan( ::aDni, { | aDni | aDni == cDni } ) == 0
      aAdd( ::aDni, cDni )
   else
      cDni := ""
   end if

Return ( cDni )

//---------------------------------------------------------------------------//

METHOD bankCount( cPaisIBAN, cCtrlIBAN, cEntBnc, cSucBnc, cDigBnc, cCtaBnc )

   local cCuentaBanco   := ""

   cCuentaBanco         += AllTrim( cPaisIBAN )
   cCuentaBanco         += AllTrim( cCtrlIBAN )
   cCuentaBanco         += Space(1)
   cCuentaBanco         += AllTrim( cEntBnc )
   cCuentaBanco         += Space(1)
   cCuentaBanco         += AllTrim( cSucBnc )
   cCuentaBanco         += Space(1)
   cCuentaBanco         += AllTrim( cDigBnc )
   cCuentaBanco         += SubStr( AllTrim( cCtaBnc ), 1, 2 )
   cCuentaBanco         += Space(1)
   cCuentaBanco         += SubStr( AllTrim( cCtaBnc ), 3, 4 )
   cCuentaBanco         += Space(1)
   cCuentaBanco         += SubStr( AllTrim( cCtaBnc ), 7, 4 )

Return ( cCuentaBanco )

//---------------------------------------------------------------------------//

METHOD sanitizedBankCount( cPaisIBAN, cCtrlIBAN, cEntBnc, cSucBnc, cDigBnc, cCtaBnc )

   local cCuentaBanco   := ""

   cCuentaBanco         += AllTrim( cPaisIBAN )
   cCuentaBanco         += AllTrim( cCtrlIBAN )
   cCuentaBanco         += AllTrim( cEntBnc )
   cCuentaBanco         += AllTrim( cSucBnc )
   cCuentaBanco         += AllTrim( cDigBnc )
   cCuentaBanco         += AllTrim( cCtaBnc )

Return ( cCuentaBanco )

//---------------------------------------------------------------------------//

METHOD formatNumeric( uVal )

   local cFormat  := "0.000"

   if hb_isnumeric( uVal )
      cFormat     := AllTrim( Trans( uVal, "@E 999999.99" ) )
   end if

   //cFormat        := strtran( cFormat, ".", "" )
   cFormat        := strtran( cFormat, ",", "." )

Return ( cFormat )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

FUNCTION ExpOdoo( oMenuItem, oWnd )

   local oExpOdoo
   local nLevel   := Auth():Level( oMenuItem )
   if nAnd( nLevel, 1 ) == 0
      msgStop( "Acceso no permitido." )
      return ( nil )
   end if

   oExpOdoo       := ExportOdoo():New():Resource()

RETURN nil

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TOdooIds FROM TMant

   METHOD DefineFiles()

END CLASS

//----------------------------------------------------------------------------//

METHOD DefineFiles( cPath, cDriver )

   DEFAULT cPath        := ::cPath
   DEFAULT cDriver      := cDriver()

   DEFINE DATABASE ::oDbf FILE "ODOOIDS.DBF" CLASS "ODOOIDS" PATH ( cPath ) VIA ( cDriver ) COMMENT "ODOOIDS"

      FIELD NAME "uuid"       TYPE "C" LEN 40  DEC 0  COMMENT "Identificador"       DEFAULT win_uuidcreatestring()   OF ::oDbf
      FIELD NAME "cCodEmp"    TYPE "C" LEN  4  DEC 0  COMMENT "Nombre"                                               OF ::oDbf
      FIELD NAME "cTipDoc"    TYPE "C" LEN 60  DEC 0  COMMENT "Tipo de documento"                                    OF ::oDbf
      FIELD NAME "cCodGest"   TYPE "C" LEN 40  DEC 0  COMMENT "Código Gestool"                                       OF ::oDbf
      FIELD NAME "id_odoo"    TYPE "C" LEN 40  DEC 0  COMMENT "Código Odoo"                                          OF ::oDbf

      INDEX TO "ODOOIDS.CDX" TAG "UUID" ON "UUID" COMMENT "UUID" NODELETED OF ::oDbf

   END DATABASE ::oDbf

RETURN ( ::oDbf )

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

CLASS OdooIdsModel FROM ADSBaseModel

   METHOD getTableName()                                          INLINE ::getDatosTableName( "ODOOIDS" )

   METHOD InsertFromHashSql( hHash )
   METHOD lExisteUuid( uuid )

   METHOD insertOdooId( cTipo, idGestool, idOdoo )
      METHOD insertClienteToOdooId( idGestool, idOdoo )           INLINE ( ::insertOdooId( "cliente", idGestool, idOdoo ) )
      METHOD insertProveedorToOdooId( idGestool, idOdoo )         INLINE ( ::insertOdooId( "proveedor", idGestool, idOdoo ) )
      METHOD insertAgenteToOdooId( idGestool, idOdoo )            INLINE ( ::insertOdooId( "agente", idGestool, idOdoo ) )

   METHOD getCount( cCodigo, cTipo )
      METHOD getCountCliente( cCodigo, lNew )                     INLINE ( ::getCount( cCodigo, "cliente", lNew ) )
      METHOD getCountProveedor( cCodigo, lNew )                   INLINE ( ::getCount( cCodigo, "proveedor", lNew ) )
      METHOD getCountAgente( cCodigo, lNew )                      INLINE ( ::getCount( cCodigo, "agente", lNew ) )

   METHOD lastCountResPartner()

END CLASS

//---------------------------------------------------------------------------//

METHOD InsertFromHashSql( hHash ) CLASS OdooIdsModel

   local cStm     := "InsertFromHashSql"
   local cSql     := ""

   if !Empty( hHash ) .and. !::lExisteUuid( hGet( hHash, "uuid" ) )

      cSql         := "INSERT INTO " + ::getTableName() 
      cSql         += " ( uuid, cCodEmp, cTipDoc, cCodGest, id_odoo ) VALUES "
      cSql         += " ( " + quoted( hGet( hHash, "uuid" ) )
      cSql         += ", " + quoted( hGet( hHash, "empresa_codigo" ) )
      cSql         += ", " + quoted( hGet( hHash, "tipo_documento" ) )
      cSql         += ", " + quoted( hGet( hHash, "codigo_gestool" ) )
      cSql         += ", " + quoted( hGet( hHash, "id_odoo" ) ) + " )"

      ::ExecuteSqlStatement( cSql, @cStm )

   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD lExisteUuid( uuid ) CLASS OdooIdsModel

   local cStm     := "lExisteUuid"
   local cSql     := ""

   cSql     := "SELECT * FROM " + ::getTableName() + " WHERE uuid = " + quoted( uuid )

      if ::ExecuteSqlStatement( cSql, @cStm )

         if ( cStm )->( RecCount() ) > 0
            Return ( .t. )
         end if

      end if

Return ( .f. )

//---------------------------------------------------------------------------//

METHOD insertOdooId( cTipo, idGestool, idOdoo ) CLASS OdooIdsModel

   local cStm        := "OdooIds_insertOdooId"
   local nId
   local cSentence   := ""

   cSentence         := "SELECT id_odoo FROM " + ::getTableName() + ;
                        " WHERE cTipDoc = " + quoted( cTipo ) + " AND " + ;
                           "cCodGest = " + quoted( idGestool ) + " AND " + ;
                           "id_odoo = " + quoted( idOdoo ) + " AND " + ;
                           "cCodEmp = " + quoted( cCodEmp() )

   if ::ExecuteSqlStatement( cSentence, @cStm )

      if ( cStm )->( RecCount() ) > 0
         
         ( cStm )->( dbGoTop() )

         nId   := ( cStm )->id_odoo

      end if

   end if

   if Empty( nId )

      cSentence         := "INSERT INTO " + ::getTableName() + " ( "          + ;
                              "uuid, cCodEmp, cTipDoc, cCodGest, id_odoo ) "  + ;
                           "VALUES  ( "                                       + ;
                              quoted( win_uuidcreatestring() ) + ", "         + ;
                              quoted( cCodEmp() ) + ", "                      + ;
                              quoted( cTipo ) + ", "                          + ;
                              quoted( idGestool ) + ", "                      + ;
                              quoted( idOdoo ) + " )"

      ::ExecuteSqlStatement( cSentence, @cStm )

   end if

Return .t.

//---------------------------------------------------------------------------//

METHOD lastCountResPartner() CLASS OdooIdsModel

   local cStm        := "OdooIds_lastCountResPartner"
   local lastid      := 0
   local cSentence   := ""

   cSentence         := "SELECT id_odoo FROM " + ::getTableName() + ;
                        " WHERE cTipDoc IN ( 'cliente', 'proveedor', 'agente' ) AND " + ;
                           "cCodEmp = " + quoted( cCodEmp() ) + Space( 1 ) + ;
                           "ORDER BY cast(id_odoo as SQL_INTEGER) DESC"

   if ::ExecuteSqlStatement( cSentence, @cStm )

      if ( cStm )->( RecCount() ) > 0
         
         ( cStm )->( dbGoTop() )

         lastid   := ( cStm )->id_odoo

      end if

   end if

   if ValType( lastid ) == "C"
      lastid      := Val( AllTrim( lastid ) )
   end if

   if Empty( lastid )
      lastid      := 1
   end if

Return lastid

//---------------------------------------------------------------------------//

METHOD getCount( cCodigo, cTipo, lNew ) CLASS OdooIdsModel

   local cStm        := "OdooIds_getCount"
   local nCount      := 0
   local cSentence   := ""

   DEFAULT lNew      := .t.

   cSentence         := "SELECT id_odoo FROM " + ::getTableName() + ;
                        " WHERE cTipDoc = " + quoted( cTipo ) + " AND " + ;
                           "cCodGest = " + quoted( cCodigo ) + " AND " + ;
                           "cCodEmp = " + quoted( cCodEmp() )

   if ::ExecuteSqlStatement( cSentence, @cStm )

      if ( cStm )->( RecCount() ) > 0
         
         ( cStm )->( dbGoTop() )

         nCount   := ( cStm )->id_odoo

      end if

   end if

   if lNew
      if Empty( nCount )
         nCount         := Str( ::lastCountResPartner() + 1 )
      end if
   end if

Return nCount

//---------------------------------------------------------------------------//

/*"Código de Provincia","Nombre provincia","País","ID","ID externo","Nombre mostrado"
"A","Alacant (Alicante)","España","420","base.state_es_a","Alacant (Alicante) (ES)"
"AB","Albacete","España","419","base.state_es_ab","Albacete (ES)"
"AL","Almería","España","421","base.state_es_al","Almería (ES)"
"AV","Ávila","España","423","base.state_es_av","Ávila (ES)"
"B","Barcelona","España","426","base.state_es_b","Barcelona (ES)"
"BA","Badajoz","España","424","base.state_es_ba","Badajoz (ES)"
"BI","Bizkaia (Vizcaya)","España","466","base.state_es_bi","Bizkaia (Vizcaya) (ES)"
"BU","Burgos","España","427","base.state_es_bu","Burgos (ES)"
"C","A Coruña (La Coruña)","España","417","base.state_es_c","A Coruña (La Coruña) (ES)"
"CA","Cádiz","España","429","base.state_es_ca","Cádiz (ES)"
"CC","Cáceres","España","428","base.state_es_cc","Cáceres (ES)"
"CE","Ceuta","España","432","base.state_es_ce","Ceuta (ES)"
"CO","Córdoba","España","434","base.state_es_co","Córdoba (ES)"
"CR","Ciudad Real","España","433","base.state_es_cr","Ciudad Real (ES)"
"CS","Castelló (Castellón)","España","431","base.state_es_cs","Castelló (Castellón) (ES)"
"CU","Cuenca","España","435","base.state_es_cu","Cuenca (ES)"
"GC","Las Palmas","España","444","base.state_es_gc","Las Palmas (ES)"
"GI","Girona (Gerona)","España","436","base.state_es_gi","Girona (Gerona) (ES)"
"GR","Granada","España","437","base.state_es_gr","Granada (ES)"
"GU","Guadalajara","España","438","base.state_es_gu","Guadalajara (ES)"
"H","Huelva","España","440","base.state_es_h","Huelva (ES)"
"HU","Huesca","España","441","base.state_es_hu","Huesca (ES)"
"J","Jaén","España","442","base.state_es_j","Jaén (ES)"
"L","Lleida (Lérida)","España","446","base.state_es_l","Lleida (Lérida) (ES)"
"LE","León","España","445","base.state_es_le","León (ES)"
"LO","La Rioja","España","443","base.state_es_lo","La Rioja (ES)"
"LU","Lugo","España","447","base.state_es_lu","Lugo (ES)"
"M","Madrid","España","448","base.state_es_m","Madrid (ES)"
"MA","Málaga","España","449","base.state_es_ma","Málaga (ES)"
"ME","Melilla","España","450","base.state_es_ml","Melilla (ES)"
"MU","Murcia","España","451","base.state_es_mu","Murcia (ES)"
"NA","Navarra (Nafarroa)","España","452","base.state_es_na","Navarra (Nafarroa) (ES)"
"O","Asturias","España","422","base.state_es_o","Asturias (ES)"
"OR","Ourense (Orense)","España","453","base.state_es_or","Ourense (Orense) (ES)"
"P","Palencia","España","454","base.state_es_p","Palencia (ES)"
"PM","Illes Balears (Islas Baleares)","España","425","base.state_es_pm","Illes Balears (Islas Baleares) (ES)"
"PO","Pontevedra","España","455","base.state_es_po","Pontevedra (ES)"
"S","Cantabria","España","430","base.state_es_s","Cantabria (ES)"
"SA","Salamanca","España","456","base.state_es_sa","Salamanca (ES)"
"SE","Sevilla","España","459","base.state_es_se","Sevilla (ES)"
"SG","Segovia","España","458","base.state_es_sg","Segovia (ES)"
"SO","Soria","España","460","base.state_es_so","Soria (ES)"
"SS","Gipuzkoa (Guipúzcoa)","España","439","base.state_es_ss","Gipuzkoa (Guipúzcoa) (ES)"
"T","Tarragona","España","461","base.state_es_t","Tarragona (ES)"
"TE","Teruel","España","462","base.state_es_te","Teruel (ES)"
"TF","Santa Cruz de Tenerife","España","457","base.state_es_tf","Santa Cruz de Tenerife (ES)"
"TO","Toledo","España","463","base.state_es_to","Toledo (ES)"
"V","València (Valencia)","España","464","base.state_es_v","València (Valencia) (ES)"
"VA","Valladolid","España","465","base.state_es_va","Valladolid (ES)"
"VI","Araba/Álava","España","418","base.state_es_vi","Araba/Álava (ES)"
"Z","Zaragoza","España","468","base.state_es_z","Zaragoza (ES)"
"ZA","Zamora","España","467","base.state_es_za","Zamora (ES)"*/
