// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*Datos de cabecera*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_CabeceraType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'Cabecera'
        DATA ObligadoEmision AS OBJECT INIT Nil
        DATA Representante AS OBJECT INIT Nil
        DATA RemisionVoluntaria AS OBJECT INIT Nil
        DATA RemisionRequerimiento AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_CabeceraType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_CabeceraType

    ::ObligadoEmision := TVF_PersonaFisicaJuridicaESType():New( ::__oVerifactu, REQUIRED, "ObligadoEmision" , Self)
    ::Representante := TVF_PersonaFisicaJuridicaESType():New( ::__oVerifactu, OPTIONAL, "Representante" , Self)
    ::RemisionVoluntaria := TVF_RemisionVoluntaria():New( ::__oVerifactu, OPTIONAL, "RemisionVoluntaria" , Self)
    ::RemisionRequerimiento := TVF_RemisionRequerimiento():New( ::__oVerifactu, OPTIONAL, "RemisionRequerimiento" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_CabeceraType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::ObligadoEmision:HasData() .Or.;
       ::Representante:HasData() .Or.;
       ::RemisionVoluntaria:HasData() .Or.;
       ::RemisionRequerimiento:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::ObligadoEmision:BuildXml( oChild )
        ::Representante:BuildXml( oChild )
        ::RemisionVoluntaria:BuildXml( oChild )
        ::RemisionRequerimiento:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_CabeceraType


    ::ObligadoEmision:Check()
    ::Representante:Check()
    ::RemisionVoluntaria:Check()
    ::RemisionRequerimiento:Check()

Return ( Self )

METHOD HasData() CLASS TVF_CabeceraType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::ObligadoEmision:HasData(), .T., lHasData)
    lHasData := Iif( ::Representante:HasData(), .T., lHasData)
    lHasData := Iif( ::RemisionVoluntaria:HasData(), .T., lHasData)
    lHasData := Iif( ::RemisionRequerimiento:HasData(), .T., lHasData)

Return ( lHasData )


