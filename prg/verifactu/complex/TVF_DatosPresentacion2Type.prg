// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/**/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_DatosPresentacion2Type FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'DatosPresentacion2'
        DATA NIFPresentador AS OBJECT INIT Nil
        DATA TimestampPresentacion AS OBJECT INIT Nil
        DATA IdPeticion AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_DatosPresentacion2Type

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_DatosPresentacion2Type

    ::NIFPresentador := TVF_NIFType():New( ::__oVerifactu, REQUIRED, "NIFPresentador" , Self)
    ::TimestampPresentacion := TVF_dateTime():New( ::__oVerifactu, REQUIRED, "TimestampPresentacion" , Self)
    ::IdPeticion := TVF_TextMax20Type():New( ::__oVerifactu, REQUIRED, "IdPeticion" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_DatosPresentacion2Type
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::NIFPresentador:HasData() .Or.;
       ::TimestampPresentacion:HasData() .Or.;
       ::IdPeticion:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::NIFPresentador:BuildXml( oChild )
        ::TimestampPresentacion:BuildXml( oChild )
        ::IdPeticion:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_DatosPresentacion2Type


    ::NIFPresentador:Check()
    ::TimestampPresentacion:Check()
    ::IdPeticion:Check()

Return ( Self )

METHOD HasData() CLASS TVF_DatosPresentacion2Type

    Local lHasData as Logical := .F.

    lHasData := Iif( ::NIFPresentador:HasData(), .T., lHasData)
    lHasData := Iif( ::TimestampPresentacion:HasData(), .T., lHasData)
    lHasData := Iif( ::IdPeticion:HasData(), .T., lHasData)

Return ( lHasData )


