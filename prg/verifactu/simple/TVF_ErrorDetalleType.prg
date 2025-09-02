// CLASS: TErrorDetalleType 
#include 'hbclass.ch'
#include "Verifactu.inc"
            
CREATE CLASS TVF_ErrorDetalleType FROM TVF_Tags
            
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR
        METHOD Get()
        METHOD Set( uData ) 
        METHOD Check( uData )
        METHOD BuildXml( oFather )
        METHOD HasData()

        DATA __cTag AS STRING INIT ''
        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:

        DATA __ErrorDetalleType AS NUMERIC INIT 0
        DATA __oVerifactu AS OBJECT INIT NIL
        DATA __lRequired AS LOGICAL INIT .F.
        DATA __lDataSet AS LOGICAL INIT .F.

        METHOD Convert( uData )
            
ENDCLASS
            
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_ErrorDetalleType 

    hb_default( @lRequired, .F. )
    hb_default( @cTag, 'ErrorDetalleType' )

    ::__oVerifactu := oVerifactu
    ::__lRequired := lRequired
    ::__cTag := cTag
    ::oFather := oFather        

Return ( Self )
            
METHOD Set( uData ) CLASS TVF_ErrorDetalleType 

    uData := ::Convert( uData )

    If ::Check( uData )
            
        ::__ErrorDetalleType := uData
        ::__lDataSet := .T.

    Endif
            
Return ( Self )  

METHOD HasData() CLASS TVF_ErrorDetalleType 
Return( ::__lDataSet )


METHOD Convert( uData ) CLASS TVF_ErrorDetalleType 
    // TODO: Eliminar del switch los tipos de datos que no correspondan en esta clase

    switch ValType( uData )

        case 'N'
            
            If HB_ISNUMERIC( uData )
                
                uData := Alltrim( Transform( uData, '999999999.99') ) // TODO: Definir la m├íscara seg├║n los requisitos
        
            Endif

        exit

        case 'C'

            uData := Alltrim( uData )  // TODO: Revisar si hay que mantener espacios o no

        exit

        case 'D'

            IF HB_ISDATE( uData )

                uData := uData:StrFormat('0d-0m-aaaa') // TODO: Definir la mΓö£├¡scara segΓö£Γòæn los requisitos

            Endif

        exit

    endswitch

Return( uData )

METHOD Get() CLASS TVF_ErrorDetalleType 
Return ( ::__ErrorDetalleType )

METHOD Check( uData ) CLASS TVF_ErrorDetalleType 

    hb_default( @uData, ::__ErrorDetalleType )


    If .Not. HB_ISNUMERIC( uData )

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El dato CodigoErrorRegistro : ' + hb_ValToStr( uData ) + ' no es del tipo integer para ' + ::__cTag
        Return ( .F. )

    Endif



Return ( .T. )

METHOD BuildXml( oFather) CLASS TVF_ErrorDetalleType 
    
    If ::HasData()
    
        oFather:NewChild( 'sumI:' + ::__cTag, hb_ValToStr( ::__ErrorDetalleType ) )

    Endif

Return  ( Self )
