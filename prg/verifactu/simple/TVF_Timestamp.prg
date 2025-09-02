// CLASS: TTimestamp 
#include 'hbclass.ch'
#include "Verifactu.inc"
            
CREATE CLASS TVF_Timestamp FROM TVF_Tags
            
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR
        METHOD Get()
        METHOD Set( uData ) 
        METHOD Check( uData )
        METHOD BuildXml( oFather )
        METHOD HasData()

        DATA __cTag AS STRING INIT ''
            
    PROTECTED:
        DATA oFather     AS OBJECT  INIT Nil
        DATA __Timestamp AS STRING INIT ""
        DATA __oVerifactu AS OBJECT INIT NIL
        DATA __lRequired AS LOGICAL INIT .F.
        DATA __lDataSet AS LOGICAL INIT .F.

        METHOD Convert( uData )
            
ENDCLASS
            
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_Timestamp 

    hb_default( @lRequired, .F. )
    hb_default( @cTag, 'Timestamp' )

    ::__oVerifactu := oVerifactu
    ::__lRequired := lRequired
    ::__cTag := cTag
    ::oFather := oFather        

Return ( Self )
            
METHOD Set( uData ) CLASS TVF_Timestamp 

    uData := ::Convert( uData )

    If ::Check( uData )
            
        ::__Timestamp := uData
        ::__lDataSet := .T.

    Endif
            
Return ( Self )  

METHOD HasData() CLASS TVF_Timestamp 
Return( ::__lDataSet )


METHOD Convert( uData ) CLASS TVF_Timestamp 
    // TODO: Eliminar del switch los tipos de datos que no correspondan en esta clase

    switch ValType( uData )

        case 'N'
            
            If HB_ISNUMERIC( uData )
                
                uData := Alltrim( Transform( uData, '999999999.999') ) // TODO: Definir la m├íscara seg├║n los requisitos
        
            Endif

        exit

        case 'C'

            uData := Alltrim( uData )  // TODO: Revisar si hay que mantener espacios o no

        exit

        case 'D'

            IF HB_ISDATE( uData )

                uData := Transform( uData, '@D' ) // TODO: Definir la m├íscara seg├║n los requisitos

            Endif

        exit

    endswitch

Return( uData )

METHOD Get() CLASS TVF_Timestamp 
Return ( ::__Timestamp )

METHOD Check( uData ) CLASS TVF_Timestamp 

    hb_default( @uData, ::__Timestamp )

    If ::__lRequired .And. Len(Alltrim(( uData ))) == 0
            
        ::__oTicketBai:__oReturn:Success := .F.
        ::__oTicketBai:__oReturn:Log := 'El dato TimestampPresentacion es requerido ' + ::__cTag 
        Return ( .F. )
    
    Endif

    If .Not. HB_ISSTRING( uData )

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El dato TimestampPresentacion no es del tipo string para ' + ::__cTag
        Return ( .F. )
            
    Endif

    If Len( uData ) > 19
                    
        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El dato TimestampPresentacion excede los 19 caracteres para ' + ::__cTag
        Return ( .F. )
                
    Endif
    If .Not. hb_RegExLike( '\d{2,2}-\d{2,2}-\d{4,4} \d{2,2}:\d{2,2}:\d{2,2}', uData,  ) 
                    
        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El dato TimestampPresentacion no cumple el patr├│n \d{2,2}-\d{2,2}-\d{4,4} \d{2,2}:\d{2,2}:\d{2,2} para ' + ::__cTag
        Return ( .F. )
                
    Endif


Return ( .T. )

METHOD BuildXml( oFather) CLASS TVF_Timestamp 
    
    If ::HasData()
    
        oFather:NewChild( ::__cTag, hb_ValToStr( ::__Timestamp ) )

    Endif

Return  ( Self )
