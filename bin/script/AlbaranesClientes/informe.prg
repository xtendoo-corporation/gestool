#include "FiveWin.Ch"
#include "Factu.ch"

/*
Hay que crear los campos extra necesarios para este script---------------------
*/

Function InformeArticulos( nView )                  
         
   local oInformeArticulos    := TInformeArticulos():New( nView )

   oInformeArticulos:Run()

Return nil

//---------------------------------------------------------------------------//  

CLASS TInformeArticulos

   DATA oDialog
   DATA nView

   DATA oFecIni
   DATA dFecIni
   DATA oFecFin
   DATA dFecFin

   DATA separador
   DATA finLinea

   DATA cFichero

   DATA cNameFile

   DATA selectLineasAlbaran

   METHOD New()

   METHOD Run()

   METHOD SetResources()      INLINE ( SetResources( fullcurdir() + "Script\AlbaranesClientes\Informe.dll" ) )

   METHOD FreeResources()     INLINE ( FreeResources() )

   METHOD Resource() 

   METHOD Process()

   METHOD addCabecera()

   METHOD getLineasAlbaranes()

   METHOD addLineasAlbaranes()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView ) CLASS TInformeArticulos

   ::nView                 := nView

   ::dFecIni               := cTod( "01/01/" + AllTrim( Str( Year( Date() ) ) ) )
   ::dFecFin               := GetSysDate()

   ::separador             := ";"
   ::finLinea              := CRLF
   ::cFichero              := ""

   ::cNameFile             := ""

   ::selectLineasAlbaran   := "selectLineas"

Return ( Self )

//----------------------------------------------------------------------------//

