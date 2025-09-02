/* CLASS: TVeriFactu 
    Clase que gestiona los ficheros de facturas de VeriFactu
*/
#include 'hbclass.ch'
#include 'hbcompat.ch'
#include 'TORM.ch'
#include 'tchilkat.ch'
#include 'fivewin.ch'
#include 'verifactu.inc'

#define RECTIFICATIVA_SUSTITUCION 'S'
#define RECTIFICATIVA_DIFERENCIAS 'I'

CREATE CLASS TVeriFactu

    EXPORTED:
        METHOD New(  ) CONSTRUCTOR

        METHOD BuildCabeceraXml()
        METHOD BuildFacturaXml( oRegFacAl, oRegFacAlAnterior )  
        METHOD CreateXmlFile()
        METHOD CreateVeriSend( oRegFacAl)
        METHOD SendXmlFile()
        

        DATA oTVF_Verifactu AS OBJECT INIT Nil
        DATA lEnable AS LOGICAL INIT .T.
        DATA cXmlFile AS CHARACTER INIT ''
        DATA cXmlFileResponse AS CHARACTER INIT ''

        DATA oTVF_RegistroFacturacionAltaType AS OBJECT INIT Nil
    PROTECTED:
        DATA oDocumento AS OBJECT INIT Nil
        DATA oQueDoc AS OBJECT INIT Nil
        DATA oTVF_RegistroFacturacionAnulacionType AS OBJECT INIT Nil

        METHOD Init()
        METHOD Validate()
        METHOD CargaCliente( )
        METHOD RegistroFacturacionAltaType( oRegFacAl, oRegFacAlAnterior )
        METHOD RegistroFacturacionAnulacionType( oRegFacAl, oRegFacAlAnterior )
        METHOD SetTipoFactura( oCliente )
        METHOD SetFacturaSinIdentifDestinatarioArt61d( oCliente )
        METHOD SetDescripcionOperacion( oRegFacAl )
        METHOD SetSubsanacion( oRegFacAl )
        METHOD SetRechazoPrevio( oRegFacAl )
        METHOD SetMacroDato( )
        METHOD SetBaseImponibleACoste( oDetalleDesglose )
        METHOD SetFechaHoraHusoGenRegistro( tAlta, oTVF_RegistroFacturacionType )
        METHOD SetCalificacionOperacion( oDetalleDesglose ) 
        METHOD SetOperacionExenta( oDetalleDesglose )
        METHOD SetNumeroInstalacion( oTVF_RegistroFacturacionType )
        METHOD SetFacturasRectificadas( oRegFacAl )
        METHOD SetEncadenamiento( oRegFacAlAnterior, oTVF_RegistroFacturacionType )
        METHOD SetSistemaInformatico( oTVF_RegistroFacturacionType )
        METHOD SetIndicadorMultiplesOT( oTVF_RegistroFacturacionType )
        METHOD RegFacAlSaveHuella( oRegFacAl, cHuella )

ENDCLASS

// Group: EXPORTED METHODS

/* METHOD: New(  )
    Constructor.  

Devuelve:
    Self
*/
METHOD New( ) CLASS TVeriFactu

    ::Init()

Return ( Self )

// Group: PROTECTED METHODS

/* METHOD: Init(  )
    Inicializa los valores de la clase
Devuelve:
    Objeto
*/
METHOD Init(  ) CLASS TVeriFactu

    ::oTVF_Verifactu := TVF_Verifactu():New(  )

Return ( Self )

/* METHOD: BuildCabeceraXml(  )
    Crea la cabecera del Xml de Verifactu

Devuelve:
    Objeto
*/
METHOD BuildCabeceraXml(  ) CLASS TVeriFactu

    // Cabecera
    ::oTVF_Verifactu:RegFactuSistemaFacturacion:Cabecera:ObligadoEmision:NombreRazon:Set( cNomEmp )
    ::oTVF_Verifactu:RegFactuSistemaFacturacion:Cabecera:ObligadoEmision:NIF:Set( cCifEmp )
    // ::oTVF_Verifactu:RegFactuSistemaFacturacion:Cabecera:FechaFinVeriFactu // No la utilizaremos nunca, es para indicar que el sistema pasa a NO Verifactu
    ::oTVF_Verifactu:RegFactuSistemaFacturacion:Cabecera:RemisionVoluntaria:Incidencia:Set('N') 
    // ::oTVF_Verifactu:RegFactuSistemaFacturacion:Cabecera:RemisionRequerimiento:Incidencia:Set('N') TODO: Pendiente de implementar

Return ( Self )


/* METHOD: Create(  )
    Genera y crea el fichero XML
Devuelve:
    Objeto
*/
/* METHOD Create(  ) CLASS TVeriFactu

    If ::lEnable

        ::LoadCliente()
        ::BuildXml()
        ::CreateXmlFile()

    Endif

Return ( Self ) */

/* METHOD: Validate(  )
    Valida los datos de la clase según los requerimientos de VeriFactu

Devuelve:
    Objeto
*/
METHOD Validate(  ) CLASS TVeriFactu
Return ( Self )

/* METHOD: BuildFacturaXml( oRegFacAl, oRegFacAlAnterior )
    Añade una factura en el objeto verifactu

    Parámetros:
        oRegFacAl: Objeto con los datos del registro de alta
        oRegFacAlAnterior: Objeto con los datos del registro de alta anterior para el encadenamiento

Devuelve:
    Objeto
*/
METHOD BuildFacturaXml( oRegFacAl as Object , oRegFacAlAnterior as Object ) CLASS TVeriFactu
    
    If ::oTVF_Verifactu:__oReturn:Fail()

        Return ( Self )

    Endif

    ::oQueDoc := TQueDoc():New( oRegFacAl:DOCUMENTO )

    switch oRegFacAl:TIPO

        case VERIFACTU_TIPO_REGISTRO_ALTA

            ::RegistroFacturacionAltaType( oRegFacAl, oRegFacAlAnterior )
            
        exit

        case VERIFACTU_TIPO_REGISTRO_ANULACION

            ::RegistroFacturacionAnulacionType( oRegFacAl, oRegFacAlAnterior )

        exit

    endswitch
    
    
