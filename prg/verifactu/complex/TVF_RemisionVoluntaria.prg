// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/**/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_RemisionVoluntaria FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT ''
        DATA FechaFinVeriFactu AS OBJECT INIT Nil
        DATA Incidencia AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_RemisionVoluntaria

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_RemisionVoluntaria

    ::FechaFinVeriFactu := TVF_fecha():New( ::__oVerifactu, OPTIONAL, "FechaFinVeriFactu" , Self)
    ::Incidencia := TVF_IncidenciaType():New( ::__oVerifactu, OPTIONAL, "Incidencia" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_RemisionVoluntaria
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::FechaFinVeriFactu:HasData() .Or.;
       ::Incidencia:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::FechaFinVeriFactu:BuildXml( oChild )
        ::Incidencia:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_RemisionVoluntaria


    ::FechaFinVeriFactu:Check()
    ::Incidencia:Check()

Return ( Self )

METHOD HasData() CLASS TVF_RemisionVoluntaria

    Local lHasData as Logical := .F.

    lHasData := Iif( ::FechaFinVeriFactu:HasData(), .T., lHasData)
    lHasData := Iif( ::Incidencia:HasData(), .T., lHasData)

Return ( lHasData )