METHOD Run() CLASS TInformeArticulos

   ::SetResources()

   ::Resource()

   ::FreeResources()

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD Resource() CLASS TInformeArticulos

   DEFINE DIALOG ::oDialog RESOURCE "INFORME" 

   REDEFINE GET ::oFecIni VAR ::dFecIni ;
      ID          100;
      SPINNER ;
      OF          ::oDialog

   REDEFINE GET ::oFecFin VAR ::dFecFin ;
      ID          110;
      SPINNER ;
      OF          ::oDialog

   REDEFINE BUTTON ;
      ID          IDOK ;
      OF          ::oDialog ;
      ACTION      ( ::Process() )

   REDEFINE BUTTON ;
      ID          IDCANCEL ;
      OF          ::oDialog ;
      ACTION      ( ::oDialog:End( IDCANCEL ) )

   ::oDialog:AddFastKey( VK_F5, {|| ::Process() } )

   ACTIVATE DIALOG ::oDialog CENTER

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD Process() CLASS TInformeArticulos

   local nHand
   local cNameFile
   local nOrdAnt     := ( D():AlbaranesClientes( ::nView ) )->( OrdSetFocus( "NNUMALB" ) )

   ::addCabecera()

   ::getLineasAlbaranes()
   
   ::addLineasAlbaranes()

   ::cNameFile             := "c:\ficheros\Silicie"
   ::cNameFile             += if( day( ::dFecIni ) < 10, "0" + AllTrim( Str( day( ::dFecIni ) ) ), AllTrim( Str( day( ::dFecIni ) ) ) )
   ::cNameFile             += if( month( ::dFecIni ) < 10, "0" + AllTrim( Str( month( ::dFecIni ) ) ), AllTrim( Str( month( ::dFecIni ) ) ) )
   ::cNameFile             += AllTrim( Str( year( ::dFecIni ) ) )
   ::cNameFile             += if( day( ::dFecFin ) < 10, "0" + AllTrim( Str( day( ::dFecFin ) ) ), AllTrim( Str( day( ::dFecFin ) ) ) )
   ::cNameFile             += if( month( ::dFecFin ) < 10, "0" + AllTrim( Str( month( ::dFecFin ) ) ), AllTrim( Str( month( ::dFecFin ) ) ) )
   ::cNameFile             += AllTrim( Str( year( ::dFecFin ) ) )
   ::cNameFile             += ".csv"

   if !Empty( ::cFichero )

      fErase( ::cNameFile )
      nHand                := fCreate( ::cNameFile )
      fWrite( nHand, ::cFichero )
      fClose( nHand )

   end if

   ( D():AlbaranesClientes( ::nView ) )->( OrdSetFocus( nOrdAnt ) )

   MsgInfo( "Proceso finalizado con éxito" )

   ::oDialog:End( IDOK )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD addCabecera() CLASS TInformeArticulos

   ::cFichero  += "Número Referencia Interno" + ::separador
   ::cFichero  += "Número Asiento Previo" + ::separador
   ::cFichero  += "Fecha Movimiento" + ::separador
   ::cFichero  += "Fecha Registro Contable" + ::separador
   ::cFichero  += "Tipo Movimiento" + ::separador
   ::cFichero  += "Información adicional Diferencia en Menos" + ::separador
   ::cFichero  += "Régimen Fiscal" + ::separador
   ::cFichero  += "Tipo de Operación" + ::separador
   ::cFichero  += "Número Operación" + ::separador
   ::cFichero  += "Descripción Unidad de Fabricación" + ::separador
   ::cFichero  += "Código Unidad de Fabricación" + ::separador
   ::cFichero  += "Tipo Justificante" + ::separador
   ::cFichero  += "Número Justificante" + ::separador
   ::cFichero  += "Tipo Documento Identificativo" + ::separador
   ::cFichero  += "Número Documento Identificativo" + ::separador
   ::cFichero  += "Razón Social" + ::separador
   ::cFichero  += "CAE/Número Seed" + ::separador
   ::cFichero  += "Repercusión Tipo Documento Identificativo" + ::separador
   ::cFichero  += "Repercusión Número Documento Identificativo" + ::separador
   ::cFichero  += "Repercusión Razón Social" + ::separador
   ::cFichero  += "Epígrafe" + ::separador
   ::cFichero  += "Código Epígrafe" + ::separador
   ::cFichero  += "Código NC" + ::separador
   ::cFichero  += "Clave" + ::separador
   ::cFichero  += "Cantidad" + ::separador
   ::cFichero  += "Unidad de Medida" + ::separador
   ::cFichero  += "Descripción de Producto" + ::separador
   ::cFichero  += "Referencia Producto" + ::separador
   ::cFichero  += "Densidad" + ::separador
   ::cFichero  += "Grado Alcohólico" + ::separador
   ::cFichero  += "Cantidad de Alcohol Puro" + ::separador
   ::cFichero  += "Porcentaje de Extracto" + ::separador
   ::cFichero  += "Kg. - Extracto" + ::separador
   ::cFichero  += "Grado Plato Medio" + ::separador
   ::cFichero  += "Grado Acético" + ::separador
   ::cFichero  += "Tipo de Envase" + ::separador
   ::cFichero  += "Capacidad de Envase" + ::separador
   ::cFichero  += "Número de Envases" + ::separador
   ::cFichero  += "Observaciones" + ::finLinea

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD getLineasAlbaranes() CLASS TInformeArticulos

   local cArticulos
   local cSql        := "SELECT * FROM " + cPatEmp() + "AlbCliL" + ;
                        " WHERE dFecAlb >= " + quoted( dToc( ::dFecIni ) ) + " AND dFecAlb <= " + quoted( dToc( ::dFecFin ) )

   ADSBaseModel():ExecuteSqlStatement( cSql, @::selectLineasAlbaran )

   ( ::selectLineasAlbaran )->( dbGoTop() )

   while !( ::selectLineasAlbaran )->( Eof() )

      if ( ( ::selectLineasAlbaran )->cSerAlb == "A" .or. ( ::selectLineasAlbaran )->cSerAlb == "E" ) .and.;
         !Empty( ( ::selectLineasAlbaran )->cRef )
         
         ( D():AlbaranesClientes( ::nView ) )->( dbSeek( ( ::selectLineasAlbaran )->cSerAlb + Str( ( ::selectLineasAlbaran )->nNumAlb ) + ( ::selectLineasAlbaran )->cSufAlb ) )
         ( D():Articulos( ::nView ) )->( dbSeek( ( ::selectLineasAlbaran )->cRef ) )

         if AllTrim( ( D():Articulos( ::nView ) )->cCodCate ) == "001" .or.;
            AllTrim( ( D():Articulos( ::nView ) )->cCodCate ) == "002" .or.;
            AllTrim( ( D():Articulos( ::nView ) )->cCodCate ) == "003" .or.;
            AllTrim( ( D():Articulos( ::nView ) )->cCodCate ) == "004"

            ::addLineasAlbaranes()

         end if

      end if

      ( ::selectLineasAlbaran )->( dbSkip() )

   end while

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD addLineasAlbaranes() CLASS TInformeArticulos

   MsgWait( "Duplicando:" + AllTrim( ( ::selectLineasAlbaran )->cSerAlb ) + "/" + AllTrim( Str( ( ::selectLineasAlbaran )->nNumAlb ) ) + "---" + AllTrim( ( ::selectLineasAlbaran )->cRef ) + " - " + AllTrim( ( ::selectLineasAlbaran )->cDetalle ), "", 0.05 )

   ::cFichero  += AllTrim( ( ::selectLineasAlbaran )->cSerAlb ) + AllTrim( Str( ( ::selectLineasAlbaran )->nNumAlb ) ) + "-" + AllTrim( Str( ( ::selectLineasAlbaran )->nNumLin ) ) + ::separador //Número Referencia Interno  ---  SerieNumero-Numerolinea
   ::cFichero  += ::separador //Número Asiento Previo  ---  Nada
   ::cFichero  += AllTrim( dToc( ( ::selectLineasAlbaran )->dFecAlb ) )  + ::separador //Fecha Movimiento  ---  Fecha Albarán
   ::cFichero  += AllTrim( dToc( ( ::selectLineasAlbaran )->dFecAlb ) )  + ::separador //Fecha Registro Contable  ---  Fecha Albarán
   ::cFichero  += AllTrim( getCustomExtraField( "001", "Clientes", ( ::selectLineasAlbaran )->cCodCli ) ) + ::separador //Tipo Movimiento  ---  Campo Extra 001 Clientes
   ::cFichero  += ::separador //Información adicional Diferencia en Menos  ---  Nada
   ::cFichero  += AllTrim( getCustomExtraField( "002", "Clientes", ( ::selectLineasAlbaran )->cCodCli ) ) + ::separador //Régimen Fiscal  ---  Campo Extra 002 Clientes
   ::cFichero  += ::separador //Tipo de Operación  ---  Nada
   ::cFichero  += ::separador //Número Operación  ---  Nada
   ::cFichero  += ::separador //Descripción Unidad de Fabricación  ---  Nada
   ::cFichero  += ::separador //Código Unidad de Fabricación  ---  Nada
   if !Empty( AllTrim( ( D():AlbaranesClientes( ::nView ) )->cCodSuAlb ) )
      ::cFichero  += "J01"  + ::separador //Tipo Justificante  ---  Depende de su albarán
      ::cFichero  += AllTrim( ( D():AlbaranesClientes( ::nView ) )->cCodSuAlb ) + ::separador //Número Justificante  ---  Depende de su albarán (Si está vacío es el número de albarán, si no es el de su albarán)
   else
      ::cFichero  += "J03"  + ::separador //Tipo Justificante  ---  Depende de su albarán
      ::cFichero  += AllTrim( ( ::selectLineasAlbaran )->cSerAlb ) + AllTrim( Str( ( ::selectLineasAlbaran )->nNumAlb ) ) + ::separador //Número Justificante  ---  Depende de su albarán (Si está vacío es el número de albarán, si no es el de su albarán)
   end if
   ::cFichero  += AllTrim( getCustomExtraField( "003", "Clientes", ( ::selectLineasAlbaran )->cCodCli ) ) + ::separador //Tipo Documento Identificativo  --- Campo extra en cliente 003 Clientes
   if !Empty( AllTrim( getCustomExtraField( "004", "Albaranes a clientes", ( ::selectLineasAlbaran )->cSerAlb + Str( ( ::selectLineasAlbaran )->nNumAlb ) + ( ::selectLineasAlbaran )->cSufAlb ) ) )
      ::cFichero  += AllTrim( getCustomExtraField( "004", "Albaranes a clientes", ( ::selectLineasAlbaran )->cSerAlb + Str( ( ::selectLineasAlbaran )->nNumAlb ) + ( ::selectLineasAlbaran )->cSufAlb ) ) + ::separador //Número Documento Identificativo  ---  Campo extra en linea de albarán de cliente 004 AlbCliL
   else
      ::cFichero  += AllTrim( ( D():AlbaranesClientes( ::nView ) )->cDniCli ) + ::separador //Número Documento Identificativo  ---  Campo extra en linea de albarán de cliente
   end if
   ::cFichero  += AllTrim( ( D():AlbaranesClientes( ::nView ) )->cNomCli ) + ::separador //Razón Social  ---  Nombre del cliente
   ::cFichero  += AllTrim( getCustomExtraField( "005", "Clientes", ( ::selectLineasAlbaran )->cCodCli ) ) + ::separador //CAE/Número Seed  ---  Campo extra en la ficha del cliente 005 Cli
   ::cFichero  += ::separador //Repercusión Tipo Documento Identificativo  ---  Nada
   ::cFichero  += ::separador //Repercusión Número Documento Identificativo  ---  Nada
   ::cFichero  += ::separador //Repercusión Razón Social  ---  Nada
   ::cFichero  += ::separador //Epígrafe  ---  Nada
   ::cFichero  += "A0" + ::separador //Código Epígrafe  ---  "A0" Constante
   ::cFichero   += AllTrim( getCustomExtraField( "006", "Artículos", ( ::selectLineasAlbaran )->cRef ) ) + ::separador //Código NC  ---  Campo extra en artículos 006 Art
   ::cFichero  += AllTrim( getCustomExtraField( "007", "Artículos", ( ::selectLineasAlbaran )->cRef ) ) + ::separador //Clave  ---  Campo extra en artículos 007 Art
   ::cFichero  += AllTrim( Trans( ( nTotNAlbCli( ::selectLineasAlbaran ) * ( ::selectLineasAlbaran )->nVolumen ), "@E 999999.99" ) ) + ::separador //Cantidad  ---  Und * Vol del artículo
   ::cFichero  += "LTR" + ::separador //Unidad de Medida  ---  "LTR" Constante
   ::cFichero  += AllTrim( retFld( ( D():Articulos( ::nView ) )->cCodCate, D():Categorias( ::nView ), "cNombre" ) ) + ::separador //Descripción de Producto  --- Nombre de la categoria
   ::cFichero  += AllTrim( retFld( ( D():Articulos( ::nView ) )->cCodCate, D():Categorias( ::nView ), "cNombre" ) )  + ::separador //Referencia Producto  ---  Nombre de la categoria
   ::cFichero  += ::separador //Densidad  ---  Nada
   if ValType( getCustomExtraField( "008", "Artículos", ( ::selectLineasAlbaran )->cRef ) ) == "N"
      ::cFichero  += AllTrim( Trans( getCustomExtraField( "008", "Artículos", ( ::selectLineasAlbaran )->cRef ), "@E 999999.99" ) ) + ::separador //Grado Alcohólico  ---  Campo extra en el artículo 008 Art
      ::cFichero  += AllTrim( Trans( ( ( ( nTotNAlbCli( ::selectLineasAlbaran ) * ( ::selectLineasAlbaran )->nVolumen ) * getCustomExtraField( "008", "Artículos", ( ::selectLineasAlbaran )->cRef ) ) / 100 ), "@E 999999.999" ) ) + ::separador //Cantidad de Alcohol Puro  ---  Nº de litros por grado alcoholico dividido entre 100
   else
      ::cFichero  += "0,00" + ::separador //Grado Alcohólico  ---  Campo extra en el artículo 008 Art
      ::cFichero  += "0,000" + ::separador //Cantidad de Alcohol Puro  ---  Nº de litros por grado alcoholico dividido entre 100
   end if
   ::cFichero  += ::separador //Porcentaje de Extracto  ---  Nada
   ::cFichero  += ::separador //Kg. - Extracto  ---  Nada
   ::cFichero  += ::separador //Grado Plato Medio  ---  Nada
   ::cFichero  += ::separador //Grado Acético  ---  Nada
   ::cFichero  += "AD01" + ::separador //Tipo de Envase  ---  "AD01" Constante
   ::cFichero  += AllTrim( Trans( ( ::selectLineasAlbaran )->nVolumen, "@E 999999.99" ) )  + ::separador //Capacidad de Envase  ---  Volumen del artículo
   ::cFichero  += AllTrim( Trans( nTotNAlbCli( ::selectLineasAlbaran ), "@E 999999.99" ) ) + ::separador //Número de Envases  ---  Cajas por unidades
   ::cFichero  += AllTrim( ( ::selectLineasAlbaran )->mObsLin ) + ::finLinea  //Observaciones  ---  Observaciones de las lineas

Return ( .t. )

//---------------------------------------------------------------------------//