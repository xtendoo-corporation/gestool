#include "hbclass.ch"

#define CRLF chr( 13 ) + chr( 10 )

//---------------------------------------------------------------------------//

Function Inicio( nView )

   local oImportaArticulos := ImportaArticulos():New( nView )

Return ( nil )

//---------------------------------------------------------------------------//

CLASS ImportaArticulos

   DATA nView
   DATA cFileArticulo
   DATA cFileFamilia
   DATA cFileFabricante
   DATA cFileCliente
   DATA cFileDirecciones
   DATA cFileImagenes
   DATA cFilePropiedades
   DATA cFileLineasPropiedades
   DATA cFilePropiedadesArticulos
   DATA cFileDescripcionesArticulos

   DATA cUrlPsImagen
   DATA cUrlDwImagen

   DATA aDownloadImagenes

   METHOD New()
   METHOD ImpArticulos()
   METHOD ImpFamilias()
   METHOD ImpFabricantes()
   METHOD ImpClientes()
   METHOD ImpDirecciones()
   METHOD ImpImagenes()
   METHOD ImpPropiedades()
   METHOD ImpLineasPropiedades()
   METHOD ImpPropiedadesArticulos()
   METHOD ImpDescripciones()

ENDCLASS

//---------------------------------------------------------------------------//

METHOD New( nView ) CLASS ImportaArticulos

   ::nView                       := nView
   ::cFileArticulo               := "c:\ficheros\product.csv"
   ::cFileFamilia                := "c:\ficheros\category.csv"
   ::cFileFabricante             := "c:\ficheros\manufacturer.csv"
   ::cFileCliente                := "c:\ficheros\customer.csv"
   ::cFileDirecciones            := "c:\ficheros\address.csv"
   ::cFileImagenes               := "c:\ficheros\product.csv"
   ::cFilePropiedades            := "c:\ficheros\propiedades.csv"
   ::cFileLineasPropiedades      := "c:\ficheros\lineaspropiedades.csv"
   ::cFilePropiedadesArticulos   := "c:\ficheros\propiedadesarticulos.csv"
   ::cFileDescripcionesArticulos := "c:\ficheros\descripcionesarticulos.csv"

   ::cUrlPsImagen                := "http://motosdasilva.com/t/img/p/"
   ::cUrlDwImagen                := "c:\ficheros\images2020\"

   ::aDownloadImagenes           := {}

   if msgYesNo( "¿Desea importar productos?" )
      ::ImpArticulos()
   end if

   if msgYesNo( "¿Desea importar familias?" )
      ::ImpFamilias()
   end if

   if msgYesNo( "¿Desea importar fabricantes?" )
      ::ImpFabricantes()
   end if

   if msgYesNo( "¿Desea importar clientes?" )
      ::ImpClientes()
   end if

   if msgYesNo( "¿Desea importar direcciones?" )
      ::ImpDirecciones()
   end if

   if msgYesNo( "¿Desea importar imagenes?" )
      ::ImpImagenes()
   end if

   if msgYesNo( "¿Desea importar propiedades?" )
      ::ImpPropiedades()
   end if

   if msgYesNo( "¿Desea importar lineas propiedades?" )
      ::ImpLineasPropiedades()
   end if

   if msgYesNo( "¿Desea importar lineas propiedades de artículos?" )
      ::ImpPropiedadesArticulos()
   end if

   if msgYesNo( "¿Desea importar descripciones de artículos?" )
      ::ImpDescripciones()
   end if


Return ( Self )

//---------------------------------------------------------------------------//

