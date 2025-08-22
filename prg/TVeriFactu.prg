//---------------------------------------------------------------------------//
//
// TVeriFactu.prg - Sistema VeriFactu para la AEAT
//
// Descripción: Módulo completo para generar archivos JSON y códigos QR
//              que cumplen con los requisitos de VeriFactu de la AEAT
//
// Normativa: Resolución de 1 de febrero de 2024 del Departamento de 
//           Aduanas e Impuestos Especiales de la AEAT
//
// Autor: Sistema Gestool
// Fecha: Agosto 2025
//
//---------------------------------------------------------------------------//

#include "FiveWin.Ch"
#include "Font.ch"
#include "Factu.ch" 
#include "MesDbf.ch"

// Declaración de variables MEMVAR para evitar ambigüedades
MEMVAR __cRutaCertVeriFactu, __cPassCertVeriFactu, __cTipoCertVeriFactu, __cEntornoVeriFactu
MEMVAR nTotNet, nTotIva, nTotFac

//---------------------------------------------------------------------------//
//
// Clase principal VeriFactu - Cumplimiento normativa AEATfactcli
//
//---------------------------------------------------------------------------//

CLASS TVeriFactu
   
   DATA lEnable               INIT .f.

   DATA hDocumento      INIT nil
   DATA hResultado         INIT nil

   // Datos básicos de la factura
   DATA cNumero    INIT ""
   DATA cSerie         INIT ""
   DATA nNumero    INIT 0
   DATA cSufijo    INIT ""
   DATA dFecha     INIT CToD("")
   DATA cHora      INIT ""
   
   // Importes (según normativa AEAT)
   DATA nBaseImponible    INIT 0
   DATA nCuotaIVA         INIT 0
   DATA nTotal     INIT 0
   DATA nImporteTotal     INIT 0
   
   // Datos del emisor (empresa)
   DATA cNIFEmisor        INIT ""
   DATA cNombreEmisor     INIT ""
   
   // Datos del receptor (cliente)  
   DATA cNIFReceptor      INIT ""
   DATA cNombreReceptor   INIT ""
   DATA cTipoIdReceptor   INIT "02" // NIF por defecto
   
   // Control VeriFactu
   DATA cIdVeriFactu      INIT ""
   DATA cHashAnterior     INIT ""
   DATA cHashActual       INIT ""
   DATA cCodigoSeguro     INIT ""
   
   // Certificado digital y comunicación AEAT
   DATA cRutaCertificado  INIT ""
   DATA cPasswordCert     INIT ""
   DATA cTipoCertificado  INIT "P12"  // P12, PFX, CER+KEY
   DATA cRutaKeyPrivada   INIT ""
   DATA cURLAEAT          INIT ""
   DATA cTokenSesion      INIT ""
   DATA nTimeoutHTTPS     INIT 30000  // 30 segundos
   DATA cProxyServer      INIT ""
   DATA nProxyPort        INIT 0
   DATA cProxyUser        INIT ""
   DATA cProxyPass        INIT ""
   
   // Archivos y rutas
   DATA cRutaJSON         INIT ""
   DATA cRutaQR           INIT ""
   DATA cNombreArchivoJSON INIT ""
   DATA cNombreArchivoQR  INIT ""
   
   // Control de errores
   DATA lError            INIT .f.
   DATA cMensajeError     INIT ""
   DATA aErrores          INIT {}
   
   // Configuración
   DATA lGenerarQR        INIT .t.
   DATA lEnviarAEAT       INIT .f.
   DATA cEntorno          INIT "PRUEBAS" // PRUEBAS / PRODUCCION

   DATA nBaseImponible21
   DATA nBaseImponible10
   DATA nBaseImponible4
   DATA nBaseImponibleExenta

   DATA nCuotaIVA21
   DATA nCuotaIVA10
   DATA nCuotaIVA4
   
   // Variables adicionales para VeriFactu
   DATA cDescripcionOperacion  INIT ""     // Descripción de la operación
   DATA cNumeroAnterior       INIT ""     // Número de la factura anterior
   DATA dFechaAnterior        INIT CToD("") // Fecha de la factura anterior
   DATA nCuotaTotal           INIT 0      // Suma total de las cuotas de IVA

   // Métodos principales
   METHOD New( aTmp, cNifEmisor, cNomEmisor ) CONSTRUCTOR
   METHOD End()                  VIRTUAL
   METHOD SetDatos()
   METHOD ConfigurarCertificado()
   METHOD ValidarCertificado()
   METHOD GenerarVeriFactu()
   METHOD GenerarJSON()
   METHOD GenerarQR()
   METHOD EnviarAEAT()
   METHOD AutenticarAEAT()
   
   // Métodos auxiliares
   METHOD CalcularHash()
   METHOD GenerarIdVeriFactu()
   METHOD ValidarDatos()
   METHOD CrearNombresArchivos()
   METHOD EscribirArchivos( cJSON, cQR ) 
   METHOD EnviarHTTPS( cURL, cDatos, cMetodo )
   METHOD PrepararCabeceras()
   METHOD ProcesarRespuestaAEAT( cRespuesta )
   
   // Métodos de utilidad
   METHOD FormatearFecha( dFecha )
   METHOD FormatearImporte( nImporte )
   METHOD LimpiarString( cTexto )

END CLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS TVeriFactu

   ::hResultado           := {=>}

   ::nBaseImponible21   := 5
   ::nBaseImponible10   := 5
   ::nBaseImponible4   := 5
   ::nBaseImponibleExenta   := 5

   ::nCuotaIVA21  := 54
   ::nCuotaIVA10  := 54
   ::nCuotaIVA4   := 54

   // Inicializar las nuevas variables
   ::cDescripcionOperacion := "Bakery Shop/0003"  // Valor por defecto
   ::cNumeroAnterior      := ""
   ::dFechaAnterior       := CToD("")
   ::nCuotaTotal          := ::nCuotaIVA21 + ::nCuotaIVA10 + ::nCuotaIVA4

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD SetDatos( hDocumento ) CLASS TVeriFactu

   ::hDocumento        := hDocumento

   if Empty( ::hDocumento )
      AAdd( ::aErrores, "Documento no proporcionado." )
      RETURN Self
   end if

   // Inicializar variables
   
   ::aErrores          := {}
   ::lEnable           := ConfiguracionesEmpresaModel():getLogic( 'lVeryFactu', .f. )

   if ::lEnable

      // Datos básicos del documento
      ::cSerie  := AllTrim( hGet( ::hDocumento, "Serie" ) )
      ::nNumero := hGet( ::hDocumento, "Numero" )
      ::cSufijo := AllTrim( hGet( ::hDocumento, "Sufijo" ) )
      ::dFecha  := hGet( ::hDocumento, "Fecha" )
      ::cHora   := hGet( ::hDocumento, "Hora" )
      
      // Construir número completo
      ::cNumero := ::cSerie + "/" + AllTrim( Str( ::nNumero ) ) + if( !Empty( ::cSufijo ), "/" + ::cSufijo, "" )

      // Importes (usar variables globales si están disponibles)
      ::nBaseImponible := hGet( ::hDocumento, "Neto" )
      ::nCuotaIVA      := hGet( ::hDocumento, "Impuesto" )
      ::nTotal  := hGet( ::hDocumento, "Total" )
      ::nImporteTotal  := ::nBaseImponible + ::nCuotaIVA

      // Datos del emisor

      ::cNIFEmisor      := ::LimpiarString( uFieldempresa( 'cNif' ) )
      ::cNombreEmisor   := ::LimpiarString( uFieldempresa( 'cNombre' ) )

      // Datos del receptor

      ::cNIFReceptor     := ::LimpiarString( hGet( ::hDocumento, "CifCliente" ) )
      ::cNombreReceptor  := ::LimpiarString( hGet( ::hDocumento, "CifCliente" ) )
      ::cTipoIdReceptor  := "02"  // Tipos de receptores 02=NIF, 03=Pasaporte, etc.

      // ID VeriFactu

      ::GenerarIdVeriFactu()

      //Certificado digital y configuración AEAT

      ::ConfigurarCertificado()
      ::lEnviarAEAT := ConfiguracionesEmpresaModel():getLogic( 'lVeryFactu', .f. ) // Activar envío a AEAT    //**//

      else

      AAdd( ::aErrores, "VeriFactu no está habilitado en la configuración de la empresa." )

      RETURN Self

   end if
  
RETURN Self

//---------------------------------------------------------------------------//

METHOD LimpiarString( cTexto ) CLASS TVeriFactu
RETURN AllTrim( StrTran( StrTran( cTexto, Chr(13), "" ), Chr(10), "" ) )

//---------------------------------------------------------------------------//

METHOD ConfigurarCertificado() CLASS TVeriFactu

   ::cRutaCertificado    := ::LimpiarString( padr( ConfiguracionesEmpresaModel():getValue( 'cert_ruta', '' ), 200 ))
   ::cPasswordCert       := ::LimpiarString( padr( ConfiguracionesEmpresaModel():getValue( 'cert_pass', '' ), 50 ))
   ::cTipoCertificado   := "P12" // Por defecto P12, puede ser PFX o CER+KEY
   
   // Validar que el archivo existe
   if !File( ::cRutaCertificado )
      AAdd( ::aErrores, "No se encuentra el archivo de certificado: " + ::cRutaCertificado )
      RETURN .f.
   end if

   // Configurar URLs según entorno PRODUCCION o PRUEBAS

   if ConfiguracionesEmpresaModel():getLogic( 'lEntornoPruebas', .f. )
      ::cURLAEAT := "https://prewww2.aeat.es/wlpl/TIKE-CONT/ws/VeriFactu" 
   else
      ::cURLAEAT := "https://www2.aeat.es/wlpl/TIKE-CONT/ws/VeriFactu"
   end if     

