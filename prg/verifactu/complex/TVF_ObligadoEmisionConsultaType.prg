// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*Datos de una persona física o jurídica Española con un NIF asociado*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_ObligadoEmisionConsultaType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'ObligadoEmisionConsulta'
        DATA NombreRazon AS OBJECT INIT Nil
        DATA NIF AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_ObligadoEmisionConsultaType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_ObligadoEmisionConsultaType

    ::NombreRazon := TVF_TextMax120Type():New( ::__oVerifactu, REQUIRED, "NombreRazon" , Self)
    ::NIF := TVF_NIFType():New( ::__oVerifactu, REQUIRED, "NIF" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_ObligadoEmisionConsultaType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::NombreRazon:HasData() .Or.;
       ::NIF:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::NombreRazon:BuildXml( oChild )
        ::NIF:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_ObligadoEmisionConsultaType


    ::NombreRazon:Check()
    ::NIF:Check()

Return ( Self )

METHOD HasData() CLASS TVF_ObligadoEmisionConsultaType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::NombreRazon:HasData(), .T., lHasData)
    lHasData := Iif( ::NIF:HasData(), .T., lHasData)

Return ( lHasData )


