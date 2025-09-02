// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*Identificador de persona Física o jurídica distinto del NIF 
        								 (Código pais, Tipo de Identificador, y hasta 15 caractéres)
        								 No se permite CodigoPais=ES e IDType=01-NIFContraparte
        								 para ese caso, debe utilizarse NIF en lugar de IDOtro.*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_IDOtroType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'IDOtro'
        DATA CodigoPais AS OBJECT INIT Nil
        DATA IDType AS OBJECT INIT Nil
        DATA ID AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_IDOtroType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_IDOtroType

    ::CodigoPais := TVF_CountryType2():New( ::__oVerifactu, OPTIONAL, "CodigoPais" , Self)
    ::IDType := TVF_PersonaFisicaJuridicaIDTypeType():New( ::__oVerifactu, REQUIRED, "IDType" , Self)
    ::ID := TVF_TextMax20Type():New( ::__oVerifactu, REQUIRED, "ID" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_IDOtroType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::CodigoPais:HasData() .Or.;
       ::IDType:HasData() .Or.;
       ::ID:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::CodigoPais:BuildXml( oChild )
        ::IDType:BuildXml( oChild )
        ::ID:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_IDOtroType


    ::CodigoPais:Check()
    ::IDType:Check()
    ::ID:Check()

Return ( Self )

METHOD HasData() CLASS TVF_IDOtroType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::CodigoPais:HasData(), .T., lHasData)
    lHasData := Iif( ::IDType:HasData(), .T., lHasData)
    lHasData := Iif( ::ID:HasData(), .T., lHasData)

Return ( lHasData )