RETURN .t.

//---------------------------------------------------------------------------//

METHOD ValidarCertificado() CLASS TVeriFactu

   local lValido := .f.
   local oWinHttp, oCertErr

   if Empty( ::cRutaCertificado )
      AAdd( ::aErrores, "Ruta del certificado no configurada" )
      RETURN .f.
   end if
   
   if !File( ::cRutaCertificado )
      AAdd( ::aErrores, "Archivo de certificado no encontrado" )
      RETURN .f.
   end if

   try
      // Verificar que el certificado es válido y no ha expirado
      // Esto requiere componentes COM de Windows o librerías específicas
      
      // TODO: Implementar validación real del certificado
      // Ejemplo con WinHTTP (requiere componente COM):
      /*
      oWinHttp := CreateObject( "WinHttp.WinHttpRequest.5.1" )
      if oWinHttp != nil
         oWinHttp:SetClientCertificate( ::cRutaCertificado, ::cPasswordCert )
         lValido := .t.
      end if
      */
      
      lValido := .t. // Temporal para desarrollo
      
   catch oCertErr
      ::lError := .t.
      AAdd( ::aErrores, "Error al validar certificado: " + oCertErr:Description )
      lValido := .f.
   end try

RETURN lValido

//---------------------------------------------------------------------------//

METHOD AutenticarAEAT() CLASS TVeriFactu

   local lError := .f.
   local cRespuesta := ""
   local hRespuesta := {=>}
   local cURL := ""
   local cDatos := ""
   local oErr

   try
      // Endpoint de autenticación AEAT
      cURL := ::cURLAEAT + "/auth"
      
      // Datos de autenticación
      cDatos := hb_JsonEncode( {;
         "nif" => ::cNIFEmisor,;
         "timestamp" => hb_TToC( hb_DateTime() ),;
         "version" => "1.0";
      } )
      
      // Enviar petición de autenticación
      cRespuesta := ::EnviarHTTPS( cURL, cDatos, "POST" )
      
      if !Empty( cRespuesta )
         hRespuesta := hb_JsonDecode( cRespuesta )
         
         if hb_HHasKey( hRespuesta, "token" )
            ::cTokenSesion := hRespuesta["token"]
         else
            lError := .t.
            AAdd( ::aErrores, "Token de sesión no recibido" )
         end if
      else
         lError := .t.
         AAdd( ::aErrores, "Sin respuesta del servidor AEAT" )
      end if
      
   catch oErr
      lError := .t.
      AAdd( ::aErrores, "Error en autenticación AEAT: " + oErr:Description )
   end try

RETURN lError

//---------------------------------------------------------------------------//

METHOD EnviarHTTPS( cURL, cDatos, cMetodo ) CLASS TVeriFactu

   local cRespuesta := ""
   local oWinHttp, oHttpErr
   local aCabeceras := {}
   local i

   DEFAULT cMetodo := "POST"

   try
      // Crear objeto WinHTTP para comunicación HTTPS
      oWinHttp := CreateObject( "WinHttp.WinHttpRequest.5.1" )
      
      if oWinHttp == nil
         AAdd( ::aErrores, "No se pudo crear objeto WinHTTP" )
      else
         // Configurar timeout
         oWinHttp:SetTimeOuts( ::nTimeoutHTTPS, ::nTimeoutHTTPS, ::nTimeoutHTTPS, ::nTimeoutHTTPS )
         
         // Configurar proxy si está definido
         if !Empty( ::cProxyServer )
            oWinHttp:SetProxy( 2, ::cProxyServer + ":" + AllTrim( Str( ::nProxyPort ) ) )
            if !Empty( ::cProxyUser )
               oWinHttp:SetCredentials( ::cProxyUser, ::cProxyPass, 1 ) // 1 = HTTPREQUEST_PROXYSETTING_PROXY
            end if
         end if
         
         // Abrir conexión
         oWinHttp:Open( cMetodo, cURL, .f. ) // .f. = síncrono
         
         // Configurar certificado digital
         if !Empty( ::cRutaCertificado )
            do case
               case ::cTipoCertificado == "P12" .or. ::cTipoCertificado == "PFX"
                  oWinHttp:SetClientCertificate( ::cRutaCertificado )
               otherwise
                  AAdd( ::aErrores, "Tipo de certificado no soportado: " + ::cTipoCertificado )
            endcase
         end if
         
         // Configurar cabeceras HTTP solo si no hay errores de certificado
         if Len( ::aErrores ) == 0 .or. ATail( ::aErrores ) != "Tipo de certificado no soportado: " + ::cTipoCertificado
            aCabeceras := ::PrepararCabeceras()
            for i := 1 to Len( aCabeceras )
               oWinHttp:SetRequestHeader( aCabeceras[i][1], aCabeceras[i][2] )
            next
            
            // Enviar petición
            if !Empty( cDatos )
               oWinHttp:Send( cDatos )
            else
               oWinHttp:Send()
            end if
            
            // Obtener respuesta
            if oWinHttp:Status == 200
               cRespuesta := oWinHttp:ResponseText
            else
               AAdd( ::aErrores, "Error HTTP " + AllTrim( Str( oWinHttp:Status ) ) + ": " + oWinHttp:StatusText )
            end if
         end if
      end if
      
   catch oHttpErr
      ::lError := .t.
      AAdd( ::aErrores, "Error en comunicación HTTPS: " + oHttpErr:Description )
      cRespuesta := ""
   end try

