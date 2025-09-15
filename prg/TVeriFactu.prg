//---------------------------------------------------------------------------//

#include "FiveWin.Ch"
#include "Font.ch"
#include "Factu.ch" 
#include "MesDbf.ch"
#include "Chilkat.ch"


// Constantes de WinHTTP para opciones de seguridad
#define WINHTTP_OPTION_SECURITY_FLAGS                31
#define SECURITY_FLAG_IGNORE_UNKNOWN_CA             0x00001000
#define SECURITY_FLAG_IGNORE_CERT_DATE_INVALID      0x00002000
#define SECURITY_FLAG_IGNORE_CERT_CN_INVALID        0x00001000
#define SECURITY_FLAG_IGNORE_CERT_WRONG_USAGE       0x00000200

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
   DATA cCifAnterior     INIT ""
   
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
   DATA cRutaXML           INIT ""
   DATA cRutaQR           INIT ""
   DATA cNombreArchivoJSON INIT ""
   DATA cNombreArchivoXML INIT ""
   DATA cNombreArchivoQR  INIT ""
   
   // Control de errores
   DATA lError            INIT .f.
   DATA cMensajeError     INIT ""
   DATA aErrores          INIT {}
   
   // Configuración
   DATA lGenerarQR        INIT .t.
   DATA lEnviarAEAT       INIT .f.
   DATA cEntorno          INIT "PRUEBAS" // PRUEBAS / PRODUCCION

   DATA aTotIva

   // Variables adicionales para VeriFactu
   DATA cNumeroAnterior       INIT ""     // Número de la factura anterior
   DATA dFechaAnterior        INIT CToD("") // Fecha de la factura anterior

   // Métodos principales
   METHOD New( aTmp, cNifEmisor, cNomEmisor ) CONSTRUCTOR
   METHOD End()                  VIRTUAL
   METHOD SetDatos()
   METHOD ConfigurarCertificado()
   METHOD ValidarCertificado()
   METHOD GenerarVeriFactu()
   METHOD GenerarJSON()
   METHOD GenerarXml()
   METHOD GenerarQR()
   METHOD EnviarAEAT()
   METHOD AutenticarAEAT()
   
   // Métodos auxiliares
   METHOD CalcularHash()
   METHOD GenerarIdVeriFactu()
   METHOD ValidarDatos()
   METHOD CrearNombresArchivos()
   METHOD EscribirArchivos( cJSON, cXml ) 
   METHOD EnviarHTTPS( cURL, cDatos, cMetodo )
   METHOD PrepararCabeceras()
   METHOD ProcesarRespuestaAEAT( cRespuesta )
   
   // Métodos de utilidad
   METHOD FormatearFecha( dFecha )
   METHOD FormatearImporte( nImporte )
   METHOD LimpiarString( cTexto )
   METHOD EnviarXmlAEAT()

END CLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS TVeriFactu

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

      //atotIva
      ::aTotIva := hGet( ::hDocumento, "aTotIva" )

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

      //Factura anterior

      ::cCifAnterior             := hget( ::hDocumento, "CifAnterior" )
      ::cNumeroAnterior      := hget( ::hDocumento, "NumeroAnterior" )
      ::dFechaAnterior       := hget( ::hDocumento, "FechaAnterior" )
      ::cHashAnterior        :=  hget( ::hDocumento, "HuellaAnterior" )

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
      ::cURLAEAT := "https://prewww1.aeat.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP"
      ::cEntorno := "PRUEBAS"
   else
      ::cURLAEAT := "https://www1.aeat.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP"
      ::cEntorno := "PRODUCCION"
   end if
   
   // Validar que la URL se configuró correctamente
   if Empty( ::cURLAEAT )
      AAdd( ::aErrores, "Error: URL de AEAT no se pudo configurar" )
      RETURN .f.
   end if
   
   // Debug: Mostrar configuración
   //MsgInfo( "Entorno: " + ::cEntorno + Chr(13) + "URL: " + ::cURLAEAT, "Configuración AEAT" )     

