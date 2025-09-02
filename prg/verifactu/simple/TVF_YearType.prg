// CLASS: TYearType 
#include 'hbclass.ch'
#include "Verifactu.inc"
            
CREATE CLASS TVF_YearType FROM TVF_Tags
            
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

        DATA __YearType AS STRING INIT ""
        DATA __oVerifactu AS OBJECT INIT NIL
        DATA __lRequired AS LOGICAL INIT .F.
        DATA __lDataSet AS LOGICAL INIT .F.

        METHOD Convert( uData )
            
ENDCLASS
            
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_YearType 

    hb_default( @lRequired, .F. )
    hb_default( @cTag, 'YearType' )

    ::__oVerifactu := oVerifactu
    ::__lRequired := lRequired
    ::__cTag := cTag
    ::oFather := oFather        

Return ( Self )
            
METHOD Set( uData ) CLASS TVF_YearType 

    uData := ::Convert( uData )

    If ::Check( uData )
            
        ::__YearType := uData
        ::__lDataSet := .T.

    Endif
            
Return ( Self )  

METHOD HasData() CLASS TVF_YearType 
Return( ::__lDataSet )


METHOD Convert( uData ) CLASS TVF_YearType 
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

METHOD Get() CLASS TVF_YearType 
Return ( ::__YearType )

METHOD Check( uData ) CLASS TVF_YearType 

    hb_default( @uData, ::__YearType )

    If ::__lRequired .And. Len(Alltrim(( uData ))) == 0
            
        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El dato Ejercicio : ' + hb_ValToStr( uData ) + ' es requerido ' + ::__cTag 
        Return ( .F. )
    
    Endif

    If .Not. HB_ISSTRING( uData )

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El dato Ejercicio : ' + hb_ValToStr( uData ) + ' no es del tipo string para ' + ::__cTag
        Return ( .F. )
            
    Endif

    If Len( uData ) > 4
                    
        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El dato Ejercicio : ' + hb_ValToStr( uData ) + ' excede los 4 caracteres para ' + ::__cTag
        Return ( .F. )
                
    Endif
    If .Not. hb_RegExLike( '\d{4,4}', uData,  ) 
                    
        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El dato Ejercicio : ' + hb_ValToStr( uData ) + ' no cumple el patr├│n \d{4,4} para ' + ::__cTag
        Return ( .F. )
                
    Endif


Return ( .T. )

METHOD BuildXml( oFather) CLASS TVF_YearType 
    
    If ::HasData()
    
        oFather:NewChild( 'sumI:' + ::__cTag, hb_ValToStr( ::__YearType ) )

    Endif

Return  ( Self )
