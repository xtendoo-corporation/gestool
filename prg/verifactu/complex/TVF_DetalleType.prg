// Clase creada autm├íticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/**/
    
#include 'hbclass.ch'
#include "Verifactu.inc"
    
CREATE CLASS TVF_DetalleType FROM TVF_Tags
    
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()

        DATA __cTag      AS STRING  INIT 'Detalle'
        DATA Impuesto AS OBJECT INIT Nil
        DATA ClaveRegimen AS OBJECT INIT Nil
        DATA CalificacionOperacion AS OBJECT INIT Nil
        DATA OperacionExenta AS OBJECT INIT Nil
        DATA TipoImpositivo AS OBJECT INIT Nil
        DATA BaseImponibleOimporteNoSujeto AS OBJECT INIT Nil
        DATA BaseImponibleACoste AS OBJECT INIT Nil
        DATA CuotaRepercutida AS OBJECT INIT Nil
        DATA TipoRecargoEquivalencia AS OBJECT INIT Nil
        DATA CuotaRecargoEquivalencia AS OBJECT INIT Nil

        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
        DATA __oVerifactu AS OBJECT INIT Nil

            

ENDCLASS
    
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_DetalleType

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    ::__oVerifactu := oVerifactu
    ::__cTag := cTag
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS TVF_DetalleType

    ::Impuesto := TVF_ImpuestoType():New( ::__oVerifactu, OPTIONAL, "Impuesto" , Self)
    ::ClaveRegimen := TVF_IdOperacionesTrascendenciaTributariaType():New( ::__oVerifactu, OPTIONAL, "ClaveRegimen" , Self)
    ::CalificacionOperacion := TVF_CalificacionOperacionType():New( ::__oVerifactu, REQUIRED, "CalificacionOperacion" , Self)
    ::OperacionExenta := TVF_OperacionExentaType():New( ::__oVerifactu, REQUIRED, "OperacionExenta" , Self)
    ::TipoImpositivo := TVF_Tipo2_2Type():New( ::__oVerifactu, OPTIONAL, "TipoImpositivo" , Self)
    ::BaseImponibleOimporteNoSujeto := TVF_ImporteSgn12_2Type():New( ::__oVerifactu, REQUIRED, "BaseImponibleOimporteNoSujeto" , Self)
    ::BaseImponibleACoste := TVF_ImporteSgn12_2Type():New( ::__oVerifactu, OPTIONAL, "BaseImponibleACoste" , Self)
    ::CuotaRepercutida := TVF_ImporteSgn12_2Type():New( ::__oVerifactu, OPTIONAL, "CuotaRepercutida" , Self)
    ::TipoRecargoEquivalencia := TVF_Tipo2_2Type():New( ::__oVerifactu, OPTIONAL, "TipoRecargoEquivalencia" , Self)
    ::CuotaRecargoEquivalencia := TVF_ImporteSgn12_2Type():New( ::__oVerifactu, OPTIONAL, "CuotaRecargoEquivalencia" , Self)

Return ( Self )
    
METHOD BuildXml( oFather ) CLASS TVF_DetalleType
    
    Local oChild as Object := Nil
    Local cXml as String := ""

    If ::Impuesto:HasData() .Or.;
       ::ClaveRegimen:HasData() .Or.;
       ::CalificacionOperacion:HasData() .Or.;
       ::OperacionExenta:HasData() .Or.;
       ::TipoImpositivo:HasData() .Or.;
       ::BaseImponibleOimporteNoSujeto:HasData() .Or.;
       ::BaseImponibleACoste:HasData() .Or.;
       ::CuotaRepercutida:HasData() .Or.;
       ::TipoRecargoEquivalencia:HasData() .Or.;
       ::CuotaRecargoEquivalencia:HasData()

        oChild := oFather:NewChild( "sumI:" + ::__cTag,"")

        ::Impuesto:BuildXml( oChild )
        ::ClaveRegimen:BuildXml( oChild )
        ::CalificacionOperacion:BuildXml( oChild )
        ::OperacionExenta:BuildXml( oChild )
        ::TipoImpositivo:BuildXml( oChild )
        ::BaseImponibleOimporteNoSujeto:BuildXml( oChild )
        ::BaseImponibleACoste:BuildXml( oChild )
        ::CuotaRepercutida:BuildXml( oChild )
        ::TipoRecargoEquivalencia:BuildXml( oChild )
        ::CuotaRecargoEquivalencia:BuildXml( oChild )

    Endif
    
Return ( Self )

METHOD Check() CLASS TVF_DetalleType

    Local nChoices as Numeric := 0
    Local cChoicesActuales as String := ""

    nChoices += Iif( ::CalificacionOperacion:HasData(), 1, 0 )
    cChoicesActuales += Iif( ::CalificacionOperacion:HasData(), "CalificacionOperacion,", "")

    nChoices += Iif( ::OperacionExenta:HasData(), 1, 0 )
    cChoicesActuales += Iif( ::OperacionExenta:HasData(), "OperacionExenta,", "")

    If nChoices > 1

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'DetalleType solo puede tener un dato de los siguientes elementos: CalificacionOperacion,OperacionExenta, ahora tiene ' + cChoicesActuales

    Endif

    ::Impuesto:Check()
    ::ClaveRegimen:Check()
    ::CalificacionOperacion:Check()
    ::OperacionExenta:Check()
    ::TipoImpositivo:Check()
    ::BaseImponibleOimporteNoSujeto:Check()
    ::BaseImponibleACoste:Check()
    ::CuotaRepercutida:Check()
    ::TipoRecargoEquivalencia:Check()
    ::CuotaRecargoEquivalencia:Check()

Return ( Self )

METHOD HasData() CLASS TVF_DetalleType

    Local lHasData as Logical := .F.

    lHasData := Iif( ::Impuesto:HasData(), .T., lHasData)
    lHasData := Iif( ::ClaveRegimen:HasData(), .T., lHasData)
    lHasData := Iif( ::CalificacionOperacion:HasData(), .T., lHasData)
    lHasData := Iif( ::OperacionExenta:HasData(), .T., lHasData)
    lHasData := Iif( ::TipoImpositivo:HasData(), .T., lHasData)
    lHasData := Iif( ::BaseImponibleOimporteNoSujeto:HasData(), .T., lHasData)
    lHasData := Iif( ::BaseImponibleACoste:HasData(), .T., lHasData)
    lHasData := Iif( ::CuotaRepercutida:HasData(), .T., lHasData)
    lHasData := Iif( ::TipoRecargoEquivalencia:HasData(), .T., lHasData)
    lHasData := Iif( ::CuotaRecargoEquivalencia:HasData(), .T., lHasData)

Return ( lHasData )