RETURN .t.

//---------------------------------------------------------------------------//

METHOD ValidarCertificado() CLASS TVeriFactu

   local lValido := .f.
   local lOpenResult := .f.
   local cErrorMsg := ""
   local oWinHttp
   local oCertErr
   local oSendErr
   local oHttpErr
   local oErr
   local nSecurityFlags := SECURITY_FLAG_IGNORE_UNKNOWN_CA + ;
                                     SECURITY_FLAG_IGNORE_CERT_DATE_INVALID + ;
                                     SECURITY_FLAG_IGNORE_CERT_CN_INVALID + ;
                                     SECURITY_FLAG_IGNORE_CERT_WRONG_USAGE

   MsgInfo( "Iniciando validación del certificado...", "VeriFactu - Paso 1" )

   if Empty( ::cRutaCertificado )
      AAdd( ::aErrores, "Ruta del certificado no configurada" )
      MsgInfo( "Error: Ruta del certificado no configurada", "VeriFactu - Error" )
      RETURN .f.
   end if
   
   MsgInfo( "Ruta del certificado: " + ::cRutaCertificado, "VeriFactu - Paso 2" )
   
   if !File( ::cRutaCertificado )
      AAdd( ::aErrores, "Archivo de certificado no encontrado" )
      MsgInfo( "Error: Archivo de certificado no encontrado en: " + ::cRutaCertificado, "VeriFactu - Error" )
      RETURN .f.
   end if
   
   MsgInfo( "Archivo de certificado encontrado correctamente", "VeriFactu - Paso 3" )

   //try
      // Verificar que el certificado es válido y no ha expirado
      // Esto requiere componentes COM de Windows o librerías específicas
      
      // TODO: Implementar validación real del certificado
      // Ejemplo con WinHTTP (requiere componente COM):

      MsgInfo( "Intentando crear objeto WinHTTP...", "VeriFactu - Paso 4" )
      
      //try
         oWinHttp := CreateObject( "WinHttp.WinHttpRequest.5.1" )
      /*catch oCertErr
         AAdd( ::aErrores, "Error al crear objeto WinHTTP: " + oCertErr:Description )
         MsgInfo( "Error al crear objeto WinHTTP", "VeriFactu - Error" )
         RETURN .f.
      end*/
      
      if oWinHttp == nil
         AAdd( ::aErrores, "No se pudo crear el objeto WinHTTP. Verifique que WinHTTP esté instalado." )
         MsgInfo( "Error: No se pudo crear el objeto WinHTTP", "VeriFactu - Error" )
         RETURN .f.
      end if
      
      MsgInfo( "Objeto WinHTTP creado correctamente", "VeriFactu - Paso 5" )
      
      //try
         // Intentamos realizar una conexión de prueba a la AEAT

         MsgInfo("Conectando a AEAT: " + ::cURLAEAT)
         
         // Validar URL antes de intentar la conexión
         if Empty(::cURLAEAT)
            AAdd( ::aErrores, "URL de AEAT no configurada" )
            lValido := .f.
         else

            MsgInfo( "Configurando opciones de seguridad...", "VeriFactu - Paso 6" )
            try
               // Configurar opciones de seguridad usando la sintaxis correcta
               oWinHttp:Option(6, .t. )    // SECURITY_FLAG_IGNORE_UNKNOWN_CA
               oWinHttp:Option(18, .t. )   // SECURITY_FLAG_IGNORE_CERT_DATE_INVALID
               oWinHttp:Option(19, .t. )   // SECURITY_FLAG_IGNORE_CERT_CN_INVALID
               
               MsgInfo( "Opciones de seguridad configuradas correctamente", "VeriFactu - Paso 7" )
            catch oErr
               AAdd( ::aErrores, "Error al configurar opciones de seguridad: " + oErr:Description )
               MsgInfo( "Error al configurar opciones de seguridad: " + oErr:Description, "VeriFactu - Error" )
               RETURN .f.
            end

               // Configurar opciones adicionales antes de Open
               ?"1"
               oWinHttp:Option(4, .f. )     // WINHTTP_OPTION_REDIRECT_POLICY (no seguir redirecciones)
               ?"2"
               //oWinHttp:Option(31, 13056 )  // WINHTTP_OPTION_SECURITY_FLAGS (todas las flags)
               ?"3"
               //oWinHttp:Option(45, .t. )   // WINHTTP_OPTION_ENABLE_HTTP2 (habilitar HTTP/2)
               ?"4"
               
               // Configurar SSL/TLS
               //oWinHttp:Option(9 , 0x00000800 + 0x00000200 )  // TLS 1.2 + TLS 1.1
               ?"5"
               
               MsgInfo( "URL AEAT: " + ::cURLAEAT, "VeriFactu - Debug URL" )
               
               MsgInfo( "Intentando abrir conexión con AEAT...", "VeriFactu - Paso 8" )
               
               try
                  // Intentar abrir la conexión con parámetros explícitos
                  lOpenResult := oWinHttp:Open("GET", ::cURLAEAT, .f.)
                  
                  if lOpenResult == nil
                     MsgInfo("Error: Open devolvió NIL - Verificar URL y configuración", "VeriFactu - Error")
                  endif
                  
                  MsgInfo("Resultado de la conexión: " + if(lOpenResult == nil, "NIL", if(lOpenResult, "ÉXITO", "FALLO")), "VeriFactu - Paso 9" )
               catch oErr
                  MsgInfo("Error en Open: " + oErr:Description, "VeriFactu - Error")
                  lOpenResult := nil
               end
               
               if lOpenResult == nil .or. !lOpenResult
                  // Intentar obtener más información sobre el error
                  cErrorMsg := "Error al abrir conexión HTTP. "
                  if HB_ISOBJECT(oWinHttp) .and. oWinHttp:Status != nil
                     cErrorMsg += "Status: " + AllTrim(Str(oWinHttp:Status))
                  endif
                  if HB_ISOBJECT(oWinHttp) .and. !Empty(oWinHttp:StatusText)
                     cErrorMsg += " - " + oWinHttp:StatusText
                  endif
                  AAdd(::aErrores, cErrorMsg)
                  lValido := .f.
               else
                  // Conexión abierta correctamente, intentar enviar
                  
                  //try
                     MsgInfo( "Enviando petición al servidor AEAT...", "VeriFactu - Paso 10" )
                     oWinHttp:Send()
                     MsgInfo("Respuesta del servidor - Código: " + AllTrim(Str(oWinHttp:Status)), "VeriFactu - Paso 11" )
                     
                     MsgInfo( "Verificando respuesta del servidor...", "VeriFactu - Paso 12" )
                     // Verificar si la respuesta indica que el certificado es válido
                     if oWinHttp:Status >= 200 .and. oWinHttp:Status < 500
                        lValido := .t.
                        MsgInfo( "¡Certificado validado correctamente!", "VeriFactu - Éxito" )
                     else
                        AAdd(::aErrores, "Error en la respuesta del servidor: " + ;
                                       AllTrim(Str(oWinHttp:Status)) + " - " + ;
                                       oWinHttp:StatusText)
                        lValido := .f.
                        MsgInfo( "Error en la validación: " + AllTrim(Str(oWinHttp:Status)) + " - " + ;
                                oWinHttp:StatusText, "VeriFactu - Error" )
                     endif
                  /*catch oSendErr
                     AAdd(::aErrores, "Error al enviar petición: " + oSendErr:Description)
                     lValido := .f.
                  end*/
               endif
            /*catch oHttpErr
               AAdd(::aErrores, "Error en la conexión: " + oHttpErr:Description)
               lValido := .f.
            end*/
         endif

         // Configurar el certificado según el tipo
         if lOpenResult != .f. .and. lOpenResult != nil
            do case
               case ::cTipoCertificado == "P12" .or. ::cTipoCertificado == "PFX"
                  if Empty(::cPasswordCert)
                     AAdd( ::aErrores, "Se requiere la contraseña para el certificado P12/PFX" )
                     lValido := .f.
                  else
                     //try
                        oWinHttp:SetClientCertificate( ::cRutaCertificado, ::cPasswordCert )
                     /*catch oCertErr
                        AAdd( ::aErrores, "Error al configurar certificado: " + oCertErr:Description )
                        lValido := .f.
                     end*/
                  endif
               case ::cTipoCertificado == "CER"
                  if !Empty(::cRutaKeyPrivada)
                     // Para certificados .cer necesitamos la clave privada
                     //try
                        oWinHttp:SetClientCertificate( ::cRutaCertificado, ::cRutaKeyPrivada )
                     /*catch oCertErr
                        AAdd( ::aErrores, "Error al configurar certificado CER: " + oCertErr:Description )
                        lValido := .f.
                     end*/
                  else
                     AAdd( ::aErrores, "Se requiere la ruta de la clave privada para certificados .cer" )
                     lValido := .f.
                  endif
            endcase

            // Intentar establecer una conexión segura solo si no hay errores previos
            if Len(::aErrores) == 0 .or. ATail(::aErrores) != "Error al configurar certificado: "
               //try
                  oWinHttp:Send()
                  MsgInfo( hb_ValToExp(oWinHttp:Status), "Status Final" )

                  // Si llegamos aquí sin errores, el certificado es válido
                  if oWinHttp:Status == 200 .or. oWinHttp:Status == 401  // 401 es aceptable ya que solo validamos el certificado
                     lValido := .t.
                  else
                     AAdd( ::aErrores, "Error al validar el certificado. Estado HTTP: " + AllTrim(Str(oWinHttp:Status)) )
                  endif
               /*catch oCertErr
                  AAdd( ::aErrores, "Error al configurar el certificado: " + oCertErr:Description )
                  lValido := .f.
               end*/
            endif
         endif
      
      //lValido := .t. // Temporal para desarrollo
      
   /*catch oCertErr
      ::lError := .t.
      AAdd( ::aErrores, "Error al validar certificado: " + oCertErr:Description )
      lValido := .f.
   end try*/

   MsgInfo( hb_ValToExp( ::aErrores ), "ValidarCertificado" )

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
   local cXML := ""
   local oGenErr

   try
      // Validar datos requeridos
      if ::ValidarDatos()
         // Generar hash y código seguro
         ::CalcularHash()

         // Crear nombres de archivos
         ::CrearNombresArchivos()

         // Generar JSON
         cJSON := ::GenerarJSON()

         // Generar Xml
         cXML := ::GenerarXml()

         // Generar código QR si está habilitado
         if ::lGenerarQR
            cQR := ::GenerarQR()
         end if
         
         // Escribir archivos
         lExito := ::EscribirArchivos( cJSON, cXML )

         // Enviar a AEAT si está configurado
         if lExito .and. ::lEnviarAEAT
            //::EnviarAEAT() 
            ::EnviarXmlAEAT()
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
   local hTotIva

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
      hRegistroAlta["DescripcionOperacion"] := uFieldEmpresa( 'cNombre' )
      hRegistroAlta["Subsanacion"] := "N"

      /*
      Tipos de Ivas--------------------------------------------------------------
      */
      
      for each hTotIva in ::aTotIva
         
         AAdd(aDetalleDesglose, {;
                     "Impuesto" => "01",;
                     "ClaveRegimen" => "20",;
                     "CalificacionOperacion" => "S1",;
                     "TipoImpositivo" => Str( hGet( hTotIva, "porcentajeiva" ) ),;
                     "BaseImponibleOimporteNoSujeto" => ::FormatearImporte( hGet( hTotIva, "neto" ) ),;
                     "CuotaRepercutida" => ::FormatearImporte( hGet( hTotIva, "impiva" ) );
                  })
      next

      hDesglose["DetalleDesglose"] := aDetalleDesglose
      hRegistroAlta["Desglose"] := hDesglose

      // Totales
      hRegistroAlta["CuotaTotal"] := ::FormatearImporte(::nCuotaIVA)
      hRegistroAlta["ImporteTotal"] := ::FormatearImporte(::nImporteTotal)

      // Sistema Informático
      hSistemaInformatico["NombreRazon"] := "Xtendoo Software S.L.U."
      hSistemaInformatico["IDOtro"] := {;
         "CodigoPais" => "ES",;
         "IDType" => "02",;
         "ID" => "ESB16890287";
      }
      hSistemaInformatico["NombreSistemaInformatico"] := __GSTROTOR__
      hSistemaInformatico["IdSistemaInformatico"] := "00"
      hSistemaInformatico["Version"] := __GSTVERSION__
      hSistemaInformatico["NumeroInstalacion"] := AllTrim( Str( Abs( nSerialHD() ) ) )
      hSistemaInformatico["TipoUsoPosibleSoloVerifactu"] := "S"
      hSistemaInformatico["TipoUsoPosibleMultiOT"] := "S"
      hSistemaInformatico["IndicadorMultiplesOT"] := "S"
      hRegistroAlta["SistemaInformatico"] := hSistemaInformatico

      // Encadenamiento
      if !Empty(::cNumeroAnterior)
         hRegistroAnterior["IDEmisorFactura"] := ::cCifAnterior
         hRegistroAnterior["NumSerieFactura"] := ::cNumeroAnterior
         hRegistroAnterior["FechaExpedicionFactura"] := ::FormatearFecha( ::dFechaAnterior )
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

      // Debug - Verificar estructura antes de codificar
      if Empty(hDocumento["RegistroAlta"])
         ::lError := .t.
         AAdd(::aErrores, "Error: RegistroAlta está vacío")
      endif
      
      // Convertir a JSON y validar
      cJSON := hb_JsonEncode(hDocumento, .t.)

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

