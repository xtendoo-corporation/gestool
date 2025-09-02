// Clase creada autmÃ¡ticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/**/
    
#include 'hbclass.ch'
//#include "Verifactu.inc"
    
CREATE CLASS TVF_PeriodoImputacionType 
    
    EXPORTED:
        METHOD New( oVerifactu, l.t., cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'PeriodoImputacion'
        DATA Ejercicio AS OBJECT INIT Nil
        DATA Periodo AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __l.t. AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, l.t., cTag, oFather ) CLASS TVF_PeriodoImputacionType

    hb_default( @l.t., .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__l.t. := l.t.
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_PeriodoImputacionType

    ::Ejercicio := TVF_YearType():New( ::__oVerifactu, .t., "Ejercicio" )
    ::Periodo := TVF_TipoPeriodoType():New( ::__oVerifactu, .t., "Periodo" )

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_PeriodoImputacionType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::Ejercicio:HasData() .Or.;
       ::Periodo:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::Ejercicio:BuildXml( oChild )
        ::Periodo:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_PeriodoImputacionType


    ::Ejercicio:Check()
    ::Periodo:Check()

Return ( Self )

METHOD HasData() CLASS TVF_PeriodoImputacionType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::Ejercicio:HasData(), .T., lHasData)
    lHasData := Iif( ::Periodo:HasData(), .T., lHasData)

Return ( lHasData )


