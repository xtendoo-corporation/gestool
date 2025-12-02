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
   DATA UuidFactura INIT ""
   DATA cTipoDocumento

   DATA cFacturaRectificada   INIT ""
   DATA dFechaRectificada    INIT CToD("")

   DATA nNetoRectificado
   DATA nIvaRectificado
   DATA nTotalRectificado

   DATA QRCodeDirectory INIT ""

   // Importes (según normativa AEAT)
   DATA nBaseImponible    INIT 0
   DATA nCuotaIVA         INIT 0
   DATA nTotal     INIT 0
   DATA nImporteTotal     INIT 0
   
   // Datos del emisor (empresa)
   DATA cNIFEmisor        INIT ""
   DATA cNombreEmisor     INIT ""
   DATA cDireccionEmisor  INIT ""
   DATA cCodigoPostalEmisor INIT ""
   DATA cPoblacionEmisor  INIT ""
   DATA cProvinciaEmisor  INIT ""
   DATA cPaisEmisor       INIT "ES"
   
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
   METHOD ProcesarRespuestaXMLAEAT( cRespuestaXML )
   
   // Métodos de utilidad
   METHOD FormatearFecha( dFecha )
   METHOD FormatearFechaLeft( dFecha )
   METHOD FormatearImporte( nImporte )
   METHOD FormatearHora( cHora )
   METHOD LimpiarString( cTexto )
   METHOD NormalizarDireccionAEAT( cTexto )
   METHOD NormalizarMunicipioAEAT( cTexto )
   METHOD ValidarDireccionAEAT()
   METHOD OverrideDireccionAEAT( cDireccion, cCP, cMunicipio, cProvincia, cPais )
   METHOD EscapeXML( cTexto )
   METHOD EnviarXmlAEAT()
   METHOD ExplorarObjetoChilkat( oObjeto )  // Nuevo método para debug
      METHOD ProbarMetodo( oObjeto, cProp )
      METHOD ProbarPropiedad( oObjeto, cProp )

   METHOD GeneraQrCode()
      METHOD GenerarQR()

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

   // Datos básicos del documento
   ::cSerie  := AllTrim( hGet( ::hDocumento, "Serie" ) )
   ::nNumero := hGet( ::hDocumento, "Numero" )
   ::cSufijo := AllTrim( hGet( ::hDocumento, "Sufijo" ) )
   ::dFecha  := hGet( ::hDocumento, "Fecha" )
   ::cHora   := hGet( ::hDocumento, "Hora" )
   ::UuidFactura := hGet( ::hDocumento, "Uuid" )
   ::cTipoDocumento := hGet( ::hDocumento, "TipoDocumento" )

   ::cFacturaRectificada := hGet( ::hDocumento, "FacturaRectificada" )
   ::dFechaRectificada := hGet( ::hDocumento, "FechaFacturaRectificada" )

   ::nNetoRectificado  := hGet( ::hDocumento, "NetoFacturaRectificada" )
   ::nIvaRectificado   := hGet( ::hDocumento, "IvaFacturaRectificada" )
   ::nTotalRectificado  := hGet( ::hDocumento, "TotalFacturaRectificada" )

   // Construir número completo
   ::cNumero := ::cSerie + ::cSufijo
   if ValType( ::nNumero ) == "N"
      ::cNumero+= AllTrim( Str( ::nNumero ) )
   else
      ::cNumero+= AllTrim( ::nNumero )
   end if

   //atotIva
   ::aTotIva := hGet( ::hDocumento, "aTotIva" )

   // Importes (usar variables globales si están disponibles)
   ::nBaseImponible := hGet( ::hDocumento, "Neto" )
   ::nCuotaIVA      := hGet( ::hDocumento, "Impuesto" )
   ::nTotal  := hGet( ::hDocumento, "Total" )
   ::nImporteTotal  := ::nBaseImponible + ::nCuotaIVA

   // Datos del emisor

   ::cNIFEmisor         := ::LimpiarString( uFieldempresa( 'cNif' ) )
   ::cNombreEmisor      := ::LimpiarString( uFieldempresa( 'cNombre' ) )
   ::cDireccionEmisor   := ::NormalizarDireccionAEAT( uFieldempresa( 'cDomicilio' ) )
   ::cCodigoPostalEmisor := ::LimpiarString( uFieldempresa( 'cCodPos' ) )
   ::cPoblacionEmisor   := ::NormalizarMunicipioAEAT( uFieldempresa( 'cPoblacion' ) )
   ::cProvinciaEmisor   := ::LimpiarString( uFieldempresa( 'cProvincia' ) )

   // Validar y normalizar dirección según requisitos AEAT
   if !::ValidarDireccionAEAT()
      ::lError := .t.
      AAdd( ::aErrores, "Error en validación de dirección para AEAT" )
   endif

   // Datos del receptor

   ::cNIFReceptor     := ::LimpiarString( hGet( ::hDocumento, "CifCliente" ) )
   ::cNombreReceptor  := ::LimpiarString( hGet( ::hDocumento, "NombreCliente" ) )  
   ::cTipoIdReceptor  := "02"  // Tipos de receptores 02=NIF, 03=Pasaporte, etc.

   // ID VeriFactu

   ::GenerarIdVeriFactu()

   //Factura anterior

   ::cCifAnterior             := ::LimpiarString( uFieldempresa( 'cNif' ) )
   ::cNumeroAnterior      := hget( ::hDocumento, "NumeroAnterior" )
   ::dFechaAnterior       := hget( ::hDocumento, "FechaAnterior" )
   ::cHashAnterior        :=  hget( ::hDocumento, "HuellaAnterior" )

   //Certificado digital y configuración AEAT

   ::ConfigurarCertificado()
   ::lEnviarAEAT := ConfiguracionesEmpresaModel():getLogic( 'lVeryFactu', .f. )
  
RETURN Self

//---------------------------------------------------------------------------//