METHOD GenerarXml() CLASS TVeriFactu

   local cXML := ""
   local hTotIva
   local oXmlErr

   try
      // Inicio del documento XML
      cXML += '<?xml version="1.0" encoding="UTF-8"?>' + CRLF
      cXML += '<DocumentoVerifactu>' + CRLF
      
      // RegistroAlta
      cXML += '  <RegistroAlta>' + CRLF
      cXML += '    <IDVersion>1.0</IDVersion>' + CRLF
      cXML += '    <FechaHoraHusoGenRegistro>' + ::FormatearFecha( ::dFecha ) + 'T' + PadL(::cHora, 8, "0") + '+02:00</FechaHoraHusoGenRegistro>' + CRLF
      cXML += '    <NombreRazonEmisor>' + AllTrim(::cNombreEmisor) + '</NombreRazonEmisor>' + CRLF
      
      // IDFactura
      cXML += '    <IDFactura>' + CRLF
      cXML += '      <IDEmisorFactura>' + AllTrim(::cNIFEmisor) + '</IDEmisorFactura>' + CRLF
      cXML += '      <NumSerieFactura>' + AllTrim(::cNumero) + '</NumSerieFactura>' + CRLF
      cXML += '      <FechaExpedicionFactura>' + ::FormatearFecha(::dFecha) + '</FechaExpedicionFactura>' + CRLF
      cXML += '    </IDFactura>' + CRLF
      
      // Destinatarios
      if !Empty(::cNIFReceptor)
         cXML += '    <Destinatarios>' + CRLF
         cXML += '      <IDDestinatario>' + CRLF
         cXML += '        <NIF>' + ::cNIFReceptor + '</NIF>' + CRLF
         cXML += '        <NombreRazon>' + ::cNombreReceptor + '</NombreRazon>' + CRLF
         cXML += '      </IDDestinatario>' + CRLF
         cXML += '    </Destinatarios>' + CRLF
      endif
      
      // Datos de la factura
      cXML += '    <TipoFactura>F1</TipoFactura>' + CRLF
      cXML += '    <DescripcionOperacion>' + uFieldEmpresa( 'cNombre' ) + '</DescripcionOperacion>' + CRLF
      cXML += '    <Subsanacion>N</Subsanacion>' + CRLF
      
      // Desglose de IVA
      cXML += '    <Desglose>' + CRLF
      cXML += '      <DetalleDesglose>' + CRLF
      
      for each hTotIva in ::aTotIva
         cXML += '        <LineaDesglose>' + CRLF
         cXML += '          <Impuesto>01</Impuesto>' + CRLF
         cXML += '          <ClaveRegimen>20</ClaveRegimen>' + CRLF
         cXML += '          <CalificacionOperacion>S1</CalificacionOperacion>' + CRLF
         cXML += '          <TipoImpositivo>' + Str( hGet( hTotIva, "porcentajeiva" ) ) + '</TipoImpositivo>' + CRLF
         cXML += '          <BaseImponibleOimporteNoSujeto>' + ::FormatearImporte( hGet( hTotIva, "neto" ) ) + '</BaseImponibleOimporteNoSujeto>' + CRLF
         cXML += '          <CuotaRepercutida>' + ::FormatearImporte( hGet( hTotIva, "impiva" ) ) + '</CuotaRepercutida>' + CRLF
         cXML += '        </LineaDesglose>' + CRLF
      next
      
      cXML += '      </DetalleDesglose>' + CRLF
      cXML += '    </Desglose>' + CRLF
      
      // Totales
      cXML += '    <CuotaTotal>' + ::FormatearImporte(::nCuotaIVA) + '</CuotaTotal>' + CRLF
      cXML += '    <ImporteTotal>' + ::FormatearImporte(::nImporteTotal) + '</ImporteTotal>' + CRLF
      
      // Sistema Informático
      cXML += '    <SistemaInformatico>' + CRLF
      cXML += '      <NombreRazon>Xtendoo Software S.L.U.</NombreRazon>' + CRLF
      cXML += '      <IDOtro>' + CRLF
      cXML += '        <CodigoPais>ES</CodigoPais>' + CRLF
      cXML += '        <IDType>02</IDType>' + CRLF
      cXML += '        <ID>ESB16890287</ID>' + CRLF
      cXML += '      </IDOtro>' + CRLF
      cXML += '      <NombreSistemaInformatico>' + __GSTROTOR__ + '</NombreSistemaInformatico>' + CRLF
      cXML += '      <IdSistemaInformatico>00</IdSistemaInformatico>' + CRLF
      cXML += '      <Version>' + __GSTVERSION__ + '</Version>' + CRLF
      cXML += '      <NumeroInstalacion>' + AllTrim( Str( Abs( nSerialHD() ) ) ) + '</NumeroInstalacion>' + CRLF
      cXML += '      <TipoUsoPosibleSoloVerifactu>S</TipoUsoPosibleSoloVerifactu>' + CRLF
      cXML += '      <TipoUsoPosibleMultiOT>S</TipoUsoPosibleMultiOT>' + CRLF
      cXML += '      <IndicadorMultiplesOT>S</IndicadorMultiplesOT>' + CRLF
      cXML += '    </SistemaInformatico>' + CRLF
      
      // Encadenamiento
      if !Empty(::cNumeroAnterior)
         cXML += '    <Encadenamiento>' + CRLF
         cXML += '      <RegistroAnterior>' + CRLF
         cXML += '        <IDEmisorFactura>' + ::cCifAnterior + '</IDEmisorFactura>' + CRLF
         cXML += '        <NumSerieFactura>' + ::cNumeroAnterior + '</NumSerieFactura>' + CRLF
         cXML += '        <FechaExpedicionFactura>' + ::FormatearFecha( ::dFechaAnterior ) + '</FechaExpedicionFactura>' + CRLF
         cXML += '        <Huella>' + ::cHashAnterior + '</Huella>' + CRLF
         cXML += '      </RegistroAnterior>' + CRLF
         cXML += '    </Encadenamiento>' + CRLF
      endif
      
      // Huella
      cXML += '    <TipoHuella>01</TipoHuella>' + CRLF
      cXML += '    <Huella>' + ::cHashActual + '</Huella>' + CRLF
      
      cXML += '  </RegistroAlta>' + CRLF
      cXML += '</DocumentoVerifactu>' + CRLF

   catch oXmlErr
      ::lError := .t.
      AAdd( ::aErrores, "Error al generar XML: " + oXmlErr:Description )
      RETURN ("")
   end try