RETURN cRespuesta

//---------------------------------------------------------------------------//

METHOD PrepararCabeceras() CLASS TVeriFactu

   local aCabeceras := {}

   // Cabeceras estándar
   AAdd( aCabeceras, { "Content-Type", "application/json; charset=utf-8" } )
   AAdd( aCabeceras, { "Accept", "application/json" } )
   AAdd( aCabeceras, { "User-Agent", "Gestool-VeriFactu/1.0" } )
   
   // Token de sesión si existe
   if !Empty( ::cTokenSesion )
      AAdd( aCabeceras, { "Authorization", "Bearer " + ::cTokenSesion } )
   end if
   
   // Cabeceras específicas AEAT
   AAdd( aCabeceras, { "X-AEAT-NIF", ::cNIFEmisor } )
   AAdd( aCabeceras, { "X-AEAT-Version", "1.0" } )

RETURN aCabeceras

//---------------------------------------------------------------------------//

METHOD ProcesarRespuestaAEAT( cRespuesta ) CLASS TVeriFactu

   local hRespuesta := {=>}
   local lExito := .f.
   local oRespErr

   try
      if !Empty( cRespuesta )
         hRespuesta := hb_JsonDecode( cRespuesta )
         
         if hb_HHasKey( hRespuesta, "estado" )
            do case
               case hRespuesta["estado"] == "ACEPTADO"
                  lExito := .t.
                  // Guardar datos de respuesta
                  if hb_HHasKey( hRespuesta, "csv" )
                     // CSV (Código Seguro de Verificación) de la AEAT
                  end if
                  
               case hRespuesta["estado"] == "RECHAZADO"
                  if hb_HHasKey( hRespuesta, "errores" )
                     // Procesar errores
                     AAdd( ::aErrores, "AEAT rechazó la factura: " + hb_ValToExp( hRespuesta["errores"] ) )
                  end if
                  
               otherwise
                  AAdd( ::aErrores, "Estado desconocido: " + hRespuesta["estado"] )
            endcase
         else
            AAdd( ::aErrores, "Respuesta AEAT sin campo estado" )
         end if
      else
         AAdd( ::aErrores, "Respuesta AEAT vacía" )
      end if
      
   catch oRespErr
      ::lError := .t.
      AAdd( ::aErrores, "Error al procesar respuesta AEAT: " + oRespErr:Description )
   end try

RETURN lExito

//---------------------------------------------------------------------------//

METHOD GenerarVeriFactu() CLASS TVeriFactu

   local lExito := .f.
   local cJSON := ""
   local cQR := ""
   local oGenErr

   MsgInfo( "Entro en GenerarVeriFactu" )

   try
      // Validar datos requeridos
      if ::ValidarDatos()
         // Generar hash y código seguro
         ::CalcularHash()

         // Crear nombres de archivos
         ::CrearNombresArchivos()

         // Generar JSON
         cJSON := ::GenerarJSON()
         if !Empty( cJSON )
            // Generar código QR si está habilitado
            if ::lGenerarQR
               cQR := ::GenerarQR()
            end if
            
            // Escribir archivos
            lExito := ::EscribirArchivos( cJSON, cQR )
            
            // Enviar a AEAT si está configurado
            if lExito .and. ::lEnviarAEAT
               //::EnviarAEAT() 
            end if
         else
            AAdd( ::aErrores, "Error al generar JSON" )
            lExito := .f.
         end if
      else
         lExito := .f.
      end if

   catch oGenErr
      ::lError := .t.
      AAdd( ::aErrores, "Error en GenerarVeriFactu: " + oGenErr:Description )
      lExito := .f.
   end try

RETURN lExito

//---------------------------------------------------------------------------//

