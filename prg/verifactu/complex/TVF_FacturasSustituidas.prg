// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*El ID de las facturas sustituidas, únicamente se rellena en el caso de facturas sustituidas*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_FacturasSustituidas FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()
        METHOD Set()
        DATA __cTag      AS STRING  INIT ''
        DATA aIDFacturaSustituida AS ARRAY INIT Array( 0 )

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

        DATA __nMaxOccurs AS NUMERIC INIT 1000
            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_FacturasSustituidas

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_FacturasSustituidas

    ::aIDFacturaSustituida := Array( 0 )
    ::__nMaxOccurs := 1000

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_FacturasSustituidas
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::aIDFacturaSustituida:NotEmpty()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")
        oIDFacturaSustituida := Nil  // TODO: Definirlo bien como Local

        for each oIDFacturaSustituida in ::aIDFacturaSustituida

            oIDFacturaSustituida:BuildXml( oChild )

        next

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_FacturasSustituidas


    ::IDFacturaSustituida:Check()
    If Len( ::aIDFacturaSustituida ) > ::__nMaxOccurs

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'Se han incluido ' + Alltrim( Str( Len( ::aIDFacturaSustituida ) ) ) + ' IDFacturaSustituida y solo se permiten ' + Alltrim( Str( ::__nMaxOccurs ) )
        
            
    Endif                

Return ( Self )

METHOD HasData() CLASS TVF_FacturasSustituidas

    Local lHasData as Logical := .F.

    lHasData := Iif( ::IDFacturaSustituida:HasData(), .T., lHasData)

Return ( lHasData )

METHOD Set( oIDFacturaARType ) CLASS TVF_FacturasSustituidas

    If oIDFacturaARType == Nil

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'No se ha pasado inig├║n dato'
        Return( Self )

    Endif

    If .Not. HB_ISOBJECT( oIDFacturaARType )

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'No se ha pasado un objeto'
        Return( Self )

    Endif

    If .Not. oIDFacturaARType:IsKindOf( "TVF_IDFacturaARType" )

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El objeto no es del tipo TVF_IDFacturaARType'
        Return( Self )

    Endif

    aAdd( ::aIDFacturaSustituida, oIDFacturaARType )

Return( Self )

