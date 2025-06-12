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

   METHOD getCodigoFamilia()
   METHOD getNombreFamilia()
   
   METHOD siguienteLinea()       INLINE ( ++::nFilaInicioImportacion )

   METHOD existeRegistro()       INLINE ( FamiliasModel():Exist( ::getCodigoFamilia() ) )

   METHOD importarFamilia()

   METHOD reemplazaFamilia()

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

   if At( "FAMILIA", upper( ::cFicheroExcel ) ) == 0
      MsgStop( "Fichero inválido" )
      Return ( .f. )
   end if

   msgrun( "Procesando fichero " + ::cFicheroExcel, "Espere por favor...",  {|| ::procesaFicheroExcel() } )

   msginfo( "Proceso finalizado" )

Return ( .t. )

//----------------------------------------------------------------------------//

METHOD procesaFicheroExcel()

   ::openExcel()

   while ( ::filaValida() )

      if !Empty( ::getCodigoFamilia() )

         MsgWait( "Familia: " + AllTrim( ::getCodigoFamilia() ) + " - " + AllTrim( ::getNombreFamilia() ), Str( ::nFilaInicioImportacion ), 0.01 )

         //if !::existeRegistro()
            ::importarFamilia()
         /*else
            ::reemplazaFamilia()
         end if*/

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

   cSql         := "INSERT INTO " + ADSBaseModel():getEmpresaTableName( "Familias" ) 
   cSql         += " ( CCODFAM, CNOMFAM ) VALUES "
   cSql         += " ( " + quoted( ::GetCodigoFamilia() )
   cSql         += ", " + quoted( ::GetNombreFamilia() ) + " )"

   ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )

Return nil

//---------------------------------------------------------------------------// 

METHOD getCodigoFamilia()

   local cCodeFamilia   := ""

   if !Empty( ::getExcelString( "B" ) )
      cCodeFamilia      += AllTrim( ::getExcelString( "B" ) )
   end if

   /*if !Empty( ::getExcelString( "B" ) )
      
      if !Empty( ::getExcelString( "A" ) )
         cCodeFamilia      += "."
      end if

      cCodeFamilia      += AllTrim( ::getExcelString( "B" ) )
   end if

   if !Empty( ::getExcelString( "C" ) )
      cCodeFamilia      += "."
      cCodeFamilia      += AllTrim( ::getExcelString( "C" ) )
   end if

   if !Empty( ::getExcelString( "D" ) )
      cCodeFamilia      += "."
      cCodeFamilia      += AllTrim( ::getExcelString( "D" ) )
   end if*/

Return ( Padr( cCodeFamilia, 16 ) )

//---------------------------------------------------------------------------// 

METHOD getNombreFamilia()

   local cNameFamilia   := ""

   if !Empty( ::getExcelString( "A" ) )
      cNameFamilia      += AllTrim( ::getExcelString( "A" ) )
   end if

   /*if !Empty( ::getExcelString( "F" ) )
      cNameFamilia      += " "
      cNameFamilia      += AllTrim( ::getExcelString( "F" ) )
   end if

   if !Empty( ::getExcelString( "G" ) )
      cNameFamilia      += " "
      cNameFamilia      += AllTrim( ::getExcelString( "G" ) )
   end if*/

Return ( Padr( strtran( cNameFamilia, "'", "" ), 40 ) )

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getCodigoFamilia() ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"