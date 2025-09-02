// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*Datos de identificación de factura que se anula para operaciones de baja*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_IDFacturaExpedidaBajaType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'IDFacturaExpedidaBaja'
        DATA IDEmisorFacturaAnulada AS OBJECT INIT Nil
        DATA NumSerieFacturaAnulada AS OBJECT INIT Nil
        DATA FechaExpedicionFacturaAnulada AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_IDFacturaExpedidaBajaType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_IDFacturaExpedidaBajaType

    ::IDEmisorFacturaAnulada := TVF_NIFType():New( ::__oVerifactu, REQUIRED, "IDEmisorFacturaAnulada" , Self)
    ::NumSerieFacturaAnulada := TVF_TextoIDFacturaType():New( ::__oVerifactu, REQUIRED, "NumSerieFacturaAnulada" , Self)
    ::FechaExpedicionFacturaAnulada := TVF_fecha():New( ::__oVerifactu, REQUIRED, "FechaExpedicionFacturaAnulada" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_IDFacturaExpedidaBajaType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::IDEmisorFacturaAnulada:HasData() .Or.;
       ::NumSerieFacturaAnulada:HasData() .Or.;
       ::FechaExpedicionFacturaAnulada:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::IDEmisorFacturaAnulada:BuildXml( oChild )
        ::NumSerieFacturaAnulada:BuildXml( oChild )
        ::FechaExpedicionFacturaAnulada:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_IDFacturaExpedidaBajaType


    ::IDEmisorFacturaAnulada:Check()
    ::NumSerieFacturaAnulada:Check()
    ::FechaExpedicionFacturaAnulada:Check()

Return ( Self )

METHOD HasData() CLASS TVF_IDFacturaExpedidaBajaType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::IDEmisorFacturaAnulada:HasData(), .T., lHasData)
    lHasData := Iif( ::NumSerieFacturaAnulada:HasData(), .T., lHasData)
    lHasData := Iif( ::FechaExpedicionFacturaAnulada:HasData(), .T., lHasData)

Return ( lHasData )