METHOD ImpArticulos() CLASS ImportaArticulos

   local cMemoRead
   local aLineas
   local line
   local aRegistro
   local n           := 1

   if !File( ::cFileArticulo )
      Return .f.
   end if

   alineas           := hb_aTokens( MemoRead( ::cFileArticulo ), CRLF )

   for each line in alineas

      aRegistro := hb_aTokens( line, ";" )

      if len( aRegistro ) != 0

         msgWait( "Añadiendo " + AllTrim( Str( n ) ) + " - " + AllTrim( aRegistro[5] ), "Atención", 0.1 )

         ( D():Articulos( ::nView ) )->( dbAppend() )

         ( D():Articulos( ::nView ) )->Codigo      := AllTrim( aRegistro[1] )
         ( D():Articulos( ::nView ) )->Familia     := AllTrim( aRegistro[2] )
         ( D():Articulos( ::nView ) )->cCodFab     := if( AllTrim( aRegistro[3] ) != "0", AllTrim( aRegistro[3] ), "" )
         ( D():Articulos( ::nView ) )->pVenta1     := val( AllTrim( aRegistro[4] ) )
         ( D():Articulos( ::nView ) )->pVtaIva1    := Round( val( AllTrim( aRegistro[4] ) ) * 1.21, 2 )
         ( D():Articulos( ::nView ) )->Nombre      := AllTrim( aRegistro[5] )
         ( D():Articulos( ::nView ) )->nTarWeb     := 1

         ( D():Articulos( ::nView ) )->lSbrInt     := .t.
         ( D():Articulos( ::nView ) )->pVtaWeb     := val( AllTrim( aRegistro[4] ) )
         ( D():Articulos( ::nView ) )->nDtoInt1    := 0
         ( D():Articulos( ::nView ) )->nImpInt1    := val( AllTrim( aRegistro[4] ) )
         ( D():Articulos( ::nView ) )->nImpIva1    := Round( val( AllTrim( aRegistro[4] ) ) * 1.21, 2 )
         ( D():Articulos( ::nView ) )->lIvaWeb     := .t.

         ( D():Articulos( ::nView ) )->cTitSeo     := AllTrim( aRegistro[8] ) 
         ( D():Articulos( ::nView ) )->cDesSeo     := AllTrim( aRegistro[9] )
         ( D():Articulos( ::nView ) )->cKeySeo     := AllTrim( aRegistro[10] )
         ( D():Articulos( ::nView ) )->mDesTec     := AllTrim( aRegistro[5] )

         ( D():Articulos( ::nView ) )->lPubInt     := .t.
         ( D():Articulos( ::nView ) )->cWebShop    := "dasilva"
         ( D():Articulos( ::nView ) )->uuid        := win_uuidcreatestring()
         ( D():Articulos( ::nView ) )->TipoIva     := "G"
         ( D():Articulos( ::nView ) )->lObs        := ( AllTrim( aRegistro[11] ) != "1" )

         ( D():Articulos( ::nView ) )->( dbUnlock() )

      end if

      n++

   next

Return .t.

//---------------------------------------------------------------------------//

METHOD ImpFamilias() CLASS ImportaArticulos

   local cMemoRead
   local aLineas
   local line
   local aRegistro

   if !File( ::cFileFamilia )
      Return .f.
   end if

   alineas           := hb_aTokens( MemoRead( ::cFileFamilia ), CRLF )

   for each line in alineas

      aRegistro := hb_aTokens( line, ";" )

      if len( aRegistro ) != 0

         msgWait( "Añadiendo " + formatText( AllTrim( aRegistro[3] ) ), "Atención", 0.05 )

         ( D():Familias( ::nView ) )->( dbAppend() )

         ( D():Familias( ::nView ) )->cCodFam    := AllTrim( aRegistro[1] )
         ( D():Familias( ::nView ) )->cFamCmb    := AllTrim( aRegistro[4] )
         ( D():Familias( ::nView ) )->cNomFam    := hb_StrToUTF8( AllTrim( aRegistro[3] ) )

         ( D():Familias( ::nView ) )->( dbUnlock() )

      end if

   next

Return .t.

//---------------------------------------------------------------------------//

METHOD ImpFabricantes() CLASS ImportaArticulos

   local cMemoRead
   local aLineas
   local line
   local aRegistro

   if !File( ::cFileFabricante )
      Return .f.
   end if

   alineas           := hb_aTokens( MemoRead( ::cFileFabricante ), CRLF )

   for each line in alineas

      aRegistro := hb_aTokens( line, ";" )

      if len( aRegistro ) != 0

         msgWait( "Añadiendo " + formatText( AllTrim( aRegistro[2] ) ), "Atención", 0.05 )

         ( D():Fabricantes( ::nView ) )->( dbAppend() )

         ( D():Fabricantes( ::nView ) )->cCodFab    := AllTrim( aRegistro[1] )
         ( D():Fabricantes( ::nView ) )->cNomFab    := AllTrim( aRegistro[3] )

         ( D():Fabricantes( ::nView ) )->( dbUnlock() )

      end if

   next

Return .t.

//---------------------------------------------------------------------------//