METHOD GenerarJSON() CLASS TVeriFactu

   local cJSON := ""
   local hDocumento := {=>}
   local hRegistroAlta := {=>}
   local hIDFactura := {=>}
   local hDestinatarios := {=>}
   local aIDDestinatario := {}
   local hDesglose := {=>}
   local aDetalleDesglose := {}
   local hSistemaInformatico := {=>}
   local hEncadenamiento := {=>}
   local hRegistroAnterior := {=>}
   local oJsonErr

   try
      // RegistroAlta - validamos y formateamos los datos
      hRegistroAlta := {=>}
      hRegistroAlta["IDVersion"] := "1.0"
      hRegistroAlta["FechaHoraHusoGenRegistro"] := ::FormatearFecha( ::dFecha ) + "T" + PadL(::cHora, 8, "0") + "+02:00"
      hRegistroAlta["NombreRazonEmisor"] := AllTrim(::cNombreEmisor)

      // IDFactura - aseguramos el formato correcto
      hIDFactura := {=>}
      hIDFactura["IDEmisorFactura"] := AllTrim(::cNIFEmisor)
      hIDFactura["NumSerieFactura"] := AllTrim(::cNumero)
      hIDFactura["FechaExpedicionFactura"] := ::FormatearFecha(::dFecha)
      hRegistroAlta["IDFactura"] := hIDFactura

      // Destinatarios
      if !Empty(::cNIFReceptor)
         AAdd(aIDDestinatario, {;
            "NIF" => ::cNIFReceptor,;
            "NombreRazon" => ::cNombreReceptor;
         })
         hDestinatarios["IDDestinatario"] := aIDDestinatario
         hRegistroAlta["Destinatarios"] := hDestinatarios
      endif

      // Datos de la factura
      hRegistroAlta["TipoFactura"] := "F1"
      hRegistroAlta["DescripcionOperacion"] := ::cDescripcionOperacion
      hRegistroAlta["Subsanacion"] := "N"

      // Desglose - Múltiples tipos de IVA
      if ::nBaseImponible21 > 0
         AAdd(aDetalleDesglose, {;
            "Impuesto" => "01",;
            "ClaveRegimen" => "20",;
            "CalificacionOperacion" => "S1",;
            "TipoImpositivo" => "21.00",;
            "BaseImponibleOimporteNoSujeto" => ::FormatearImporte(::nBaseImponible21),;
            "CuotaRepercutida" => ::FormatearImporte(::nCuotaIVA21);
         })
      endif

      if ::nBaseImponible10 > 0
         AAdd(aDetalleDesglose, {;
            "Impuesto" => "01",;
            "ClaveRegimen" => "20",;
            "CalificacionOperacion" => "S1",;
            "TipoImpositivo" => "10.00",;
            "BaseImponibleOimporteNoSujeto" => ::FormatearImporte(::nBaseImponible10),;
            "CuotaRepercutida" => ::FormatearImporte(::nCuotaIVA10);
         })
      endif

      if ::nBaseImponible4 > 0
         AAdd(aDetalleDesglose, {;
            "Impuesto" => "01",;
            "ClaveRegimen" => "20",;
            "CalificacionOperacion" => "S1",;
            "TipoImpositivo" => "4.00",;
            "BaseImponibleOimporteNoSujeto" => ::FormatearImporte(::nBaseImponible4),;
            "CuotaRepercutida" => ::FormatearImporte(::nCuotaIVA4);
         })
      endif

      if ::nBaseImponibleExenta > 0
         AAdd(aDetalleDesglose, {;
            "Impuesto" => "01",;
            "ClaveRegimen" => "20",;
            "CalificacionOperacion" => "N2",;
            "BaseImponibleOimporteNoSujeto" => ::FormatearImporte(::nBaseImponibleExenta);
         })
      endif

      hDesglose["DetalleDesglose"] := aDetalleDesglose
      hRegistroAlta["Desglose"] := hDesglose

      // Totales
      hRegistroAlta["CuotaTotal"] := ::FormatearImporte(::nCuotaTotal)
      hRegistroAlta["ImporteTotal"] := ::FormatearImporte(::nImporteTotal)

      // Sistema Informático
      hSistemaInformatico["NombreRazon"] := "Odoo SA"
      hSistemaInformatico["IDOtro"] := {;
         "CodigoPais" => "BE",;
         "IDType" => "02",;
         "ID" => "BE0477472701";
      }
      hSistemaInformatico["NombreSistemaInformatico"] := "Odoo"
      hSistemaInformatico["IdSistemaInformatico"] := "00"
      hSistemaInformatico["Version"] := "18.0"
      hSistemaInformatico["NumeroInstalacion"] := "2A3F415E9FDEE74DCAF240498A26BF293955A5F8C5F90E347B5CF3C502FE25E7"
      hSistemaInformatico["TipoUsoPosibleSoloVerifactu"] := "S"
      hSistemaInformatico["TipoUsoPosibleMultiOT"] := "S"
      hSistemaInformatico["IndicadorMultiplesOT"] := "S"
      hRegistroAlta["SistemaInformatico"] := hSistemaInformatico

      // Encadenamiento
      if !Empty(::cNumeroAnterior)
         hRegistroAnterior["IDEmisorFactura"] := ::cNIFEmisor
         hRegistroAnterior["NumSerieFactura"] := ::cNumeroAnterior
         hRegistroAnterior["FechaExpedicionFactura"] := ::FormatearFecha(::dFechaAnterior)
         hRegistroAnterior["Huella"] := ::cHashAnterior
         hEncadenamiento["RegistroAnterior"] := hRegistroAnterior
         hRegistroAlta["Encadenamiento"] := hEncadenamiento
      endif

      // Huella
      hRegistroAlta["TipoHuella"] := "01"
      hRegistroAlta["Huella"] := ::cHashActual

      // Estructura final
      hDocumento := {=>}
      hDocumento["RegistroAlta"] := hRegistroAlta

      MsgInfo( "Estructura JSON generada: " + hb_ValToExp( hDocumento ) )

      // Debug - Verificar estructura antes de codificar
      if Empty(hDocumento["RegistroAlta"])
         ::lError := .t.
         AAdd(::aErrores, "Error: RegistroAlta está vacío")
      endif
      
      // Convertir a JSON y validar
      cJSON := hb_JsonEncode(hDocumento, .t.)
      
      Msginfo( "JSON generado: " + cJSON )
      
      if Empty(cJSON)
         ::lError := .t.
         AAdd(::aErrores, "Error: JSON generado está vacío")
      endif

   catch oJsonErr
      ::lError := .t.
      AAdd( ::aErrores, "Error al generar JSON: " + oJsonErr:Description )
      RETURN ("")
   end try

