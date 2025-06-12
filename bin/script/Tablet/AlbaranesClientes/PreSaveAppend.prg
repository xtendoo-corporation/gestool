#include "Factu.ch" 
#include "FiveWin.ch"

//cNumDoc

//---------------------------------------------------------------------------//

Function PreSave( oSender )

   local oPre

   oPre := oPreSave():New( oSender )

   if !Empty( oPre )
      oPre:setAlmacenPrincipal( "000" )
      oPre:setAlmacenTablet( Application():codigoAlmacen() )
      oPre:run()
   end if

Return nil

//---------------------------------------------------------------------------//

CLASS oPreSave

   DATA nView2

   DATA cAlmacenPrincipal
   DATA cAlmacenTablet

   DATA oSender

   DATA cSerieDuplicate
   DATA nNumeroDuplicate
   DATA cSufijoDuplicate

   DATA cCodigoArticuloCarga

   METHOD new( oSender )

   METHOD run()

   METHOD setAlmacenPrincipal( cAlmacen )          INLINE ( ::cAlmacenPrincipal  := cAlmacen )
   METHOD setAlmacenTablet( cAlmacen )             INLINE ( ::cAlmacenTablet     := cAlmacen )

   METHOD runAppendMode()

   METHOD runEditMode()

   METHOD duplicateAlbaran()

   METHOD setAlmacenEnAlbaran()

   METHOD delDocumentoAsociado()

   METHOD lArticuloCarga()

END CLASS

//---------------------------------------------------------------------------//

METHOD New( oSender ) CLASS oPreSave

   ::nView2                := D():CreateView()

   D():AlbaranesClientes( ::nView2 )

   ::oSender               := oSender

   ::cSerieDuplicate       := "H"

   ::cCodigoArticuloCarga  := "999"

Return self

//---------------------------------------------------------------------------//

METHOD run() CLASS oPreSave

   if AllTrim( ::cAlmacenPrincipal ) == AllTrim( Application():codigoAlmacen() )
      return nil
   end if

   if hGet( ::oSender:hDictionaryMaster, "Serie" ) == ::cSerieDuplicate
      Return nil
   end if

   if hGet( ::oSender:hDictionaryMaster, "Estado" ) > 2
      Return nil
   end if   

   if !::lArticuloCarga()
      Return nil
   end if

   do case
      case ::oSender:lAppendMode()

         ::runAppendMode()

      case ::oSender:lEditMode()

         ::runEditMode()

   end case

   D():DeleteView( ::nView2 )

Return nil

//---------------------------------------------------------------------------//

METHOD runAppendMode() CLASS oPreSave

   /*
   Duplicamos en uno nuevo en negativo en la serie H---------------------------
   */

   ::duplicateAlbaran()

   /*
   Cambiamos el almacen y anotamos que tiene uno relacionado-------------------
   */

   ::setAlmacenEnAlbaran()

Return nil

//---------------------------------------------------------------------------//

METHOD runEditMode() CLASS oPreSave

   /*
   Eliminamos el albarán asociado----------------------------------------------
   */

   ::delDocumentoAsociado()

   /*
   Duplicamos en uno nuevo en negativo en la serie H---------------------------
   */

   ::duplicateAlbaran()

   /*
   Cambiamos el almacen y anotamos que tiene uno relacionado-------------------
   */

   ::setAlmacenEnAlbaran()

Return nil

//---------------------------------------------------------------------------//

