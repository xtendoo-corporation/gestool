#include "FiveWin.Ch"

#include "Hbxml.ch"
#include "Hbclass.ch"
#include "Fileio.ch"
#include "Factu.ch" 
      
//---------------------------------------------------------------------------//

Function ImportarExcelFamilias( nView )
	      
   local oImportarExcel    := TImportarExcelFamilias():New( nView )

   oImportarExcel:Run()

Return nil

//---------------------------------------------------------------------------//  

CLASS TImportarExcelFamilias FROM TImportarExcel

   METHOD New()

   METHOD Run()

   METHOD procesaFicheroExcel()

   METHOD filaValida()

   METHOD siguienteLinea()       INLINE ( ++::nFilaInicioImportacion )

   METHOD importarFamilia()

   METHOD reemplazaFamilia()

   METHOD getCodigoKit()
   METHOD getCodigoCompo()
   METHOD getUnd()
   METHOD getPrc()
   METHOD getNombre()

   METHOD MarcaArticulo()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView )

   ::nView                    := nView

   /*
   Cambiar el nombre del fichero-----------------------------------------------
   */

   ::cFicheroExcel            := cGetFile( "*.*", "Selección de fichero" )

   /*
   Cambiar la fila de cominezo de la importacion-------------------------------
   */

   ::nFilaInicioImportacion   := 1

Return ( Self )

//----------------------------------------------------------------------------//

METHOD Run()

   if !file( ::cFicheroExcel )
      msgStop( "El fichero " + ::cFicheroExcel + " no existe." )
      Return ( .f. )
   end if 

   /*if At( "FAMILIA", upper( ::cFicheroExcel ) ) == 0
      MsgStop( "Fichero inválido" )
      Return ( .f. )
   end if*/

   msgrun( "Procesando fichero " + ::cFicheroExcel, "Espere por favor...",  {|| ::procesaFicheroExcel() } )

   msginfo( "Proceso finalizado" )

Return ( .t. )

//----------------------------------------------------------------------------//

METHOD procesaFicheroExcel()

   ::openExcel()

   while ( ::filaValida() )

      if !Empty( ::getCodigoKit() )

         MsgWait( "Familia: " + AllTrim( ::getCodigoKit() ) + " - " + AllTrim( ::getNombre() ), Str( ::nFilaInicioImportacion ), 0.01 )

         ::importarFamilia()

      end if

      ::siguienteLinea()

   end while

   ::closeExcel()

Return nil

//---------------------------------------------------------------------------//

METHOD reemplazaFamilia()

   local cStm  := "UpdateFamiliaScript"
   local cSql  := ""

   cSql        := "UPDATE " + ADSBaseModel():getEmpresaTableName( "Familias" )
   cSql        += " SET CNOMFAM = " + quoted( ::GetNombreFamilia() ) + ", "
   cSql        += " CCODGRP = " + quoted( Padr( "6", 3 ) )
   cSql        += " WHERE CCODFAM = " + quoted( ::GetCodigoFamilia() )

   ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )

Return nil

//---------------------------------------------------------------------------//

METHOD importarFamilia()
   
   local cStm  := "InsertFamiliaScript"
   local cSql  := ""

   ::MarcaArticulo()

   cSql         := "INSERT INTO " + ADSBaseModel():getEmpresaTableName( "ArtKit" ) 
   cSql         += " ( CCODKIT, CREFKIT, NUNDKIT, NPREKIT, CDESKIT ) VALUES "
   cSql         += " ( " + quoted( ::getCodigoKit() )
   cSql         += ", " + quoted( ::getCodigoCompo() )
   cSql         += ", " + Str( ::getUnd() )
   cSql         += ", " + Str( ::getPrc() )
   cSql         += ", " + quoted( ::GetNombre() ) + " )"

   ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )

Return nil

//---------------------------------------------------------------------------// 

METHOD MarcaArticulo()

   local cStm  := "UpdateScriptArticulo"
   local cSql  := ""
   local cCodArt  := ::getCodigoKit()

   cSql        := "UPDATE " + ADSBaseModel():getEmpresaTableName( "Articulo" ) + Space( 1 )
   cSql        += "SET lKitArt=.t. "
   cSql        += "WHERE Codigo = " + toSQLString( cCodArt )

RETURN ( ADSBaseModel():ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------// 

METHOD getCodigoKit()

   local cCodeFamilia   := ""

   if !Empty( ::getExcelString( "A" ) )
      cCodeFamilia      += AllTrim( ::getExcelString( "A" ) )
   end if

Return ( Padr( cCodeFamilia, 18 ) )

//---------------------------------------------------------------------------// 

METHOD getCodigoCompo()

   local cCodeFamilia   := ""

   if !Empty( ::getExcelString( "B" ) )
      cCodeFamilia      += AllTrim( ::getExcelString( "B" ) )
   end if

Return ( Padr( cCodeFamilia, 18 ) )

//---------------------------------------------------------------------------// 

METHOD getUnd()

   local cCodeFamilia   := 0

   if !Empty( ::getExcelNumeric( "D" ) )
      cCodeFamilia      := ::getExcelNumeric( "D" )
   end if

Return ( cCodeFamilia )

//---------------------------------------------------------------------------// 

METHOD getPrc()

Return ( 0 )

//---------------------------------------------------------------------------// 

METHOD getNombre()

   local cNameFamilia   := ""

   if !Empty( ::getExcelString( "C" ) )
      cNameFamilia      += AllTrim( ::getExcelString( "C" ) )
   end if

Return ( Padr( strtran( cNameFamilia, "'", "" ), 40 ) )

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getCodigoKit() ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"