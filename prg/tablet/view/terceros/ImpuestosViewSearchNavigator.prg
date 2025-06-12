#include "FiveWin.Ch"
#include "Factu.ch" 

CLASS ImpuestosViewSearchNavigator FROM ViewSearchNavigator

   METHOD setItemsBusqueda()           INLINE ( ::hashItemsSearch := { "Tipo" => "Tipo" } )

   METHOD setColumns()

   METHOD botonesAcciones()            INLINE ( self )

END CLASS

//---------------------------------------------------------------------------//

METHOD setColumns() CLASS ImpuestosViewSearchNavigator

   ::setBrowseConfigurationName( "grid_impuestos" )

   with object ( ::addColumn() )
      :cHeader          := "Tipo"
      :bEditValue       := {|| ( ( D():TiposIva( ::getView() ) )->Tipo + CRLF + ( D():TiposIva( ::getView() ) )->DescIva )  }
      :nWidth           := 420
   end with

   with object ( ::addColumn() )
      :cHeader          := "% Imp."
      :bEditValue       := {|| Trans( ( D():TiposIva( ::getView() ) )->TpIva, "@E 999.99" ) }
      :nWidth           := 420
      :nDataStrAlign    := 1
      :nHeadStrAlign    := 1
   end with

Return ( self )

//---------------------------------------------------------------------------//