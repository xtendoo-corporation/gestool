#include "FiveWin.Ch"
#include "Factu.ch"

/*
Hay que crear los campos extra necesarios para este script---------------------
*/

Function DuplicaArticulos( nView )                  
         
   local oDuplicaArticulos    := TDuplicaArticulos():New( nView )

   oDuplicaArticulos:Run()

Return nil

//---------------------------------------------------------------------------//  

CLASS TDuplicaArticulos

   DATA oDialog
   DATA nView

   DATA oSemanaOrigen
   DATA cSemanaOrigen

   DATA oSemanaDestino
   DATA cSemanaDestino

   DATA oBmpSemanaOrigen
   DATA oBmpSemanaDestino

   DATA cNewCodigo

   DATA selectArticulo
   DATA selectPropiedades

   DATA cCodigoTipoArticulo

   METHOD New()

   METHOD Run()

   METHOD SetResources()      INLINE ( SetResources( fullcurdir() + "Script\Articulos\DuplicaArticulos.dll" ) )

   METHOD FreeResources()     INLINE ( FreeResources() )

   METHOD Resource() 

   METHOD Process()

   METHOD lValidProcess()

   METHOD getNombreNuevoArticulo()

   METHOD duplicaPropiedades()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView ) CLASS TDuplicaArticulos

   ::nView                    := nView

   ::cCodigoTipoArticulo      := "1   "

   ::selectArticulo           := "selectArticulo"
   ::selectPropiedades        := "selectPropiedades"

Return ( Self )

//----------------------------------------------------------------------------//

METHOD Run() CLASS TDuplicaArticulos

   ::SetResources()

   ::Resource()

   ::FreeResources()

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD Resource() CLASS TDuplicaArticulos

   DEFINE DIALOG ::oDialog RESOURCE "DUPLICAARTICULOS" 

   REDEFINE GET ::oSemanaOrigen ;
      VAR      ::cSemanaOrigen ;
      ID       100 ;
      IDTEXT   110 ;
      BITMAP   "LUPA" ;
      OF       ::oDialog

      ::oSemanaOrigen:bHelp   := {|| brwTemporada( ::oSemanaOrigen, ::oSemanaOrigen:oHelpText, ::oBmpSemanaDestino, .f. ) }
      ::oSemanaOrigen:bValid  := {|| cTemporada( ::oSemanaOrigen, D():Temporadas( ::nView ), ::oSemanaOrigen:oHelpText, ::oBmpSemanaDestino ) }

   REDEFINE BITMAP ::oBmpSemanaOrigen ;
      ID       120 ;
      TRANSPARENT ;
      OF       ::oDialog

   REDEFINE GET ::oSemanaDestino ;
      VAR      ::cSemanaDestino ;
      ID       130 ;
      IDTEXT   140 ;
      BITMAP   "LUPA" ;
      OF       ::oDialog

      ::oSemanaDestino:bHelp   := {|| brwTemporada( ::oSemanaDestino, ::oSemanaDestino:oHelpText, ::oBmpSemanaDestino, .f. ) }
      ::oSemanaDestino:bValid  := {|| cTemporada( ::oSemanaDestino, D():Temporadas( ::nView ), ::oSemanaDestino:oHelpText, ::oBmpSemanaDestino ) }

   REDEFINE BITMAP ::oBmpSemanaDestino ;
      ID       150 ;
      TRANSPARENT ;
      OF       ::oDialog

   REDEFINE BUTTON ;
      ID          IDOK ;
      OF          ::oDialog ;
      ACTION      ( if( ::lValidProcess(), ::Process(), ) )

   REDEFINE BUTTON ;
      ID          IDCANCEL ;
      OF          ::oDialog ;
      ACTION      ( ::oDialog:End( IDCANCEL ) )

   ::oDialog:AddFastKey( VK_F5, {|| if( ::lValidProcess(), ::Process(), ) } )

   ::oDialog:bStart := {|| ::oSemanaOrigen:SetFocus() }

   ACTIVATE DIALOG ::oDialog CENTER

   ::oBmpSemanaOrigen:End()
   ::oBmpSemanaDestino:End()

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD lValidProcess() CLASS TDuplicaArticulos

   if Empty( ::cSemanaOrigen )
      MsgStop( "La semana origen no puede estar vacía" )
      ::oSemanaOrigen:SetFocus()
      Return .f.
   end if

   if Empty( ::cSemanaDestino )
      MsgStop( "La semana destino no puede estar vacía" )
      ::oSemanaDestino:SetFocus()
      Return .f.
   end if

   if AllTrim( ::cSemanaOrigen ) == AllTrim( ::cSemanaDestino )
      MsgStop( "La semana origen no puede ser igual a la semana a crear" )
      ::oSemanaDestino:SetFocus()
      Return .f.
   end if

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD Process() CLASS TDuplicaArticulos

   local cArticulos
   local cSql     := "SELECT * FROM " + cPatEmp() + "Articulo" + ;
                     " WHERE cCodTemp = " + quoted( ::cSemanaOrigen ) + " AND cCodTip = " + quoted( ::cCodigoTipoArticulo )

   ADSBaseModel():ExecuteSqlStatement( cSql, @::selectArticulo )

   ( ::selectArticulo )->( dbGoTop() )

   while !( ::selectArticulo )->( Eof() )

      MsgWait( "Duplicando:" + AllTrim( ( ::selectArticulo )->Codigo ) + " - " + AllTrim( ( ::selectArticulo )->Nombre ), "", 0.5 )

      ::cNewCodigo  := NextKey( dbLast( D():Articulos( ::nView ) ), D():Articulos( ::nView ) ) 

      appendRegisterByHash( ::selectArticulo, D():Articulos( ::nView ), {  "Codigo" => ::cNewCodigo ,;
                                                                           "Nombre" => ::getNombreNuevoArticulo() ,;
                                                                           "cCodTemp" => ::cSemanaDestino } )

      ::duplicaPropiedades()

      ( ::selectArticulo )->( dbSkip() )

   end while

   ::oDialog:End( IDOK )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD getNombreNuevoArticulo() CLASS TDuplicaArticulos

   local cFufijo  := ""
   local cNombre  := ""

   cFufijo        := right( AllTrim( ::oSemanaDestino:oHelpText:VarGet() ), 2 )
   cNombre        := SubStr( AllTrim( ( ::selectArticulo )->Nombre ), 1, Len( AllTrim( ( ::selectArticulo )->Nombre ) ) - 2 )
   cNombre        += cFufijo

Return ( cNombre )

//---------------------------------------------------------------------------//

METHOD duplicaPropiedades() CLASS TDuplicaArticulos

   local cSql     := "SELECT * FROM " + cPatEmp() + "ArtDiv" + ;
                     " WHERE cCodArt = " + quoted( ( ::selectArticulo )->Codigo )

   ADSBaseModel():ExecuteSqlStatement( cSql, @::selectPropiedades )

   ( ::selectPropiedades )->( dbGoTop() )

   while !( ::selectPropiedades )->( Eof() )

      appendRegisterByHash( ::selectPropiedades, D():ArticuloPrecioPropiedades( ::nView ), { "cCodArt" => ::cNewCodigo } )
      
      ( ::selectPropiedades )->( dbSkip() )

   end while

Return ( .t. )

//---------------------------------------------------------------------------//