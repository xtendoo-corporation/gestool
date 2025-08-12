#include "FiveWin.Ch"
#include "Factu.ch" 
#include "MesDbf.ch"

CLASS DuplicaTarifa

   DATA oDlg

   DATA oClienteOrigen
   DATA cClienteOrigen

   DATA oClienteDestino
   DATA cClienteDestino

   DATA oBrowse

   DATA aAtipicas

   METHOD New()

   METHOD Resource()

   METHOD lValidClienteOrigen()

   METHOD lValidClienteDestino()

   METHOD LoadAtipica()

   METHOD excute()

END CLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS DuplicaTarifa

   ::aAtipicas          := {}

   aAdd( ::aAtipicas,   {  "lSel" => .t.,;
                           "codigocliente" => "",;
                           "nombrecliente" => "",;
                           "codigoarticulo" => "",;
                           "nombrearticulo" => "",;
                           "codigoFamilia" => "",;
                           "nTipAtp" => 0,;
                           "dFecIni" => ctod( "" ),;
                           "dFecFin" => ctod( "" ),;
                           "costo" => 0,;
                           "precio1" => 0,;
                           "precio2" => 0,;
                           "precio3" => 0,; 
                           "precio4" => 0,;
                           "precio5" => 0,;
                           "precio6" => 0,;
                           "prciva1" => 0,;
                           "prciva2" => 0,;
                           "prciva3" => 0,;
                           "prciva4" => 0,;
                           "prciva5" => 0,;
                           "prciva6" => 0,;
                           "ndto" => 0 } )

   ::cClienteOrigen     := Space( 12 )
   ::cClienteDestino    := Space( 12 )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Resource() CLASS DuplicaTarifa

   local oBmp
   
   if oWnd() != nil
      oWnd():CloseAll()
   end if

   DEFINE DIALOG ::oDlg RESOURCE "DUPLTARIFA" OF oWnd()
  
      REDEFINE BITMAP oBmp RESOURCE "gc_symbol_euro_48" TRANSPARENT ID 600 OF ::oDlg

      REDEFINE GET ::oClienteOrigen VAR ::cClienteOrigen ;
         ID       110 ;
         IDTEXT   111 ;
         BITMAP   "LUPA" ;
         OF       ::oDlg

      ::oClienteOrigen:bHelp     := {|| BrwClient( ::oClienteOrigen, ::oClienteOrigen:oHelpText ) }
      ::oClienteOrigen:bValid    := {|| ::lValidClienteOrigen() }

      REDEFINE GET ::oClienteDestino VAR ::cClienteDestino ;
         ID       120 ;
         IDTEXT   121 ;
         BITMAP   "LUPA" ;
         OF       ::oDlg

      ::oClienteDestino:bHelp     := {|| BrwClient( ::oClienteDestino, ::oClienteDestino:oHelpText ) }
      ::oClienteDestino:bValid    := {|| ::lValidClienteDestino() }

      ::oBrowse                        := IXBrowse():New( ::oDlg )

      ::oBrowse:bClrSel                := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
      ::oBrowse:bClrSelFocus           := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

      ::oBrowse:SetArray( ::aAtipicas, , , .f. )

      ::oBrowse:nMarqueeStyle          := 5
      ::oBrowse:lRecordSelector        := .f.
      ::oBrowse:lHScroll               := .f.

      ::oBrowse:CreateFromResource( 130 )

      ::oBrowse:bLDblClick             := {|| hSet( ::aAtipicas[ ::oBrowse:nArrayAt ], "lSel", !hget( ::aAtipicas[ ::oBrowse:nArrayAt ], "lSel" ) ), ::oBrowse:refresh() }

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Sel"
         :bStrData         := {|| "" }
         :bEditValue       := {|| hGet( ::aAtipicas[ ::oBrowse:nArrayAt ], "lSel" ) }
         :nWidth           := 20
         :SetCheck( { "Sel16", "Nil16" } )
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Artículo"
         :bEditValue       := {|| AllTrim( hGet( ::aAtipicas[ ::oBrowse:nArrayAt ], "codigoarticulo" ) ) + " - " + AllTrim( hGet( ::aAtipicas[ ::oBrowse:nArrayAt ], "nombrearticulo" ) ) }
         :nWidth           := 200
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Familia"
         :bEditValue       := {|| AllTrim( hGet( ::aAtipicas[ ::oBrowse:nArrayAt ], "codigoFamilia" ) ) }
         :nWidth           := 150
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Precio 1"
         :bStrData         := {|| hGet( ::aAtipicas[ ::oBrowse:nArrayAt ], "precio1" ) }
         :cEditPicture     := "@E 999.99"
         :nWidth           := 76
         :nDataStrAlign    := 1
         :nHeadStrAlign    := 1
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Descuento"
         :bStrData         := {|| hGet( ::aAtipicas[ ::oBrowse:nArrayAt ], "ndto" ) }
         :cEditPicture     := "@E 999.99"
         :nWidth           := 76
         :nDataStrAlign    := 1
         :nHeadStrAlign    := 1
      end with

      REDEFINE BUTTON ID IDOK       OF ::oDlg ACTION ( ::excute() )
      REDEFINE BUTTON ID IDCANCEL   OF ::oDlg ACTION ( ::oDlg:end() )

   ::oDlg:AddFastKey( VK_F5, {|| ::excute() } )

   ACTIVATE DIALOG ::oDlg CENTER

   oBmp:End()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD lValidClienteOrigen()

   cClient( ::oClienteOrigen, , ::oClienteOrigen:oHelpText )

   if !Empty( ::cClienteOrigen )
      ::LoadAtipica()
   end if

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD lValidClienteDestino()

   cClient( ::oClienteDestino, , ::oClienteDestino:oHelpText )

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD LoadAtipica()

   local aAtp    := AtipicasModel():getAtipicasFromCliente( ::cClienteOrigen )

   if hb_isarray( aAtp ) .and. len( aAtp ) > 0

      ::aAtipicas      := aAtp

      ::oBrowse:SetArray( aAtp )
      ::oBrowse:Refresh()

   end if

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD excute()

   if Empty( ::cClienteOrigen )
      MsgStop( "Cliente de Origen no puede estar vacío" )
      ::oClienteOrigen:SetFocus()
      Return .f.
   end if

   if Empty( ::cClienteDestino )
      MsgStop( "Cliente de destino no puede estar vacío" )
      ::oClienteDestino:SetFocus()
      Return .f.
   end if

   if ::cClienteOrigen == ::cClienteDestino
      MsgStop( "Cliente de origen y destino tienen que ser distintos" )
      ::oClienteDestino:SetFocus()
      Return .f.
   end if

   aEval( ::aAtipicas, {|h| if( hget( h, "lSel" ), AtipicasModel():setAtipicasFromDplCliente( h, ::cClienteDestino ), ) } )

   MsgInfo( "Proceso realizado con éxito" )

   ::oDlg:End()

RETURN ( .t. )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

FUNCTION DupTarifa( oMenuItem, oWnd )

   local oDupTarifa
   local nLevel   := Auth():Level( oMenuItem )
   if nAnd( nLevel, 1 ) == 0
      msgStop( "Acceso no permitido." )
      return ( nil )
   end if

   oDupTarifa       := DuplicaTarifa():New():Resource()

RETURN nil

//---------------------------------------------------------------------------//