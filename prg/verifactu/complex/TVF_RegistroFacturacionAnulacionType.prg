// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*Datos correspondientes al registro de facturacion de anulacion*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_RegistroFacturacionAnulacionType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'RegistroFacturacionAnulacion'
        DATA IDVersion AS OBJECT INIT Nil
        DATA IDFactura AS OBJECT INIT Nil
        DATA RefExterna AS OBJECT INIT Nil
        DATA SinRegistroPrevio AS OBJECT INIT Nil
        DATA RechazoPrevio AS OBJECT INIT Nil
        DATA GeneradoPor AS OBJECT INIT Nil
        DATA Generador AS OBJECT INIT Nil
        DATA Encadenamiento AS OBJECT INIT Nil
        DATA SistemaInformatico AS OBJECT INIT Nil
        DATA FechaHoraHusoGenRegistro AS OBJECT INIT Nil
        DATA TipoHuella AS OBJECT INIT Nil
        DATA Huella AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_RegistroFacturacionAnulacionType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_RegistroFacturacionAnulacionType

    ::IDVersion := TVF_VersionType():New( ::__oVerifactu, REQUIRED, "IDVersion" , Self)
    ::IDFactura := TVF_IDFacturaExpedidaBajaType():New( ::__oVerifactu, REQUIRED, "IDFactura" , Self)
    ::RefExterna := TVF_TextMax60Type():New( ::__oVerifactu, OPTIONAL, "RefExterna" , Self)
    ::SinRegistroPrevio := TVF_SinRegistroPrevioType():New( ::__oVerifactu, OPTIONAL, "SinRegistroPrevio" , Self)
    ::RechazoPrevio := TVF_RechazoPrevioAnulacionType():New( ::__oVerifactu, OPTIONAL, "RechazoPrevio" , Self)
    ::GeneradoPor := TVF_GeneradoPorType():New( ::__oVerifactu, OPTIONAL, "GeneradoPor" , Self)
    ::Generador := TVF_PersonaFisicaJuridicaType():New( ::__oVerifactu, OPTIONAL, "Generador" , Self)
    ::Encadenamiento := TVF_Encadenamiento():New( ::__oVerifactu, REQUIRED, "Encadenamiento" , Self)
    ::SistemaInformatico := TVF_SistemaInformaticoType():New( ::__oVerifactu, REQUIRED, "SistemaInformatico" , Self)
    ::FechaHoraHusoGenRegistro := TVF_dateTime():New( ::__oVerifactu, REQUIRED, "FechaHoraHusoGenRegistro" , Self)
    ::TipoHuella := TVF_TipoHuellaType():New( ::__oVerifactu, REQUIRED, "TipoHuella" , Self)
    ::Huella := TVF_TextMax64Type():New( ::__oVerifactu, REQUIRED, "Huella" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_RegistroFacturacionAnulacionType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::IDVersion:HasData() .Or.;
       ::IDFactura:HasData() .Or.;
       ::RefExterna:HasData() .Or.;
       ::SinRegistroPrevio:HasData() .Or.;
       ::RechazoPrevio:HasData() .Or.;
       ::GeneradoPor:HasData() .Or.;
       ::Generador:HasData() .Or.;
       ::Encadenamiento:HasData() .Or.;
       ::SistemaInformatico:HasData() .Or.;
       ::FechaHoraHusoGenRegistro:HasData() .Or.;
       ::TipoHuella:HasData() .Or.;
       ::Huella:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::IDVersion:BuildXml( oChild )
        ::IDFactura:BuildXml( oChild )
        ::RefExterna:BuildXml( oChild )
        ::SinRegistroPrevio:BuildXml( oChild )
        ::RechazoPrevio:BuildXml( oChild )
        ::GeneradoPor:BuildXml( oChild )
        ::Generador:BuildXml( oChild )
        ::Encadenamiento:BuildXml( oChild )
        ::SistemaInformatico:BuildXml( oChild )
        ::FechaHoraHusoGenRegistro:BuildXml( oChild )
        ::TipoHuella:BuildXml( oChild )
        ::Huella:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_RegistroFacturacionAnulacionType


    ::IDVersion:Check()
    ::IDFactura:Check()
    ::RefExterna:Check()
    ::SinRegistroPrevio:Check()
    ::RechazoPrevio:Check()
    ::GeneradoPor:Check()
    ::Generador:Check()
    ::Encadenamiento:Check()
    ::SistemaInformatico:Check()
    ::FechaHoraHusoGenRegistro:Check()
    ::TipoHuella:Check()
    ::Huella:Check()

Return ( Self )

METHOD HasData() CLASS TVF_RegistroFacturacionAnulacionType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::IDVersion:HasData(), .T., lHasData)
    lHasData := Iif( ::IDFactura:HasData(), .T., lHasData)
    lHasData := Iif( ::RefExterna:HasData(), .T., lHasData)
    lHasData := Iif( ::SinRegistroPrevio:HasData(), .T., lHasData)
    lHasData := Iif( ::RechazoPrevio:HasData(), .T., lHasData)
    lHasData := Iif( ::GeneradoPor:HasData(), .T., lHasData)
    lHasData := Iif( ::Generador:HasData(), .T., lHasData)
    lHasData := Iif( ::Encadenamiento:HasData(), .T., lHasData)
    lHasData := Iif( ::SistemaInformatico:HasData(), .T., lHasData)
    lHasData := Iif( ::FechaHoraHusoGenRegistro:HasData(), .T., lHasData)
    lHasData := Iif( ::TipoHuella:HasData(), .T., lHasData)
    lHasData := Iif( ::Huella:HasData(), .T., lHasData)

Return ( lHasData )


