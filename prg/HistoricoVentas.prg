#include "FiveWin.Ch"
#include "Factu.ch" 
#include "MesDbf.ch"

CLASS HistoricoVentas

   DATA oDlg
   DATA oBmp
   DATA oSay

   METHOD New()

   METHOD Historico()

END CLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS HistoricoVentas



RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Historico() CLASS HistoricoVentas

   DEFINE DIALOG ::oDlg RESOURCE "HIS_PROVEEDOR" OF oWnd()

      REDEFINE BITMAP ::oBmp ;
         ID       500 ;
         RESOURCE "gc_symbol_euro_48" ;
         TRANSPARENT ;
         OF       ::oDlg

      REDEFINE SAY ::oSay VAR "Historico de artículos vendidos";
         ID       50 ;
         OF       ::oDlg

      REDEFINE BUTTON ;
         ID       IDOK ;
         OF       ::oDlg ;
         ACTION   ( ::oDlg:end() )

      REDEFINE BUTTON ;
         ID       IDCANCEL ;
         OF       ::oDlg ;
         CANCEL ;
         ACTION   ( ::oDlg:end() )

   ACTIVATE DIALOG ::oDlg CENTER

   ::oBmp:End()

RETURN ( Self )

//---------------------------------------------------------------------------//