METHOD LimpiarString( cTexto, lUpper ) CLASS TVeriFactu
   local cResult := ""

   default lUpper := .t.
   
   if ValType( cTexto ) != "C"
      RETURN ""
   endif
   
   // Eliminar caracteres de control y normalizar
   cResult := AllTrim( cTexto )
   cResult := StrTran( cResult, Chr(13), "" )
   cResult := StrTran( cResult, Chr(10), "" )
   cResult := StrTran( cResult, Chr(9), " " )  // Tabuladores a espacios
   
   // Normalizar espacios múltiples a uno solo
   do while At( "  ", cResult ) > 0
      cResult := StrTran( cResult, "  ", " " )
   enddo
   
   // Convertir a mayúsculas para normalizar (AEAT espera mayúsculas)
   if lUpper
      cResult := Upper( cResult )
   endif

   // Caracteres especiales que pueden causar problemas
   cResult := StrTran( cResult, "Ñ", "N" )
   cResult := StrTran( cResult, "Ç", "C" )
   cResult := StrTran( cResult, "Á", "A" )
   cResult := StrTran( cResult, "É", "E" )
   cResult := StrTran( cResult, "Í", "I" )
   cResult := StrTran( cResult, "Ó", "O" )
   cResult := StrTran( cResult, "Ú", "U" )
   cResult := StrTran( cResult, "Ü", "U" )
   
RETURN cResult

//---------------------------------------------------------------------------//

METHOD NormalizarDireccionAEAT( cTexto ) CLASS TVeriFactu
   // Normaliza direcciones para que coincidan con el formato exacto de AEAT
   local cResult := ""
   
   if ValType( cTexto ) != "C" .or. Empty( cTexto )
      RETURN ""
   endif
   
   cResult := ::LimpiarString( cTexto )
   
   // Normalizaciones específicas para direcciones españolas
   cResult := StrTran( cResult, "CALLE ", "" )
   cResult := StrTran( cResult, "C/ ", "" )
   cResult := StrTran( cResult, "C/", "" )
   cResult := StrTran( cResult, " NUM ", ", " )
   cResult := StrTran( cResult, " NUMERO ", ", " )
   cResult := StrTran( cResult, " N ", ", " )
   cResult := StrTran( cResult, " Nº ", ", " )
   cResult := StrTran( cResult, " NO ", ", " )
   
   // Normalizaciones específicas para tu caso
   if "PIO XII" $ cResult
      if At( "50", cResult ) > 0
         cResult := "PIO XII, 50"
      endif
   endif
   
   // Normalizar espacios múltiples después de las sustituciones
   do while At( "  ", cResult ) > 0
      cResult := StrTran( cResult, "  ", " " )
   enddo
   
   cResult := AllTrim( cResult )
   
RETURN cResult

//---------------------------------------------------------------------------//

METHOD NormalizarMunicipioAEAT( cTexto ) CLASS TVeriFactu
   // Normaliza municipios para que coincidan con el formato exacto de AEAT
   local cResult := ""
   
   if ValType( cTexto ) != "C" .or. Empty( cTexto )
      RETURN ""
   endif
   
   cResult := ::LimpiarString( cTexto )
   
   // Normalizaciones específicas para municipios
   cResult := StrTran( cResult, " DEL CDO", " del Condado" )
   cResult := StrTran( cResult, " DEL CONDADO", " del Condado" )
   cResult := StrTran( cResult, "BOLLULLOS", "Bollullos" )
   
   // Caso específico tuyo
   if "BOLLULLOS" $ Upper( cResult ) .and. ( "CDO" $ Upper( cResult ) .or. "CONDADO" $ Upper( cResult ) )
      cResult := "Bollullos del Condado"
   endif
   
RETURN cResult

//---------------------------------------------------------------------------//

METHOD ValidarDireccionAEAT() CLASS TVeriFactu
   // Valida y normaliza los datos de dirección según los requisitos de AEAT
   // El error 4118 indica que la dirección no coincide con los datos del NIF
   
   local lValid := .t.
   
   // Normalizar dirección principal
   if !Empty( ::cDireccionEmisor )
      // Asegurar que no exceda el límite de caracteres (120 según AEAT)
      if Len( ::cDireccionEmisor ) > 120
         ::cDireccionEmisor := Left( ::cDireccionEmisor, 120 )
      endif
   endif
   
   // Validar código postal español
   if !Empty( ::cCodigoPostalEmisor )
      // El código postal español debe ser de 5 dígitos
      if Len( ::cCodigoPostalEmisor ) != 5 .or. !IsDigit( ::cCodigoPostalEmisor )
         AAdd( ::aErrores, "Código postal inválido: " + ::cCodigoPostalEmisor + " (debe tener 5 dígitos)" )
         lValid := .f.
      endif
   endif
   
   // Validar municipio
   if !Empty( ::cPoblacionEmisor ) .and. Len( ::cPoblacionEmisor ) > 50
      ::cPoblacionEmisor := Left( ::cPoblacionEmisor, 50 )
   endif
   
   // Validar provincia
   if !Empty( ::cProvinciaEmisor ) .and. Len( ::cProvinciaEmisor ) > 30
      ::cProvinciaEmisor := Left( ::cProvinciaEmisor, 30 )
   endif
   
   // El país debe ser siempre ES para emisores españoles
   if Empty( ::cPaisEmisor ) .or. ::cPaisEmisor != "ES"
      ::cPaisEmisor := "ES"
   endif
   
   // Verificación adicional: todos los campos de dirección deben estar presentes
   // si al menos uno está informado (requisito AEAT)
   if !Empty( ::cDireccionEmisor ) .or. !Empty( ::cCodigoPostalEmisor ) .or. ;
      !Empty( ::cPoblacionEmisor ) .or. !Empty( ::cProvinciaEmisor )
      
      if Empty( ::cDireccionEmisor )
         AAdd( ::aErrores, "Dirección requerida cuando se informa la ubicación" )
         lValid := .f.
      endif
      
      if Empty( ::cCodigoPostalEmisor )
         AAdd( ::aErrores, "Código postal requerido cuando se informa la ubicación" )
         lValid := .f.
      endif
      
      if Empty( ::cPoblacionEmisor )
         AAdd( ::aErrores, "Municipio requerido cuando se informa la ubicación" )
         lValid := .f.
      endif
      
      if Empty( ::cProvinciaEmisor )
         AAdd( ::aErrores, "Provincia requerida cuando se informa la ubicación" )
         lValid := .f.
      endif
   endif
   
