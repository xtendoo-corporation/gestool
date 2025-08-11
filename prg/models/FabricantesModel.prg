#include "FiveWin.Ch"
#include "Factu.ch" 

CLASS FabricantesModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "Fabric" )

END CLASS

//---------------------------------------------------------------------------//