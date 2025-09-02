// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*Datos de una persona física o jurídica Española o Extranjera*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_PersonaFisicaJuridicaType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'PersonaFisicaJuridica'
        DATA NombreRazon AS OBJECT INIT Nil
        DATA NIF AS OBJECT INIT Nil
        DATA IDOtro AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_PersonaFisicaJuridicaType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_PersonaFisicaJuridicaType

    ::NombreRazon := TVF_TextMax120Type():New( ::__oVerifactu, REQUIRED, "NombreRazon" , Self)
    ::NIF := TVF_NIFType():New( ::__oVerifactu, REQUIRED, "NIF" , Self)
    ::IDOtro := TVF_IDOtroType():New( ::__oVerifactu, REQUIRED, "IDOtro" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_PersonaFisicaJuridicaType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::NombreRazon:HasData() .Or.;
       ::NIF:HasData() .Or.;
       ::IDOtro:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::NombreRazon:BuildXml( oChild )
        ::NIF:BuildXml( oChild )
        ::IDOtro:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_PersonaFisicaJuridicaType

    Local nChoices as Numeric := 0
    Local cChoicesActuales as String := ""

    nChoices += Iif( ::NIF:HasData(), 1, 0 )
    cChoicesActuales += Iif( ::NIF:HasData(), "NIF,", "")

    nChoices += Iif( ::IDOtro:HasData(), 1, 0 )
    cChoicesActuales += Iif( ::IDOtro:HasData(), "IDOtro,", "")

    If nChoices > 1

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'PersonaFisicaJuridicaType solo puede tener un dato de los siguientes elementos: NIF,IDOtro, ahora tiene ' + cChoicesActuales

    Endif

    ::NombreRazon:Check()
    ::NIF:Check()
    ::IDOtro:Check()

Return ( Self )

METHOD HasData() CLASS TVF_PersonaFisicaJuridicaType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::NombreRazon:HasData(), .T., lHasData)
    lHasData := Iif( ::NIF:HasData(), .T., lHasData)
    lHasData := Iif( ::IDOtro:HasData(), .T., lHasData)

Return ( lHasData )