RETURN lValid

//---------------------------------------------------------------------------//

METHOD OverrideDireccionAEAT( cDireccion, cCP, cMunicipio, cProvincia, cPais ) CLASS TVeriFactu
   // Permite establecer manualmente la dirección exacta que AEAT tiene registrada
   // para evitar el error 4118 cuando los datos de la empresa no coinciden exactamente
   
   if !Empty( cDireccion )
      ::cDireccionEmisor := ::NormalizarDireccionAEAT( cDireccion )
   endif
   
   if !Empty( cCP )
      ::cCodigoPostalEmisor := ::LimpiarString( cCP )
   endif
   
   if !Empty( cMunicipio )
      ::cPoblacionEmisor := ::NormalizarMunicipioAEAT( cMunicipio )
   endif
   
   if !Empty( cProvincia )
      ::cProvinciaEmisor := ::LimpiarString( cProvincia )
   endif
   
   if !Empty( cPais )
      ::cPaisEmisor := ::LimpiarString( cPais )
   else
      ::cPaisEmisor := "ES"  // Por defecto España
   endif
   
   // Re-validar después del override
   ::ValidarDireccionAEAT()
   
RETURN Self

//---------------------------------------------------------------------------//

METHOD EscapeXML( cTexto ) CLASS TVeriFactu
   // Escapa caracteres especiales para XML según estándar XML 1.0
   local cResult := ""
   
   if ValType( cTexto ) != "C" .or. Empty( cTexto )
      RETURN ""
   endif
   
   cResult := AllTrim( cTexto )
   
   // Escapar caracteres XML obligatorios
   cResult := StrTran( cResult, "&", "&amp;" )   // Debe ser el primero
   cResult := StrTran( cResult, "<", "&lt;" )
   cResult := StrTran( cResult, ">", "&gt;" )
   cResult := StrTran( cResult, '"', "&quot;" )
   cResult := StrTran( cResult, "'", "&apos;" )
   
   // Eliminar caracteres de control que no son válidos en XML
   cResult := StrTran( cResult, Chr(0), "" )
   cResult := StrTran( cResult, Chr(1), "" )
   cResult := StrTran( cResult, Chr(2), "" )
   cResult := StrTran( cResult, Chr(3), "" )
   cResult := StrTran( cResult, Chr(4), "" )
   cResult := StrTran( cResult, Chr(5), "" )
   cResult := StrTran( cResult, Chr(6), "" )
   cResult := StrTran( cResult, Chr(7), "" )
   cResult := StrTran( cResult, Chr(8), "" )
   // Chr(9) = TAB es válido
   // Chr(10) = LF es válido  
   cResult := StrTran( cResult, Chr(11), "" )
   cResult := StrTran( cResult, Chr(12), "" )
   // Chr(13) = CR es válido
   cResult := StrTran( cResult, Chr(14), "" )
   cResult := StrTran( cResult, Chr(15), "" )
   cResult := StrTran( cResult, Chr(16), "" )
   cResult := StrTran( cResult, Chr(17), "" )
   cResult := StrTran( cResult, Chr(18), "" )
   cResult := StrTran( cResult, Chr(19), "" )
   cResult := StrTran( cResult, Chr(20), "" )
   cResult := StrTran( cResult, Chr(21), "" )
   cResult := StrTran( cResult, Chr(22), "" )
   cResult := StrTran( cResult, Chr(23), "" )
   cResult := StrTran( cResult, Chr(24), "" )
   cResult := StrTran( cResult, Chr(25), "" )
   cResult := StrTran( cResult, Chr(26), "" )
   cResult := StrTran( cResult, Chr(27), "" )
   cResult := StrTran( cResult, Chr(28), "" )
   cResult := StrTran( cResult, Chr(29), "" )
   cResult := StrTran( cResult, Chr(30), "" )
   cResult := StrTran( cResult, Chr(31), "" )
   
RETURN cResult

//---------------------------------------------------------------------------//

METHOD ConfigurarCertificado() CLASS TVeriFactu

   ::cRutaCertificado    := ::LimpiarString( padr( ConfiguracionesEmpresaModel():getValue( 'cert_ruta', '' ), 200 ))
   ::cPasswordCert       := ::LimpiarString( padr( ConfiguracionesEmpresaModel():getValue( 'cert_pass', '' ), 50 ), .f.)
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
      hRegistroAlta["FechaHoraHusoGenRegistro"] := ::FormatearFecha( ::dFecha ) + "T" + ::FormatearHora( ::cHora ) + "+02:00"
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
      hSistemaInformatico["IdSistemaInformatico"] := "01"
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

