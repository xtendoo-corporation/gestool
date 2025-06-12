#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS TGenMailingDatabaseFacturasClientes FROM TGenMailingDatabase 

   METHOD New( nView )

   METHOD columnPageDatabase( oDlg )   

   METHOD getAdjunto()

   METHOD setFacturasClientesSend( hMail )

   METHOD CreateIndicencia()

END CLASS

//---------------------------------------------------------------------------//

METHOD New( nView ) CLASS TGenMailingDatabaseFacturasClientes

   ::Create()

   ::Super:New( nView )

   ::setItems( aItmFacCli() )

   ::setWorkArea( D():FacturasClientes( nView ) )

   ::setIncidenciaWorkArea( D():FacturasClientesIncidencias( nView ) )

   ::setTypeDocument( "nFacCli" )

   ::setTypeFormat( "FC" )

   ::setFormatoDocumento( cFormatoFacturasClientes( ( D():FacturasClientes( ::nView ) )->cSerie ) )

   ::setOrderDatabase( { "N�mero", "Fecha", "C�digo", "Nombre" } )

   ::setBmpDatabase( "gc_document_text_user2_48" )

   ::setAsunto( "Envio de nuestra factura de cliente {Serie de la factura}/{N�mero de la factura}" )

   ::setBlockRecipients( {|| alltrim( retFld( ( D():FacturasClientes( ::nView ) )->cCodCli, D():Clientes( ::nView ), "cMeiInt", "Cod" ) ) } )

   ::setPostSend( {|hMail| ::setFacturasClientesSend( hMail ) } )

   ::setCargo( {|| D():FacturasClientesId( nView ) } )

   ( ::getWorkArea() )->( ordsetfocus( "lMail" ) )
   ( ::getWorkArea() )->( dbgotop() )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD columnPageDatabase( oDlg ) CLASS TGenMailingDatabaseFacturasClientes

   with object ( ::oBrwDatabase:AddCol() )
      :cHeader          := "Se. seleccionado"
      :cSortOrder       := "lMail"
      :bStrData         := {|| "" }
      :bEditValue       := {|| ( ::getWorkArea() )->lMail }
      :nWidth           := 20
      :SetCheck( { "Sel16", "Nil16" } )
   end with

   with object ( ::oBrwDatabase:AddCol() )
      :cHeader          := "N�mero"
      :cSortOrder       := "nNumFac"
      :bEditValue       := {|| ( ::getWorkArea() )->cSerie + "/" + alltrim( str( ( ::getWorkArea() )->nNumFac ) ) }
      :nWidth           := 80
      :bLClickHeader    := {| nMRow, nMCol, nFlags, oCol | ::oOrderDatabase:Set( oCol:cHeader ) }
   end with

   with object ( ::oBrwDatabase:AddCol() )
      :cHeader          := "Fecha"
      :cSortOrder       := "dFecDes"
      :bEditValue       := {|| dtoc( ( ::getWorkArea() )->dFecFac ) }
      :nWidth           := 80
      :bLClickHeader    := {| nMRow, nMCol, nFlags, oCol | ::oOrderDatabase:Set( oCol:cHeader ) }
   end with

   with object ( ::oBrwDatabase:AddCol() )
      :cHeader          := "C�digo"
      :cSortOrder       := "cCodCli"
      :bEditValue       := {|| ( ::getWorkArea() )->cCodCli }
      :nWidth           := 70
      :bLClickHeader    := {| nMRow, nMCol, nFlags, oCol | ::oOrderDatabase:Set( oCol:cHeader ) }
   end with

   with object ( ::oBrwDatabase:AddCol() )
      :cHeader          := "Nombre"
      :cSortOrder       := "cNomCli"
      :bEditValue       := {|| ( ::getWorkArea() )->cNomCli }
      :nWidth           := 300
      :bLClickHeader    := {| nMRow, nMCol, nFlags, oCol | ::oOrderDatabase:Set( oCol:cHeader ) }
   end with

   with object ( ::oBrwDatabase:AddCol() )
      :cHeader          := "Total"
      :bEditValue       := {|| ( ::getWorkArea() )->nTotFac }
      :cEditPicture     := cPorDiv()
      :nWidth           := 80
      :nDataStrAlign    := 1
      :nHeadStrAlign    := 1
   end with

Return ( Self )   

//---------------------------------------------------------------------------//

METHOD setFacturasClientesSend( hMail ) CLASS TGenMailingDatabaseFacturasClientes

   local idFactura

   if !hhaskey( hMail, "cargo" )
      Return .f.
   end if 

   idFactura         := hGet( hMail, "cargo" )

   if dbSeekInOrd( idFactura, "nNumFac", D():FacturasClientes( ::nView ) ) 

      if ( D():FacturasClientes( ::nView ) )->( dbrlock() )
         ( D():FacturasClientes( ::nView ) )->lMail   := .f.
         ( D():FacturasClientes( ::nView ) )->dMail   := Date()
         ( D():FacturasClientes( ::nView ) )->tMail   := TimeToString()
         ( D():FacturasClientes( ::nView ) )->( dbunlock() )
      end if

   end if 

Return ( .t. )   

//---------------------------------------------------------------------------//

METHOD CreateIndicencia( Cargo )

   local cSerie
   local nNumero
   local cSufijo

   default Cargo  := ( ::getWorkArea() )->cSerie + Str( ( ::getWorkArea() )->nNumFac ) + ( ::getWorkArea() )->cSufFac

   cSerie         := SubStr( Cargo, 1, 1 )
   nNumero        := Val( SubStr( Cargo, 2, 9 ) )
   cSufijo        := SubStr( Cargo, 11, 2 )

   ( ::getIncidenciaWorkArea() )->( dbAppend() )
   ( ::getIncidenciaWorkArea() )->cSerie     := cSerie
   ( ::getIncidenciaWorkArea() )->nNumFac    := nNumero
   ( ::getIncidenciaWorkArea() )->cSufFac    := cSufijo
   ( ::getIncidenciaWorkArea() )->dFecInc    := GetSysDate()
   ( ::getIncidenciaWorkArea() )->mDesInc    := "Factura " + cSerie + "/" + AllTrim( Str( nNumero ) ) + "/" + cSufijo + " enviada por correo." + ;
                                                CRLF + "Destinatario: " + AllTrim( ::cRecipients ) + ;
                                                CRLF + "Usuario: " + AllTrim( Auth():Codigo() ) + " - " + AllTrim( UsuariosModel():getNombre( Auth():Codigo() ) ) + ;
                                                CRLF + "Fecha: " + AllTrim( dToc( GetSysDate() ) ) + ;
                                                CRLF + "Hora: " + AllTrim( GetSysTime() ) + ;
                                                CRLF + "Adjuntos: " + AllTrim( ::cGetAdjunto )
   ( ::getIncidenciaWorkArea() )->lListo     := .t.
   ( ::getIncidenciaWorkArea() )->lAviso     := .f.
   ( ::getIncidenciaWorkArea() )->( dbUnlock() )

Return ( Self )

//--------------------------------------------------------------------------//

METHOD getAdjunto()

   if !Empty( ::cGetAdjunto )
      Return ( AllTrim( ::cGetAdjunto ) + ";" + AllTrim( mailReportFacCli( ::cFormatoDocumento ) ) )
   end if

Return ( mailReportFacCli( ::cFormatoDocumento ) )

//--------------------------------------------------------------------------//