RETURN cJSON

//---------------------------------------------------------------------------//

METHOD GenerarQR() CLASS TVeriFactu

   local cQR := ""
   local cURL := ""
   local cDatos := ""
   local oQrErr

   try
      // Construir URL según normativa AEAT VeriFactu
      // Formato: https://prewww2.aeat.es/wlpl/TIKE-CONT/ValidarQR?nif=...&numserie=...&fecha=...&importe=...
      
      cURL := if( ::cEntorno == "PRODUCCION", ;
                  "https://www2.aeat.es/wlpl/TIKE-CONT/ValidarQR", ;
                  "https://prewww2.aeat.es/wlpl/TIKE-CONT/ValidarQR" )
      
      cDatos := "?nif=" + ::cNIFEmisor + ;
                "&numserie=" + UrlEncode( ::cNumero ) + ;
                "&fecha=" + if( Day( ::dFecha ) < 10, "0" + AllTrim( Str( Day( ::dFecha ) ) ), AllTrim( Str( Day( ::dFecha ) ) ) ) + ;
                if( Month( ::dFecha ) < 10, "0" + AllTrim( Str( Month( ::dFecha ) ) ), AllTrim( Str( Month( ::dFecha ) ) ) ) + ;
                AllTrim( Str( Year( ::dFecha ) ) ) + ;
                "&importe=" + AllTrim( Str( ::nImporteTotal, 12, 2 ) ) + ;
                "&codigo=" + ::cCodigoSeguro
      
      cQR := cURL + cDatos
      
      // Aquí se podría integrar una librería de generación de QR
      // Por ahora devolvemos la URL que debe codificarse en QR

      QrCodeToHBmp( 3, 3, AllTrim( cQR ), ::cRutaQR )
      
   catch oQrErr
      ::lError := .t.
      AAdd( ::aErrores, "Error al generar QR: " + oQrErr:Description )
      cQR := ""
   end try

RETURN cQR

//---------------------------------------------------------------------------//

METHOD CalcularHash() CLASS TVeriFactu

   local cDatos := ""
   local cHash := ""
   local oHashErr

   try
      // Construir cadena para hash según normativa AEAT
      cDatos := ::cNIFEmisor + ;
                ::cNumero + ;
                DToS( ::dFecha ) + ;
                ::cHora + ;
                AllTrim( Str( ::nImporteTotal, 12, 2 ) )
      
      // Generar hash SHA-256 (requiere librería externa o función del sistema)
      cHash := hb_SHA256( cDatos )
      
      ::cHashActual := cHash
      
      // Generar código seguro (primeros 16 caracteres del hash)
      ::cCodigoSeguro := Left( cHash, 16 )
      
   catch oHashErr
      ::lError := .t.
      AAdd( ::aErrores, "Error al calcular hash: " + oHashErr:Description )
   end try

RETURN Self

//---------------------------------------------------------------------------//

METHOD GenerarIdVeriFactu() CLASS TVeriFactu

   ::cIdVeriFactu := "VF" + DToS( Date() ) + StrTran( Time(), ":", "" ) + Right( "000" + AllTrim( Str( hb_Random( 999 ) ) ), 3 )

RETURN Self

//---------------------------------------------------------------------------//

