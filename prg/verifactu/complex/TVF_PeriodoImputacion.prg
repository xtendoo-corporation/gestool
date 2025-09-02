// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*Período de la fecha de la operación*/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_PeriodoImputacion FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT ''
        DATA Ejercicio AS OBJECT INIT Nil
        DATA Periodo AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_PeriodoImputacion

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_PeriodoImputacion

    ::Ejercicio := TVF_YearType():New( ::__oVerifactu, REQUIRED, "Ejercicio" , Self)
    ::Periodo := TVF_TipoPeriodoType():New( ::__oVerifactu, REQUIRED, "Periodo" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_PeriodoImputacion
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::Ejercicio:HasData() .Or.;
       ::Periodo:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::Ejercicio:BuildXml( oChild )
        ::Periodo:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_PeriodoImputacion


    ::Ejercicio:Check()
    ::Periodo:Check()

Return ( Self )

METHOD HasData() CLASS TVF_PeriodoImputacion

    Local lHasData as Logical := .F.

    lHasData := Iif( ::Ejercicio:HasData(), .T., lHasData)
    lHasData := Iif( ::Periodo:HasData(), .T., lHasData)

Return ( lHasData )