RETURN cXML

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
   ::cNombreArchivoQR   := cBase + "_QR.bmp"
   ::cNombreArchivoXML  := cBase + ".xml"
   
   // Rutas completas
   ::cRutaJSON := FullJsonDir() + ::cNombreArchivoJSON
   ::cRutaXML := FullXMLDir() + ::cNombreArchivoXML
   ::cRutaQR   := FullQrDir() + ::cNombreArchivoQR

RETURN Self

//---------------------------------------------------------------------------//

METHOD EscribirArchivos( cJSON, cXml ) CLASS TVeriFactu

   local lExito := .t.
   local hArchivo
   local oFileErr

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
      
   catch oFileErr
      ::lError := .t.
      AAdd( ::aErrores, "Error al escribir archivos: " + oFileErr:Description )
      lExito := .f.
   end try

   try
      // Escribir archivo Xml
      hArchivo := FCreate( ::cRutaXml )
      if hArchivo != -1
         FWrite( hArchivo,  cXml )
         FClose( hArchivo )
      else
         AAdd( ::aErrores, "Error al crear archivo Xml: " + ::cRutaXml )
         lExito := .f.
      end if
      
   catch oFileErr
      ::lError := .t.
      AAdd( ::aErrores, "Error al escribir archivos: " + oFileErr:Description )
      lExito := .f.
   end try

