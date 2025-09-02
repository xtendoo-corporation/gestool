// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*Cabecera de la Cobnsulta*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_CabeceraConsultaSf FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT ''
        DATA IDVersion AS OBJECT INIT Nil
        DATA ObligadoEmision AS OBJECT INIT Nil
        DATA Destinatario AS OBJECT INIT Nil
        DATA IndicadorRepresentante AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_CabeceraConsultaSf

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_CabeceraConsultaSf

    ::IDVersion := TVF_VersionType():New( ::__oVerifactu, REQUIRED, "IDVersion" , Self)
    ::ObligadoEmision := TVF_ObligadoEmisionConsultaType():New( ::__oVerifactu, OPTIONAL, "ObligadoEmision" , Self)
    ::Destinatario := TVF_PersonaFisicaJuridicaESType():New( ::__oVerifactu, OPTIONAL, "Destinatario" , Self)
    ::IndicadorRepresentante := TVF_IndicadorRepresentanteType():New( ::__oVerifactu, OPTIONAL, "IndicadorRepresentante" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_CabeceraConsultaSf
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::IDVersion:HasData() .Or.;
       ::ObligadoEmision:HasData() .Or.;
       ::Destinatario:HasData() .Or.;
       ::IndicadorRepresentante:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::IDVersion:BuildXml( oChild )
        ::ObligadoEmision:BuildXml( oChild )
        ::Destinatario:BuildXml( oChild )
        ::IndicadorRepresentante:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_CabeceraConsultaSf

    Local nChoices as Numeric := 0
    Local cChoicesActuales as String := ""

    nChoices += Iif( ::ObligadoEmision:HasData(), 1, 0 )
    cChoicesActuales += Iif( ::ObligadoEmision:HasData(), "ObligadoEmision,", "")

    nChoices += Iif( ::Destinatario:HasData(), 1, 0 )
    cChoicesActuales += Iif( ::Destinatario:HasData(), "Destinatario,", "")

    If nChoices > 1

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'CabeceraConsultaSf solo puede tener un dato de los siguientes elementos: ObligadoEmision,Destinatario, ahora tiene ' + cChoicesActuales

    Endif

    ::IDVersion:Check()
    ::ObligadoEmision:Check()
    ::Destinatario:Check()
    ::IndicadorRepresentante:Check()

Return ( Self )

METHOD HasData() CLASS TVF_CabeceraConsultaSf

    Local lHasData as Logical := .F.

    lHasData := Iif( ::IDVersion:HasData(), .T., lHasData)
    lHasData := Iif( ::ObligadoEmision:HasData(), .T., lHasData)
    lHasData := Iif( ::Destinatario:HasData(), .T., lHasData)
    lHasData := Iif( ::IndicadorRepresentante:HasData(), .T., lHasData)

Return ( lHasData )