METHOD ValidarDatos() CLASS TVeriFactu

   local lValido := .t.

   ::aErrores := {}

   // Validaciones obligatorias según normativa AEAT
   if Empty( ::cNIFEmisor )
      AAdd( ::aErrores, "NIF del emisor es obligatorio" )
      lValido := .f.
   end if
   
   if Empty( ::cNombreEmisor )
      AAdd( ::aErrores, "Nombre del emisor es obligatorio" )
      lValido := .f.
   end if
   
   if Empty( ::cNumero )
      AAdd( ::aErrores, "Número es obligatorio" )
      lValido := .f.
   end if
   
   if Empty( ::dFecha )
      AAdd( ::aErrores, "Fecha es obligatoria" )
      lValido := .f.
   end if
   
   if ::nImporteTotal <= 0
      AAdd( ::aErrores, "El importe total debe ser mayor que cero" )
      lValido := .f.
   end if

RETURN lValido

//---------------------------------------------------------------------------//

METHOD CrearNombresArchivos() CLASS TVeriFactu

   local cFecha := ""
   local cHora := ""
   local cBase := ""
   
   cFecha := if( Day( ::dFecha ) < 10, "0" + AllTrim(Str( Day( ::dFecha ) ) ), AllTrim( Str( Day( ::dFecha ) ) ) )
   cFecha +=  if( Month( ::dFecha ) < 10, "0" + AllTrim( Str( Month( ::dFecha ) ) ), AllTrim( Str( Month( ::dFecha ) ) ) )
   cFecha +=  AllTrim( Str( Year( ::dFecha ) ) )

   cHora := StrTran( ::cHora, ":", "" )

   cBase := "VeriFactu_" + ::cNIFEmisor + "_" + StrTran( ::cNumero, "/", "_" ) + "_" + cFecha + "_" + cHora

   ::cNombreArchivoJSON := cBase + ".json"
   //::cNombreArchivoQR   := cBase + "_QR.txt"
   ::cNombreArchivoQR   := cBase + "_QR.bmp"
   
   // Rutas completas
   ::cRutaJSON := FullJsonDir() + ::cNombreArchivoJSON
   ::cRutaQR   := FullQrDir() + ::cNombreArchivoQR

RETURN Self

//---------------------------------------------------------------------------//

METHOD EscribirArchivos( cJSON, cQR ) CLASS TVeriFactu

   local lExito := .t.
   local hArchivo
   local oFileErr

   MsgInfo( "Entro en EscribirArchivos" )
   MsgInfo( "Contenido JSON: " +  ::cRutaJSON )
   MsgInfo( "Contenido QR: " + ::cRutaQR )
   MsgInfo(  "Contenido cJSON: " + cJSON  )

   try
      // Escribir archivo JSON
      hArchivo := FCreate( ::cRutaJSON )
      if hArchivo != -1
         FWrite( hArchivo,  cJSON )
         FClose( hArchivo )
      else
         AAdd( ::aErrores, "Error al crear archivo JSON: " + ::cRutaJSON )
         lExito := .f.
      end if
      
      // Escribir archivo QR si existe
      /*if !Empty( cQR )
         hArchivo := FCreate( ::cRutaQR )
         if hArchivo != -1
            FWrite( hArchivo, cQR )
            FClose( hArchivo )
         else
            AAdd( ::aErrores, "Error al crear archivo QR: " + ::cRutaQR )
         end if
      end if*/

   catch oFileErr
      ::lError := .t.
      AAdd( ::aErrores, "Error al escribir archivos: " + oFileErr:Description )
      lExito := .f.
   end try

RETURN lExito

//---------------------------------------------------------------------------//

METHOD EnviarAEAT() CLASS TVeriFactu

   local lExito := .f.
   local cJSON := ""
   local cRespuesta := ""
   local cURL := ""
   local oAeatErr

   try
      // Validar certificado
      if ::ValidarCertificado()
         // Autenticar con AEAT
         if ::AutenticarAEAT()
            // Preparar datos para envío
            cJSON := ::GenerarJSON()
            if !Empty( cJSON )
               // URL del endpoint de facturas
               cURL := ::cURLAEAT + "/facturas"
               
               // Enviar factura
               cRespuesta := ::EnviarHTTPS( cURL, cJSON, "POST" )
               
               // Procesar respuesta
               lExito := ::ProcesarRespuestaAEAT( cRespuesta )
               
               if lExito
                  // Log de éxito
                  //LogWrite( "VeriFactu enviado correctamente a AEAT: " + ::cNumero )
               else
                  // Log de errores
                  //LogWrite( "Error enviando VeriFactu a AEAT: " + hb_ValToExp( ::aErrores ) )
               end if
            else
               AAdd( ::aErrores, "Error al generar JSON para AEAT" )
               lExito := .f.
            end if
         else
            AAdd( ::aErrores, "Error en autenticación con AEAT" )
            lExito := .f.
         end if
      else
         AAdd( ::aErrores, "Certificado digital no válido" )
         lExito := .f.
      end if
      
   catch oAeatErr
      ::lError := .t.
      AAdd( ::aErrores, "Error general en envío AEAT: " + oAeatErr:Description )
      lExito := .f.
   end try

