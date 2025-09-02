// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*Sistemas de facturacion*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_SistemaFacturacionFact FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT ''
        DATA Cabecera AS OBJECT INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA oFather     AS OBJECT  INIT Nil
        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_SistemaFacturacionFact

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_SistemaFacturacionFact

    ::Cabecera := TVF_Cabecera():New( ::__oVerifactu, REQUIRED, "Cabecera" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_SistemaFacturacionFact
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::Cabecera:HasData()

        oChild := oFather:NewChild( ::__cTag,"")

        ::Cabecera:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_SistemaFacturacionFact


    ::Cabecera:Check()

Return ( Self )

METHOD HasData() CLASS TVF_SistemaFacturacionFact

    Local lHasData as Logical := .F.

    lHasData := Iif( ::Cabecera:HasData(), .T., lHasData)

Return ( lHasData )


