// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*Datos de encadenamiento*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_EncadenamientoFacturaAnteriorType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'EncadenamientoFacturaAnterior'
        DATA IDEmisorFactura AS OBJECT INIT Nil
        DATA NumSerieFactura AS OBJECT INIT Nil
        DATA FechaExpedicionFactura AS OBJECT INIT Nil
        DATA Huella AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_EncadenamientoFacturaAnteriorType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_EncadenamientoFacturaAnteriorType

    ::IDEmisorFactura := TVF_NIFType():New( ::__oVerifactu, REQUIRED, "IDEmisorFactura" , Self)
    ::NumSerieFactura := TVF_TextMax60Type():New( ::__oVerifactu, REQUIRED, "NumSerieFactura" , Self)
    ::FechaExpedicionFactura := TVF_fecha():New( ::__oVerifactu, REQUIRED, "FechaExpedicionFactura" , Self)
    ::Huella := TVF_TextMax64Type():New( ::__oVerifactu, REQUIRED, "Huella" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_EncadenamientoFacturaAnteriorType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::IDEmisorFactura:HasData() .Or.;
       ::NumSerieFactura:HasData() .Or.;
       ::FechaExpedicionFactura:HasData() .Or.;
       ::Huella:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::IDEmisorFactura:BuildXml( oChild )
        ::NumSerieFactura:BuildXml( oChild )
        ::FechaExpedicionFactura:BuildXml( oChild )
        ::Huella:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_EncadenamientoFacturaAnteriorType


    ::IDEmisorFactura:Check()
    ::NumSerieFactura:Check()
    ::FechaExpedicionFactura:Check()
    ::Huella:Check()

Return ( Self )

METHOD HasData() CLASS TVF_EncadenamientoFacturaAnteriorType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::IDEmisorFactura:HasData(), .T., lHasData)
    lHasData := Iif( ::NumSerieFactura:HasData(), .T., lHasData)
    lHasData := Iif( ::FechaExpedicionFactura:HasData(), .T., lHasData)
    lHasData := Iif( ::Huella:HasData(), .T., lHasData)

Return ( lHasData )


