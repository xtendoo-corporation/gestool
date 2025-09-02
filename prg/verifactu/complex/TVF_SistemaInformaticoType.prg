// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/**/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_SistemaInformaticoType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'SistemaInformatico'
        DATA NombreRazon AS OBJECT INIT Nil
        DATA NIF AS OBJECT INIT Nil
        DATA NombreSistemaInformatico AS OBJECT INIT Nil
        DATA IdSistemaInformatico AS OBJECT INIT Nil
        DATA Version AS OBJECT INIT Nil
        DATA NumeroInstalacion AS OBJECT INIT Nil
        DATA TipoUsoPosibleSoloVerifactu AS OBJECT INIT Nil
        DATA TipoUsoPosibleMultiOT AS OBJECT INIT Nil
        DATA IndicadorMultiplesOT AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_SistemaInformaticoType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_SistemaInformaticoType

    ::NombreRazon := TVF_TextMax120Type():New( ::__oVerifactu, REQUIRED, "NombreRazon" , Self)
    ::NIF := TVF_NIFType():New( ::__oVerifactu, REQUIRED, "NIF" , Self)
    ::NombreSistemaInformatico := TVF_TextMax30Type():New( ::__oVerifactu, REQUIRED, "NombreSistemaInformatico" , Self)
    ::IdSistemaInformatico := TVF_TextMax2Type():New( ::__oVerifactu, REQUIRED, "IdSistemaInformatico" , Self)
    ::Version := TVF_TextMax50Type():New( ::__oVerifactu, REQUIRED, "Version" , Self)
    ::NumeroInstalacion := TVF_TextMax100Type():New( ::__oVerifactu, REQUIRED, "NumeroInstalacion" , Self)
    ::TipoUsoPosibleSoloVerifactu := TVF_SiNoType():New( ::__oVerifactu, REQUIRED, "TipoUsoPosibleSoloVerifactu" , Self)
    ::TipoUsoPosibleMultiOT := TVF_SiNoType():New( ::__oVerifactu, REQUIRED, "TipoUsoPosibleMultiOT" , Self)
    ::IndicadorMultiplesOT := TVF_SiNoType():New( ::__oVerifactu, REQUIRED, "IndicadorMultiplesOT" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_SistemaInformaticoType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::NombreRazon:HasData() .Or.;
       ::NIF:HasData() .Or.;
       ::NombreSistemaInformatico:HasData() .Or.;
       ::IdSistemaInformatico:HasData() .Or.;
       ::Version:HasData() .Or.;
       ::NumeroInstalacion:HasData() .Or.;
       ::TipoUsoPosibleSoloVerifactu:HasData() .Or.;
       ::TipoUsoPosibleMultiOT:HasData() .Or.;
       ::IndicadorMultiplesOT:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::NombreRazon:BuildXml( oChild )
        ::NIF:BuildXml( oChild )
        ::NombreSistemaInformatico:BuildXml( oChild )
        ::IdSistemaInformatico:BuildXml( oChild )
        ::Version:BuildXml( oChild )
        ::NumeroInstalacion:BuildXml( oChild )
        ::TipoUsoPosibleSoloVerifactu:BuildXml( oChild )
        ::TipoUsoPosibleMultiOT:BuildXml( oChild )
        ::IndicadorMultiplesOT:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_SistemaInformaticoType

    ::NombreRazon:Check()
    ::NIF:Check()
    ::NombreSistemaInformatico:Check()
    ::IdSistemaInformatico:Check()
    ::Version:Check()
    ::NumeroInstalacion:Check()
    ::TipoUsoPosibleSoloVerifactu:Check()
    ::TipoUsoPosibleMultiOT:Check()
    ::IndicadorMultiplesOT:Check()

Return ( Self )

METHOD HasData() CLASS TVF_SistemaInformaticoType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::NombreRazon:HasData(), .T., lHasData)
    lHasData := Iif( ::NIF:HasData(), .T., lHasData)
    lHasData := Iif( ::NombreSistemaInformatico:HasData(), .T., lHasData)
    lHasData := Iif( ::IdSistemaInformatico:HasData(), .T., lHasData)
    lHasData := Iif( ::Version:HasData(), .T., lHasData)
    lHasData := Iif( ::NumeroInstalacion:HasData(), .T., lHasData)
    lHasData := Iif( ::TipoUsoPosibleSoloVerifactu:HasData(), .T., lHasData)
    lHasData := Iif( ::TipoUsoPosibleMultiOT:HasData(), .T., lHasData)
    lHasData := Iif( ::IndicadorMultiplesOT:HasData(), .T., lHasData)

Return ( lHasData )