Return ( Self )

/* METHOD: RegistroFacturacionAnulacionType( oRegFacAl, oRegFacAlAnterior )
    Genera la estructura del registro de anulacion de verifactu
    
    Parámetros:
        oRegFacAl: Objeto con los datos del registro de anulacion
        oRegFacAlAnterior: Objeto con los datos del registro de alta anterior para el encadenamiento

Devuelve:
Objeto
    
*/
METHOD RegistroFacturacionAnulacionType( oRegFacAl, oRegFacAlAnterior ) CLASS TVerifactu

    Local cInfoHuella as String := ''
    Local cHuella as String := ''

    WITH OBJECT ::oTVF_RegistroFacturacionAnulacionType := TVF_RegistroFacturacionAnulacionType():New( ::oTVF_Verifactu, , "RegistroAnulacion", Self )

        :IDVersion:Set( '1.0' )
        :IDFactura:IDEmisorFacturaAnulada:Set( cCifEmp )
        :IDFactura:NumSerieFacturaAnulada:Set( TVerifactuDocumento():New( oRegFacAl:SERIE, oRegFacAl:NUMERO, ::oQueDoc ):Str() )
        :IDFactura:FechaExpedicionFacturaAnulada:Set( oRegFacAl:FECHA )
        :RefExterna:Set( oRegFacAl:ID:Str():Alltrim() )
        // :SinRegistroPrevio // Este dato es adicional no hace falta. En principio no pueden haber anulaciones sin registro previo ya que se anula la propia factura que ya existe en el fichero
        // :RechazoPrevio // Este dato es adicional no hace falta        
        // :GeneradoPor // se utiliza cuando el generador de la anulación es diferente al de la factura
        // :Generador // Se utiliza cuando se utiliza GeneradoPor

        ::SetEncadenamiento( oRegFacAlAnterior, ::oTVF_RegistroFacturacionAnulacionType )
        ::SetSistemaInformatico( ::oTVF_RegistroFacturacionAnulacionType )
        ::SetFechaHoraHusoGenRegistro( oRegFacAl:ALTA, ::oTVF_RegistroFacturacionAnulacionType )
        :TipoHuella:Set( '01' )
        cInfoHuella :=  'IDEmisorFacturaAnulada=' + :IDFactura:IDEmisorFacturaAnulada:Get():Alltrim()+'&'+;
                        'NumSerieFacturaAnulada=' + :IDFactura:NumSerieFacturaAnulada:Get():Alltrim()+'&'+;
                        'FechaExpedicionFacturaAnulada=' + :IDFactura:FechaExpedicionFacturaAnulada:Get():Alltrim()+'&'+;
                        'Huella=' + oRegFacAlAnterior:HUELLA:Alltrim()+'&'+;
                        'FechaHoraHusoGenRegistro=' + :FechaHoraHusoGenRegistro:Get():Alltrim()
        cHuella := TChilkatTools():New():HashString('SHA-256', cInfoHuella,'hex')
        :Huella:Set( cHuella )
        ::RegFacAlSaveHuella( oRegFacAl, cHuella)
        
        /* hb_MemoWrit( 'huella.txt', 'Info para crear la huella: ' + cInfoHuella + CRLF + ;
                     'Huella: ' + cHuella  ) */

        // :Signature  // No lo vamos a aplicar nunca, ya que es para sistemas NO Verifactu
                
    END WITH
    
    ::oTVF_Verifactu:RegFactuSistemaFacturacion:RegistroFactura:Set( ::oTVF_RegistroFacturacionAnulacionType )

    If ::oTVF_Verifactu:Fail()

        ::oTVF_Verifactu:__oReturn:Log := 'Fallo en anulación ' + oRegFacAl:SERIE:Str() + '-' + oRegFacAl:NUMERO:Str() 

    Endif

Return ( Self )