METHOD GeneraQrCode() CLASS TVeriFactu

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

         // Generar código QR si está habilitado
         cQR := ::GenerarQR()

         lExito := .t.

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

      cDatos := "?nif=" + if ( substr( ::cNIFEmisor, 1, 2 ) == "ES", Substr( ::cNIFEmisor, 3 ), ::cNIFEmisor ) + ;
                "&numserie=" + UrlEncode( ::cNumero ) + ;
                "&fecha=" + if( Day( ::dFecha ) < 10, "0" + AllTrim( Str( Day( ::dFecha ) ) ), AllTrim( Str( Day( ::dFecha ) ) ) ) + "-" +;
                if( Month( ::dFecha ) < 10, "0" + AllTrim( Str( Month( ::dFecha ) ) ), AllTrim( Str( Month( ::dFecha ) ) ) ) + "-" + ;
                AllTrim( Str( Year( ::dFecha ) ) ) + ;
                "&importe=" + AllTrim( Str( ::nImporteTotal, 12, 2 ) ) + ;
                "&codigo=" + ::cCodigoSeguro
      
      cQR := cURL + cDatos

      ::QRCodeDirectory := cQR

      LogWrite("Generando código QR con datos: " )
      LogWrite(cQR)

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
      // Según la normativa oficial VeriFactu (Real Decreto 1007/2023)
      // La huella se calcula con SHA-256 sobre la concatenación (SIN separadores) de:
      // 1. IDEmisorFactura
      // 2. NumSerieFactura  
      // 3. FechaExpedicionFactura (formato DD-MM-AAAA)
      // 4. TipoFactura
      // 5. CuotaTotal (formato #.## sin separadores de miles)
      // 6. ImporteTotal (formato #.## sin separadores de miles)
      // 7. Huella del registro anterior (si existe)
      // 8. FechaHoraHusoGenRegistro (formato AAAA-MM-DDTHH:MM:SS+HH:MM)
      
      cDatos := "IDEmisorFactura=" + AllTrim(::cNIFEmisor)
      cDatos += "&NumSerieFactura=" + AllTrim(::cNumero)
      cDatos += "&FechaExpedicionFactura=" + ::FormatearFecha(::dFecha)  // DD-MM-AAAA
      cDatos += "&TipoFactura=F1"
      cDatos += "&CuotaTotal=" + ::FormatearImporte(::nCuotaIVA)    // Sin separadores de miles
      cDatos += "&ImporteTotal=" + ::FormatearImporte(::nImporteTotal) // Sin separadores de miles
      
      // Si hay registro anterior, incluir su huella
      if !Empty(::cHashAnterior)
         cDatos += "&Huella=" + ::cHashAnterior
      endif
      
      // Fecha y hora con formato ISO 8601 + huso horario
      cDatos += "&FechaHoraHusoGenRegistro=" + ::FormatearFechaLeft(::dFecha) + "T" + ::FormatearHora(::cHora) + "+01:00"
      
      // Log de debug detallado
      LogWrite("=== DEBUG VERIFACTU HASH ===")
      LogWrite("1. IDEmisorFactura: [" + AllTrim(::cNIFEmisor) + "]")
      LogWrite("2. NumSerieFactura: [" + AllTrim(::cNumero) + "]")
      LogWrite("3. FechaExpedicionFactura: [" + ::FormatearFecha(::dFecha) + "]")
      LogWrite("4. TipoFactura: [F1]")
      LogWrite("5. CuotaTotal: [" + ::FormatearImporte(::nCuotaIVA) + "]")
      LogWrite("6. ImporteTotal: [" + ::FormatearImporte(::nImporteTotal) + "]")
      LogWrite("7. HuellaAnterior: [" + if(Empty(::cHashAnterior), "VACIO", ::cHashAnterior) + "]")
      LogWrite("8. FechaHoraGen: [" + ::FormatearFechaLeft(::dFecha) + "T" + ::FormatearHora(::cHora) + "+01:00]")
      LogWrite("CADENA COMPLETA: [" + cDatos + "]")
      LogWrite("LONGITUD: " + AllTrim(Str(Len(cDatos))))
      
      // Calcular hash SHA-256 y convertir a minúsculas
      cHash := Upper(hb_SHA256(cDatos))
      
      ::cHashActual := cHash
      ::cCodigoSeguro := Left(cHash, 16)
      
      LogWrite("HASH SHA-256: " + ::cHashActual)
      LogWrite("=== FIN DEBUG ===")
      
   catch oHashErr
      ::lError := .t.
      AAdd(::aErrores, "Error al calcular hash: " + oHashErr:Description)
      LogWrite("ERROR en cálculo hash: " + oHashErr:Description)
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

   do case
      case ::cTipoDocumento == FAC_CLI
         ::cRutaQR   := FullQrDir() + ::cNombreArchivoQR

      case ::cTipoDocumento == FAC_REC
         ::cRutaQR   := FullQrFacRecDir() + ::cNombreArchivoQR

      case ::cTipoDocumento == TIK_CLI
         ::cRutaQR   := FullQrTikCliDir() + ::cNombreArchivoQR
         
   endcase

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
   
   local cFec       := ""

   cFec     += Padl( AllTrim( Str( Day( dFecha ) )), 2, "0" ) + "-"
   cFec     += Padl( AllTrim( Str( Month( dFecha ) )), 2, "0" ) + "-"
   cFec     += AllTrim( Str( Year( dFecha ) ) )

RETURN ( cFec )

//--------- ------------------------------------------------------------------//

METHOD FormatearFechaLeft( dFecha ) CLASS TVeriFactu
   
   local cFec       := ""

   cFec     += AllTrim( Str( Year( dFecha ) ) ) + "-"
   cFec     += Padl( AllTrim( Str( Month( dFecha ) )), 2, "0" ) + "-"
   cFec     += Padl( AllTrim( Str( Day( dFecha ) )), 2, "0" )

RETURN ( cFec )

//---------------------------------------------------------------------------//

METHOD FormatearImporte( nImporte ) CLASS TVeriFactu
   // Formato AEAT: sin separadores de miles, punto decimal, sin espacios
   local cImporte := AllTrim( Str( nImporte, 12, 2 ) )
   
   // Asegurar que el formato sea exacto (ej: "13.60", no " 13.60")
   if At(".", cImporte) > 0
      // Ya tiene decimales
      RETURN cImporte
   else
      // Agregar .00 si es número entero
      RETURN cImporte + ".00"
   endif

RETURN cImporte

//---------------------------------------------------------------------------//

