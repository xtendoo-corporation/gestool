// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*Desglose de Base y Cuota sustituida en las Facturas Rectificativas sustitutivas*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_DesgloseRectificacionType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'DesgloseRectificacion'
        DATA BaseRectificada AS OBJECT INIT Nil
        DATA CuotaRectificada AS OBJECT INIT Nil
        DATA CuotaRecargoRectificado AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_DesgloseRectificacionType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_DesgloseRectificacionType

    ::BaseRectificada := TVF_ImporteSgn12_2Type():New( ::__oVerifactu, REQUIRED, "BaseRectificada" , Self)
    ::CuotaRectificada := TVF_ImporteSgn12_2Type():New( ::__oVerifactu, REQUIRED, "CuotaRectificada" , Self)
    ::CuotaRecargoRectificado := TVF_ImporteSgn12_2Type():New( ::__oVerifactu, OPTIONAL, "CuotaRecargoRectificado" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_DesgloseRectificacionType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::BaseRectificada:HasData() .Or.;
       ::CuotaRectificada:HasData() .Or.;
       ::CuotaRecargoRectificado:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::BaseRectificada:BuildXml( oChild )
        ::CuotaRectificada:BuildXml( oChild )
        ::CuotaRecargoRectificado:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_DesgloseRectificacionType


    ::BaseRectificada:Check()
    ::CuotaRectificada:Check()
    ::CuotaRecargoRectificado:Check()

Return ( Self )

METHOD HasData() CLASS TVF_DesgloseRectificacionType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::BaseRectificada:HasData(), .T., lHasData)
    lHasData := Iif( ::CuotaRectificada:HasData(), .T., lHasData)
    lHasData := Iif( ::CuotaRecargoRectificado:HasData(), .T., lHasData)

Return ( lHasData )


