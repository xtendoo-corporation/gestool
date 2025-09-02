// CLASS: TNIFType 
#include 'hbclass.ch'
#include "Verifactu.inc"
            
CREATE CLASS TVF_NIFType FROM TVF_Tags
            
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

        DATA __NIFType AS STRING INIT ""
        DATA __oVerifactu AS OBJECT INIT NIL
        DATA __lRequired AS LOGICAL INIT .F.
        DATA __lDataSet AS LOGICAL INIT .F.

        METHOD Convert( uData )
            
ENDCLASS
            
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_NIFType 

    hb_default( @lRequired, .F. )
    hb_default( @cTag, 'NIFType' )

    ::__oVerifactu := oVerifactu
    ::__lRequired := lRequired
    ::__cTag := cTag
    ::oFather := oFather        

Return ( Self )
            
METHOD Set( uData ) CLASS TVF_NIFType 

    uData := ::Convert( uData )

    If ::Check( uData )
            
        ::__NIFType := uData
        ::__lDataSet := .T.

    Endif
            
Return ( Self )  

METHOD HasData() CLASS TVF_NIFType 
Return( ::__lDataSet )


METHOD Convert( uData ) CLASS TVF_NIFType 
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

METHOD Get() CLASS TVF_NIFType 
Return ( ::__NIFType )

METHOD Check( uData ) CLASS TVF_NIFType 

    hb_default( @uData, ::__NIFType )

    If ::__lRequired .And. Len(Alltrim(( uData ))) == 0
            
        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El dato NIF : ' + hb_ValToStr( uData ) + ' es requerido ' + ::Tags()
        Return ( .F. )
        
    
    Endif

    If .Not. HB_ISSTRING( uData )

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El dato NIF : ' + hb_ValToStr( uData ) + ' no es del tipo string para ' + ::Tags()
        Return ( .F. )
            
    Endif

    If Len( uData ) > 9
                    
        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El dato NIF : ' + hb_ValToStr( uData ) + ' excede los 9 caracteres para ' + ::Tags()
        Return ( .F. )
                
    Endif


Return ( .T. )

METHOD BuildXml( oFather) CLASS TVF_NIFType 
    
    If ::HasData()
    
        oFather:NewChild( 'sumI:' + ::__cTag, hb_ValToStr( ::__NIFType ) )

    Endif

Return  ( Self )
