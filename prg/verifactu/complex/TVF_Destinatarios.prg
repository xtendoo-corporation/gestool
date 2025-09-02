// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*Contraparte de la operación. Cliente*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_Destinatarios FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()
        METHOD Set()
        DATA __cTag      AS STRING  INIT ''
        DATA aIDDestinatario AS ARRAY INIT Array( 0 )

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

        DATA __nMaxOccurs AS NUMERIC INIT 1000
            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_Destinatarios

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_Destinatarios

    ::aIDDestinatario := Array( 0 )
    ::__nMaxOccurs := 1000

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_Destinatarios
    
    Local oChild as Object := Nil
    Local cXml as String := ""

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

oIDDestinatario := Nil  // TODO: Definirlo bien como Local

    for each oIDDestinatario in ::aIDDestinatario
                            
        oIDDestinatario:BuildXml( oChild )
                                
    next

    
Return ( Self )

METHOD Check() CLASS TVF_Destinatarios


    ::IDDestinatario:Check()
    If Len( ::aIDDestinatario ) > ::__nMaxOccurs

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'Se han incluido ' + Alltrim( Str( Len( ::aIDDestinatario ) ) ) + ' IDDestinatario y solo se permiten ' + Alltrim( Str( ::__nMaxOccurs ) )
        
            
    Endif                

Return ( Self )

METHOD HasData() CLASS TVF_Destinatarios

    Local lHasData as Logical := .F.

    lHasData := Iif( ::IDDestinatario:HasData(), .T., lHasData)

Return ( lHasData )

METHOD Set( oPersonaFisicaJuridicaType ) CLASS TVF_Destinatarios

    If oPersonaFisicaJuridicaType == Nil

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'No se ha pasado inig├║n dato'
        Return( Self )

    Endif

    If .Not. HB_ISOBJECT( oPersonaFisicaJuridicaType )

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'No se ha pasado un objeto'
        Return( Self )

    Endif

    If .Not. oPersonaFisicaJuridicaType:IsKindOf( "TVF_PersonaFisicaJuridicaType" )

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El objeto no es del tipo TVF_PersonaFisicaJuridicaType'
        Return( Self )

    Endif

    aAdd( ::aIDDestinatario, oPersonaFisicaJuridicaType )

Return( Self )