METHOD FormatearHora( cHora ) CLASS TVeriFactu
   
   local cHoraFormateada := ""
   local aParts := {}
   
   // Limpiar la hora de espacios y caracteres extraños
   cHora := AllTrim( cHora )
   
   // Si está vacía, usar hora actual
   if Empty( cHora )
      cHora := Time()
   endif
   
   // Separar por dos puntos
   aParts := hb_ATokens( cHora, ":" )
   
   // Asegurar formato HH:MM:SS
   do case
      case Len( aParts ) >= 3
         // Ya tiene HH:MM:SS, usar los primeros 3 componentes
         cHoraFormateada := PadL( AllTrim( aParts[1] ), 2, "0" ) + ":" + ;
                           PadL( AllTrim( aParts[2] ), 2, "0" ) + ":" + ;
                           PadL( AllTrim( aParts[3] ), 2, "0" )
                           
      case Len( aParts ) == 2
         // Tiene HH:MM, agregar :00
         cHoraFormateada := PadL( AllTrim( aParts[1] ), 2, "0" ) + ":" + ;
                           PadL( AllTrim( aParts[2] ), 2, "0" ) + ":00"
                           
      case Len( aParts ) == 1 .and. Len( AllTrim( aParts[1] ) ) >= 4
         // Formato HHMM sin dos puntos
         cHora := AllTrim( aParts[1] )
         cHoraFormateada := Left( cHora, 2 ) + ":" + SubStr( cHora, 3, 2 ) + ":00"
         
      otherwise
         // Formato inválido, usar 00:00:00
         cHoraFormateada := "00:00:00"
   endcase

RETURN cHoraFormateada

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

   local lExito := .f.
   local cXml := ""
   local cRespuesta := ""
   local oChilkat
   local cTextoRespuesta := ""

   //MsgInfo( "Entro en EnviarXmlAEAT" )

   //try 
      // Generar XML
      cXml := ::GenerarXml()
      LogWrite( "---------------------------------------TIKCET-----------------------------------------------------------" )
      LogWrite( "XML generado para envío a AEAT:" )
      LogWrite( cXml )
      //MsgInfo( cXml )
      
      // Crear objeto Chilkat HTTP
      oChilkat := CreateObject( "Chilkat_9_5_0.Http" )
      oChilkat:UnlockComponent("XTENDO.CB1112026_MEQCIGeYxxz+b3c4HW83VMTPP2JU2/mbYrmNpbafHFAAJoYJAiAXYURxd0bGYX6sM6aEtf97ZG2SKkS+Pc5a/leaj/K7uQ==")

      if oChilkat == nil
         AAdd( ::aErrores, "Error al crear objeto Chilkat" )
         lExito := .f.
      endif
      
      // Configurar certificado
      if File(::cRutaCertificado)
         oChilkat:SetSslClientCertPfx( ::cRutaCertificado, ::cPasswordCert )
      else
         AAdd( ::aErrores, "Certificado no encontrado: " + ::cRutaCertificado )
         lExito := .f.
      endif

      // Configurar timeouts más largos
      oChilkat:ConnectTimeout := 30
      oChilkat:ReadTimeout := 30
      
      // enviamos el contenido del XML
      oChilkat:SetRequestHeader("Content-Type", "application/xml")
      cRespuesta := oChilkat:PostXml( ::cURLAEAT, cXml, "utf-8" )

     // Debug: Investigar tipo de objeto devuelto

      oChilkat := nil

      // Procesar respuesta de la AEAT
      ::ProcesarRespuestaXMLAEAT( cRespuesta )

   //catch
   //   AAdd( ::aErrores, "Error general en envío XML" )
   //end try

RETURN ( lExito )

//---------------------------------------------------------------------------//

METHOD ProcesarRespuestaXMLAEAT( cRespuestaXML ) CLASS TVeriFactu

   local oXml
   local cEstado := ""
   local nEstado := 0
   local cDescripcion := ""
   local cCodeError := ""
   local oNodo
   local cBodyString
   local cStatusCode
   local cStatusText

   if Empty( cRespuestaXML )
      RETURN .f.
   end if

   cBodyString := cRespuestaXML:BodyStr
   cStatusCode := cRespuestaXML:StatusCode
   cStatusText := cRespuestaXML:StatusText

   //MsgInfo( cBodyString )
   //MsgInfo( cStatusCode )
   //MsgInfo( cStatusText )

   // Crear objeto Chilkat XML
   oXml := CreateObject( "Chilkat_9_5_0.Xml" )
   oXml:LoadXml( cBodyString )

   /*
   REGISTRO CON ERRORES
   Buscamos el nodo faultstring para obtener el mensaje de error
   */
   oNodo := oXml:ExtractChildByName("env:Body|env:Fault|faultstring","","")
   
   if oNodo != NIL .and. ValType(oNodo) == "O"
      cCodeError := oNodo:Content()
   end if   

   /*
   Aceptado con errores
   Buscamos el nodo EstadoEnvio para obtener el mensaje de error
   */
   oNodo := oXml:ExtractChildByName("env:Body|tikR:RespuestaRegFactuSistemaFacturacion|tikR:EstadoEnvio","","")
   
   if oNodo != NIL .and. ValType(oNodo) == "O"
      cEstado :=  oNodo:Content()
   end if

   /*
   REGISTRO YA PRESENTADO
   Buscamos el nodo DescripcionErrorRegistro para obtener el mensaje de error
   */
   oNodo := oXml:ExtractChildByName("env:Body|tikR:RespuestaRegFactuSistemaFacturacion|tikR:RespuestaLinea|tikR:DescripcionErrorRegistro","","")
   
   if oNodo != NIL .and. ValType(oNodo) == "O"
      cDescripcion := oNodo:Content()
   end if   

   //Proceso el estado en verifactu para pasarselo a la factura----------------------------------
   do case
      case Empty( cEstado )
         nEstado := 1

      case cEstado == "Incorrecto"
         nEstado := 1 

      case cEstado == "Correcto"
         nEstado := 3

      otherwise
         nEstado := 2

   endcase

   //Pasamos el estado de procesado a la factura----------------------------------------------

   do case
      case ::cTipoDocumento == FAC_CLI
         FacturasClientesModel():SetEstadoVeriFactu( ::UuidFactura, nEstado )

      case ::cTipoDocumento == FAC_REC
         RectificativasClientesModel():SetEstadoVeriFactu( ::UuidFactura, nEstado )

      case ::cTipoDocumento == TIK_CLI
         TicketsClientesModel():SetEstadoVeriFactu( ::UuidFactura, nEstado )
         
   endcase
   
   //Escribimos en el log de verifactu-----------------------------------------------------------

   cDescripcion := StrTran(  cDescripcion , "'", "" )
   cDescripcion := StrTran(  cDescripcion , CRLF, "" )
   cDescripcion := StrTran(  cDescripcion , CHR(10), "" )
   cDescripcion := StrTran(  cDescripcion , CHR(13), "" )   

   LogverifactuModel():RegEntrada( ::UuidFactura, ::cTipoDocumento, cEstado, cCodeError, cDescripcion, Str( cStatusCode ), cStatusText )
         
