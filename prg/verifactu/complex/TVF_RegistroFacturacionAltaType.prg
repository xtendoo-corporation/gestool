// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*Datos correspondientes al registro de facturacion de alta*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_RegistroFacturacionAltaType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'RegistroFacturacionAlta'
        DATA IDVersion AS OBJECT INIT Nil
        DATA IDFactura AS OBJECT INIT Nil
        DATA RefExterna AS OBJECT INIT Nil
        DATA NombreRazonEmisor AS OBJECT INIT Nil
        DATA Subsanacion AS OBJECT INIT Nil
        DATA RechazoPrevio AS OBJECT INIT Nil
        DATA TipoFactura AS OBJECT INIT Nil
        DATA TipoRectificativa AS OBJECT INIT Nil
        DATA FacturasRectificadas AS OBJECT INIT Nil
        DATA FacturasSustituidas AS OBJECT INIT Nil
        DATA ImporteRectificacion AS OBJECT INIT Nil
        DATA FechaOperacion AS OBJECT INIT Nil
        DATA DescripcionOperacion AS OBJECT INIT Nil
        DATA FacturaSimplificadaArt7273 AS OBJECT INIT Nil
        DATA FacturaSinIdentifDestinatarioArt61d AS OBJECT INIT Nil
        DATA Macrodato AS OBJECT INIT Nil
        DATA EmitidaPorTerceroODestinatario AS OBJECT INIT Nil
        DATA Tercero AS OBJECT INIT Nil
        DATA Destinatarios AS OBJECT INIT Nil
        DATA Cupon AS OBJECT INIT Nil
        DATA Desglose AS OBJECT INIT Nil
        DATA CuotaTotal AS OBJECT INIT Nil
        DATA ImporteTotal AS OBJECT INIT Nil
        DATA Encadenamiento AS OBJECT INIT Nil
        DATA SistemaInformatico AS OBJECT INIT Nil
        DATA FechaHoraHusoGenRegistro AS OBJECT INIT Nil
        DATA NumRegistroAcuerdoFacturacion AS OBJECT INIT Nil
        DATA IdAcuerdoSistemaInformatico AS OBJECT INIT Nil
        DATA TipoHuella AS OBJECT INIT Nil
        DATA Huella AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_RegistroFacturacionAltaType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )

    
