#include "fivewin.ch"
#include "factu.ch" 
#include "hdo.ch"

//---------------------------------------------------------------------------//

CLASS CentroCosteModel FROM ADSBaseModel

   METHOD getTableName()                   INLINE ::getDatosTableName( "CCoste" )

   MESSAGE getNombre( Uuid )               INLINE ::getField( "cNombre", "uuid", Uuid )

   MESSAGE getCodigo( Uuid )               INLINE ::getField( "cCodigo", "uuid", Uuid )

   MESSAGE getUuid( cCodigo )              INLINE ::getField( "uuid", "cCodigo", cCodigo )

   MESSAGE getNombreFromCodigo( cCodigo )  INLINE ::getField( "cNombre", "cCodigo", cCodigo )

END CLASS

//---------------------------------------------------------------------------//