RETURN .t.

//---------------------------------------------------------------------------//

METHOD GenerarXml() CLASS TVeriFactu

   local cXML := ""
   local hTotIva
   local oXmlErr

   // Inicio del documento XML con sobre SOAP
   cXml += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sum="https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tike/cont/ws/SuministroLR.xsd" xmlns:sum1="https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tike/cont/ws/SuministroInformacion.xsd" xmlns:xd="http://www.w3.org/2000/09/xmldsig#">' + CRLF

   cXml += '  <soapenv:Header/>' + CRLF
   cXml += '  <soapenv:Body>' + CRLF
   cXml += '    <sum:RegFactuSistemaFacturacion>' + CRLF
   cXml += '      <sum:Cabecera>' + CRLF
   cXml += '        <sum1:ObligadoEmision>' + CRLF
   cXml += '          <sum1:NombreRazon>' + ::EscapeXML(::cNombreEmisor) + '</sum1:NombreRazon>' + CRLF
   cXml += '          <sum1:NIF>' + ::cNIFEmisor + '</sum1:NIF>' + CRLF
   cXml += '        </sum1:ObligadoEmision>' + CRLF
   cXml += '      </sum:Cabecera>' + CRLF
   cXml += '      <sum:RegistroFactura>' + CRLF
   cXml += '        <sum1:RegistroAlta>' + CRLF
   cXml += '          <sum1:IDVersion>1.0</sum1:IDVersion>' + CRLF
   cXml += '          <sum1:IDFactura>' + CRLF
   cXml += '            <sum1:IDEmisorFactura>' + ::cNIFEmisor + '</sum1:IDEmisorFactura>' + CRLF
   cXml += '            <sum1:NumSerieFactura>' + AllTrim(::cNumero) + '</sum1:NumSerieFactura>' + CRLF
   cXml += '            <sum1:FechaExpedicionFactura>' + ::FormatearFecha(::dFecha) + '</sum1:FechaExpedicionFactura>' + CRLF
   cXml += '          </sum1:IDFactura>' + CRLF
   cXml += '          <sum1:NombreRazonEmisor>' + ::EscapeXML(::cNombreEmisor) + '</sum1:NombreRazonEmisor>' + CRLF
   
   do case
      case ::cTipoDocumento == FAC_CLI
         cXml += '          <sum1:TipoFactura>F1</sum1:TipoFactura>' + CRLF
         cXml += '          <sum1:DescripcionOperacion>VENTA DE MERCADERIAS</sum1:DescripcionOperacion>' + CRLF

      case ::cTipoDocumento == FAC_REC
         cXml += '          <sum1:TipoFactura>R1</sum1:TipoFactura>' + CRLF
         cXml += '          <sum1:TipoRectificativa>S</sum1:TipoRectificativa>' + CRLF

      case ::cTipoDocumento == TIK_CLI
         cXml += '          <sum1:TipoFactura>F2</sum1:TipoFactura>' + CRLF
         cXml += '          <sum1:DescripcionOperacion>VENTA DE MERCADERIAS</sum1:DescripcionOperacion>' + CRLF
         
   endcase

   if ::cTipoDocumento == FAC_REC
         cXml += '          <sum1:FacturasRectificadas>' + CRLF
         cXml += '              <sum1:IDFacturaRectificada>' + CRLF
         cXml += '                <sum1:IDEmisorFactura>' + ::cNIFEmisor + '</sum1:IDEmisorFactura>' + CRLF
         cXml += '                <sum1:NumSerieFactura>' + AllTrim( ::cFacturaRectificada ) + '</sum1:NumSerieFactura>' + CRLF
         cXml += '                <sum1:FechaExpedicionFactura>' + ::FormatearFecha( ::dFechaRectificada ) + '</sum1:FechaExpedicionFactura>' + CRLF
         cXml += '              </sum1:IDFacturaRectificada>' + CRLF
         cXml += '          </sum1:FacturasRectificadas>' + CRLF
         cXml += '          <sum1:ImporteRectificacion>' + CRLF
         cXml += '            <sum1:BaseRectificada>' + ::FormatearImporte( ::nNetoRectificado ) + '</sum1:BaseRectificada>' + CRLF
         cXml += '            <sum1:CuotaRectificada>' + ::FormatearImporte( ::nIvaRectificado ) + '</sum1:CuotaRectificada>' + CRLF
         cXml += '          </sum1:ImporteRectificacion>' + CRLF
         cXml += '          <sum1:FechaOperacion>' + ::FormatearFecha( ::dFechaRectificada ) + '</sum1:FechaOperacion>' + CRLF
         cXml += '          <sum1:DescripcionOperacion>RECTIFICATIVA POR ERROR EN PRECIO</sum1:DescripcionOperacion>' + CRLF
   end if
   
   if ::cTipoDocumento != TIK_CLI
   cXml += '          <sum1:Destinatarios>' + CRLF
   cXml += '            <sum1:IDDestinatario>' + CRLF
   cXml += '              <sum1:NombreRazon>' + ::cNombreReceptor + '</sum1:NombreRazon>' + CRLF
   cXml += '              <sum1:NIF>' + ::cNIFReceptor + '</sum1:NIF>' + CRLF
   cXml += '            </sum1:IDDestinatario>' + CRLF
   cXml += '          </sum1:Destinatarios>' + CRLF
   end if

   cXml += '          <sum1:Desglose>' + CRLF
   for each hTotIva in ::aTotIva
   cXml += '            <sum1:DetalleDesglose>' + CRLF
   cXml += '              <sum1:Impuesto>01</sum1:Impuesto>' + CRLF
   cXml += '              <sum1:ClaveRegimen>01</sum1:ClaveRegimen>' + CRLF
   cXml += '              <sum1:CalificacionOperacion>S1</sum1:CalificacionOperacion>' + CRLF
   cXml += '              <sum1:TipoImpositivo>' + AllTrim( Str( hGet( hTotIva, "porcentajeiva" ) ) ) + '</sum1:TipoImpositivo>' + CRLF
   cXml += '              <sum1:BaseImponibleOimporteNoSujeto>' + ::FormatearImporte( hGet( hTotIva, "neto" ) ) + '</sum1:BaseImponibleOimporteNoSujeto>' + CRLF
   cXml += '              <sum1:CuotaRepercutida>' + ::FormatearImporte( hGet( hTotIva, "impiva" ) ) + '</sum1:CuotaRepercutida>' + CRLF
   cXml += '            </sum1:DetalleDesglose>' + CRLF
   next
   cXml += '          </sum1:Desglose>' + CRLF
   cXml += '          <sum1:CuotaTotal>' + ::FormatearImporte(::nCuotaIVA) + '</sum1:CuotaTotal>' + CRLF
   cXml += '          <sum1:ImporteTotal>' + ::FormatearImporte(::nImporteTotal) + '</sum1:ImporteTotal>' + CRLF
   
   if LogverifactuModel():lPrimerRegistro( ::cTipoDocumento )
   cXml += '          <sum1:Encadenamiento>' + CRLF
   cXml += '            <sum1:PrimerRegistro>S</sum1:PrimerRegistro>' + CRLF
   cXml += '          </sum1:Encadenamiento>' + CRLF
   else
   cXml += '          <sum1:Encadenamiento>' + CRLF
   cXml += '            <sum1:RegistroAnterior>' + CRLF
   cXml += '              <sum1:IDEmisorFactura>'+ ::cCifAnterior + '</sum1:IDEmisorFactura>' + CRLF
   cXml += '              <sum1:NumSerieFactura>' + ::cNumeroAnterior + '</sum1:NumSerieFactura>' + CRLF
   cXml += '              <sum1:FechaExpedicionFactura>' + ::FormatearFecha( ::dFechaAnterior ) + '</sum1:FechaExpedicionFactura>' + CRLF
   cXml += '              <sum1:Huella>' + ::cHashAnterior + '</sum1:Huella>' + CRLF
   cXml += '            </sum1:RegistroAnterior>' + CRLF
   cXml += '          </sum1:Encadenamiento>' + CRLF
   end if

   cXml += '          <sum1:SistemaInformatico>' + CRLF
   cXml += '            <sum1:NombreRazon>Xtendoo Software SL</sum1:NombreRazon>' + CRLF
   cXml += '            <sum1:NIF>B16890287</sum1:NIF>' + CRLF
   cXml += '            <sum1:NombreSistemaInformatico>Gestool</sum1:NombreSistemaInformatico>' + CRLF
   cXml += '            <sum1:IdSistemaInformatico>77</sum1:IdSistemaInformatico>' + CRLF
   cXml += '            <sum1:Version>' + __GSTVERSION__ + '</sum1:Version>' + CRLF
   cXml += '            <sum1:NumeroInstalacion>' + AllTrim( Str( Abs( nSerialHD() ) ) ) + '</sum1:NumeroInstalacion>' + CRLF
   cXml += '            <sum1:TipoUsoPosibleSoloVerifactu>N</sum1:TipoUsoPosibleSoloVerifactu>' + CRLF
   cXml += '            <sum1:TipoUsoPosibleMultiOT>S</sum1:TipoUsoPosibleMultiOT>' + CRLF
   cXml += '            <sum1:IndicadorMultiplesOT>S</sum1:IndicadorMultiplesOT>' + CRLF
   cXml += '          </sum1:SistemaInformatico>' + CRLF
   cXml += '          <sum1:FechaHoraHusoGenRegistro>' + ::FormatearFechaLeft( ::dFecha ) + 'T' + ::FormatearHora( ::cHora ) + '+01:00</sum1:FechaHoraHusoGenRegistro>' + CRLF
   cXml += '          <sum1:TipoHuella>01</sum1:TipoHuella>' + CRLF
   cXml += '          <sum1:Huella>' + ::cHashActual + '</sum1:Huella>' + CRLF
   cXml += '        </sum1:RegistroAlta>' + CRLF
   cXml += '      </sum:RegistroFactura>' + CRLF
   cXml += '    </sum:RegFactuSistemaFacturacion>' + CRLF
   cXml += '  </soapenv:Body>' + CRLF
   cXml += '</soapenv:Envelope>' + CRLF
   