RETURN lExito

//---------------------------------------------------------------------------//

METHOD FormatearFecha( dFecha ) CLASS TVeriFactu
   // Formato: YYYY-MM-DD
RETURN Transform( dFecha, "@R 9999-99-99" )

//---------------------------------------------------------------------------//

METHOD FormatearImporte( nImporte ) CLASS TVeriFactu
   // Formato: sin separadores de miles, punto decimal
RETURN AllTrim( Str( nImporte, 12, 2 ) )

//---------------------------------------------------------------------------//
//
// Función principal para generar VeriFactu desde facturas
//
//---------------------------------------------------------------------------//

/*FUNCTION GenerarVeriFactu( aTmp, cNifEmisor, cNomEmisor, cNifCliente, cNomCliente, cRutaCert, cPassCert )

   local oVeriFactu
   local lExito := .f.
   local oMainErr

   DEFAULT cNifEmisor  := ""
   DEFAULT cNomEmisor  := ""
   DEFAULT cNifCliente := ""
   DEFAULT cNomCliente := ""
   DEFAULT cRutaCert   := ""
   DEFAULT cPassCert   := ""

   if aTmp == nil
      RETURN .f.
   end if

   try
      // Crear instancia de VeriFactu
      oVeriFactu := TVeriFactu():New( aTmp, cNifEmisor, cNomEmisor )
      
      // Configurar datos del cliente si existen
      if !Empty( cNifCliente )
         oVeriFactu:SetDatosReceptor( cNifCliente, cNomCliente )
      end if
      
      // Configurar certificado digital si se proporciona
      if !Empty( cRutaCert )
         oVeriFactu:ConfigurarCertificado( cRutaCert, cPassCert, "P12" )
         oVeriFactu:lEnviarAEAT := .t. // Activar envío a AEAT
      end if
      
      // Generar VeriFactu completo
      lExito := oVeriFactu:GenerarVeriFactu()
      
      // Log de errores si los hay
      if !lExito .and. Len( oVeriFactu:aErrores ) > 0
         // LogWrite( "Errores VeriFactu: " + hb_ValToExp( oVeriFactu:aErrores ) )
      end if

   catch oMainErr
      lExito := .f.
      // LogWrite( "Error GenerarVeriFactu: " + oMainErr:Description )
   end try

RETURN lExito

//---------------------------------------------------------------------------//
//
// Función para configurar certificado digital globalmente
//
//---------------------------------------------------------------------------//

FUNCTION ConfigurarCertificadoVeriFactu( cRuta, cPassword, cTipo, cEntorno )

   // Variables globales para certificado (definir en el sistema principal)
   PUBLIC __cRutaCertVeriFactu := cRuta
   PUBLIC __cPassCertVeriFactu := cPassword  
   PUBLIC __cTipoCertVeriFactu := if( Empty( cTipo ), "P12", cTipo )
   PUBLIC __cEntornoVeriFactu  := if( Empty( cEntorno ), "PRUEBAS", cEntorno )

RETURN .t.

//---------------------------------------------------------------------------//
//
// Función simplificada con certificado global
//
//---------------------------------------------------------------------------//

FUNCTION GenerarVeriFactuConCert( aTmp, cNifEmisor, cNomEmisor, cNifCliente, cNomCliente )

   local cRutaCert := ""
   local cPassCert := ""
   
   // Usar certificado global si está configurado
   if Type("__cRutaCertVeriFactu") == "C"
      cRutaCert := __cRutaCertVeriFactu
   end if
   
   if Type("__cPassCertVeriFactu") == "C"
      cPassCert := __cPassCertVeriFactu
   end if

RETURN GenerarVeriFactu( aTmp, cNifEmisor, cNomEmisor, cNifCliente, cNomCliente, cRutaCert, cPassCert )*/

//---------------------------------------------------------------------------//

// Función auxiliar para codificar URL
STATIC FUNCTION UrlEncode( cTexto )
   local cResult := ""
   local i, cChar, nAsc
   
   for i := 1 to Len( cTexto )
      cChar := SubStr( cTexto, i, 1 )
      nAsc := Asc( cChar )
      
      do case
         case ( nAsc >= 48 .and. nAsc <= 57 ) .or. ;  // 0-9
              ( nAsc >= 65 .and. nAsc <= 90 ) .or. ;  // A-Z
              ( nAsc >= 97 .and. nAsc <= 122 ) .or. ; // a-z
              cChar $ "-_.~"
            cResult += cChar
         otherwise
            cResult += "%" + Right( "0" + hb_NumToHex( nAsc ), 2 )
      endcase
   next

RETURN cResult

//---------------------------------------------------------------------------//
//
// Constantes para compatibilidad
//
//---------------------------------------------------------------------------//

#define _CSERIE              1
#define _NNUMFAC             2  
#define _CSUFFAC             3
#define _DFECFAC             6

//---------------------------------------------------------------------------//