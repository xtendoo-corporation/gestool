// CLASS: TCountryType2 
#include 'hbclass.ch'
#include "Verifactu.inc"
            
CREATE CLASS TVF_CountryType2 FROM TVF_Tags
            
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

        DATA __CountryType2 AS STRING INIT ""
        DATA __oVerifactu AS OBJECT INIT NIL
        DATA __lRequired AS LOGICAL INIT .F.
        DATA __lDataSet AS LOGICAL INIT .F.

        METHOD Convert( uData )
            
ENDCLASS
            
METHOD New( oVerifactu, lRequired, cTag, oFather ) CLASS TVF_CountryType2 

    hb_default( @lRequired, .F. )
    hb_default( @cTag, 'CountryType2' )

    ::__oVerifactu := oVerifactu
    ::__lRequired := lRequired
    ::__cTag := cTag
    ::oFather := oFather        

Return ( Self )
            
METHOD Set( uData ) CLASS TVF_CountryType2 

    uData := ::Convert( uData )

    If ::Check( uData )
            
        ::__CountryType2 := uData
        ::__lDataSet := .T.

    Endif
            
Return ( Self )  

METHOD HasData() CLASS TVF_CountryType2 
Return( ::__lDataSet )


METHOD Convert( uData ) CLASS TVF_CountryType2 
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

METHOD Get() CLASS TVF_CountryType2 
Return ( ::__CountryType2 )

METHOD Check( uData ) CLASS TVF_CountryType2 

    hb_default( @uData, ::__CountryType2 )


    If .Not. HB_ISSTRING( uData )

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El dato CodigoPais : ' + hb_ValToStr( uData ) + ' no es del tipo string para ' + ::__cTag
        Return ( .F. )
            
    Endif


    If hb_AScan( { 'AF','AL','DE','AD','AO','AI','AQ','AG','SA','DZ','AR','AM','AW','AU','AT','AZ','BS','BH','BD','BB','BE','BZ','BJ','BM','BY','BO','BA','BW','BV','BR','BN','BG','BF','BI','BT','CV','KY','KH','CM','CA','CF','CC','CO','KM','CG','CD','CK','KP','KR','CI','CR','HR','CU','TD','CZ','CL','CN','CY','CW','DK','DM','DO','EC','EG','AE','ER','SK','SI','ES','US','EE','ET','FO','PH','FI','FJ','FR','GA','GM','GE','GS','GH','GI','GD','GR','GL','GU','GT','GG','GN','GQ','GW','GY','HT','HM','HN','HK','HU','IN','ID','IR','IQ','IE','IM','IS','IL','IT','JM','JP','JE','JO','KZ','KE','KG','KI','KW','LA','LS','LV','LB','LR','LY','LI','LT','LU','XG','MO','MK','MG','MY','MW','MV','ML','MT','FK','MP','MA','MH','MU','MR','YT','UM','MX','FM','MD','MC','MN','ME','MS','MZ','MM','NA','NR','CX','NP','NI','NE','NG','NU','NF','NO','NC','NZ','IO','OM','NL','BQ','PK','PW','PA','PG','PY','PE','PN','PF','PL','PT','PR','QA','GB','RW','RO','RU','SB','SV','WS','AS','KN','SM','SX','PM','VC','SH','LC','ST','SN','RS','SC','SL','SG','SY','SO','LK','SZ','ZA','SD','SS','SE','CH','SR','TH','TW','TZ','TJ','PS','TF','TL','TG','TK','TO','TT','TN','TC','TM','TR','TV','UA','UG','UY','UZ','VU','VA','VE','VN','VG','VI','WF','YE','DJ','ZM','ZW','QU','XB','XU','XN' } , uData ) == 0

        ::__oVerifactu:__oReturn:Success := .F.
        ::__oVerifactu:__oReturn:Log := 'El dato ' + uData + ' no se encuentra en la lista de datos permitidos de para ' + ::__cTag
        Return ( .F. )

    Endif

Return ( .T. )

METHOD BuildXml( oFather) CLASS TVF_CountryType2 
    
    If ::HasData()
    
        oFather:NewChild( 'sumI:' + ::__cTag, hb_ValToStr( ::__CountryType2 ) )

    Endif

Return  ( Self )