METHOD ImpClientes() CLASS ImportaArticulos

   local cMemoRead
   local aLineas
   local line
   local aRegistro

   if !File( ::cFileCliente )
      Return .f.
   end if

   alineas           := hb_aTokens( MemoRead( ::cFileCliente ), CRLF )

   for each line in alineas

      aRegistro := hb_aTokens( line, "," )

      if len( aRegistro ) != 0

         msgWait( "Añadiendo " + formatText( AllTrim( aRegistro[3] ) ), "Atención", 0.05 )

         ( D():Clientes( ::nView ) )->( dbAppend() )

         ( D():Clientes( ::nView ) )->Cod       := Rjust( formatText( AllTrim( aRegistro[1] ) ), "0", RetNumCodCliEmp() )
         ( D():Clientes( ::nView ) )->Titulo    := formatText( AllTrim( aRegistro[5] ) ) + Space( 1 ) + formatText( AllTrim( aRegistro[4] ) )
         ( D():Clientes( ::nView ) )->cMeiInt   := formatText( AllTrim( aRegistro[6] ) )

         ( D():Clientes( ::nView ) )->( dbUnlock() )

      end if

   next

Return .t.

//---------------------------------------------------------------------------//

METHOD ImpDirecciones() CLASS ImportaArticulos

   local cMemoRead
   local aLineas
   local line
   local aRegistro
   local cCliente    := ""

   if !File( ::cFileDirecciones )
      Return .f.
   end if

   alineas           := hb_aTokens( MemoRead( ::cFileDirecciones ), CRLF )

   for each line in alineas

      aRegistro := hb_aTokens( line, "," )

      if len( aRegistro ) != 0 .and. len( aRegistro ) == 23

         msgWait( "Añadiendo " + formatText( AllTrim( aRegistro[11] ) ), "Atención", 0.05 )

         cCliente    := Rjust( formatText( AllTrim( aRegistro[4] ) ), "0", RetNumCodCliEmp() )

         if ( D():Clientes( ::nView ) )->( dbSeek( cCliente ) )

            if Empty( ( D():Clientes( ::nView ) )->Domicilio )

               if dbLock( ( D():Clientes( ::nView ) ) )

                  ( D():Clientes( ::nView ) )->Domicilio   := formatText( AllTrim( aRegistro[11] ) ) + Space( 1 ) + formatText( AllTrim( aRegistro[12] ) )
                  ( D():Clientes( ::nView ) )->CodPostal   := formatText( AllTrim( aRegistro[13] ) )
                  ( D():Clientes( ::nView ) )->Poblacion   := formatText( AllTrim( aRegistro[14] ) )
                  ( D():Clientes( ::nView ) )->Telefono    := formatText( AllTrim( aRegistro[16] ) )
                  ( D():Clientes( ::nView ) )->Movil       := formatText( AllTrim( aRegistro[17] ) )
                  ( D():Clientes( ::nView ) )->Nif         := formatText( AllTrim( aRegistro[19] ) )

                  ( D():Clientes( ::nView ) )->( dbUnlock() )

               end if

            else
               
               ( D():ClientesDirecciones( ::nView ) )->( dbAppend() )

                  ( D():ClientesDirecciones( ::nView ) )->cCodCli   := cCliente
                  ( D():ClientesDirecciones( ::nView ) )->cCodObr   := formatText( AllTrim( aRegistro[1] ) )
                  ( D():ClientesDirecciones( ::nView ) )->cNomObr   := formatText( AllTrim( aRegistro[8] ) )
                  ( D():ClientesDirecciones( ::nView ) )->cDirObr   := formatText( AllTrim( aRegistro[11] ) ) + Space( 1 ) + formatText( AllTrim( aRegistro[12] ) )
                  ( D():ClientesDirecciones( ::nView ) )->cPosObr   := formatText( AllTrim( aRegistro[13] ) )
                  ( D():ClientesDirecciones( ::nView ) )->cPobObr   := formatText( AllTrim( aRegistro[14] ) )
                  ( D():ClientesDirecciones( ::nView ) )->cTelObr   := formatText( AllTrim( aRegistro[16] ) )
                  ( D():ClientesDirecciones( ::nView ) )->cMovObr   := formatText( AllTrim( aRegistro[17] ) )
                  ( D():ClientesDirecciones( ::nView ) )->Nif       := formatText( AllTrim( aRegistro[19] ) )

               ( D():ClientesDirecciones( ::nView ) )->( dbUnlock() )

            end if

         end if

      end if

   next

Return .t.

//---------------------------------------------------------------------------//

