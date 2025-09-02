// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*Datos de identificación de factura expedida para operaciones de consulta*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_IDFacturaExpedidaBCType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'IDFacturaExpedidaBC'
        DATA IDEmisorFactura AS OBJECT INIT Nil
        DATA NumSerieFactura AS OBJECT INIT Nil
        DATA FechaExpedicionFactura AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_IDFacturaExpedidaBCType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_IDFacturaExpedidaBCType

    ::IDEmisorFactura := TVF_NIFType():New( ::__oVerifactu, REQUIRED, "IDEmisorFactura" , Self)
    ::NumSerieFactura := TVF_TextoIDFacturaType():New( ::__oVerifactu, REQUIRED, "NumSerieFactura" , Self)
    ::FechaExpedicionFactura := TVF_fecha():New( ::__oVerifactu, REQUIRED, "FechaExpedicionFactura" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_IDFacturaExpedidaBCType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::IDEmisorFactura:HasData() .Or.;
       ::NumSerieFactura:HasData() .Or.;
       ::FechaExpedicionFactura:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::IDEmisorFactura:BuildXml( oChild )
        ::NumSerieFactura:BuildXml( oChild )
        ::FechaExpedicionFactura:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_IDFacturaExpedidaBCType


    ::IDEmisorFactura:Check()
    ::NumSerieFactura:Check()
    ::FechaExpedicionFactura:Check()

Return ( Self )

METHOD HasData() CLASS TVF_IDFacturaExpedidaBCType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::IDEmisorFactura:HasData(), .T., lHasData)
    lHasData := Iif( ::NumSerieFactura:HasData(), .T., lHasData)
    lHasData := Iif( ::FechaExpedicionFactura:HasData(), .T., lHasData)

Return ( lHasData )


