// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/**/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_DesgloseType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()
        METHOD Set()
        DATA __cTag      AS STRING  INIT 'Desglose'
        DATA aDetalleDesglose AS ARRAY INIT Array( 0 )

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

        DATA __nMaxOccurs AS NUMERIC INIT 12
            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_DesgloseType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_DesgloseType

    ::aDetalleDesglose := Array( 0 )
    ::__nMaxOccurs := 12

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_DesgloseType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

oDetalleDesglose := Nil  // TODO: Definirlo bien como Local

    for each oDetalleDesglose in ::aDetalleDesglose
                            
        oDetalleDesglose:BuildXml( oChild )
                                
    next

    
Return ( Self )

METHOD Check() CLASS TVF_DesgloseType


    ::DetalleDesglose:Check()
    If Len( ::aDetalleDesglose ) > ::__nMaxOccurs

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'Se han incluido ' + Alltrim( Str( Len( ::aDetalleDesglose ) ) ) + ' DetalleDesglose y solo se permiten ' + Alltrim( Str( ::__nMaxOccurs ) )
        
            
    Endif                

Return ( Self )

METHOD HasData() CLASS TVF_DesgloseType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::DetalleDesglose:HasData(), .T., lHasData)

Return ( lHasData )

METHOD Set( oDetalleType ) CLASS TVF_DesgloseType

    If oDetalleType == Nil

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'No se ha pasado inig├║n dato'
        Return( Self )

    Endif

    If .Not. HB_ISOBJECT( oDetalleType )

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'No se ha pasado un objeto'
        Return( Self )

    Endif

    If .Not. oDetalleType:IsKindOf( "TVF_DetalleType" )

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El objeto no es del tipo TVF_DetalleType'
        Return( Self )

    Endif

    aAdd( ::aDetalleDesglose, oDetalleType )

Return( Self )

