#include "FiveWin.Ch"
#include "Factu.ch"

CLASS RecStockPresenter FROM DocumentsSales

   DATA oRecStockView

   DATA lSyncronize                    AS LOGIC INIT .t.

   METHOD New()

   METHOD runNavigator()

   METHOD onPreRunNavigator()          INLINE ( .t. )

   METHOD play()

   METHOD runRecStock()

END CLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS RecStockPresenter

   ::oRecStockView    := RecStockView():New( self )

   ::oRecStockView:setTitleDocumento( "Recalculo de stock" )

Return( self )

//---------------------------------------------------------------------------//

METHOD runNavigator() CLASS RecStockPresenter

   if !empty( ::oRecStockView )
      ::oRecStockView:Resource()
   end if

Return( self )

//---------------------------------------------------------------------------//

METHOD play() CLASS RecStockPresenter

   if ::onPreRunNavigator()
      ::runNavigator()
   end if 

return ( self )

//---------------------------------------------------------------------------//

METHOD runRecStock() CLASS RecStockPresenter
 
   local oClassReindexa

   oClassReindexa                      := TDataCenter()

   if !Empty( oClassReindexa )

      oClassReindexa:aLgcIndices[ 1 ]  := .f.
      oClassReindexa:aLgcIndices[ 2 ]  := .f.
      oClassReindexa:aLgcIndices[ 3 ]  := .f.
      oClassReindexa:aLgcIndices[ 4 ]  := .t.

      oClassReindexa:aProgress[ 4 ]    := ::oRecStockView:oMeterStock
      oClassReindexa:nProgress[ 4 ]    := ::oRecStockView:nMeterStock

      oClassReindexa:oMsg              := ::oRecStockView:oSayInformacion

      oClassReindexa:RecalculoStock()

   end if

Return ( self )

//---------------------------------------------------------------------------//