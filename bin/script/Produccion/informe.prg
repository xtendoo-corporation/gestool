#include "FiveWin.Ch"
#include "Factu.ch"

/*
Hay que crear los campos extra necesarios para este script---------------------
*/

Function InformeArticulos( oProducc )                  
         
   local oInformeArticulos    := TInformeArticulos():New( oProducc )

   oInformeArticulos:Run()

Return nil

//---------------------------------------------------------------------------//  

CLASS TInformeArticulos

   DATA oDialog
   DATA oProducc

   DATA oFecIni
   DATA dFecIni
   DATA oFecFin
   DATA dFecFin

   DATA cCodCate

   DATA separador
   DATA finLinea

   DATA cFichero

   DATA cNameFile

   DATA selectLineasProducidas
   DATA selectLineasConsumidas

   METHOD New()

   METHOD Run()

   METHOD SetResources()      INLINE ( SetResources( fullcurdir() + "Script\Produccion\Informe.dll" ) )

   METHOD FreeResources()     INLINE ( FreeResources() )

   METHOD Resource() 

   METHOD Process()

   METHOD addCabecera()

   METHOD getLineasProducidas()
   METHOD addLineasProducidas()
   METHOD getLineasConsumidas()
   METHOD addLineasConsumidas()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( oProducc ) CLASS TInformeArticulos

   ::oProducc                 := oProducc

   ::dFecIni                  := cTod( "01/01/" + AllTrim( Str( Year( Date() ) ) ) )
   ::dFecFin                  := GetSysDate()

   ::separador                := ";"
   ::finLinea                 := CRLF
   ::cFichero                 := ""

   ::cCodCate                 := ""

   ::cNameFile                := ""

   ::selectLineasProducidas   := "selectLineasProducidas"
   ::selectLineasConsumidas   := "selectLineasConsumidas"

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

   ::addCabecera()

   ::getLineasProducidas()
   ::addLineasProducidas()

   ::getLineasConsumidas()
   ::addLineasConsumidas()

   ::cNameFile             := "c:\ficheros\Produccion"
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

