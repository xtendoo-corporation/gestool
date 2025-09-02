// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*IdPeticion asociado a la factura registrada previamente en el sistema. Solo se suministra si la factura enviada es rechazada por estar duplicada*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_RegistroDuplicadoType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'RegistroDuplicado'
        DATA IdPeticionRegistroDuplicado AS OBJECT INIT Nil
        DATA EstadoRegistroDuplicado AS OBJECT INIT Nil
        DATA CodigoErrorRegistro AS OBJECT INIT Nil
        DATA DescripcionErrorRegistro AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_RegistroDuplicadoType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_RegistroDuplicadoType

    ::IdPeticionRegistroDuplicado := TVF_TextMax20Type():New( ::__oVerifactu, REQUIRED, "IdPeticionRegistroDuplicado" , Self)
    ::EstadoRegistroDuplicado := TVF_EstadoRegistroSFType():New( ::__oVerifactu, REQUIRED, "EstadoRegistroDuplicado" , Self)
    ::CodigoErrorRegistro := TVF_ErrorDetalleType():New( ::__oVerifactu, OPTIONAL, "CodigoErrorRegistro" , Self)
    ::DescripcionErrorRegistro := TVF_TextMax500Type():New( ::__oVerifactu, OPTIONAL, "DescripcionErrorRegistro" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_RegistroDuplicadoType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::IdPeticionRegistroDuplicado:HasData() .Or.;
       ::EstadoRegistroDuplicado:HasData() .Or.;
       ::CodigoErrorRegistro:HasData() .Or.;
       ::DescripcionErrorRegistro:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::IdPeticionRegistroDuplicado:BuildXml( oChild )
        ::EstadoRegistroDuplicado:BuildXml( oChild )
        ::CodigoErrorRegistro:BuildXml( oChild )
        ::DescripcionErrorRegistro:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_RegistroDuplicadoType


    ::IdPeticionRegistroDuplicado:Check()
    ::EstadoRegistroDuplicado:Check()
    ::CodigoErrorRegistro:Check()
    ::DescripcionErrorRegistro:Check()

Return ( Self )

METHOD HasData() CLASS TVF_RegistroDuplicadoType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::IdPeticionRegistroDuplicado:HasData(), .T., lHasData)
    lHasData := Iif( ::EstadoRegistroDuplicado:HasData(), .T., lHasData)
    lHasData := Iif( ::CodigoErrorRegistro:HasData(), .T., lHasData)
    lHasData := Iif( ::DescripcionErrorRegistro:HasData(), .T., lHasData)

Return ( lHasData )