METHOD ImpImagenes() CLASS ImportaArticulos

   local cMemoRead
   local aLineas
   local line
   local aRegistro
   local cImagen  := ""

   /*if !File( ::cFileImagenes )
      Return .f.
   end if

   alineas           := hb_aTokens( MemoRead( ::cFileImagenes ), CRLF )

   for each line in alineas

      aRegistro := hb_aTokens( line, ";" )

      if len( aRegistro ) != 0

         msgWait( "Añadiendo " + AllTrim( aRegistro[6] ), "Atención", 0.05 )

         if !ArticulosImagenesModel():exist( aRegistro[1], cFileImageName( aRegistro[6] ) )

            ( D():ArticuloImagenes( ::nView ) )->( dbAppend() )

            ( D():ArticuloImagenes( ::nView ) )->cCodArt    := AllTrim( aRegistro[1] )
            ( D():ArticuloImagenes( ::nView ) )->cImgArt    := cFileImageName( aRegistro[6] )
            ( D():ArticuloImagenes( ::nView ) )->cRmtArt    := aRegistro[6]

            ( D():ArticuloImagenes( ::nView ) )->( dbUnlock() )

         end if

      end if

   next*/

   ( D():ArticuloImagenes( ::nView ) )->( dbGoTop() )

   while !( D():ArticuloImagenes( ::nView ) )->( eof() )

      msgWait( "Descargando " + AllTrim( ( D():ArticuloImagenes( ::nView ) )->cRmtArt ) , "Atención", 0.1 )

      DownLoadFileToUrl( AllTrim( ( D():ArticuloImagenes( ::nView ) )->cRmtArt ), ::cUrlDwImagen + AllTrim( ( D():ArticuloImagenes( ::nView ) )->cImgArt ) )

      ( D():ArticuloImagenes( ::nView ) )->( dbSkip() )

   end while

   /*if len( ::aDownloadImagenes ) != 0

      for each cImagen in ::aDownloadImagenes
         
         msgWait( "Descargando " + cImagen, "Atención", 0.05 )

         DownLoadFileToUrl( ::cUrlPsImagen + cImagen, ::cUrlDwImagen + cImagen )

      next

   end if*/

Return .t.

//---------------------------------------------------------------------------//

METHOD ImpPropiedades() CLASS ImportaArticulos

   local cMemoRead
   local aLineas
   local line
   local aRegistro

   if !File( ::cFilePropiedades )
      Return .f.
   end if

   alineas           := hb_aTokens( MemoRead( ::cFilePropiedades ), CRLF )

   for each line in alineas

      aRegistro := hb_aTokens( line, ";" )

      if len( aRegistro ) != 0

         msgWait( "Añadiendo " + AllTrim( aRegistro[2] ), "Atención", 0.05 )

         ( D():Propiedades( ::nView ) )->( dbAppend() )

         ( D():Propiedades( ::nView ) )->cCodPro    := AllTrim( aRegistro[1] )
         ( D():Propiedades( ::nView ) )->cDesPro    := Upper( AllTrim( aRegistro[2] ) )

         ( D():Propiedades( ::nView ) )->( dbUnlock() )

      end if

   next


Return .t.

//---------------------------------------------------------------------------//

METHOD ImpLineasPropiedades() CLASS ImportaArticulos

   local cMemoRead
   local aLineas
   local line
   local aRegistro

   if !File( ::cFileLineasPropiedades )
      Return .f.
   end if

   alineas           := hb_aTokens( MemoRead( ::cFileLineasPropiedades ), CRLF )

   for each line in alineas

      aRegistro := hb_aTokens( line, ";" )

      if len( aRegistro ) != 0

         msgWait( "Añadiendo " + AllTrim( aRegistro[4] ), "Atención", 0.05 )

         ( D():PropiedadesLineas( ::nView ) )->( dbAppend() )

         ( D():PropiedadesLineas( ::nView ) )->cCodPro    := AllTrim( aRegistro[2] )
         ( D():PropiedadesLineas( ::nView ) )->cCodTbl    := AllTrim( aRegistro[1] )
         ( D():PropiedadesLineas( ::nView ) )->cDesTbl    := AllTrim( aRegistro[4] )
         ( D():PropiedadesLineas( ::nView ) )->nColor     := nHex( AllTrim( aRegistro[3] ) )


         ( D():PropiedadesLineas( ::nView ) )->( dbUnlock() )

      end if

   next

Return .t.

//---------------------------------------------------------------------------//