METHOD Init() CLASS TVF_RegistroFacturacionAltaType

    ::IDVersion := TVF_VersionType():New( ::__oVerifactu, REQUIRED, "IDVersion" , Self)
    ::IDFactura := TVF_IDFacturaExpedidaType():New( ::__oVerifactu, REQUIRED, "IDFactura" , Self)
    ::RefExterna := TVF_TextMax70Type():New( ::__oVerifactu, OPTIONAL, "RefExterna" , Self)
    ::NombreRazonEmisor := TVF_TextMax120Type():New( ::__oVerifactu, REQUIRED, "NombreRazonEmisor" , Self)
    ::Subsanacion := TVF_SubsanacionType():New( ::__oVerifactu, OPTIONAL, "Subsanacion" , Self)
    ::RechazoPrevio := TVF_RechazoPrevioType():New( ::__oVerifactu, OPTIONAL, "RechazoPrevio" , Self)
    ::TipoFactura := TVF_ClaveTipoFacturaType():New( ::__oVerifactu, REQUIRED, "TipoFactura" , Self)
    ::TipoRectificativa := TVF_ClaveTipoRectificativaType():New( ::__oVerifactu, OPTIONAL, "TipoRectificativa" , Self)
    ::FacturasRectificadas := TVF_FacturasRectificadas():New( ::__oVerifactu, OPTIONAL, "FacturasRectificadas" , Self)
    ::FacturasSustituidas := TVF_FacturasSustituidas():New( ::__oVerifactu, OPTIONAL, "FacturasSustituidas" , Self)
    ::ImporteRectificacion := TVF_DesgloseRectificacionType():New( ::__oVerifactu, OPTIONAL, "ImporteRectificacion" , Self)
    ::FechaOperacion := TVF_fecha():New( ::__oVerifactu, OPTIONAL, "FechaOperacion" , Self)
    ::DescripcionOperacion := TVF_TextMax500Type():New( ::__oVerifactu, REQUIRED, "DescripcionOperacion" , Self)
    ::FacturaSimplificadaArt7273 := TVF_SimplificadaCualificadaType():New( ::__oVerifactu, OPTIONAL, "FacturaSimplificadaArt7273" , Self)
    ::FacturaSinIdentifDestinatarioArt61d := TVF_CompletaSinDestinatarioType():New( ::__oVerifactu, OPTIONAL, "FacturaSinIdentifDestinatarioArt61d" , Self)
    ::Macrodato := TVF_MacrodatoType():New( ::__oVerifactu, OPTIONAL, "Macrodato" , Self)
    ::EmitidaPorTerceroODestinatario := TVF_TercerosODestinatarioType():New( ::__oVerifactu, OPTIONAL, "EmitidaPorTerceroODestinatario" , Self)
    ::Tercero := TVF_PersonaFisicaJuridicaType():New( ::__oVerifactu, OPTIONAL, "Tercero" , Self)
    ::Destinatarios := TVF_Destinatarios():New( ::__oVerifactu, OPTIONAL, "Destinatarios" , Self)
    ::Cupon := TVF_CuponType():New( ::__oVerifactu, OPTIONAL, "Cupon" , Self)
    ::Desglose := TVF_DesgloseType():New( ::__oVerifactu, REQUIRED, "Desglose" , Self)
    ::CuotaTotal := TVF_ImporteSgn12_2Type():New( ::__oVerifactu, REQUIRED, "CuotaTotal" , Self)
    ::ImporteTotal := TVF_ImporteSgn12_2Type():New( ::__oVerifactu, REQUIRED, "ImporteTotal" , Self)
    ::Encadenamiento := TVF_Encadenamiento():New( ::__oVerifactu, REQUIRED, "Encadenamiento" , Self)
    ::SistemaInformatico := TVF_SistemaInformaticoType():New( ::__oVerifactu, REQUIRED, "SistemaInformatico" , Self)
    ::FechaHoraHusoGenRegistro := TVF_dateTime():New( ::__oVerifactu, REQUIRED, "FechaHoraHusoGenRegistro" , Self)
    ::NumRegistroAcuerdoFacturacion := TVF_TextMax15Type():New( ::__oVerifactu, OPTIONAL, "NumRegistroAcuerdoFacturacion" , Self)
    ::IdAcuerdoSistemaInformatico := TVF_TextMax16Type():New( ::__oVerifactu, OPTIONAL, "IdAcuerdoSistemaInformatico" , Self)
    ::TipoHuella := TVF_TipoHuellaType():New( ::__oVerifactu, REQUIRED, "TipoHuella" , Self)
    ::Huella := TVF_TextMax64Type():New( ::__oVerifactu, REQUIRED, "Huella" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_RegistroFacturacionAltaType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::IDVersion:HasData() .Or.;
       ::IDFactura:HasData() .Or.;
       ::RefExterna:HasData() .Or.;
       ::NombreRazonEmisor:HasData() .Or.;
       ::Subsanacion:HasData() .Or.;
       ::RechazoPrevio:HasData() .Or.;
       ::TipoFactura:HasData() .Or.;
       ::TipoRectificativa:HasData() .Or.;
       ::FacturasRectificadas:HasData() .Or.;
       ::FacturasSustituidas:HasData() .Or.;
       ::ImporteRectificacion:HasData() .Or.;
       ::FechaOperacion:HasData() .Or.;
       ::DescripcionOperacion:HasData() .Or.;
       ::FacturaSimplificadaArt7273:HasData() .Or.;
       ::FacturaSinIdentifDestinatarioArt61d:HasData() .Or.;
       ::Macrodato:HasData() .Or.;
       ::EmitidaPorTerceroODestinatario:HasData() .Or.;
       ::Tercero:HasData() .Or.;
       ::Destinatarios:HasData() .Or.;
       ::Cupon:HasData() .Or.;
       ::Desglose:HasData() .Or.;
       ::CuotaTotal:HasData() .Or.;
       ::ImporteTotal:HasData() .Or.;
       ::Encadenamiento:HasData() .Or.;
       ::SistemaInformatico:HasData() .Or.;
       ::FechaHoraHusoGenRegistro:HasData() .Or.;
       ::NumRegistroAcuerdoFacturacion:HasData() .Or.;
       ::IdAcuerdoSistemaInformatico:HasData() .Or.;
       ::TipoHuella:HasData() .Or.;
       ::Huella:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::IDVersion:BuildXml( oChild )
        ::IDFactura:BuildXml( oChild )
        ::RefExterna:BuildXml( oChild )
        ::NombreRazonEmisor:BuildXml( oChild )
        ::Subsanacion:BuildXml( oChild )
        ::RechazoPrevio:BuildXml( oChild )
        ::TipoFactura:BuildXml( oChild )
        ::TipoRectificativa:BuildXml( oChild )
        ::FacturasRectificadas:BuildXml( oChild )
        ::FacturasSustituidas:BuildXml( oChild )
        ::ImporteRectificacion:BuildXml( oChild )
        ::FechaOperacion:BuildXml( oChild )
        ::DescripcionOperacion:BuildXml( oChild )
        ::FacturaSimplificadaArt7273:BuildXml( oChild )
        ::FacturaSinIdentifDestinatarioArt61d:BuildXml( oChild )
        ::Macrodato:BuildXml( oChild )
        ::EmitidaPorTerceroODestinatario:BuildXml( oChild )
        ::Tercero:BuildXml( oChild )
        ::Destinatarios:BuildXml( oChild )
        ::Cupon:BuildXml( oChild )
        ::Desglose:BuildXml( oChild )
        ::CuotaTotal:BuildXml( oChild )
        ::ImporteTotal:BuildXml( oChild )
        ::Encadenamiento:BuildXml( oChild )
        ::SistemaInformatico:BuildXml( oChild )
        ::FechaHoraHusoGenRegistro:BuildXml( oChild )
        ::NumRegistroAcuerdoFacturacion:BuildXml( oChild )
        ::IdAcuerdoSistemaInformatico:BuildXml( oChild )
        ::TipoHuella:BuildXml( oChild )
        ::Huella:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_RegistroFacturacionAltaType


    ::IDVersion:Check()
    ::IDFactura:Check()
    ::RefExterna:Check()
    ::NombreRazonEmisor:Check()
    ::Subsanacion:Check()
    ::RechazoPrevio:Check()
    ::TipoFactura:Check()
    ::TipoRectificativa:Check()
    ::FacturasRectificadas:Check()
    ::FacturasSustituidas:Check()
    ::ImporteRectificacion:Check()
    ::FechaOperacion:Check()
    ::DescripcionOperacion:Check()
    ::FacturaSimplificadaArt7273:Check()
    ::FacturaSinIdentifDestinatarioArt61d:Check()
    ::Macrodato:Check()
    ::EmitidaPorTerceroODestinatario:Check()
    ::Tercero:Check()
    ::Destinatarios:Check()
    ::Cupon:Check()
    ::Desglose:Check()
    ::CuotaTotal:Check()
    ::ImporteTotal:Check()
    ::Encadenamiento:Check()
    ::SistemaInformatico:Check()
    ::FechaHoraHusoGenRegistro:Check()
    ::NumRegistroAcuerdoFacturacion:Check()
    ::IdAcuerdoSistemaInformatico:Check()
    ::TipoHuella:Check()
    ::Huella:Check()

Return ( Self )

METHOD HasData() CLASS TVF_RegistroFacturacionAltaType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::IDVersion:HasData(), .T., lHasData)
    lHasData := Iif( ::IDFactura:HasData(), .T., lHasData)
    lHasData := Iif( ::RefExterna:HasData(), .T., lHasData)
    lHasData := Iif( ::NombreRazonEmisor:HasData(), .T., lHasData)
    lHasData := Iif( ::Subsanacion:HasData(), .T., lHasData)
    lHasData := Iif( ::RechazoPrevio:HasData(), .T., lHasData)
    lHasData := Iif( ::TipoFactura:HasData(), .T., lHasData)
    lHasData := Iif( ::TipoRectificativa:HasData(), .T., lHasData)
    lHasData := Iif( ::FacturasRectificadas:HasData(), .T., lHasData)
    lHasData := Iif( ::FacturasSustituidas:HasData(), .T., lHasData)
    lHasData := Iif( ::ImporteRectificacion:HasData(), .T., lHasData)
    lHasData := Iif( ::FechaOperacion:HasData(), .T., lHasData)
    lHasData := Iif( ::DescripcionOperacion:HasData(), .T., lHasData)
    lHasData := Iif( ::FacturaSimplificadaArt7273:HasData(), .T., lHasData)
    lHasData := Iif( ::FacturaSinIdentifDestinatarioArt61d:HasData(), .T., lHasData)
    lHasData := Iif( ::Macrodato:HasData(), .T., lHasData)
    lHasData := Iif( ::EmitidaPorTerceroODestinatario:HasData(), .T., lHasData)
    lHasData := Iif( ::Tercero:HasData(), .T., lHasData)
    lHasData := Iif( ::Destinatarios:HasData(), .T., lHasData)
    lHasData := Iif( ::Cupon:HasData(), .T., lHasData)
    lHasData := Iif( ::Desglose:HasData(), .T., lHasData)
    lHasData := Iif( ::CuotaTotal:HasData(), .T., lHasData)
    lHasData := Iif( ::ImporteTotal:HasData(), .T., lHasData)
    lHasData := Iif( ::Encadenamiento:HasData(), .T., lHasData)
    lHasData := Iif( ::SistemaInformatico:HasData(), .T., lHasData)
    lHasData := Iif( ::FechaHoraHusoGenRegistro:HasData(), .T., lHasData)
    lHasData := Iif( ::NumRegistroAcuerdoFacturacion:HasData(), .T., lHasData)
    lHasData := Iif( ::IdAcuerdoSistemaInformatico:HasData(), .T., lHasData)
    lHasData := Iif( ::TipoHuella:HasData(), .T., lHasData)
    lHasData := Iif( ::Huella:HasData(), .T., lHasData)

Return ( lHasData )