/* METHOD: RegistroFacturacionAltaType( oRegFacAl, oRegFacAlAnterior )
    Genera la estructura del registro de alta de verifactu
    
    Parámetros:
        oRegFacAl: Objeto con los datos del registro de alta
        oRegFacAlAnterior: Objeto con los datos del registro de alta anterior para el encadenamiento
        

Devuelve:
    Objeto
*/
METHOD RegistroFacturacionAltaType( oRegFacAl, oRegFacAlAnterior ) CLASS TVerifactu

    Local oCliente as Object := Nil
    Local oDestinatario as Object := Nil
    Local oDetalleDesglose as Object := Nil
    Local nIva as Numeric := 0
    Local nTotalCuota as Numeric := 0
    Local cInfoHuella as String := ''
    Local cHuella as String := ''

    ::oDocumento := oRegFacAl:GetModel()

    If ::oDocumento == Nil .Or.;
       ::oDocumento:Fail()

       ::oTVF_Verifactu:__oReturn:Success := .F.
       ::oTVF_Verifactu:__oReturn:Log('Error al cargar el documento ' + ::oQueDoc:NombreHumano() + ' ' + oRegFacAl:SERIE:Str() + '-' + oRegFacAl:NUMERO:Str() + ::oTVF_Verifactu:__oReturn:LogToString())

        Return ( Self )

    Endif

    oApp:oCache:oSeries:Find( ::oDocumento:SERIE )
    If oApp:oCache:oSeries:Fail()

        ::oTVF_Verifactu:__oReturn:Success := .F.
        ::oTVF_Verifactu:__oReturn:Log := 'Error al cargar la serie ' + ::oDocumento:SERIE:Str() + ' del documento ' + ::oQueDoc:NombreHumano() + ' ' + oRegFacAl:SERIE:Str() + '-' + oRegFacAl:NUMERO:Str() + ::oTVF_Verifactu:__oReturn:LogToString()

        Return ( Self )

    Endif

    oCliente := ::CargaCliente( )

    WITH OBJECT ::oTVF_RegistroFacturacionAltaType := TVF_RegistroFacturacionAltaType():New( ::oTVF_Verifactu, , "RegistroAlta", Self )
        :IDVersion:Set( '1.0' )
        :IDFactura:IDEmisorFactura:Set( cCifEmp )
        :IDFactura:NumSerieFactura:Set( TVerifactuDocumento():New( ::oDocumento:SERIE, ::oDocumento:NUMERO, ::oQueDoc ):Str() )
        :IDFactura:FechaExpedicionFactura:Set( ::oDocumento:FECHA )
        :RefExterna:Set( oRegFacAl:ID:Str():Alltrim() )
        :NombreRazonEmisor:Set( cNomEmp )
        ::SetSubsanacion( oRegFacAl )
        ::SetRechazoPrevio( oRegFacAl )

        If ::oDocumento:RECTISER != 0 .And. ::oDocumento:RECTINUM != 0  // Es rectificativa

            :TipoRectificativa:Set( ::oDocumento:RECTITIP )
            ::SetFacturasRectificadas( oRegFacAl )

            // :FacturasSustituidas  // Se utilizan cuando la factura anula las anteriores, por ejemplo una factura de un ticket

        Endif

        If  ::oDocumento:FECHAOPE != ::oDocumento:FECHA

            :FechaOperacion:Set( ::oDocumento:FECHAOPE )

        Endif

        ::SetTipoFactura( oCliente )
        ::SetDescripcionOperacion( oRegFacAl,)
        ::SetFacturaSinIdentifDestinatarioArt61d( oCliente )
        ::SetMacroDato( )  
        
        // :EmitidaPorTerceroODestinatario:Set( 'D' )  // esto solo se utilizaría si la factura se emite por alguien que no es el obligado tributario, en principio no contemplamos esto.
        // :Tercero  // Esto sería en el caso de que :EmitidaPorTerceroODestinatario fuese 'S'


        If (::oTVF_RegistroFacturacionAltaType:TipoFactura:Get != 'F2' .And.; 
            ::oTVF_RegistroFacturacionAltaType:TipoFactura:Get != 'R5' ) .And.;
            ::oTVF_RegistroFacturacionAltaType:FacturaSinIdentifDestinatarioArt61d:Get() == 'S' 

           // Se ha emitido un documento que no es ticket y el cliente no tiene CIF, por lo tanto es incorrecto. No se puede enviar
            ::oTVF_Verifactu:__oReturn:Success := .F.
            ::oTVF_Verifactu:__oReturn:Log := 'Se está intentando enviar un documento factura con un cliente sin identificación fiscal. Revise el cliente del documento ' + ::oQueDoc:NombreHumano() + ' ' + oRegFacAl:SERIE:Str() + '-' + oRegFacAl:NUMERO:Str() 

        Endif

        If (::oTVF_RegistroFacturacionAltaType:TipoFactura:Get != 'F2' .And.; 
            ::oTVF_RegistroFacturacionAltaType:TipoFactura:Get != 'R5' ) .And.;
            ::oTVF_RegistroFacturacionAltaType:FacturaSinIdentifDestinatarioArt61d:Get() == 'N' 

            WITH OBJECT oDestinatario := TVF_PersonaFisicaJuridicaType():New( ::oTVF_Verifactu, , 'IDDestinatario', Self, NO_NIF_REQUIRED )
                :NombreRazon:Set( oCliente:NOMBRE )

                If oCliente:TIPOCIF == 1 // NIF/CIF Español

                    :NIF:Set( oCliente:CIF ) 

                Else

                    WITH OBJECT :IDOtro := TVF_IDOtroType():New( ::oTVF_Verifactu, ,'IDOtro', Self )
                        :cDescripcion := 'Cliente con CIF distinto a NIF/CIF Español'
                        :cSolucion := 'Revisa los datos del cliente; país, CIF y indentificación CID/DNI'
                        :CodigoPais:Set( oCliente:PAIS )  
                        :IDType:Set( oCliente:TIPOCIF:Str():Zeros(2) )
                        :ID:Set( oCliente:CIF )
                    END WITH

                Endif
            
            END

            :Destinatarios:Set( oDestinatario )

        Endif
        
        :Cupon:Set('N')

        For nIva := 1 To oApp:oAppData:nNumeroMaximoIvaenDocumento

            If ::oDocumento:&('IVACOD'+nIva:Str()) != 0

                WITH OBJECT oDetalleDesglose := TVF_DetalleType():New( ::oTVF_Verifactu, , 'DetalleDesglose', Self )
                    :Impuesto:Set( ::oDocumento:VIMPAPLI)  
                    :ClaveRegimen:Set( ::oDocumento:REGIMENV )  

                    If .Not. ::SetOperacionExenta( oDetalleDesglose )

                        ::SetCalificacionOperacion( oDetalleDesglose )
                        :TipoImpositivo:Set( ::oDocumento:&('IVACOD' + nIva:Str() ) )
                        :CuotaRepercutida:Set( ::oDocumento:&('IVAIMP' + nIva:Str() ) )
                        nTotalCuota += ::oDocumento:&('IVAIMP' + nIva:Str() )

                        If ::oDocumento:EXENTAV == S1_SUJETA_NOEXENTA_SIN_INV_SUJETO_PASIVO

                            If ::oDocumento:&('RECPOR' + nIva:Str()):NotEmpty()

                                :TipoRecargoEquivalencia:Set( ::oDocumento:&('RECPOR' + nIva:Str()) )  
                                :CuotaRecargoEquivalencia:Set( ::oDocumento:&('RECIMP' + nIva:Str() ) )
                                nTotalCuota+= ::oDocumento:&('RECIMP' + nIva:Str() )

                            Endif

                        Endif

                    Endif

                    :BaseImponibleOimporteNoSujeto:Set( ::oDocumento:&('BASE' + nIva:Str() ) )
                    ::SetBaseImponibleACoste( oDetalleDesglose )

                END

                :Desglose:Set( oDetalleDesglose )

            Endif

        Next

        :CuotaTotal:Set( nTotalCuota )
        :ImporteTotal:Set( ::oDocumento:TOTAL )
        ::SetEncadenamiento( oRegFacAlAnterior, ::oTVF_RegistroFacturacionAltaType )
        ::SetSistemaInformatico( ::oTVF_RegistroFacturacionAltaType )
        ::SetFechaHoraHusoGenRegistro( oRegFacAl:ALTA, ::oTVF_RegistroFacturacionAltaType )
        :NumRegistroAcuerdoFacturacion:Set(  oApp:oData:oVerifactu:cVeriFNRAF )
        // :IdAcuerdoSistemaInformatico // Este campo no lo utilizaremos nunca, está pensado para programas que los utilizan varios obligatos tributarios ( sass, nube, etc... )

        :TipoHuella:Set( '01' )
        cInfoHuella :=  'IDEmisorFactura=' + :IDFactura:IDEmisorFactura:Get():Alltrim()+'&'+;
                        'NumSerieFactura=' + :IDFactura:NumSerieFactura:Get():Alltrim()+'&'+;
                        'FechaExpedicionFactura=' + :IDFactura:FechaExpedicionFactura:Get():Alltrim()+'&'+;
                        'TipoFactura=' + :TipoFactura:Get():Alltrim()+'&'+;
                        'CuotaTotal=' + :CuotaTotal:Get():Alltrim()+'&'+;
                        'ImporteTotal=' + :ImporteTotal:Get():Alltrim()+'&'+;
                        'Huella=' + oRegFacAlAnterior:HUELLA:Alltrim()+'&'+;
                        'FechaHoraHusoGenRegistro=' + :FechaHoraHusoGenRegistro:Get():Alltrim()
        cHuella := TChilkatTools():New():HashString('SHA-256', cInfoHuella,'hex')
        :Huella:Set( cHuella )
        ::RegFacAlSaveHuella( oRegFacAl, cHuella)

        /* hb_MemoWrit( 'huella.txt', 'Info para crear la huella: ' + cInfoHuella + CRLF + ;
                     'Huella: ' + cHuella  ) */
        /*
            Para comprobar, según https://www.agenciatributaria.es/static_files/AEAT_Desarrolladores/EEDD/IVA/VERI-FACTU/Veri-Factu_especificaciones_huella_hash_registros.pdf
            Esto: :Huella:Set( TChilkatTools():New():HashString('SHA-256', "IDEmisorFactura=89890001K&NumSerieFactura=12345679/G34&FechaExpedicionFactura=01-01-2024&TipoFactura=F1&CuotaTotal=12.35&ImporteTotal=123.45&Huella=3C464DAF61ACB827C65FDA19F352A4E3BDC2C640E9E9FC4CC058073F38F12F60&FechaHoraHusoGenRegistro=2024-01-01T19:20:35+01:00",'hex') )
            Ha de devolver esto: F7B94CFD8924EDFF273501B01EE5153E4CE8F259766F88CF6ACB8935802A2B97
        */

        // :Signature  // No lo vamos a aplicar nunca, ya que es para sistemas NO Verifactu
                
    END WITH

    
    ::oTVF_Verifactu:RegFactuSistemaFacturacion:RegistroFactura:Set( ::oTVF_RegistroFacturacionAltaType )

    If ::oTVF_Verifactu:Fail()

        ::oTVF_Verifactu:__oReturn:Log := hb_Eol() + 'Fallo en factura ' + oRegFacAl:SERIE:Str() + '-' + oRegFacAl:NUMERO:Str() 

    Endif