METHOD getLineasProducidas() CLASS TInformeArticulos

   local cSql        := "SELECT * FROM " + cPatEmp() + "ProLin" + ;
                        " WHERE dFecOrd >= " + quoted( dToc( ::dFecIni ) ) + " AND dFecOrd <= " + quoted( dToc( ::dFecFin ) )

   ADSBaseModel():ExecuteSqlStatement( cSql, @::selectLineasProducidas )

   ( ::selectLineasProducidas )->( dbGoTop() )

   while !( ::selectLineasProducidas )->( Eof() )

      if !Empty( ( ::selectLineasProducidas )->cCodArt )

         ::cCodCate  := ArticulosModel():getField( 'CCODCATE', 'Codigo', ( ::selectLineasProducidas )->cCodArt )
         
         if AllTrim( ::cCodCate ) == "001" .or.;
            AllTrim( ::cCodCate ) == "002" .or.;
            AllTrim( ::cCodCate ) == "003" .or.;
            AllTrim( ::cCodCate ) == "004" .or.;
            AllTrim( ::cCodCate ) == "005" .or.;
            AllTrim( ::cCodCate ) == "006" .or.;
            AllTrim( ::cCodCate ) == "007" .or.;
            AllTrim( ::cCodCate ) == "008" .or.;
            AllTrim( ::cCodCate ) == "009" .or.;
            AllTrim( ::cCodCate ) == "010" .or.;
            AllTrim( ::cCodCate ) == "011" .or.;
            AllTrim( ::cCodCate ) == "012" .or.;
            AllTrim( ::cCodCate ) == "013" .or.;
            AllTrim( ::cCodCate ) == "014" .or.;
            AllTrim( ::cCodCate ) == "015" .or.;
            AllTrim( ::cCodCate ) == "016" .or.;
            AllTrim( ::cCodCate ) == "017" .or.;
            AllTrim( ::cCodCate ) == "018" .or.;
            AllTrim( ::cCodCate ) == "019" .or.;
            AllTrim( ::cCodCate ) == "020"

            ::addLineasProducidas()

         end if

      end if

      ( ::selectLineasProducidas )->( dbSkip() )

   end while

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD addLineasProducidas() CLASS TInformeArticulos

   MsgWait( "Duplicando:" + AllTrim( ( ::selectLineasProducidas )->cSerOrd ) + "/" + AllTrim( Str( ( ::selectLineasProducidas )->nNumOrd ) ) + "---" + AllTrim( ( ::selectLineasProducidas )->cCodArt ) + " - " + AllTrim( ( ::selectLineasProducidas )->cNomArt ), "", 0.05 )

   ::cFichero  += AllTrim( ( ::selectLineasProducidas )->cCodArt ) + ::finLinea

   /*::cFichero  += AllTrim( ( ::selectLineasProducidas )->cSerAlb ) + AllTrim( Str( ( ::selectLineasProducidas )->nNumAlb ) ) + "-" + AllTrim( Str( ( ::selectLineasProducidas )->nNumLin ) ) + ::separador //Número Referencia Interno  ---  SerieNumero-Numerolinea
   ::cFichero  += ::separador //Número Asiento Previo  ---  Nada
   ::cFichero  += AllTrim( dToc( ( ::selectLineasProducidas )->dFecAlb ) )  + ::separador //Fecha Movimiento  ---  Fecha Albarán
   ::cFichero  += AllTrim( dToc( ( ::selectLineasProducidas )->dFecAlb ) )  + ::separador //Fecha Registro Contable  ---  Fecha Albarán
   ::cFichero  += AllTrim( getCustomExtraField( "001", "Clientes", ( ::selectLineasProducidas )->cCodCli ) ) + ::separador //Tipo Movimiento  ---  Campo Extra 001 Clientes
   ::cFichero  += ::separador //Información adicional Diferencia en Menos  ---  Nada
   ::cFichero  += AllTrim( getCustomExtraField( "002", "Clientes", ( ::selectLineasProducidas )->cCodCli ) ) + ::separador //Régimen Fiscal  ---  Campo Extra 002 Clientes
   ::cFichero  += ::separador //Tipo de Operación  ---  Nada
   ::cFichero  += ::separador //Número Operación  ---  Nada
   ::cFichero  += ::separador //Descripción Unidad de Fabricación  ---  Nada
   ::cFichero  += ::separador //Código Unidad de Fabricación  ---  Nada
   if !Empty( AllTrim( ( D():AlbaranesClientes( ::nView ) )->cCodSuAlb ) )
      ::cFichero  += "J01"  + ::separador //Tipo Justificante  ---  Depende de su albarán
      ::cFichero  += AllTrim( ( D():AlbaranesClientes( ::nView ) )->cCodSuAlb ) + ::separador //Número Justificante  ---  Depende de su albarán (Si está vacío es el número de albarán, si no es el de su albarán)
   else
      ::cFichero  += "J03"  + ::separador //Tipo Justificante  ---  Depende de su albarán
      ::cFichero  += AllTrim( ( ::selectLineasProducidas )->cSerAlb ) + AllTrim( Str( ( ::selectLineasProducidas )->nNumAlb ) ) + ::separador //Número Justificante  ---  Depende de su albarán (Si está vacío es el número de albarán, si no es el de su albarán)
   end if
   ::cFichero  += AllTrim( getCustomExtraField( "003", "Clientes", ( ::selectLineasProducidas )->cCodCli ) ) + ::separador //Tipo Documento Identificativo  --- Campo extra en cliente 003 Clientes
   if !Empty( AllTrim( getCustomExtraField( "004", "Albaranes a clientes", ( ::selectLineasProducidas )->cSerAlb + Str( ( ::selectLineasProducidas )->nNumAlb ) + ( ::selectLineasProducidas )->cSufAlb ) ) )
      ::cFichero  += AllTrim( getCustomExtraField( "004", "Albaranes a clientes", ( ::selectLineasProducidas )->cSerAlb + Str( ( ::selectLineasProducidas )->nNumAlb ) + ( ::selectLineasProducidas )->cSufAlb ) ) + ::separador //Número Documento Identificativo  ---  Campo extra en linea de albarán de cliente 004 AlbCliL
   else
      ::cFichero  += AllTrim( ( D():AlbaranesClientes( ::nView ) )->cDniCli ) + ::separador //Número Documento Identificativo  ---  Campo extra en linea de albarán de cliente
   end if
   ::cFichero  += AllTrim( ( D():AlbaranesClientes( ::nView ) )->cNomCli ) + ::separador //Razón Social  ---  Nombre del cliente
   ::cFichero  += AllTrim( getCustomExtraField( "005", "Clientes", ( ::selectLineasProducidas )->cCodCli ) ) + ::separador //CAE/Número Seed  ---  Campo extra en la ficha del cliente 005 Cli
   ::cFichero  += ::separador //Repercusión Tipo Documento Identificativo  ---  Nada
   ::cFichero  += ::separador //Repercusión Número Documento Identificativo  ---  Nada
   ::cFichero  += ::separador //Repercusión Razón Social  ---  Nada
   ::cFichero  += ::separador //Epígrafe  ---  Nada
   ::cFichero  += "A0" + ::separador //Código Epígrafe  ---  "A0" Constante
   ::cFichero   += AllTrim( getCustomExtraField( "006", "Artículos", ( ::selectLineasProducidas )->cRef ) ) + ::separador //Código NC  ---  Campo extra en artículos 006 Art
   ::cFichero  += AllTrim( getCustomExtraField( "007", "Artículos", ( ::selectLineasProducidas )->cRef ) ) + ::separador //Clave  ---  Campo extra en artículos 007 Art
   ::cFichero  += AllTrim( Trans( ( nTotNAlbCli( ::selectLineasProducidas ) * ( ::selectLineasProducidas )->nVolumen ), "@E 999999.99" ) ) + ::separador //Cantidad  ---  Und * Vol del artículo
   ::cFichero  += "LTR" + ::separador //Unidad de Medida  ---  "LTR" Constante
   ::cFichero  += AllTrim( retFld( ::cCodCate, D():Categorias( ::nView ), "cNombre" ) ) + ::separador //Descripción de Producto  --- Nombre de la categoria
   ::cFichero  += AllTrim( retFld( ::cCodCate, D():Categorias( ::nView ), "cNombre" ) )  + ::separador //Referencia Producto  ---  Nombre de la categoria
   ::cFichero  += ::separador //Densidad  ---  Nada
   if ValType( getCustomExtraField( "008", "Artículos", ( ::selectLineasProducidas )->cRef ) ) == "N"
      ::cFichero  += AllTrim( Trans( getCustomExtraField( "008", "Artículos", ( ::selectLineasProducidas )->cRef ), "@E 999999.99" ) ) + ::separador //Grado Alcohólico  ---  Campo extra en el artículo 008 Art
      ::cFichero  += AllTrim( Trans( ( ( ( nTotNAlbCli( ::selectLineasProducidas ) * ( ::selectLineasProducidas )->nVolumen ) * getCustomExtraField( "008", "Artículos", ( ::selectLineasProducidas )->cRef ) ) / 100 ), "@E 999999.999" ) ) + ::separador //Cantidad de Alcohol Puro  ---  Nº de litros por grado alcoholico dividido entre 100
   else
      ::cFichero  += "0,00" + ::separador //Grado Alcohólico  ---  Campo extra en el artículo 008 Art
      ::cFichero  += "0,000" + ::separador //Cantidad de Alcohol Puro  ---  Nº de litros por grado alcoholico dividido entre 100
   end if
   ::cFichero  += ::separador //Porcentaje de Extracto  ---  Nada
   ::cFichero  += ::separador //Kg. - Extracto  ---  Nada
   ::cFichero  += ::separador //Grado Plato Medio  ---  Nada
   ::cFichero  += ::separador //Grado Acético  ---  Nada
   ::cFichero  += "AD01" + ::separador //Tipo de Envase  ---  "AD01" Constante
   ::cFichero  += AllTrim( Trans( ( ::selectLineasProducidas )->nVolumen, "@E 999999.99" ) )  + ::separador //Capacidad de Envase  ---  Volumen del artículo
   ::cFichero  += AllTrim( Trans( nTotNAlbCli( ::selectLineasProducidas ), "@E 999999.99" ) ) + ::separador //Número de Envases  ---  Cajas por unidades
   ::cFichero  += AllTrim( ( ::selectLineasProducidas )->mObsLin ) + ::finLinea  //Observaciones  ---  Observaciones de las lineas*/

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD getLineasConsumidas() CLASS TInformeArticulos

   local cSql        := "SELECT * FROM " + cPatEmp() + "ProMat" + ;
                        " WHERE dFecOrd >= " + quoted( dToc( ::dFecIni ) ) + " AND dFecOrd <= " + quoted( dToc( ::dFecFin ) )

   ADSBaseModel():ExecuteSqlStatement( cSql, @::selectLineasConsumidas )

   ( ::selectLineasConsumidas )->( dbGoTop() )

   while !( ::selectLineasConsumidas )->( Eof() )

      if !Empty( ( ::selectLineasConsumidas )->cCodArt )

         ::cCodCate  := ArticulosModel():getField( 'CCODCATE', 'Codigo', ( ::selectLineasConsumidas )->cCodArt )
         
         if AllTrim( ::cCodCate ) == "001" .or.;
            AllTrim( ::cCodCate ) == "002" .or.;
            AllTrim( ::cCodCate ) == "003" .or.;
            AllTrim( ::cCodCate ) == "004" .or.;
            AllTrim( ::cCodCate ) == "005" .or.;
            AllTrim( ::cCodCate ) == "006" .or.;
            AllTrim( ::cCodCate ) == "007" .or.;
            AllTrim( ::cCodCate ) == "008" .or.;
            AllTrim( ::cCodCate ) == "009" .or.;
            AllTrim( ::cCodCate ) == "010" .or.;
            AllTrim( ::cCodCate ) == "011" .or.;
            AllTrim( ::cCodCate ) == "012" .or.;
            AllTrim( ::cCodCate ) == "013" .or.;
            AllTrim( ::cCodCate ) == "014" .or.;
            AllTrim( ::cCodCate ) == "015" .or.;
            AllTrim( ::cCodCate ) == "016" .or.;
            AllTrim( ::cCodCate ) == "017" .or.;
            AllTrim( ::cCodCate ) == "018" .or.;
            AllTrim( ::cCodCate ) == "019" .or.;
            AllTrim( ::cCodCate ) == "020"

            ::addLineasConsumidas()

         end if

      end if

      ( ::selectLineasConsumidas )->( dbSkip() )

   end while

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD addLineasConsumidas() CLASS TInformeArticulos

   MsgWait( "Duplicando:" + AllTrim( ( ::selectLineasConsumidas )->cSerOrd ) + "/" + AllTrim( Str( ( ::selectLineasConsumidas )->nNumOrd ) ) + "---" + AllTrim( ( ::selectLineasConsumidas )->cCodArt ) + " - " + AllTrim( ( ::selectLineasConsumidas )->cNomArt ), "", 0.05 )

   ::cFichero  += AllTrim( ( ::selectLineasConsumidas )->cCodArt ) + ::finLinea

   /*::cFichero  += AllTrim( ( ::selectLineasConsumidas )->cSerAlb ) + AllTrim( Str( ( ::selectLineasConsumidas )->nNumAlb ) ) + "-" + AllTrim( Str( ( ::selectLineasConsumidas )->nNumLin ) ) + ::separador //Número Referencia Interno  ---  SerieNumero-Numerolinea
   ::cFichero  += ::separador //Número Asiento Previo  ---  Nada
   ::cFichero  += AllTrim( dToc( ( ::selectLineasConsumidas )->dFecAlb ) )  + ::separador //Fecha Movimiento  ---  Fecha Albarán
   ::cFichero  += AllTrim( dToc( ( ::selectLineasConsumidas )->dFecAlb ) )  + ::separador //Fecha Registro Contable  ---  Fecha Albarán
   ::cFichero  += AllTrim( getCustomExtraField( "001", "Clientes", ( ::selectLineasConsumidas )->cCodCli ) ) + ::separador //Tipo Movimiento  ---  Campo Extra 001 Clientes
   ::cFichero  += ::separador //Información adicional Diferencia en Menos  ---  Nada
   ::cFichero  += AllTrim( getCustomExtraField( "002", "Clientes", ( ::selectLineasConsumidas )->cCodCli ) ) + ::separador //Régimen Fiscal  ---  Campo Extra 002 Clientes
   ::cFichero  += ::separador //Tipo de Operación  ---  Nada
   ::cFichero  += ::separador //Número Operación  ---  Nada
   ::cFichero  += ::separador //Descripción Unidad de Fabricación  ---  Nada
   ::cFichero  += ::separador //Código Unidad de Fabricación  ---  Nada
   if !Empty( AllTrim( ( D():AlbaranesClientes( ::nView ) )->cCodSuAlb ) )
      ::cFichero  += "J01"  + ::separador //Tipo Justificante  ---  Depende de su albarán
      ::cFichero  += AllTrim( ( D():AlbaranesClientes( ::nView ) )->cCodSuAlb ) + ::separador //Número Justificante  ---  Depende de su albarán (Si está vacío es el número de albarán, si no es el de su albarán)
   else
      ::cFichero  += "J03"  + ::separador //Tipo Justificante  ---  Depende de su albarán
      ::cFichero  += AllTrim( ( ::selectLineasConsumidas )->cSerAlb ) + AllTrim( Str( ( ::selectLineasConsumidas )->nNumAlb ) ) + ::separador //Número Justificante  ---  Depende de su albarán (Si está vacío es el número de albarán, si no es el de su albarán)
   end if
   ::cFichero  += AllTrim( getCustomExtraField( "003", "Clientes", ( ::selectLineasConsumidas )->cCodCli ) ) + ::separador //Tipo Documento Identificativo  --- Campo extra en cliente 003 Clientes
   if !Empty( AllTrim( getCustomExtraField( "004", "Albaranes a clientes", ( ::selectLineasConsumidas )->cSerAlb + Str( ( ::selectLineasConsumidas )->nNumAlb ) + ( ::selectLineasConsumidas )->cSufAlb ) ) )
      ::cFichero  += AllTrim( getCustomExtraField( "004", "Albaranes a clientes", ( ::selectLineasConsumidas )->cSerAlb + Str( ( ::selectLineasConsumidas )->nNumAlb ) + ( ::selectLineasConsumidas )->cSufAlb ) ) + ::separador //Número Documento Identificativo  ---  Campo extra en linea de albarán de cliente 004 AlbCliL
   else
      ::cFichero  += AllTrim( ( D():AlbaranesClientes( ::nView ) )->cDniCli ) + ::separador //Número Documento Identificativo  ---  Campo extra en linea de albarán de cliente
   end if
   ::cFichero  += AllTrim( ( D():AlbaranesClientes( ::nView ) )->cNomCli ) + ::separador //Razón Social  ---  Nombre del cliente
   ::cFichero  += AllTrim( getCustomExtraField( "005", "Clientes", ( ::selectLineasConsumidas )->cCodCli ) ) + ::separador //CAE/Número Seed  ---  Campo extra en la ficha del cliente 005 Cli
   ::cFichero  += ::separador //Repercusión Tipo Documento Identificativo  ---  Nada
   ::cFichero  += ::separador //Repercusión Número Documento Identificativo  ---  Nada
   ::cFichero  += ::separador //Repercusión Razón Social  ---  Nada
   ::cFichero  += ::separador //Epígrafe  ---  Nada
   ::cFichero  += "A0" + ::separador //Código Epígrafe  ---  "A0" Constante
   ::cFichero   += AllTrim( getCustomExtraField( "006", "Artículos", ( ::selectLineasConsumidas )->cRef ) ) + ::separador //Código NC  ---  Campo extra en artículos 006 Art
   ::cFichero  += AllTrim( getCustomExtraField( "007", "Artículos", ( ::selectLineasConsumidas )->cRef ) ) + ::separador //Clave  ---  Campo extra en artículos 007 Art
   ::cFichero  += AllTrim( Trans( ( nTotNAlbCli( ::selectLineasConsumidas ) * ( ::selectLineasConsumidas )->nVolumen ), "@E 999999.99" ) ) + ::separador //Cantidad  ---  Und * Vol del artículo
   ::cFichero  += "LTR" + ::separador //Unidad de Medida  ---  "LTR" Constante
   ::cFichero  += AllTrim( retFld( ::cCodCate, D():Categorias( ::nView ), "cNombre" ) ) + ::separador //Descripción de Producto  --- Nombre de la categoria
   ::cFichero  += AllTrim( retFld( ::cCodCate, D():Categorias( ::nView ), "cNombre" ) )  + ::separador //Referencia Producto  ---  Nombre de la categoria
   ::cFichero  += ::separador //Densidad  ---  Nada
   if ValType( getCustomExtraField( "008", "Artículos", ( ::selectLineasConsumidas )->cRef ) ) == "N"
      ::cFichero  += AllTrim( Trans( getCustomExtraField( "008", "Artículos", ( ::selectLineasConsumidas )->cRef ), "@E 999999.99" ) ) + ::separador //Grado Alcohólico  ---  Campo extra en el artículo 008 Art
      ::cFichero  += AllTrim( Trans( ( ( ( nTotNAlbCli( ::selectLineasConsumidas ) * ( ::selectLineasConsumidas )->nVolumen ) * getCustomExtraField( "008", "Artículos", ( ::selectLineasConsumidas )->cRef ) ) / 100 ), "@E 999999.999" ) ) + ::separador //Cantidad de Alcohol Puro  ---  Nº de litros por grado alcoholico dividido entre 100
   else
      ::cFichero  += "0,00" + ::separador //Grado Alcohólico  ---  Campo extra en el artículo 008 Art
      ::cFichero  += "0,000" + ::separador //Cantidad de Alcohol Puro  ---  Nº de litros por grado alcoholico dividido entre 100
   end if
   ::cFichero  += ::separador //Porcentaje de Extracto  ---  Nada
   ::cFichero  += ::separador //Kg. - Extracto  ---  Nada
   ::cFichero  += ::separador //Grado Plato Medio  ---  Nada
   ::cFichero  += ::separador //Grado Acético  ---  Nada
   ::cFichero  += "AD01" + ::separador //Tipo de Envase  ---  "AD01" Constante
   ::cFichero  += AllTrim( Trans( ( ::selectLineasConsumidas )->nVolumen, "@E 999999.99" ) )  + ::separador //Capacidad de Envase  ---  Volumen del artículo
   ::cFichero  += AllTrim( Trans( nTotNAlbCli( ::selectLineasConsumidas ), "@E 999999.99" ) ) + ::separador //Número de Envases  ---  Cajas por unidades
   ::cFichero  += AllTrim( ( ::selectLineasConsumidas )->mObsLin ) + ::finLinea  //Observaciones  ---  Observaciones de las lineas*/

Return ( .t. )

//---------------------------------------------------------------------------//