METHOD ImpPropiedadesArticulos() CLASS ImportaArticulos

   local cMemoRead
   local aLineas
   local line
   local aRegistro
   local nOrdAnt     := ( D():PropiedadesLineas( ::nView ) )->( OrdSetFocus( "CCODTBL" ) )

   if !File( ::cFilePropiedadesArticulos )
      Return .f.
   end if

   alineas           := hb_aTokens( MemoRead( ::cFilePropiedadesArticulos ), CRLF )

   for each line in alineas

      aRegistro := hb_aTokens( line, ";" )

      if len( aRegistro ) != 0

         msgWait( "Añadiendo " + formatText( AllTrim( aRegistro[1] ) ), "Atención", 0.05 )

         if ( D():PropiedadesLineas( ::nView ) )->( dbSeek( Padr( AllTrim( aRegistro[2] ), 40 ) ) )

            ( D():ArticuloPrecioPropiedades( ::nView ) )->( dbAppend() )

            ( D():ArticuloPrecioPropiedades( ::nView ) )->cCodArt    := AllTrim( aRegistro[1] )
            ( D():ArticuloPrecioPropiedades( ::nView ) )->cCodDiv    := "EUR"
            ( D():ArticuloPrecioPropiedades( ::nView ) )->cCodPr1    := ( D():PropiedadesLineas( ::nView ) )->cCodPro
            ( D():ArticuloPrecioPropiedades( ::nView ) )->cValPr1    := AllTrim( aRegistro[2] )

            ( D():ArticuloPrecioPropiedades( ::nView ) )->( dbUnlock() )



            if ( D():Articulos( ::nView ) )->( dbSeek( Padr( AllTrim( aRegistro[1] ), 18 ) ) )

               if dbLock( D():Articulos( ::nView ) )

                  ( D():Articulos( ::nView ) )->cCodPrp1             := ( D():PropiedadesLineas( ::nView ) )->cCodPro

                  ( D():Articulos( ::nView ) )->( dbUnlock() )

               end if

            end if

         end if

      end if

   next

   ( D():PropiedadesLineas( ::nView ) )->( OrdSetFocus( nOrdAnt ) )

Return .t.

//---------------------------------------------------------------------------//

METHOD ImpDescripciones() CLASS ImportaArticulos

   local cMemoRead
   local aLineas
   local line
   local aRegistro
   local nOrdAnt     := ( D():Articulos( ::nView ) )->( OrdSetFocus( "Codigo" ) )

   if !File( ::cFileDescripcionesArticulos )
      Return .f.
   end if

   alineas           := hb_aTokens( MemoRead( ::cFileDescripcionesArticulos ), CRLF )

   for each line in alineas

      aRegistro := hb_aTokens( line, ";" )

      if len( aRegistro ) != 0

         msgWait( "Añadiendo " + AllTrim( aRegistro[1] ) + "-" + AllTrim( aRegistro[2] ), "Atención", 0.05 )

         if ( D():Articulos( ::nView ) )->( dbSeek( Padr( AllTrim( aRegistro[1] ), 18 ) ) )

            if !Empty( AllTrim( aRegistro[2] ) )

               if dbLock( D():Articulos( ::nView ) )

                  ( D():Articulos( ::nView ) )->Nombre      := AllTrim( aRegistro[2] )
                  ( D():Articulos( ::nView ) )->mDesTec     := AllTrim( aRegistro[2] )

                  ( D():Articulos( ::nView ) )->( dbUnlock() )

               end if

            end if

         end if

      end if

   next

   ( D():Articulos( ::nView ) )->( OrdSetFocus( nOrdAnt ) )

Return .t.

//---------------------------------------------------------------------------//

static Function formatText( cText )

   local cResult  := ""

   if !Empty( cText )
      cResult     := SubStr( cText, 2, Len( cText ) - 2 )
   end if

Return cResult

//---------------------------------------------------------------------------//

static Function formatNumber( cText )

   local nResult  := 0

   if !Empty( cText )
      nResult     := Val( AllTrim( cText ) )
   end if

Return nResult

//---------------------------------------------------------------------------//

static Function cFileImageName( cText )

   local cResult  := ""

   if !Empty( cText )
      cResult     := SubStr( AllTrim( cText ), 33 )
      cResult     := SubStr( cResult, 1, at( "t", cResult ) - 2 )
      cResult     := cResult + ".jpg"
   end if

Return cResult

//---------------------------------------------------------------------------//