Return ( Self )

/* METHOD: CreateXmlFile(  )
    Crea el fichero Xml partiendo del objeto xml verifactu

Devuelve:
    Objeto
*/
METHOD CreateXmlFile(  ) CLASS TVeriFactu

    Local oXml  as Object := Nil
    Local cMessage as String := ''

    If ::oTVF_Verifactu:__oReturn:Fail()

        Return ( Self )

    Endif

    If .Not. Hb_DirBuild( cDirEmp + '\Verifactu' )

        ::oTVF_Verifactu:__oReturn:Success := .F.
        ::oTVF_Verifactu:__oReturn:Log := 'Error al crear el directorio de Verifactu : ' + cDirEmp + '\Verifactu'
        Return ( Self )

    Endif
    oXml := ::oTVF_Verifactu:GetXmlObject()
    ::cXmlFile :=  cDirEmp + '\Verifactu\verifactu_' + hb_TToS( hb_DateTime() ) + '.xml'
    
    hb_MemoWrit ( ::cXmlFile, oXml:GetXml() )

    If .Not. File ( ::cXmlFile )

        cMessage := 'Error al crear el fichero xml : ' + hb_Eol() + ::cXmlFile
        ::oTVF_Verifactu:__oReturn:Success := .F.
        ::oTVF_Verifactu:__oReturn:Log := cMessage
        TNotification():Danger( cMessage )

    Endif

Return ( Self )

