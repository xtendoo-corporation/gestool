// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/**/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_FechaExpedicionConsultaType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'FechaExpedicionConsulta'

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_FechaExpedicionConsultaType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_FechaExpedicionConsultaType


Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_FechaExpedicionConsultaType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")


    
Return ( Self )

METHOD Check() CLASS TVF_FechaExpedicionConsultaType



Return ( Self )

METHOD HasData() CLASS TVF_FechaExpedicionConsultaType

    Local lHasData as Logical := .F.


Return ( lHasData )


