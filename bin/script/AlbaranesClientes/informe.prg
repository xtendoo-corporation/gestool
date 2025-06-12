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

   MsgInfo( "Proceso finalizado con �xito" )

   ::oDialog:End( IDOK )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD addCabecera() CLASS TInformeArticulos

   ::cFichero  += "N�mero Referencia Interno" + ::separador
   ::cFichero  += "N�mero Asiento Previo" + ::separador
   ::cFichero  += "Fecha Movimiento" + ::separador
   ::cFichero  += "Fecha Registro Contable" + ::separador
   ::cFichero  += "Tipo Movimiento" + ::separador
   ::cFichero  += "Informaci�n adicional Diferencia en Menos" + ::separador
   ::cFichero  += "R�gimen Fiscal" + ::separador
   ::cFichero  += "Tipo de Operaci�n" + ::separador
   ::cFichero  += "N�mero Operaci�n" + ::separador
   ::cFichero  += "Descripci�n Unidad de Fabricaci�n" + ::separador
   ::cFichero  += "C�digo Unidad de Fabricaci�n" + ::separador
   ::cFichero  += "Tipo Justificante" + ::separador
   ::cFichero  += "N�mero Justificante" + ::separador
   ::cFichero  += "Tipo Documento Identificativo" + ::separador
   ::cFichero  += "N�mero Documento Identificativo" + ::separador
   ::cFichero  += "Raz�n Social" + ::separador
   ::cFichero  += "CAE/N�mero Seed" + ::separador
   ::cFichero  += "Repercusi�n Tipo Documento Identificativo" + ::separador
   ::cFichero  += "Repercusi�n N�mero Documento Identificativo" + ::separador
   ::cFichero  += "Repercusi�n Raz�n Social" + ::separador
   ::cFichero  += "Ep�grafe" + ::separador
   ::cFichero  += "C�digo Ep�grafe" + ::separador
   ::cFichero  += "C�digo NC" + ::separador
   ::cFichero  += "Clave" + ::separador
   ::cFichero  += "Cantidad" + ::separador
   ::cFichero  += "Unidad de Medida" + ::separador
   ::cFichero  += "Descripci�n de Producto" + ::separador
   ::cFichero  += "Referencia Producto" + ::separador
   ::cFichero  += "Densidad" + ::separador
   ::cFichero  += "Grado Alcoh�lico" + ::separador
   ::cFichero  += "Cantidad de Alcohol Puro" + ::separador
   ::cFichero  += "Porcentaje de Extracto" + ::separador
   ::cFichero  += "Kg. - Extracto" + ::separador
   ::cFichero  += "Grado Plato Medio" + ::separador
   ::cFichero  += "Grado Ac�tico" + ::separador
   ::cFichero  += "Tipo de Envase" + ::separador
   ::cFichero  += "Capacidad de Envase" + ::separador
   ::cFichero  += "N�mero de Envases" + ::separador
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

   ::cFichero  += AllTrim( ( ::selectLineasAlbaran )->cSerAlb ) + AllTrim( Str( ( ::selectLineasAlbaran )->nNumAlb ) ) + "-" + AllTrim( Str( ( ::selectLineasAlbaran )->nNumLin ) ) + ::separador //N�mero Referencia Interno  ---  SerieNumero-Numerolinea
   ::cFichero  += ::separador //N�mero Asiento Previo  ---  Nada
   ::cFichero  += AllTrim( dToc( ( ::selectLineasAlbaran )->dFecAlb ) )  + ::separador //Fecha Movimiento  ---  Fecha Albar�n
   ::cFichero  += AllTrim( dToc( ( ::selectLineasAlbaran )->dFecAlb ) )  + ::separador //Fecha Registro Contable  ---  Fecha Albar�n
   ::cFichero  += AllTrim( getCustomExtraField( "001", "Clientes", ( ::selectLineasAlbaran )->cCodCli ) ) + ::separador //Tipo Movimiento  ---  Campo Extra 001 Clientes
   ::cFichero  += ::separador //Informaci�n adicional Diferencia en Menos  ---  Nada
   ::cFichero  += AllTrim( getCustomExtraField( "002", "Clientes", ( ::selectLineasAlbaran )->cCodCli ) ) + ::separador //R�gimen Fiscal  ---  Campo Extra 002 Clientes
   ::cFichero  += ::separador //Tipo de Operaci�n  ---  Nada
   ::cFichero  += ::separador //N�mero Operaci�n  ---  Nada
   ::cFichero  += ::separador //Descripci�n Unidad de Fabricaci�n  ---  Nada
   ::cFichero  += ::separador //C�digo Unidad de Fabricaci�n  ---  Nada
   if !Empty( AllTrim( ( D():AlbaranesClientes( ::nView ) )->cCodSuAlb ) )
      ::cFichero  += "J01"  + ::separador //Tipo Justificante  ---  Depende de su albar�n
      ::cFichero  += AllTrim( ( D():AlbaranesClientes( ::nView ) )->cCodSuAlb ) + ::separador //N�mero Justificante  ---  Depende de su albar�n (Si est� vac�o es el n�mero de albar�n, si no es el de su albar�n)
   else
      ::cFichero  += "J03"  + ::separador //Tipo Justificante  ---  Depende de su albar�n
      ::cFichero  += AllTrim( ( ::selectLineasAlbaran )->cSerAlb ) + AllTrim( Str( ( ::selectLineasAlbaran )->nNumAlb ) ) + ::separador //N�mero Justificante  ---  Depende de su albar�n (Si est� vac�o es el n�mero de albar�n, si no es el de su albar�n)
   end if
   ::cFichero  += AllTrim( getCustomExtraField( "003", "Clientes", ( ::selectLineasAlbaran )->cCodCli ) ) + ::separador //Tipo Documento Identificativo  --- Campo extra en cliente 003 Clientes
   if !Empty( AllTrim( getCustomExtraField( "004", "Albaranes a clientes", ( ::selectLineasAlbaran )->cSerAlb + Str( ( ::selectLineasAlbaran )->nNumAlb ) + ( ::selectLineasAlbaran )->cSufAlb ) ) )
      ::cFichero  += AllTrim( getCustomExtraField( "004", "Albaranes a clientes", ( ::selectLineasAlbaran )->cSerAlb + Str( ( ::selectLineasAlbaran )->nNumAlb ) + ( ::selectLineasAlbaran )->cSufAlb ) ) + ::separador //N�mero Documento Identificativo  ---  Campo extra en linea de albar�n de cliente 004 AlbCliL
   else
      ::cFichero  += AllTrim( ( D():AlbaranesClientes( ::nView ) )->cDniCli ) + ::separador //N�mero Documento Identificativo  ---  Campo extra en linea de albar�n de cliente
   end if
   ::cFichero  += AllTrim( ( D():AlbaranesClientes( ::nView ) )->cNomCli ) + ::separador //Raz�n Social  ---  Nombre del cliente
   ::cFichero  += AllTrim( getCustomExtraField( "005", "Clientes", ( ::selectLineasAlbaran )->cCodCli ) ) + ::separador //CAE/N�mero Seed  ---  Campo extra en la ficha del cliente 005 Cli
   ::cFichero  += ::separador //Repercusi�n Tipo Documento Identificativo  ---  Nada
   ::cFichero  += ::separador //Repercusi�n N�mero Documento Identificativo  ---  Nada
   ::cFichero  += ::separador //Repercusi�n Raz�n Social  ---  Nada
   ::cFichero  += ::separador //Ep�grafe  ---  Nada
   ::cFichero  += "A0" + ::separador //C�digo Ep�grafe  ---  "A0" Constante
   ::cFichero   += AllTrim( getCustomExtraField( "006", "Art�culos", ( ::selectLineasAlbaran )->cRef ) ) + ::separador //C�digo NC  ---  Campo extra en art�culos 006 Art
   ::cFichero  += AllTrim( getCustomExtraField( "007", "Art�culos", ( ::selectLineasAlbaran )->cRef ) ) + ::separador //Clave  ---  Campo extra en art�culos 007 Art
   ::cFichero  += AllTrim( Trans( ( nTotNAlbCli( ::selectLineasAlbaran ) * ( ::selectLineasAlbaran )->nVolumen ), "@E 999999.99" ) ) + ::separador //Cantidad  ---  Und * Vol del art�culo
   ::cFichero  += "LTR" + ::separador //Unidad de Medida  ---  "LTR" Constante
   ::cFichero  += AllTrim( retFld( ( D():Articulos( ::nView ) )->cCodCate, D():Categorias( ::nView ), "cNombre" ) ) + ::separador //Descripci�n de Producto  --- Nombre de la categoria
   ::cFichero  += AllTrim( retFld( ( D():Articulos( ::nView ) )->cCodCate, D():Categorias( ::nView ), "cNombre" ) )  + ::separador //Referencia Producto  ---  Nombre de la categoria
   ::cFichero  += ::separador //Densidad  ---  Nada
   if ValType( getCustomExtraField( "008", "Art�culos", ( ::selectLineasAlbaran )->cRef ) ) == "N"
      ::cFichero  += AllTrim( Trans( getCustomExtraField( "008", "Art�culos", ( ::selectLineasAlbaran )->cRef ), "@E 999999.99" ) ) + ::separador //Grado Alcoh�lico  ---  Campo extra en el art�culo 008 Art
      ::cFichero  += AllTrim( Trans( ( ( ( nTotNAlbCli( ::selectLineasAlbaran ) * ( ::selectLineasAlbaran )->nVolumen ) * getCustomExtraField( "008", "Art�culos", ( ::selectLineasAlbaran )->cRef ) ) / 100 ), "@E 999999.999" ) ) + ::separador //Cantidad de Alcohol Puro  ---  N� de litros por grado alcoholico dividido entre 100
   else
      ::cFichero  += "0,00" + ::separador //Grado Alcoh�lico  ---  Campo extra en el art�culo 008 Art
      ::cFichero  += "0,000" + ::separador //Cantidad de Alcohol Puro  ---  N� de litros por grado alcoholico dividido entre 100
   end if
   ::cFichero  += ::separador //Porcentaje de Extracto  ---  Nada
   ::cFichero  += ::separador //Kg. - Extracto  ---  Nada
   ::cFichero  += ::separador //Grado Plato Medio  ---  Nada
   ::cFichero  += ::separador //Grado Ac�tico  ---  Nada
   ::cFichero  += "AD01" + ::separador //Tipo de Envase  ---  "AD01" Constante
   ::cFichero  += AllTrim( Trans( ( ::selectLineasAlbaran )->nVolumen, "@E 999999.99" ) )  + ::separador //Capacidad de Envase  ---  Volumen del art�culo
   ::cFichero  += AllTrim( Trans( nTotNAlbCli( ::selectLineasAlbaran ), "@E 999999.99" ) ) + ::separador //N�mero de Envases  ---  Cajas por unidades
   ::cFichero  += AllTrim( ( ::selectLineasAlbaran )->mObsLin ) + ::finLinea  //Observaciones  ---  Observaciones de las lineas

Return ( .t. )

//---------------------------------------------------------------------------//