/* METHOD: CreateVeriSend( oRegFacAl )
    Agrega el envio al registro de envíos de verifactu

    Parámetros:
        oRegFacAl: Objeto con los datos del registro de alta que se van a enviar en el fichero

Devuelve:
    Objheto
*/
METHOD CreateVeriSend( oRegFacAl ) CLASS TVerifactu

    Local oVeriSend as Object := Nil    
    Local aRegFacAl as Array := oRegFacAl:GetCollection()
    Local oItem as Object := Nil
    Local oRegFacAlRow as Object := Nil

    WITH OBJECT oVeriSend := mVeriSend():New(  )

        :FICHERO := ::cXmlFile

        If :Save():Fail()

            ::oTVF_Verifactu:__oReturn:Success := .F.
            ::oTVF_Verifactu:__oReturn:Log := 'Error al guardar el registro de envios de fichero verifactu : ' + ::cXmlFile + CRLF + :LogToString()

        Endif

    END

    If ::oTVF_Verifactu:Fail()

        Return ( Self )

    Endif

    for each oItem in aRegFacAl
        
        If ::oTVF_Verifactu:Success()
            
            oRegFacAlRow := mRegFacAl():New():Find( oItem:ID, 'ID' )

            
            If oRegFacAlRow:Fail()

                ::oTVF_Verifactu:__oReturn:Success := .F.
                ::oTVF_Verifactu:__oReturn:Log := 'Error al cargar el registro de alta : ' + oRegFacAlRow:DOCUMENTO:Alltrim() + ' ' + oRegFacAlRow:SERIE:Str() + '-' + oRegFacAlRow:NUMERO:Str() + CRLF + oRegFacAlRow:LogToString()

            Endif

            oRegFacAlRow:IDVERISEND := oVeriSend:ID
            oRegFacAlRow:SUBSANADO := .F.
            oRegFacAlRow:Save()

            If oRegFacAlRow:Fail()
        
                ::oTVF_Verifactu:__oReturn:Success := .F.
                ::oTVF_Verifactu:__oReturn:Log := 'Error asignando envio verifactu en registro de alta : ' + oRegFacAlRow:SERIE:Str() + '-' + oRegFacAlRow:NUMERO:Str() + CRLF + oRegFacAlRow:LogToString()
        
            Endif

        Endif

    next
    
Return ( Self )


/* METHOD: SendXmlFile(  )
    Envía el fichero Xml a Verifactu

Devuelve:
    Objeto
*/
METHOD SendXmlFile(  ) CLASS TVeriFactu

    WITH OBJECT TVerifactuSendXmlFile():New()

        :cXmlFile := ::cXmlFile
        ::oTVF_Verifactu:__oReturn:LogStatus( :Send(  ) )

    END

Return ( Self )


/* METHOD: SetFacturaSinIdentifDestinatarioArt61d( oCliente )
    Asigna si la factura tiene CIF o no

    Parámetros:
        oCliente: Objeto con los datos del cliente

Devuelve:
Objeto
    
*/
METHOD SetFacturaSinIdentifDestinatarioArt61d( oCliente ) CLASS TVeriFactu

    If ::oDocumento:CLIVARIOS 

        If ::oDocumento:CIF:Empty()

            ::oTVF_RegistroFacturacionAltaType:FacturaSinIdentifDestinatarioArt61d:Set( 'S' ) 

        Else

            ::oTVF_RegistroFacturacionAltaType:FacturaSinIdentifDestinatarioArt61d:Set( 'N' ) 

        Endif

    Else

        If oCliente:CIF:Empty()

            ::oTVF_RegistroFacturacionAltaType:FacturaSinIdentifDestinatarioArt61d:Set( 'S' ) 
                    
        Else

            ::oTVF_RegistroFacturacionAltaType:FacturaSinIdentifDestinatarioArt61d:Set( 'N' ) 

        Endif

    Endif

Return ( Self )

/* METHOD: SetTipoFactura( oCliente )
    Asigna el tipo de factura según el tipo de documento

    Parámetros:
        oCliente: Objeto con los datos del cliente
    
Devuelve:
    Objeto
*/
METHOD SetTipoFactura( oCliente ) CLASS TVeriFactu

    If ::oQueDoc:Tiquet()

        If ::oDocumento:EsRectificativa() 

            ::oTVF_RegistroFacturacionAltaType:TipoFactura:Set( ::oDocumento:RECTICOD )  // Factura Rectificativa ( este ha de venir siempre como R5 )

        Else

            If oCliente:CIF:Empty()

                ::oTVF_RegistroFacturacionAltaType:TipoFactura:Set( 'F2' )  // Factura Simplificada

            Else

                ::oTVF_RegistroFacturacionAltaType:TipoFactura:Set( 'F1' )  // Factura Simplificada
                ::oTVF_RegistroFacturacionAltaType:FacturaSimplificadaArt7273:Set( 'S' ) // Se informa de cliente

            Endif


        Endif

    Endif

    If ::oQueDoc:FacCli()

        If ::oDocumento:EsRectificativa() 

            ::oTVF_RegistroFacturacionAltaType:TipoFactura:Set( ::oDocumento:RECTICOD )  // Factura Rectificativa

        ElseIf ::oDocumento:DETIQTOT

            ::oTVF_RegistroFacturacionAltaType:TipoFactura:Set( 'F3' )  // Factura Recapitulativa proveniente de un Tiquet

        Else

            ::oTVF_RegistroFacturacionAltaType:TipoFactura:Set( 'F1' )  // Factura cliente

        Endif

    Endif

Return ( Self )

/* METHOD: SetDescripcionOperacion( oRegFacAl )
    Asigna en la descripcionoperacion el contenido de las primeras líneas del documento

    Parámetros:
        oRegFacAl: Objeto con los datos del registro de alta que se van a enviar en el fichero

Devuelve:
    Objeto
*/
METHOD SetDescripcionOperacion( oRegFacAl ) CLASS TVeriFactu

    Local aLineas as Array := Array( 0 )
    Local oLinea as Object := Nil
    Local cDescripcionOperacion as String := ''

    aLineas := oRegFacAl:GetModelLines("NOMBRE")

    If aLineas == Nil .Or.;
        aLineas:Len() == 0

       cDescripcionOperacion := ::oQueDoc:NombreHumano() 

    Endif

    for each oLinea in aLineas

        if .Not. oLinea:NOMBRE:Empty() .And.;
           .Not. oLinea:NOIMPRIMIR .And.; 
           cDescripcionOperacion:Len() < 500

            // Sanitize control chars before converting to UTF-8 to avoid stray codes in XML
            cDescripcionOperacion += hb_StrToUTF8( SanitizeXmlText( oLinea:NOMBRE:Alltrim() ) ) + hb_Eol()

        Endif
            
        
    next

    ::oTVF_RegistroFacturacionAltaType:DescripcionOperacion:Set(cDescripcionOperacion:Substr(1, 499) ) // Le quito 1 por si acaso

