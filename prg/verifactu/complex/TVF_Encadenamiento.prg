// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/**/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_Encadenamiento FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT ''
        DATA PrimerRegistro AS OBJECT INIT Nil
        DATA RegistroAnterior AS OBJECT INIT Nil


        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_Encadenamiento

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_Encadenamiento

    ::PrimerRegistro := TVF_PrimerRegistroCadenaType():New( ::__oVerifactu, REQUIRED, "PrimerRegistro" , Self)
    ::RegistroAnterior := TVF_EncadenamientoFacturaAnteriorType():New( ::__oVerifactu, REQUIRED, "RegistroAnterior" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_Encadenamiento
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::PrimerRegistro:HasData() .Or.;
       ::RegistroAnterior:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::PrimerRegistro:BuildXml( oChild )
        ::RegistroAnterior:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_Encadenamiento

    ::PrimerRegistro:Check()
    ::RegistroAnterior:Check()

Return ( Self )

METHOD HasData() CLASS TVF_Encadenamiento

    Local lHasData as Logical := .F.

    lHasData := Iif( ::PrimerRegistro:HasData(), .T., lHasData )
    lHasData := Iif( ::RegistroAnterior:HasData(), .T., lHasData )

Return ( lHasData )