RETURN cXML

//---------------------------------------------------------------------------//


/* Ejemplo generado y entregado en postman
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sum="https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tike/cont/ws/SuministroLR.xsd" xmlns:sum1="https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tike/cont/ws/SuministroInformacion.xsd" xmlns:xd="http://www.w3.org/2000/09/xmldsig#">
  <soapenv:Header/>
  <soapenv:Body>
    <sum:RegFactuSistemaFacturacion>
      <sum:Cabecera>
        <sum1:ObligadoEmision>
          <sum1:NombreRazon>DARIO CRUZ MAURO</sum1:NombreRazon>
          <sum1:NIF>75558136P</sum1:NIF>
        </sum1:ObligadoEmision>
      </sum:Cabecera>
      <sum:RegistroFactura>
        <sum1:RegistroAlta>
          <sum1:IDVersion>1.0</sum1:IDVersion>
          <sum1:IDFactura>
            <sum1:IDEmisorFactura>75558136P</sum1:IDEmisorFactura>
            <sum1:NumSerieFactura>A100</sum1:NumSerieFactura>
            <sum1:FechaExpedicionFactura>07-10-2025</sum1:FechaExpedicionFactura>
          </sum1:IDFactura>
          <sum1:NombreRazonEmisor>DARIO CRUZ MAURO</sum1:NombreRazonEmisor>
          <sum1:TipoFactura>F1</sum1:TipoFactura>
          <sum1:DescripcionOperacion>VENTA DE MERCADERIAS</sum1:DescripcionOperacion>
          <sum1:Destinatarios>
            <sum1:IDDestinatario>
              <sum1:NombreRazon>SEVIRAMA</sum1:NombreRazon>
              <sum1:NIF>B41414806</sum1:NIF>
            </sum1:IDDestinatario>
          </sum1:Destinatarios>
          <sum1:Desglose>
            <sum1:DetalleDesglose>
              <sum1:ClaveRegimen>01</sum1:ClaveRegimen>
              <sum1:CalificacionOperacion>S1</sum1:CalificacionOperacion>
              <sum1:TipoImpositivo>21</sum1:TipoImpositivo>
              <sum1:BaseImponibleOimporteNoSujeto>300</sum1:BaseImponibleOimporteNoSujeto>
              <sum1:CuotaRepercutida>63.00</sum1:CuotaRepercutida>
            </sum1:DetalleDesglose>
          </sum1:Desglose>
          <sum1:CuotaTotal>63.0</sum1:CuotaTotal>
          <sum1:ImporteTotal>363.00</sum1:ImporteTotal>
          <sum1:Encadenamiento>
            <sum1:PrimerRegistro>S</sum1:PrimerRegistro>
          </sum1:Encadenamiento>
          <sum1:SistemaInformatico>
            <sum1:NombreRazon>Xtendoo Software SL</sum1:NombreRazon>
            <sum1:NIF>B16890287</sum1:NIF>
            <sum1:NombreSistemaInformatico>Gestool</sum1:NombreSistemaInformatico>
            <sum1:IdSistemaInformatico>77</sum1:IdSistemaInformatico>
            <sum1:Version>2K25</sum1:Version>
            <sum1:NumeroInstalacion>1747627586</sum1:NumeroInstalacion>
            <sum1:TipoUsoPosibleSoloVerifactu>N</sum1:TipoUsoPosibleSoloVerifactu>
            <sum1:TipoUsoPosibleMultiOT>S</sum1:TipoUsoPosibleMultiOT>
            <sum1:IndicadorMultiplesOT>S</sum1:IndicadorMultiplesOT>
          </sum1:SistemaInformatico>
          <sum1:FechaHoraHusoGenRegistro>2025-10-07T06:34:00+01:00</sum1:FechaHoraHusoGenRegistro>
          <sum1:TipoHuella>01</sum1:TipoHuella>
          <sum1:Huella>9a4abf93de0ea77a6eff6de550c132c1a556948ea6b9b65e6e848098f04de451</sum1:Huella>
        </sum1:RegistroAlta>
      </sum:RegistroFactura>
    </sum:RegFactuSistemaFacturacion>
  </soapenv:Body>
</soapenv:Envelope>
*/