Return ( Self )

/* METHOD: SetMacroDato( )
    Asigna el macrodato según documento e importe
    
Devuelve:
Objeto
    
*/
METHOD SetMacroDato( ) CLASS TVerifactu

    ::oTVF_RegistroFacturacionAltaType:MacroDato:Set( 'N' )   // Tiquet o factura normal es N por defecto

    If ::oQueDoc:FacCli() .And.;
       ::oDocumento:VERIMACRO .And.;
       ::oDocumento:TOTAL >= VALOR_MACRODATO

        ::oTVF_RegistroFacturacionAltaType:MacroDato:Set( 'S' )

    Endif

Return ( Self )


/* METHOD: CargaCliente( )
    Carga los datos al modelo del cliente según sea varios o cliente  

Devuelve:
    Objeto
*/
METHOD CargaCliente( ) CLASS TVeriFactu 

    Local oCliente as Object := Nil

    If ::oDocumento:CLIVARIOS 

        WITH OBJECT oCliente := mCliente():New(  )

            :NOMBRE  := ::oDocumento:NOMBRE
            :PAIS    := ::oDocumento:PAIS
            :TIPOCIF := ::oDocumento:TIPOCIF
            :CIF     := ::oDocumento:CIF
            :__oReturn:Success := .T.

        END

    Elseif ::oDocumento:CODCLI != 0

        oCliente := mCliente():New( ::oDocumento:CODCLI )

    ElseIf ::oQueDoc:Tiquet()

        WITH OBJECT oCliente := mCliente():New(  )

            :NOMBRE  := 'VARIOS'
            :PAIS    := cPaisDef
            :TIPOCIF := aTiposCIF[1]
            :CIF     := ''
            :__oReturn:Success := .T.

        END

    Else  // En teoría esto no ha de pasar nunca.

        ::oTVF_Verifactu:__oReturn:Success := .F.
        ::oTVF_verifactu:__oReturn:Log := 'El documento ' + ::oQueDoc:NombreHumano() + ' ' + oDocumento:SERIE:Str() + '-' + oDocumento:NUMERO:Str() + ' no tiene cliente asignado'
        oCliente := mCliente():New()

    Endif
    
    If oCliente:Fail

        ::oTVF_Verifactu:__oReturn:Success := .F.
        ::oTVF_Verifactu:__oReturn:Log := 'Error al cargar el cliente ' + ::oDocumento:CODCLI:Str()

    Endif

    If oCliente:PAIS:Empty()

        oCliente:PAIS := cPaisDef

    Endif

Return ( oCliente )

/* METHOD: SetBaseImponibleACoste( oDetalleDesglose )
    Se aplica solo cuando El campo BaseImponibleACoste solo puede estar cumplimentado si la ClaveRegimen es = “06” o Impuesto = “02” (IPSI) o Impuesto = “05” (Otros). 
    https://www.agenciatributaria.es/static_files/AEAT_Desarrolladores/EEDD/IVA/VERI-FACTU/Validaciones_Errores_Veri-Factu.pdf sección 15.2

    Parámetros:
        oDetalleDesglose: Objeto con los datos del detalle de desglose de la factura

Devuelve:
Objeto
    
*/
METHOD SetBaseImponibleACoste( oDetalleDesglose ) CLASS  TVerifactu

    If oDetalleDesglose:ClaveRegimen:Get()=='06' .Or.;
       oDetalleDesglose:Impuesto:Get() == '02' .Or.;
       oDetalleDesglose:Impuesto:Get() == '05'

        oDetalleDesglose:BaseImponibleACoste:Set( ::oDocumento:COSTE )

    Endif

Return ( Self )

/* METHOD: SetFechaHoraHusoGenRegistro( tAlta, oTVF_RegistroFacturacionType )
    
    Parámetros:
        tAlta: Timestamp de alta del registro

Devuelve:
Objeto
    
*/
METHOD SetFechaHoraHusoGenRegistro( tAlta, oTVF_RegistroFacturacionType ) CLASS TVeriFactu

    Local dDate as Date := 0d00000000
    Local cTime as String := ''

    dDate := HB_tTOd( tAlta, ,@cTime)

    oTVF_RegistroFacturacionType:FechaHoraHusoGenRegistro:Set( TimeStampUTC(dDate, cTime) )  

Return ( Self )


/* METHOD: SetCalificacionOperacion( oDetalleDesglose )
    Asigna la calificación de la operación 

    Parámetros:
        oDetalleDesglose: Objeto con los datos del detalle de desglose de la factura

Devuelve:
Objeto
    
*/
METHOD SetCalificacionOperacion( oDetalleDesglose )  

    switch ::oDocumento:EXENTAV

        case S1_SUJETA_NOEXENTA_SIN_INV_SUJETO_PASIVO

            oDetalleDesglose:CalificacionOperacion:Set( 'S1' )
            
        exit

        case S2_SUJETA_NOEXENTA_CON_INV_SUJETO_PASIVO

            oDetalleDesglose:CalificacionOperacion:Set( 'S2' )
            
        exit

        case N1_NO_SUJETA_ART_7_14_OTROS

            oDetalleDesglose:CalificacionOperacion:Set( 'N1' )
            
        exit

        case N2_NO_SUJETA_REGLAS_LOCALIZACION

            oDetalleDesglose:CalificacionOperacion:Set( 'N2' )
            
        exit

        otherwise

            oDetalleDesglose:CalificacionOperacion:Set( 'S1' )

        exit

    endswitch

