// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*Información básica que contienen los registros del sistema de facturacion*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_RegistroSf FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT ''
        DATA PeriodoImputacion AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_RegistroSf

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_RegistroSf

    ::PeriodoImputacion := TVF_PeriodoImputacion():New( ::__oVerifactu, REQUIRED, "PeriodoImputacion" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_RegistroSf
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::PeriodoImputacion:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::PeriodoImputacion:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_RegistroSf


    ::PeriodoImputacion:Check()

Return ( Self )

METHOD HasData() CLASS TVF_RegistroSf

    Local lHasData as Logical := .F.

    lHasData := Iif( ::PeriodoImputacion:HasData(), .T., lHasData)

Return ( lHasData )


