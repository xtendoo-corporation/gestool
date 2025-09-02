// CLASS: TVF_DateTime 
#include 'hbclass.ch'
#include "Verifactu.inc"
            
CREATE CLASS TVF_DateTime FROM TVF_Tags
            
    EXPORTED:
        METHOD New( oVerifactu, lRequired, cTag, oFather ) CONSTRUCTOR
        METHOD Get()
        METHOD Set( uData ) 
        METHOD Check( uData )
        METHOD BuildXml( oFather )
        METHOD HasData()
            
        DATA __cTag AS STRING INIT ''
        DATA oFather AS OBJECT INIT NIL
        
    PROTECTED:
        DATA __dateTime AS STRING INIT ""
        DATA __oVerifactu AS OBJECT INIT NIL
        DATA __lRequired AS LOGICAL INIT .F.
        DATA __lDataSet AS LOGICAL INIT .F.
        

ENDCLASS
            
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_DateTime 

    hb_default( @lRequired, .F. )
    hb_default( @cTag, 'dateTime' )

    ::__oVerifactu := oVerifactu
    ::__lRequired := lRequired
    ::__cTag := cTag
    ::oFather := oFather
            
Return ( Self )
            
METHOD Set( uData ) CLASS TVF_DateTime 

    If ::Check( uData )
            
        ::__dateTime := uData
        ::__lDataSet := .T.

    Endif
            
Return ( Self )  

METHOD HasData() CLASS TVF_DateTime 
Return( ::__lDataSet )


METHOD Get() CLASS TVF_DateTime 
Return ( ::__dateTime )

METHOD Check( uData ) CLASS TVF_DateTime 

    // TODO: Aquí se podría hacer una comprobación para detectar si es un tipo de dato 2024-09-13T19:20:30+01:00

    hb_default( @uData, ::__dateTime )

    If .Not. HB_ISSTRING ( uData )

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El dato no es del tipo DateTime UTC para ' + ::__cTag
        Return ( .F. )
            
    Endif

    If ::__lRequired .And. Empty( uData )
        
            
        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El dato DateTime UTC es requerido ' + ::__cTag 
        Return ( .F. )
    
    Endif

Return ( .T. )

METHOD BuildXml( oFather) CLASS TVF_DateTime 
    
    If ::HasData()
    
        oFather:NewChild( 'sumI:' + ::__cTag, hb_ValToStr( ::__dateTime ) )

    Endif

Return  ( Self )