Return ( Self )

/* METHOD: SetOperacionExenta( oDetalleDesglose )
    Indica el motivo de la operación exenta
    
    Parámetros:
        oDetalleDesglose: Objeto con los datos del detalle de desglose de la factura
        
Devuelve:
    Lógico
*/
METHOD SetOperacionExenta( oDetalleDesglose ) CLASS TVerifactu

    Local lEsExenta as Logical := .F.

    If ::oDocumento:EXENCIONV:NotEmpty()

        oDetalleDesglose:OperacionExenta:Set( ::oDocumento:EXENCIONV )
        lEsExenta := .T.

    Endif

Return ( lEsExenta )

/* METHOD: SetNumeroInstalacion( oTVF_RegistroFacturacionType )
    Aplica el número de instalación del sistema informático

    Parámetros:
        oTVF_RegistroFacturacionType: Objeto con los datos del registro de facturación de alta o anulación
    
Devuelve:
Objeto
*/
METHOD SetNumeroInstalacion( oTVF_RegistroFacturacionType ) CLASS TVeriFactu

    oTVF_RegistroFacturacionType:SistemaInformatico:NumeroInstalacion:Set( TVerifactuNumeroInstalacion():Get() ) 

Return ( Self )

/* METHOD: SetSubsanacion( oRegFacAl )
    Aplica si el registro de alta es de subsanación o no
    
    Parámetros:
        oRegFacAl: Objeto con los datos del registro de alta que se van a enviar en el fichero

Devuelve:
    Objeto
*/
METHOD SetSubsanacion( oRegFacAl ) CLASS TVerifactu

    If oRegFacAl:SUBSANADO

        ::oTVF_RegistroFacturacionAltaType:Subsanacion:Set('S')
        
    Else
        
        ::oTVF_RegistroFacturacionAltaType:Subsanacion:Set('N')

    Endif

Return ( Self )

/* METHOD: SetRechazoPRevio( oRegFacAl )
    Aplica si el registro subsanado es de un rechazo previo o no
    
    Parámetros:
        oRegFacAl: Objeto con los datos del registro de alta que se van a enviar en el fichero
    
Devuelve:
    Objeto
*/
METHOD SetRechazoPRevio( oRegFacAl ) CLASS TVeriFactu

    If oRegFacAl:SUBSANADO .And.;
       oRegFacAl:VESTADO == VALOR_INDIVIDUAL_INCORRECTO

       ::oTVF_RegistroFacturacionAltaType:RechazoPrevio:Set('X')

    Else

       ::oTVF_RegistroFacturacionAltaType:RechazoPrevio:Set('N')

    Endif

Return ( Self )

/* METHOD: SetFacturasRectificadas( oRegFacAl )
    Aplica la factura rectificada
    Parámetros:
        oRegFacAl: Objeto con los datos del registro de alta que se van a enviar en el fichero
    
Devuelve:
    Objeto
*/
METHOD SetFacturasRectificadas( oRegFacAl ) CLASS TVeriFactu

    Local oTVF_IDFacturaARType as Object := Nil
    Local oDocumentoRectificado as Object := Nil

    oDocumentoRectificado := &(::oQueDoc:ModeloCabecera())():New( {'SERIE'=>::oDocumento:RECTISER,'NUMERO'=>::oDocumento:RECTINUM} ):hCliente('CIF')

    If oDocumentoRectificado == Nil .Or.;
        oDocumentoRectificado:Fail()

        ::oTVF_Verifactu:__oReturn:Success := .F.
        ::oTVF_Verifactu:__oReturn:Log('Error al cargar el documento rectificativo por diferencias' + ::oQueDoc:NombreHumano() + ' ' + ::oDocumento:RECTISER:Str() + '-' + ::oDocumento:RECTINUM:Str() + ::oTVF_Verifactu:__oReturn:LogToString())

        Return ( Self )

    Endif

    WITH OBJECT oTVF_IDFacturaARType := TVF_IDFacturaARType():New( ::oTVF_Verifactu, , 'IDFacturaRectificada', Self )

        :IDEmisorFactura:Set( cCifEmp )
        :NumSerieFactura:Set( TVerifactuDocumento():New( ::oDocumento:RECTISER, ::oDocumento:RECTINUM, ::oQueDoc ):Str() )
        :FechaExpedicionFactura:Set( oDocumentoRectificado:FECHA )

    END

    ::oTVF_RegistroFacturacionAltaType:FacturasRectificadas:Set( oTVF_IDFacturaARType )

    If ::oTVF_RegistroFacturacionAltaType:TipoRectificativa:Get() == RECTIFICATIVA_SUSTITUCION

        ::oTVF_RegistroFacturacionAltaType:ImporteRectificacion:BaseRectificada:Set( oDocumentoRectificado:Bases() )
        ::oTVF_RegistroFacturacionAltaType:ImporteRectificacion:CuotaRectificada:Set( oDocumentoRectificado:IVAImps() )
        ::oTVF_RegistroFacturacionAltaType:ImporteRectificacion:CuotaRecargoRectificado:Set( oDocumentoRectificado:RECImps() )

    Endif

Return ( Self )

/* METHOD: SetEncadenamiento( oRegFacAlAnterior, oTVF_RegistroFacturacionType )
    Asigna el encadenamiento de la factura según el registro anterior
    
    Parámetros:
        oRegFacAlAnterior: Objeto con los datos del registro de alta anterior para el encadenamiento
        oTVF_RegistroFacturacionType: Objeto con los datos del registro de facturación de alta o anulación

Devuelve:
    Objeto
*/
METHOD SetEncadenamiento( oRegFacAlAnterior, oTVF_RegistroFacturacionType ) CLASS TVeriFactu

    If oRegFacAlAnterior:Len() == 0  

        oTVF_RegistroFacturacionType:Encadenamiento:PrimerRegistro:Set( 'S' )  

    Else

        oTVF_RegistroFacturacionType:Encadenamiento:RegistroAnterior:IDEmisorFactura:Set( cCifEmp )
        oTVF_RegistroFacturacionType:Encadenamiento:RegistroAnterior:NumSerieFactura:Set( TVerifactuDocumento():New( oRegFacAlAnterior:SERIE, oRegFacAlAnterior:NUMERO, ::oQueDoc ):Str() )
        oTVF_RegistroFacturacionType:Encadenamiento:RegistroAnterior:FechaExpedicionFactura:Set( oRegFacAlAnterior:FECHA )
        oTVF_RegistroFacturacionType:Encadenamiento:RegistroAnterior:Huella:Set( oRegFacAlAnterior:HUELLA )

    Endif