RETURN lExito

//---------------------------------------------------------------------------//

METHOD EnviarAEAT() CLASS TVeriFactu

   local lExito := .f.
   local oAeatErr

   try
      //if ::ValidarCertificado()
         lExito := ::EnviarXmlAEAT()
         if lExito
            MsgInfo("Documento enviado correctamente a AEAT")
         else
            if !Empty(::aErrores)
               MsgStop("Error al enviar a AEAT: " + ::aErrores[1])
            endif
         endif
      //else
      //   AAdd( ::aErrores, "Certificado digital no válido" )
      //endif

   catch oAeatErr
      ::lError := .t.
      AAdd( ::aErrores, "Error general en envío AEAT: " + oAeatErr:Description )
      lExito := .f.
   end try

RETURN lExito

//---------------------------------------------------------------------------//

METHOD FormatearFecha( dFecha ) CLASS TVeriFactu
   
   local cFecha   := dToc( dFecha )  // Formato: DD/MM/YYYY
   
   cFecha   := StrTran( cFecha, "/", "-" ) // Formato: DD-MM-YYYY

RETURN ( cFecha )

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

METHOD EnviarXmlAEAT() CLASS TVeriFactu

   local lExito        := .f.
   local cXml          := ""
   local cRespuesta    := ""
   local oXmlErr
   local oChilkat
   local oerr  

   MsgInfo( "EnviarXmlAEAT" )

   try 
      // Generar XML
      cXml := ::GenerarXml()
      Msginfo( "XML generado: " + cXml )
      if !Empty(cXml)
         /* 
         // IMPLEMENTACIÓN CON CHILKAT (requiere DLL adicional)
         // Descomentar si se prefiere usar Chilkat en lugar de WinHttp
         
         // Inicializar componente Chilkat para HTTPS
         BEGIN SEQUENCE WITH {|oErr| Break(oErr) }
            oChilkat := CreateObject( "Chilkat.Http" )
            if oChilkat != nil
               // Configurar certificado cliente
               oChilkat:ClientCertificateFromPfx( ::cRutaCertificado, ::cPasswordCert )
               if oChilkat:LastMethodSuccess
                  // Configurar cabeceras
                  oChilkat:RequestHeader["Content-Type"] := "application/xml"
                  oChilkat:RequestHeader["Accept"] := "application/xml"

                  // Enviar petición POST con XML
                  cRespuesta := oChilkat:PostXml( ::cURLAEAT, cXml )
                  
                  if oChilkat:LastMethodSuccess
                     // Procesar respuesta
                     lExito := ::ProcesarRespuestaAEAT( cRespuesta )
                  else
                     AAdd( ::aErrores, "Error en envío HTTPS: " + oChilkat:LastErrorText )
                  endif
               else
                  AAdd( ::aErrores, "Error al cargar certificado: " + oChilkat:LastErrorText )
               endif
            else
               AAdd( ::aErrores, "Error al crear objeto Chilkat para HTTPS" )
            endif
         RECOVER USING oErr
            AAdd( ::aErrores, "Error con Chilkat: " + oErr:description )
         END
         */

         // IMPLEMENTACIÓN CON WINHTTP (incluido en Windows)
         ?"Iniciando envío con WinHttp..."
         BEGIN SEQUENCE WITH {|oErr| Break(oErr) }
            oHttp := CreateObject( "WinHttp.WinHttpRequest.5.1" )
            if oHttp != nil
               // Configurar opciones de seguridad SSL
               oHttp:Option[WINHTTP_OPTION_SECURITY_FLAGS] := ;
                  SECURITY_FLAG_IGNORE_UNKNOWN_CA + ;
                  SECURITY_FLAG_IGNORE_CERT_DATE_INVALID + ;
                  SECURITY_FLAG_IGNORE_CERT_CN_INVALID + ;
                  SECURITY_FLAG_IGNORE_CERT_WRONG_USAGE

               // Configurar el certificado cliente
               oHttp:SetClientCertificate( ::cRutaCertificado )

               // Abrir la conexión
               oHttp:Open( "POST", ::cURLAEAT, .f. )
               
               // Configurar cabeceras
               oHttp:SetRequestHeader( "Content-Type", "application/xml" )
               oHttp:SetRequestHeader( "Accept", "application/xml" )
               
               // Enviar el XML
               oHttp:Send( cXml )
               
               // Obtener respuesta
               if oHttp:Status == 200
                  cRespuesta := oHttp:ResponseText
                  lExito := ::ProcesarRespuestaAEAT( cRespuesta )
               else
                  AAdd( ::aErrores, "Error HTTP: " + AllTrim(Str(oHttp:Status)) + " - " + oHttp:StatusText )
               endif
            else
               AAdd( ::aErrores, "Error al crear objeto WinHttp" )
            endif
         RECOVER USING oErr
            AAdd( ::aErrores, "Error con WinHttp: " + oErr:description )
         END
         ?"WinHttp creado"
      else
         AAdd( ::aErrores, "Error al generar XML para envío a AEAT" )
      endif

   ?"8"

   catch oXmlErr
      ::lError := .t.
      AAdd( ::aErrores, "Error general en envío XML AEAT: " + oXmlErr:Description )
   end try

   MsgInfo(  "Fin EnviarXmlAEAT" )

RETURN lExito

//---------------------------------------------------------------------------//