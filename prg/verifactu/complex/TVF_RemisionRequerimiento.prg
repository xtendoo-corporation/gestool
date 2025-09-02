// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/**/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_RemisionRequerimiento FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT ''
        DATA RefRequerimiento AS OBJECT INIT Nil
        DATA FinRequerimiento AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_RemisionRequerimiento

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_RemisionRequerimiento

    ::RefRequerimiento := TVF_TextMax18Type():New( ::__oVerifactu, REQUIRED, "RefRequerimiento" , Self)
    ::FinRequerimiento := TVF_FinRequerimientoType():New( ::__oVerifactu, OPTIONAL, "FinRequerimiento" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_RemisionRequerimiento
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::RefRequerimiento:HasData() .Or.;
       ::FinRequerimiento:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::RefRequerimiento:BuildXml( oChild )
        ::FinRequerimiento:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_RemisionRequerimiento


    ::RefRequerimiento:Check()
    ::FinRequerimiento:Check()

Return ( Self )

METHOD HasData() CLASS TVF_RemisionRequerimiento

    Local lHasData as Logical := .F.

    lHasData := Iif( ::RefRequerimiento:HasData(), .T., lHasData)
    lHasData := Iif( ::FinRequerimiento:HasData(), .T., lHasData)

Return ( lHasData )