Return ( Self )

/* METHOD: SetSistemaInformatico( oTVF_RegistroFacturacionType )
    
    Asigna los datos del sistema informático de verifactu
    
    Parámetros:
        oTVF_RegistroFacturacionType: Objeto con los datos del registro de facturación de alta o anulación

Devuelve:
Objeto
*/
METHOD SetSistemaInformatico( oTVF_RegistroFacturacionType ) CLASS TVeriFactu

    WITH OBJECT oTVF_RegistroFacturacionType:SistemaInformatico
        :NombreRazon:Set( 'Visionwin Software, S.L.' )
        :NIF:Set('B12428355')
        :NombreSistemaInformatico:Set( 'Visionwin Facturacion')
        :IdSistemaInformatico:Set( 'VG' )
        :Version:Set( VersionPrograma())
        ::SetNumeroInstalacion( oTVF_RegistroFacturacionType )
        
        :TipoUsoPosibleSoloVerifactu:Set( 'S' )
        :TipoUsoPosibleMultiOT:Set( 'S' )
        ::SetIndicadorMultiplesOT( oTVF_RegistroFacturacionType )
    END

Return ( Self )

/* METHOD: SetIndicadorMultiplesOT( oTVF_RegistroFacturacionType )
    Asigna el indicador de múltiples OT según la configuración del sistema informático

    Parámetros:
        oTVF_RegistroFacturacionType: Objeto con los datos del registro de facturación de alta o anulación

Devuelve:
    Objeto
*/
METHOD SetIndicadorMultiplesOT( oTVF_RegistroFacturacionType ) CLASS TVerifactu

    If oApp:oData:oVerifactu:MultiplesOT

        oTVF_RegistroFacturacionType:SistemaInformatico:IndicadorMultiplesOT:Set( 'S' )

    Else

        oTVF_RegistroFacturacionType:SistemaInformatico:IndicadorMultiplesOT:Set( 'N' )

    Endif

Return ( Self )


/* METHOD: RegFacAlSaveHuella( oRegFacAl, cHuella )
   Guarda la huella del registro de alta

   Parámetros:
       oRegFacAl: Objeto con los datos del registro de alta que se van a enviar en el fichero
       cHuella: Huella a guardar

Devuelve:
    Objeto
*/
METHOD RegFacAlSaveHuella( oRegFacAl, cHuella ) CLASS TVeriFactu

    Local oRegFacAlUpdate as Object := Nil

    oRegFacAlUpdate := mRegFacAl():New():Find( oRegFacAl:ID, 'ID' )

    If oRegFacAlUpdate:Fail()

        ::oTVF_Verifactu:__oReturn:Success := .F.
        ::oTVF_Verifactu:__oReturn:Log := 'Error al cargar el registro de alta ID : ' + oRegFacAl:ID:Str() + CRLF + ' ' + oRegFacAl:DOCUMENTO + ' ' + oRegFacAl:SERIE:Str() + '-' + oRegFacAl:NUMERO:Str() + CRLF + oRegFacAl:LogToString()

        Return ( Self )

    Endif
    
    oRegFacAlUpdate:HUELLA := cHuella
    oRegFacAlUpdate:Save() 

    // -------------------------------------------------------------------------------------------------------------------------
    // Este objeto forma parte de la colección de oRegFacAl que se adquiere en el When():Get() del principio del método Enviar
    // Se actualiza aquí porque posteriormente se clona para el registro anterior y hace falta que tenga la huella, que aún no 
    // la tiene porque al pillar la colección no se han asignado aún ya que no se han enviado los registros pendientes
    // Al ser objetos, cuando se actualiza aquí, también se actualiza el correspondiente de la colección
    oRegFacAl:HUELLA := cHuella
    // -------------------------------------------------------------------------------------------------------------------------

    If oRegFacAlUpdate:Fail()

        ::oTVF_Verifactu:__oReturn:Success := .F.
        ::oTVF_Verifactu:__oReturn:Log := 'Error al guardar la huella en el registro de alta: ' + nID:Str() + ' ' + oRegFacAlUpdate:DOCUMENTO + ' ' + oRegFacAlUpdate:SERIE:Str() + '-' + oRegFacAlUpdate:NUMERO:Str() + CRLF + CRLF + oRegFacAl:LogToString()

        Return ( Self )

    Endif

Return ( Self )

/* STATIC FUNCTION: SanitizeXmlText( cText )
    Replaces non-printable control characters (except TAB, LF, CR) with spaces to keep XML valid
    // creada íntegramente por IA
    // Si hace falta, podría probarse con el stringbuilder de Chilkat pero con esta función se asegura más la cadena devuelta ya que sabemos exactamente lo que va a devolver
*/
Static Function SanitizeXmlText( cText )

    LOCAL cOut := ""
    LOCAL n := 0
    LOCAL c := ""
    LOCAL nAsc := 0

    FOR n := 1 TO Len( cText )
        c := SubStr( cText, n, 1 )
        nAsc := Asc( c )
        IF nAsc < 32 .AND. nAsc != 9 .AND. nAsc != 10 .AND. nAsc != 13
            cOut += " "
        ELSE
            cOut += c
        ENDIF
    NEXT

RETURN cOut