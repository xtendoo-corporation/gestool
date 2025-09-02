// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*Rango de fechas de expedicion*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_RangoFechaExpedicionType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'RangoFechaExpedicion'
        DATA Desde AS OBJECT INIT Nil
        DATA Hasta AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_RangoFechaExpedicionType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_RangoFechaExpedicionType

    ::Desde := TVF_fecha():New( ::__oVerifactu, OPTIONAL, "Desde" , Self)
    ::Hasta := TVF_fecha():New( ::__oVerifactu, OPTIONAL, "Hasta" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_RangoFechaExpedicionType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::Desde:HasData() .Or.;
       ::Hasta:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::Desde:BuildXml( oChild )
        ::Hasta:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_RangoFechaExpedicionType


    ::Desde:Check()
    ::Hasta:Check()

Return ( Self )

METHOD HasData() CLASS TVF_RangoFechaExpedicionType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::Desde:HasData(), .T., lHasData)
    lHasData := Iif( ::Hasta:HasData(), .T., lHasData)

Return ( lHasData )


