// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/**/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_OperacionType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'Operacion'
        DATA TipoOperacion AS OBJECT INIT Nil
        DATA Subsanacion AS OBJECT INIT Nil
        DATA RechazoPrevio AS OBJECT INIT Nil
        DATA SinRegistroPrevio AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_OperacionType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_OperacionType

    ::TipoOperacion := TVF_TipoOperacionType():New( ::__oVerifactu, REQUIRED, "TipoOperacion" , Self)
    ::Subsanacion := TVF_SubsanacionType():New( ::__oVerifactu, OPTIONAL, "Subsanacion" , Self)
    ::RechazoPrevio := TVF_RechazoPrevioType():New( ::__oVerifactu, OPTIONAL, "RechazoPrevio" , Self)
    ::SinRegistroPrevio := TVF_SinRegistroPrevioType():New( ::__oVerifactu, OPTIONAL, "SinRegistroPrevio" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_OperacionType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::TipoOperacion:HasData() .Or.;
       ::Subsanacion:HasData() .Or.;
       ::RechazoPrevio:HasData() .Or.;
       ::SinRegistroPrevio:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::TipoOperacion:BuildXml( oChild )
        ::Subsanacion:BuildXml( oChild )
        ::RechazoPrevio:BuildXml( oChild )
        ::SinRegistroPrevio:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_OperacionType


    ::TipoOperacion:Check()
    ::Subsanacion:Check()
    ::RechazoPrevio:Check()
    ::SinRegistroPrevio:Check()

Return ( Self )

METHOD HasData() CLASS TVF_OperacionType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::TipoOperacion:HasData(), .T., lHasData)
    lHasData := Iif( ::Subsanacion:HasData(), .T., lHasData)
    lHasData := Iif( ::RechazoPrevio:HasData(), .T., lHasData)
    lHasData := Iif( ::SinRegistroPrevio:HasData(), .T., lHasData)

Return ( lHasData )