METHOD duplicateAlbaran() CLASS oPreSave

   local hLine
   local aTotAlb
   local hCloneDictionaryMaster
   local aCloneDocumentLines

   ::nNumeroDuplicate   := nNewDoc( ::cSerieDuplicate, ::oSender:getWorkArea(), ::oSender:getCounterDocuments(), , D():Contadores( ::nView2 ) )
   ::cSufijoDuplicate   := RetSufEmp()
   
   hCloneDictionaryMaster  := hb_hClone( ::oSender:hDictionaryMaster ) 
   aCloneDocumentLines     := aclone( ::oSender:oDocumentLines:getDictionaryArray() )

   /*
   Duplicamos y cambiamos la cabecera------------------------------------------
   */   

   hSet( hCloneDictionaryMaster, "Serie", ::cSerieDuplicate )
   hSet( hCloneDictionaryMaster, "Numero", ::nNumeroDuplicate )
   hSet( hCloneDictionaryMaster, "Sufijo", ::cSufijoDuplicate )
   hSet( hCloneDictionaryMaster, "Almacen", ::cAlmacenTablet )

   D():appendHashRecord( hCloneDictionaryMaster, "AlbCliT", ::nView2 )

   /*
   Duplicamos y cambiamos las lineas
   */

   for each hLine in aCloneDocumentLines
      hSet( hLine, "Serie", ::cSerieDuplicate )
      hSet( hLine, "Numero", ::nNumeroDuplicate )
      hSet( hLine, "Sufijo", ::cSufijoDuplicate )
      hSet( hLine, "Unidades", ( hGet( hLine, "Unidades" ) * ( - 1 ) ) )      
      hSet( hLine, "Almacen", ::cAlmacenTablet )

      D():appendHashRecord( hLine, "AlbCliL", ::nView2 )

   next

   /*
   Refrescamos los totales del documento nuevo---------------------------------
   */

   if ( D():AlbaranesClientes( ::nView2 ) )->( dbSeek( ::cSerieDuplicate + Str( ::nNumeroDuplicate ) + ::cSufijoDuplicate ) )

      if dbLock( D():AlbaranesClientes( ::nView2 ) )

         aTotAlb              := aTotAlbCli( ::cSerieDuplicate + Str( ::nNumeroDuplicate ) + ::cSufijoDuplicate, D():AlbaranesClientes( ::nView2 ), D():AlbaranesClientesLineas( ::nView2 ), D():TiposIva( ::nView2 ), D():Divisas( ::nView2 ), ( D():AlbaranesClientes( ::nView2 ) )->cDivAlb )

         ( D():AlbaranesClientes( ::nView2 ) )->nTotNet := aTotAlb[1]
         ( D():AlbaranesClientes( ::nView2 ) )->nTotIva := aTotAlb[2]
         ( D():AlbaranesClientes( ::nView2 ) )->nTotReq := aTotAlb[3]
         ( D():AlbaranesClientes( ::nView2 ) )->nTotAlb := aTotAlb[4]

         ( D():AlbaranesClientes( ::nView2 ) )->( dbUnlock() )

      end if 

   end if

Return nil

//---------------------------------------------------------------------------//

METHOD setAlmacenEnAlbaran() CLASS oPreSave

   local hLine

   /*
   Cabecera--------------------------------------------------------------------
   */

   hSet( ::oSender:hDictionaryMaster, "Almacen", ::cAlmacenPrincipal )
   hSet( ::oSender:hDictionaryMaster, "NumeroDocumento", ::cSerieDuplicate + Str( ::nNumeroDuplicate ) + ::cSufijoDuplicate )

   /*
   Lineas----------------------------------------------------------------------
   */

   for each hLine in ::oSender:oDocumentLines:getDictionaryArray()
      hSet( hLine, "Almacen", ::cAlmacenPrincipal )
   next

Return nil

//---------------------------------------------------------------------------//

METHOD delDocumentoAsociado() CLASS oPreSave

   local cNumDoc  := hGet( ::oSender:hDictionaryMaster, "NumeroDocumento" )

   if Empty( cNumDoc )
      Return nil
   end if

   /*
   Lineas----------------------------------------------------------------------
   */   

   while ( D():AlbaranesClientesLineas( ::nView2 ) )->( dbSeek( cNumDoc ) ) .and. !( D():AlbaranesClientesLineas( ::nView2 ) )->( eof() )

      if dbLock( D():AlbaranesClientesLineas( ::nView2 ) )
         ( D():AlbaranesClientesLineas( ::nView2 ) )->( dbDelete() )
         ( D():AlbaranesClientesLineas( ::nView2 ) )->( dbUnLock() )
      end if

   end while

   /*
   Cabecera--------------------------------------------------------------------
   */

   if ( D():AlbaranesClientes( ::nView2 ) )->( dbSeek( cNumDoc ) )

      if dbLock( D():AlbaranesClientes( ::nView2 ) )
         ( D():AlbaranesClientes( ::nView2 ) )->( dbDelete() )
         ( D():AlbaranesClientes( ::nView2 ) )->( dbUnLock() )
      end if

   end if

Return nil

//---------------------------------------------------------------------------//

METHOD lArticuloCarga CLASS oPreSave

   local lReturn           := .f.
   local aCloneDocumentLines

   aCloneDocumentLines     := aclone( ::oSender:oDocumentLines:getDictionaryArray() )

   aEval( aCloneDocumentLines, { | h | if( AllTrim( hGet( h, "Articulo" ) ) == ::cCodigoArticuloCarga, lReturn := .t., ) } )

Return lReturn

//---------------------------------------------------------------------------//