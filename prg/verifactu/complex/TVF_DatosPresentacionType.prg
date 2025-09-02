// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/**/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_DatosPresentacionType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'DatosPresentacion'
        DATA NIFPresentador AS OBJECT INIT Nil
        DATA TimestampPresentacion AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_DatosPresentacionType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_DatosPresentacionType

    ::NIFPresentador := TVF_NIFType():New( ::__oVerifactu, REQUIRED, "NIFPresentador" , Self)
    ::TimestampPresentacion := TVF_dateTime():New( ::__oVerifactu, REQUIRED, "TimestampPresentacion" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_DatosPresentacionType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::NIFPresentador:HasData() .Or.;
       ::TimestampPresentacion:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::NIFPresentador:BuildXml( oChild )
        ::TimestampPresentacion:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_DatosPresentacionType


    ::NIFPresentador:Check()
    ::TimestampPresentacion:Check()

Return ( Self )

METHOD HasData() CLASS TVF_DatosPresentacionType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::NIFPresentador:HasData(), .T., lHasData)
    lHasData := Iif( ::TimestampPresentacion:HasData(), .T., lHasData)

Return ( lHasData )