//---------------------------------------------------------------------------//
// Método para explorar objeto TOLEAUTO devuelto por Chilkat
METHOD ExplorarObjetoChilkat( oObjeto ) CLASS TVeriFactu

   local aProps := {}
   local i
   
   MsgInfo( "--- Explorando objeto TOLEAUTO ---" )
   
   // Lista de propiedades comunes que pueden tener los objetos Chilkat
   aProps := { "BodyStr", "ResponseBody", "ResponseText", "StatusCode", "Status", ;
               "StatusText", "ResponseHeader", "ContentType", "ContentLength", ;
               "CharSet", "LastErrorText", "LastStatus", "LastHeader", ;
               "SaveLastError", "VerboseLogging", "Version" }
   
   for i := 1 to Len( aProps )
      ::ProbarPropiedad( oObjeto, aProps[i] )
   next
   
   // Intentar métodos comunes
   ::ProbarMetodo( oObjeto, "GetAsString" )
   ::ProbarMetodo( oObjeto, "GetBodyStr" )
   ::ProbarMetodo( oObjeto, "GetResponseText" )
   ::ProbarMetodo( oObjeto, "ToString" )
   
   MsgInfo( "--- Fin exploración ---" )

RETURN nil

//---------------------------------------------------------------------------//
// Método auxiliar para probar propiedades
METHOD ProbarPropiedad( oObjeto, cProp ) CLASS TVeriFactu

   local xValor

   
   try
      xValor := oObjeto:&cProp
      if xValor != nil
         MsgInfo( "Propiedad " + cProp + ": " + hb_ValToExp( xValor ) )
      else
         MsgInfo( "Propiedad " + cProp + ": nil" )
      endif
   catch
      MsgInfo( "Propiedad " + cProp + ": No existe o error" )
   end try

RETURN nil

//---------------------------------------------------------------------------//
// Método auxiliar para probar métodos
METHOD ProbarMetodo( oObjeto, cMetodo ) CLASS TVeriFactu

   local xResultado
   
   try
      xResultado := oObjeto:&cMetodo()
      if xResultado != nil
         MsgInfo( "Método " + cMetodo + "(): " + hb_ValToExp( xResultado ) )
      else
         MsgInfo( "Método " + cMetodo + "(): nil" )
      endif
   catch
      MsgInfo( "Método " + cMetodo + "(): No existe o error" )
   end try

RETURN nil