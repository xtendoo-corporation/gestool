// TODO: Poder pasar en el sinotype un codeblock para que lo ejecute según la condición deseada ( para el VariosDestinatarios) 
// TODO: poner los comentarios también en las clases simples
#include 'fivewin.ch'

#DEFINE DIR_CLASES 'clases'
#DEFINE DIR_SIMPLE 'simple'
#DEFINE DIR_COMPLEX 'complex'  
#DEFINE PREFIJO_CLASES 'TVF_'
#DEFINE PREFIJO_TAGS 'sumI:'
#DEFINE SUFIJO_DATOS 'TYPE'
#DEFINE MASCARA_NUMERICOS '999999999.99'
#DEFINE ATTRIBUTES_MASTER_CLASS {   'xmlns:T' => 'urn:ticketbai:emision',;
                                    'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',;
                                    'xsi:schemaLocation' => 'http://www.w3.org/2001/XMLSchema ticketbai.xsd'}

memvar cMadreName
memvar nTab


Function ManuMain()

    Public cMadreName  := ''
    Public nTab := 0

    XSDToClass()

Return ( Nil )

Static Function XSDToClass()

    Local oXML as Object := Nil

    hb_DirRemoveAll( DIR_CLASES )
    hb_DirBuild( DIR_CLASES)
    hb_DirBuild( DIR_CLASES + '\' + DIR_SIMPLE )
    hb_DirBuild( DIR_CLASES + '\' + DIR_COMPLEX )

    oXML := CreateObject('Chilkat.Xml' )

    //If oXML:LoadXmlFile('C:\si\trabajo\fwh\Pruebas\chilkat_XSD\esquemas\ticketbai\alava\ticketbaiv1-2-2.xsd') == 0
    If oXML:LoadXmlFile('C:\Ficheros\SuministroInformacion.xsd') == 0

        MsgInfo('Error sabriendo fichero xsd')

    Endif

    ProcesaXml( oXML )
    CreaIncludes( )

Return ( Nil )

Static Function CreaIncludes()

    Local cInclude as String := ''

    TEXT INTO cInclude
#DEFINE REQUIRED .T.
#DEFINE OPTIONAL .F.
    ENDTEXT

    hb_MemoWrit( DIR_CLASES + '\' + cMadreName + '.inc', cInclude )

Return ( Nil )


Return ( Nil )

Static Function ProcesaXml( oXml )

    Local nC as Numeric := 0
    Local oChild as Object := Nil
    local oClase as Object := Nil
    

    // Creo una clase madre que ser� la que se pasar� por referencia al resto de clases. A veces est� definida en el xsd como un complex type pero a veces no, de momento la creo manualmente
    WITH OBJECT oClase := TClase():New()

        :lMadre := .T.
        :cName := 'Verifactu'
        :cClassName := PREFIJO_CLASES + :cName
        cMadreName := :cName

    END WITH

    If oXml:NumChildren > 0

        For nC = 0 to oXml:NumChildren - 1

            oChild = oXml:GetChild( nC )

            If oChild:Tag == 'complexType' // clase complex

                CreaComplex( oChild, oXml )

            Endif

        Next

    Endif

Return ( Nil )

Static Function CreaComplex( oChild, oXml )

    Local oClase as Object := Nil
    Local osequence as Object := Nil
    Local nsequence as Numeric := 0
    Local oData as Object := Nil
    Local oChoice as Object := Nil
    Local nChoice as Numeric := 0
    Local oChildsequence as Object := Nil

    WITH OBJECT oClase := TClase():New()

        :cName := oChild:GetAttrValue('name')
        :cClassName := PREFIJO_CLASES + :cName

    END WITH

    ClaseAnnotation( oChild, oClase )

    // Busco la secuencia de campos de la clase complex
    osequence := oChild:SearchForTag(oChild, 'sequence')

    If osequence != Nil

        nsequence := 0

        While nsequence < osequence:NumChildren

            oChildsequence := osequence:GetChild(nsequence)

            If oChildsequence:Tag == 'choice'

                oChoice := oChildsequence

                for nChoice := 0 to oChoice:NumChildren - 1

                    CreaData( oChoice:GetChild(nChoice), oXml, oClase )
                    aAdD(oClase:aChoices, oChoice:GetChild(nChoice):GetAttrValue('name'))

                Next

            Endif

            CreaData( oChildsequence, oXml, oClase )
            nsequence++

        Enddo

    Endif

    CreaClase( oClase )

Return (Nil )

Static Function CreaData( oChildSequence, oXml, oClase )

    Local oData as Object := Nil
    Local cTypeRaw as String := ''
    Local oChildSimple as Object := Nil
    Local oChildRestriction as Object := Nil
    Local lHasEnumeration   as Logical := .F.
    Local nRestriction as Numeric := 0
    Local oChild as Object := Nil
    Local oChildRestrictionItem as Object := Nil
    Local oRestrictionItem as Object := Nil
    Local oEnumerationItem as Object := Nil
    Local oClaseComplexAutodefinida as Object := Nil

    WITH OBJECT oData := TData():New()

        If oChildsequence:SearchForTag(oChildsequence, 'complexType') != Nil
            // Es un complex type que se autodefine en el elemento ya que solo se utiliza una vez y por este motivo no se crea un complextype a parte
            :cName    := oChildsequence:GetAttrValue('name')
            :cType    := oChildsequence:GetAttrValue('name')
            :lComplex := .T.

            CreaComplex( oChildsequence, oXml )

        Else

            :cName := oChildSequence:GetAttrValue('name')
            :cType := hb_StrReplace(oChildSequence:GetAttrValue('type'),;   // Limpio los prefijos, estos están definidos al principio en el xmlns:XX pero no sé exactamente que son, de momento los limpio manualmente
                                         {'sf:'=>'',;
                                          'T:'=>'',;
                                          '.'=>'_'})

            :lComplex := oXML:SearchForAttribute( oXml, 'complexType', 'name', :cType ) != Nil

        Endif

        cTypeRaw := hb_StrReplace(oChildSequence:GetAttrValue('type'),{'T:'=>'',;
                                                                       'sf:'=>''})
        :nminOccurs := Val( oChildSequence:GetAttrValue('minOccurs') )
        :nmaxOccurs := Max( Val( oChildSequence:GetAttrValue('maxOccurs') ), 1)
        :lRequired := oChildSequence:HasAttribute('minOccurs') == 0 .Or.;
                      :nminOccurs > 0
        
        :lSimple  := ( oChildSimple := oXML:SearchForAttribute( oXml, 'simpleType', 'name', cTypeRaw ) ) != Nil

        If :lSimple

            If ( oChildRestriction := oChildSimple:SearchForTag(oChildSimple, 'restriction') ) != Nil

                WITH OBJECT :oRestriction := TRestriction():New()

                    :cBase := oChildRestriction:GetAttrValue('base')
                    lHasEnumeration := .F.

                    For nRestriction := 0 to oChildRestriction:NumChildren - 1

                        oChildRestrictionItem := oChildRestriction:GetChild(nRestriction)

                        If oChildRestrictionItem:Tag =='enumeration'

                            lHasEnumeration := .T.

                            If oRestrictionItem == Nil

                                oRestrictionItem := TRestrictionItem():New()

                            Endif

                            WITH OBJECT oEnumerationItem := TEnumerationItem():New()

                                :cValue := oChildRestrictionItem:GetAttrValue('value')
                                :cDocumentation := oChildRestrictionItem:GetChildContent('annotation|documentation')

                            END

                            aAdD( oRestrictionItem:aEnumeration, oEnumerationItem)

                        Else

                            WITH OBJECT oRestrictionItem := TRestrictionItem():New()

                                :cOperator := oChildRestrictionItem:Tag
                                :cValue     := oChildRestrictionItem:GetAttrValue('value')

                            END 

                            aAdD( :aRestrictions, oRestrictionItem )

                        Endif
                                        
                    Next

                    If lHasEnumeration

                        aAdD( :aRestrictions, oRestrictionItem )

                    Endif

                    oRestrictionItem := Nil

                END

            Endif

        Else

            DatosStandard( cTypeRaw )

        Endif
                        
    END WITH

    If Len(Alltrim(oData:cName)) != 0

        aAdD( oClase:aDatas, oData  )

    Endif

Return ( Nil )

Static Function CreaClase( oClase )

    Local cClase as String := ''
    Local nC as Numeric := 0
    Local oData as Object := Nil
    Local cDatas as String := ''
    Local cDatasProtected as String := ''
    Local cInit as String := ''
    Local cCHeck as String := ''
    Local cCheckChoices as String := ''
    Local cMethodsArray as String := ''
    Local cMethods as String := ''
    Local cMethodsTmp as String := ''
    Local cCheckTmp as String := ''
    Local cBuildXml as String := ''
    Local cBuildXmlCondition as String := ''
    Local cXmlTmp as String := ''
    Local cHasData as String := ''
    Local cChoicesTmp as String := ''
    Local cChoices as String := ''
    Local cChoice as String := ''
    Local cTag as String := ''
    Local hAttribute as Hash := {}
    Local cComentario as String := ''

    If oClase == Nil

        Return ( Nil )

    Endif

    TEXT INTO cClase
{COMENTARIO}    
#include 'hbclass.ch'
{INCLUDES}
    
CREATE CLASS {CLASSNAME} {RETURNSTATE}
    
    EXPORTED:
        METHOD New( {DEPENDENCIA}, lRequired, cTag, oFather ) CONSTRUCTOR 
        METHOD BuildXml( oFather )
        METHOD Check()
        METHOD HasData()
{METHODS}
        DATA __cTag      AS STRING  INIT '{TAG}'
{DATAS}
        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:
        METHOD Init()   

        DATA __lRequired AS LOGICAL INIT .F.
{DATASPROTECTED}            

ENDCLASS
    
METHOD New( {DEPENDENCIA}, lRequired, cTag, oFather ) CLASS {CLASSNAME}

    hb_default( @lRequired, .F. )
    hb_default( @cTag, ::__cTag )
    

    {SETDEPENDENCIA}
    {SETTAG}
    ::oFather     := oFather
    ::__lRequired := lRequired
    ::Init()
    
Return ( Self )
    
METHOD Init() CLASS {CLASSNAME}

{INIT}
Return ( Self )
    
METHOD BuildXml( oFather ) CLASS {CLASSNAME}
    
{BUILDXML}
    
Return ( Self )

METHOD Check() CLASS {CLASSNAME}

{CHECKCHOICES}
{CHECK}
Return ( Self )

METHOD HasData() CLASS {CLASSNAME}

    Local lHasData as Logical := .F.

{HASDATA}
Return ( lHasData )

{METHODSARRAY}
    ENDTEXT

    If oClase:lMadre

        cDatas += '        DATA __oReturn AS OBJECT INIT Nil' + CRLF + CRLF
        cDatas += '        DATA __oXmlOut AS OBJECT INIT Nil' + CRLF 
        cInit += '    ::__oReturn := TReturn():New( .T. )' + CRLF + CRLF
        
    Else

        cDatasProtected += '        DATA __o'+cMadreName+' AS OBJECT INIT Nil' + CRLF + CRLF 

    Endif

    If oClase:lMadre

        cBuildXml += '    ::__oXmlOut :=  CreateObject("Chilkat_9_5_0.Xml" )' + CRLF
        cBuildXml += '    ::__oXmlOut:Tag := ::__cTag' + CRLF 

        for each hAttribute in ATTRIBUTES_MASTER_CLASS

            cBuildXml += '    ::__oXmlOut:AddAttribute( "' + hAttribute:__enumkey + '", "' + hAttribute:__enumvalue + '" )' + CRLF
            
        next

        cBuildXml += CRLF
        cBuildXml += '{BUILDXMLCONDITION}'
        cBuildXml += CRLF

        cMethods += '        METHOD GetXmlObject( )' + CRLF

    Else

        cBuildXml += '    Local oChild as Object := Nil' + CRLF 
        cBuildXml += '    Local cXml as String := ""' + CRLF + CRLF
        cBuildXml += '{BUILDXMLCONDITION}'
        cBuildXml += '        oChild := oFather:NewChild( "{PREFIJO_TAGS}" + ::__cTag,"")' + CRLF + CRLF

    Endif

    If Len( oClase:aChoices ) >0

        cCheckChoices := '    Local nChoices as Numeric := 0' + CRLF
        cCheckChoices += '    Local cChoicesActuales as String := ""' + CRLF + CRLF

        for each cChoice in oClase:aChoices

            cCheckChoices += '    nChoices += Iif( ::' + cChoice + ':HasData(), 1, 0 )' + CRLF
            cCheckChoices += '    cChoicesActuales += Iif( ::' + cChoice + ':HasData(), "' + cChoice + ',", "")' + CRLF + CRLF
            cCHoices += Iif ( cChoice:__enumindex > 1, ',','') + cChoice
            
        next

        cChoicesTmp := ''

        TEXT INTO cChoicesTmp
    If nChoices > 1

        ::__{DEPENDENCIA}:__oReturn:Success := .F.
        ::__{DEPENDENCIA}:__oReturn:Log := '{DATANAME} solo puede tener un dato de los siguientes elementos: {CHOICES}, ahora tiene ' + cChoicesActuales

    Endif
        ENDTEXT
        
        cChoicesTmp := hb_StrReplace( cChoicesTmp, { '{CHOICES}' => cChoices,;
                                                     '{DATANAME}'=>oClase:cName})
        cCheckChoices += cChoicesTmp

    Endif

    for each oData in oClase:aDatas

        If Len(oData:cName) > 0

            If oData:nminOccurs > 0

                cCheckTmp := ''
                
                TEXT INTO cCheckTmp
    Local o{DATANAME} as Object := Nil

    for each o{DATANAME} in ::a{DATANAME}
                
        o{DATANAME}:Check()
                    
    next
                ENDTEXT

                cCHeck += hb_StrReplace ( cCheckTmp, { '{DATANAME}' => oData:cName })

                cBuildXmlCondition += '    If Len( ::a' + oData:cName + ' ) > 0 ' + CRLF + CRLF

            Else

                cCheck += '    ::' + oData:cName + ':Check()' + CRLF

            Endif

            If oData:nmaxOccurs > 1

                cDatas += '        DATA a' + oData:cName + ' AS ARRAY INIT Array( 0 )' + CRLF
                cMethods += '        METHOD Set()'
                cDatasProtected += '        DATA __nMaxOccurs AS NUMERIC INIT ' + Str( oData:nmaxOccurs ) + CRLF

                cCheckTmp := ''
                TEXT INTO cCheckTmp
    If Len( ::a{DATANAME} ) > ::__nMaxOccurs

        ::__{DEPENDENCIA}:__oReturn:Success := .F.
        ::__{DEPENDENCIA}:__oReturn:Log := 'Se han incluido ' + Alltrim( Str( Len( ::a{DATANAME} ) ) ) + ' {DATANAME} y solo se permiten ' + Alltrim( Str( ::__nMaxOccurs ) )
        
            
    Endif                
                ENDTEXT

                cCHeck += hb_StrReplace ( cCheckTmp, { '{DATANAME}' => oData:cName })

            Else

                cDatas += '        DATA ' + oData:cName + ' AS OBJECT INIT Nil' + CRLF

            Endif
            

            If oClase:lMadre

                cInit += '    ::' + oData:cName + ' := ' + PREFIJO_CLASES + oData:cType + '():New( Self, {REQUIRED}, "' + oData:cName + '" )' + CRLF 

            Else

                If oData:nmaxOccurs > 1

                    cInit += '    ::a' + oData:cName + ' := Array( 0 )' + CRLF
                    cInit += '    ::__nMaxOccurs := ' + Str( oData:nmaxOccurs ) + CRLF

                Else

                    cInit += '    ::' + oData:cName + ' := ' + PREFIJO_CLASES + oData:cType + '():New( ::__{DEPENDENCIA}, {REQUIRED}, "' + oData:cName + '" )' + CRLF 

                Endif

            Endif

            If oData:nminOccurs > 0 .Or. oData:nmaxOccurs > 1

                cXmlTmp := ''

                TEXT INTO cXmlTmp
o{DATANAME} := Nil  // TODO: Definirlo bien como Local

    for each o{DATANAME} in ::a{DATANAME}
                            
        o{DATANAME}:BuildXml( oChild )
                                
    next
                ENDTEXT              

                cBuildXml += hb_StrReplace( cXmlTmp, { '{DATANAME}' => oData:cName })

            Else

                cBuildXmlCondition += Iif( cBuildXmlCondition == '', '    If ',' .Or.;' + CRLF + '       ' ) + '::' + oData:cName + ':HasData()'

                If oClase:lMadre

                    cBuildXml += '        ::' + oData:cName + ':BuildXml( ::__oXmlOut )' + CRLF
                    
                Else

                    cBuildXml += '        ::' + oData:cName + ':BuildXml( oChild )' + CRLF

                Endif

            Endif

            cInit := hb_StrReplace( cInit, { '{REQUIRED}' => Iif( oData:lRequired, 'REQUIRED', 'OPTIONAL') })

            If oData:nmaxOccurs > 1

                TEXT INTO cMethodsArray
METHOD Set( o{TYPE} ) CLASS {CLASSNAME}

    If o{TYPE} == Nil

        ::__{DEPENDENCIA}:__oReturn:Success := .F.
        ::__{DEPENDENCIA}:__oReturn:Log := 'No se ha pasado inigún dato'
        Return( Self )

    Endif

    If .Not. HB_ISOBJECT( o{TYPE} )

        ::__{DEPENDENCIA}:__oReturn:Success := .F.
        ::__{DEPENDENCIA}:__oReturn:Log := 'No se ha pasado un objeto'
        Return( Self )

    Endif

    If .Not. o{TYPE}:IsKindOf( "{PREFIJO_CLASES}{TYPE}" )

        ::__{DEPENDENCIA}:__oReturn:Success := .F.
        ::__{DEPENDENCIA}:__oReturn:Log := 'El objeto no es del tipo {PREFIJO_CLASES}{TYPE}'
        Return( Self )

    Endif

    aAdd( ::a{DATANAME}, o{TYPE} )

Return( Self )
                ENDTEXT

                cMethodsArray := hb_StrReplace( cMethodsArray, { '{DATANAME}' => oData:cName,;
                                                                 '{PREFIJO_CLASES}' => PREFIJO_CLASES,;
                                                                 '{CLASSNAME}' => oClase:cClassName,;
                                                                 '{TYPE}' => oData:cType })   

            Endif

            If oData:lSimple

                CreaClaseSimple( oData )

            Endif

        Endif

        If oData:nminOccurs > 0

            cHasData += '    lHasData := Iif( ' + 'Len( ::a' + oData:cName + ' ) > 0, .T., lHasData)' + CRLF
            //cBuildXmlCondition += '    Endif' + CRLF + CRLF

        Else

            cHasData += '    lHasData := Iif( ' + '::' + oData:cName + ':HasData(), .T., lHasData)' + CRLF

        Endif

    next

    If Len( Alltrim( cBuildXmlCondition ))  > 0

        cBuildXml += CRLF + '    Endif'
        cBuildXmlCondition += CRLF + CRLF

    Endif

    cBuildXml := hb_StrReplace( cBuildXml, { '{BUILDXMLCONDITION}'=>cBuildXmlCondition,;
                                             '{PREFIJO_TAGS}' => PREFIJO_TAGS })

    If Upper( Right( oClase:cName, Len( SUFIJO_DATOS ) ) ) == SUFIJO_DATOS

        cTag := Left( oClase:cName, Len( oClase:cName ) - Len( SUFIJO_DATOS ) )

    Endif

    If oClase:lMadre

        TEXT INTO cMethodsTmp

METHOD GetXmlObject( ) CLASS {CLASSNAME}
Return ( ::__oXmlOut )
        ENDTEXT

    Endif

    cClase += cMethodsTmp

    TEXT INTO cComentario
// Clase creada autmáticamente por xsdtohb.prg el ' + dToc(Date()) + ' ' + Time()    
/*{DESCRIPTION}*/
    ENDTEXT

    cComentario := hb_StrReplace( cComentario, { '{DESCRIPTION}' => oClase:cDescription })

    cClase := hb_StrReplace( cClase, {;
                                        '{COMENTARIO}'=>cComentario,;
                                        '{INCLUDES}'=>'#include "' + cMadreName + '.inc"',;
                                        '{NAME}'=>oClase:cName,;
                                        '{CLASSNAME}'=>oClase:cClassName,;
                                        '{DATAS}'=>cDatas,;
                                        '{TAG}'=>cTag,;
                                        '{DATASPROTECTED}'=>cDatasProtected,;
                                        '{INIT}'=>cInit,;
                                        '{CHECK}'=>cCheck,;
                                        '{BUILDXML}'=>cBuildXml,;
                                        '{METHODS}'=>cMethods,;
                                        '{HASDATA}'=>cHasData,;
                                        '{CHECKCHOICES}'=>cCheckChoices,;
                                        '{PREFIJO_CLASES}' => PREFIJO_CLASES,;
                                        '{METHODSARRAY}'=>cMethodsArray;
                                    })

    If oClase:lMadre

        cClase := hb_StrReplace( cClase , {;
                                            '{RETURNSTATE}'=>'FROM TReturnState',;
                                            '{DEPENDENCIA}:'=>'',;
                                            '{DEPENDENCIA},'=>'',;
                                            '{DEPENDENCIA}'=>'',;
                                            '{SETTAG}'=>'::__cTag := "' + cMadreName + '"',;
                                            '{SETDEPENDENCIA}'=>'';
                                        })

        
    Else

        cClase := hb_StrReplace( cClase , {;
                                            '{RETURNSTATE}'=>'',;
                                            '{DEPENDENCIA}'=>'o'+cMadreName,;
                                            '{SETTAG}'=>'::__cTag := cTag',;
                                            '{SETDEPENDENCIA}'=>'::__o'+cMadreName+' := o'+cMadreName;
                                        })

    Endif    

    cClase := hb_StrToUTF8( cClase )

    If oClase:lMadre

        hb_MemoWrit( DIR_CLASES + '\' + oClase:cClassName + '.prg', cClase )

    Else

        hb_MemoWrit( DIR_CLASES + '\' + DIR_COMPLEX + '\' + oClase:cClassName + '.prg', cClase )

    Endif

Return ( Nil )

Static Function CreaClaseSimple(oData)

    Local cClaseSimple as String := ''

    If .Not. hb_FileExists( DIR_CLASES + '\' + PREFIJO_CLASES + oData:cType + '.prg' )

        TEXT INTO cClaseSimple
// CLASS: T{SIMPLEDATATYPE} 
#include 'hbclass.ch'
{INCLUDES}
            
CREATE CLASS {PREFIJO_CLASES}{SIMPLEDATATYPE} 
            
    EXPORTED:
        METHOD New( {DEPENDENCIA}, lRequired, cTag, oFather ) CONSTRUCTOR
        METHOD Get()
        METHOD Set( uData ) 
        METHOD Check( uData )
        METHOD BuildXml( oFather )
        METHOD HasData()

        DATA __cTag AS STRING INIT ''
        DATA oFather     AS OBJECT  INIT Nil

    PROTECTED:

        DATA __{SIMPLEDATATYPE} {DATAINIT}
        DATA __{DEPENDENCIA} AS OBJECT INIT NIL
        DATA __lRequired AS LOGICAL INIT .F.
        DATA __lDataSet AS LOGICAL INIT .F.

        METHOD Convert( uData )
            
ENDCLASS
            
METHOD New( {DEPENDENCIA}, lRequired, cTag, oFather ) CLASS {PREFIJO_CLASES}{SIMPLEDATATYPE} 

    hb_default( @lRequired, .F. )
    hb_default( @cTag, '{SIMPLEDATATYPE}' )

    ::__{DEPENDENCIA} := {DEPENDENCIA}
    ::__lRequired := lRequired
    ::__cTag := cTag
    ::oFather := oFather        

Return ( Self )
            
METHOD Set( uData ) CLASS {PREFIJO_CLASES}{SIMPLEDATATYPE} 

    uData := ::Convert( uData )

    If ::Check( uData )
            
        ::__{SIMPLEDATATYPE} := uData
        ::__lDataSet := .T.

    Endif
            
Return ( Self )  

METHOD HasData() CLASS {PREFIJO_CLASES}{SIMPLEDATATYPE} 
Return( ::__lDataSet )


METHOD Convert( uData ) CLASS {PREFIJO_CLASES}{SIMPLEDATATYPE} 
    // TODO: Eliminar del switch los tipos de datos que no correspondan en esta clase

    switch ValType( uData )

        case 'N'
            
            If HB_ISNUMERIC( uData )
                
                uData := Alltrim( Transform( uData, '{MASCARANUMERICOS}') ) // TODO: Definir la máscara según los requisitos
        
            Endif

        exit

        case 'C'

            uData := Alltrim( uData )  // TODO: Revisar si hay que mantener espacios o no

        exit

        case 'D'

            IF HB_ISDATE( uData )

                uData := uData:StrFormat('0d-0m-aaaa') // TODO: Definir la m├íscara seg├║n los requisitos

            Endif

        exit

    endswitch

Return( uData )

METHOD Get() CLASS {PREFIJO_CLASES}{SIMPLEDATATYPE} 
Return ( ::__{SIMPLEDATATYPE} )

METHOD Check( uData ) CLASS {PREFIJO_CLASES}{SIMPLEDATATYPE} 

    hb_default( @uData, ::__{SIMPLEDATATYPE} )

{CLAUSULAGUARDAREQUIRED}
{CLAUSULAGUARDABASETYPE}
{CLAUSULAGUARDARESTRICTIONS}
{CLAUSULAGUARDAENUMERATION}
Return ( .T. )

METHOD BuildXml( oFather) CLASS {PREFIJO_CLASES}{SIMPLEDATATYPE} 
    
    If ::HasData()
    
        oFather:NewChild( '{PREFIJO_TAGS}' + ::__cTag, hb_ValToStr( ::__{SIMPLEDATATYPE} ) )

    Endif

Return  ( Self )
        ENDTEXT

        cClaseSimple := hb_StrReplace( cClaseSimple, {;
                                                        '{CLAUSULAGUARDAREQUIRED}'=>ClausulaGuardaRequired( oData ),;
                                                        '{CLAUSULAGUARDABASETYPE}'=>HbIsType( oData ),;
                                                        '{CLAUSULAGUARDARESTRICTIONS}'=>ClausulaGuardaRestrictions( oData ),;
                                                        '{CLAUSULAGUARDAENUMERATION}'=>ClausulaGuardaEnumeration( oData );
                                                    })

        cClaseSimple := hb_StrReplace( cClaseSimple, {;
                                                        '{PREFIJO_TAGS}' => PREFIJO_TAGS,;
                                                        '{INCLUDES}'=>'#include "' + cMadreName + '.inc"',;
                                                        '{PREFIJO_CLASES}'=>PREFIJO_CLASES,;
                                                        '{SIMPLEDATATYPE}'=>oData:cType,;
                                                        '{DATAINIT}'=>DataInit( oData ),;
                                                        '{DEPENDENCIA}'=>'o'+cMadreName,;
                                                        '{MASCARANUMERICOS}'=>MASCARA_NUMERICOS,;
                                                        '{CLAUSULAGUARDABASETYPE}'=>HbIsType( oData );
                                                    })

        cClaseSimple := hb_StrToUTF8( cClaseSimple )
        hb_MemoWrit( DIR_CLASES + '\' + DIR_SIMPLE + '\' + PREFIJO_CLASES + oData:cType + '.prg', cClaseSimple )

    Endif

Return ( Nil )


Static Function DataInit( oData )

    Local cDataInit as String := ''

    switch oData:oRestriction:cBase

        case 'string'

            cDataInit := 'AS STRING INIT ""'

        exit

        case 'integer'

            cDataInit := 'AS NUMERIC INIT 0'

        exit

    endswitch


Return ( cDataInit )

Static Function ClausulaGuardaRequired( oData )

    Local cRequired as String := ''

    If oData:lRequired

        TEXT INTO cRequired
    If ::__lRequired .And. Len(Alltrim(( uData ))) == 0
            
        ::__{DEPENDENCIA}:__oReturn:Success := .F.
        ::__{DEPENDENCIA}:__oReturn:Log := 'El dato {NAME} : ' + hb_ValToStr( uData ) + ' es requerido ' + ::__cTag 
        Return ( .F. )
    
    Endif
        ENDTEXT

        cRequired := hb_StrReplace( cRequired, { '{NAME}' => oData:cName })

    Endif

Return ( cRequired )

Static Function HbIsType( oData )

    Local cIsType as String := 'IsTypeNotDefined'

    switch oData:oRestriction:cBase
        case 'string'
            TEXT INTO cIsType
    If .Not. HB_ISSTRING( uData )

        ::__{DEPENDENCIA}:__oReturn:Success := .F.
        ::__{DEPENDENCIA}:__oReturn:Log := 'El dato {NAME} : ' + hb_ValToStr( uData ) + ' no es del tipo string para ' + ::__cTag
        Return ( .F. )
            
    Endif
            ENDTEXT
            cIsType := hb_StrReplace( cIsType, { '{NAME}' => oData:cName })
            
        exit

        case 'integer'
            TEXT INTO cIsType
    If .Not. HB_ISNUMERIC( uData )

        ::__{DEPENDENCIA}:__oReturn:Success := .F.
        ::__{DEPENDENCIA}:__oReturn:Log := 'El dato {NAME} : ' + hb_ValToStr( uData ) + ' no es del tipo integer para ' + ::__cTag
        Return ( .F. )

    Endif
            ENDTEXT
            cIsType := hb_StrReplace( cIsType, { '{NAME}' => oData:cName })

        exit

    endswitch

Return ( cIsType )

Static Function ClausulaGuardaEnumeration( oData )

    Local cGuardaEnumeration as String := ''
    Local cEnumeration as String := ''
    Local oRestrictionItem as Object := Nil
    Local oEnumerationItem as Object := Nil

    for each oRestrictionItem in oData:oRestriction:aRestrictions

        for each oEnumerationItem in oRestrictionItem:aEnumeration

            cEnumeration += Iif( oEnumerationItem:__enumindex > 1 , ',','') + "'" +  oEnumerationItem:cValue + "'"
                
        next
        
    next

    If Len( cEnumeration ) > 0

        // TODO: Poner despues de "permitidos de " el nombre del tipo de dato pero sin el type que ya lleva el {CLASSNAME} dentro
        TEXT INTO cGuardaEnumeration
    If hb_AScan( { {ENUMERATION} } , uData ) == 0

        ::__{DEPENDENCIA}:__oReturn:Success := .F.
        ::__{DEPENDENCIA}:__oReturn:Log := 'El dato ' + uData + ' no se encuentra en la lista de datos permitidos de para ' + ::__cTag
        Return ( .F. )

    Endif
        ENDTEXT

        cGuardaEnumeration := hb_StrReplace( cGuardaEnumeration, { '{ENUMERATION}' => cEnumeration })

    Endif

Return ( cGuardaEnumeration )


Static Function ClausulaGuardaRestrictions( oData )

    Local cGuardaRestriction as String := ''
    Local oRestrictionItem as Object := Nil
    Local cTmp as String := ''

    for each oRestrictionItem in oData:oRestriction:aRestrictions

        cGuardaRestriction += ClausulaLenght( oRestrictionItem, oData )
        cGuardaRestriction += ClausulaPattern( oRestrictionItem, oData )
        cGuardaRestriction += ClausulaminLength( oRestrictionItem, oData )
        cGuardaRestriction += ClausulamaxLength( oRestrictionItem, oData )

    Next

Return ( cGuardaRestriction)

Static Function ClausulaLenght( oRestrictionItem, oData )

    Local cClausula as String := ''

    If oRestrictionItem:cOperator == 'length'

        TEXT INTO cClausula
    If Len( uData ) > {LENGHT}
                    
        ::__{DEPENDENCIA}:__oReturn:Success := .F.
        ::__{DEPENDENCIA}:__oReturn:Log := 'El dato {NAME} : ' + hb_ValToStr( uData ) + ' excede los {LENGHT} caracteres para ' + ::__cTag
        Return ( .F. )
                
    Endif
        ENDTEXT

        cClausula := hb_StrReplace( cClausula, { '{LENGHT}' => oRestrictionItem:cValue,;
                                                 '{NAME}' => oData:cName })

    Endif

Return ( cClausula )

Static Function ClausulaPattern( oRestrictionItem, oData )

    Local cClausula as String := ''

    If oRestrictionItem:cOperator == 'pattern'

        TEXT INTO cClausula
    If .Not. hb_RegExLike( '{PATTERN}', uData,  ) 
                    
        ::__{DEPENDENCIA}:__oReturn:Success := .F.
        ::__{DEPENDENCIA}:__oReturn:Log := 'El dato {NAME} : ' + hb_ValToStr( uData ) + ' no cumple el patrón {PATTERN} para ' + ::__cTag
        Return ( .F. )
                
    Endif
        ENDTEXT

        cClausula := hb_StrReplace( cClausula, { '{PATTERN}' => oRestrictionItem:cValue,;
                                                 '{NAME}' => oData:cName})

    Endif

Return ( cClausula )

Static Function ClausulaminLength( oRestrictionItem, oData  )

    Local cClausula as String := ''

    If oRestrictionItem:cOperator == 'minLength'

        TEXT INTO cClausula
    If Len( uData ) < {MINLENGHT}
                    
        ::__{DEPENDENCIA}:__oReturn:Success := .F.
        ::__{DEPENDENCIA}:__oReturn:Log := 'El dato {NAME} : ' + hb_ValToStr( uData ) + ' no cumple la longitud mínima de {MINLENGHT} caracteres para ' + ::__cTag
        Return ( .F. )
                
    Endif
        ENDTEXT

        cClausula := hb_StrReplace( cClausula, { '{MINLENGHT}' => oRestrictionItem:cValue,;
                                                 '{NAME}' => oData:cName})

    Endif

Return ( cClausula )

Static Function ClausulamaxLength( oRestrictionItem, oData )

    Local cClausula as String := ''

    If oRestrictionItem:cOperator == 'maxLength'

        TEXT INTO cClausula
    If Len( uData ) > {MAXLENGHT}
                    
        ::__{DEPENDENCIA}:__oReturn:Success := .F.
        ::__{DEPENDENCIA}:__oReturn:Log := 'El dato {NAME} : ' + hb_ValToStr( uData ) + ' excede la longitud máxima de {MAXLENGHT} caracteres para ' + ::__cTag
        Return ( .F. )
                
    Endif
        ENDTEXT

        cClausula := hb_StrReplace( cClausula, { '{MAXLENGHT}' => oRestrictionItem:cValue,;
                                                 '{NAME}' => oData:cName })

    Endif

Return ( cClausula )

Static function ClaseAnnotation( oChild, oClase )

    Local oAnnotation as Object := Nil
    
    oAnnotation := oChild:SearchForTag(oChild, 'annotation')

    If oAnnotation != Nil

        oClase:cDescription := oAnnotation:GetChildContent('documentation')

    Endif

Return ( Nil )

Static Function DatosStandard( cTypeRaw )

    // Los XSD tienen definidos algunos datos standard simples que no se definen en el XSD, si los detecto los creo

    switch cTypeRaw
        case 'dateTime'
            CreaDateTimeClass()
            
        exit
    endswitch

Return ( Nil )

Static Function creadateTimeClass()

    Local cDateTimeClass as String := ''
    Local cFile as String := ''

    cFile := DIR_CLASES + '\' + DIR_SIMPLE + '\' + PREFIJO_CLASES + 'dateTime.prg'

    If File( cFile )

        Return ( Nil )

    Endif



    TEXT INTO cDateTimeClass
// CLASS: TVF_DateTime 
#include 'hbclass.ch'
#include "{cMadreName}.inc"
            
CREATE CLASS TVF_DateTime 
            
    EXPORTED:
        METHOD New( o{cMadreName}, lRequired, cTag, oFather ) CONSTRUCTOR
        METHOD Get()
        METHOD Set( uData ) 
        METHOD Check( uData )
        METHOD BuildXml( oFather )
        METHOD HasData()
            
        DATA __cTag AS STRING INIT ''
        DATA oFather AS OBJECT INIT NIL
        
    PROTECTED:
        DATA __dateTime AS STRING INIT ""
        DATA __o{cMadreName} AS OBJECT INIT NIL
        DATA __lRequired AS LOGICAL INIT .F.
        DATA __lDataSet AS LOGICAL INIT .F.
        

ENDCLASS
            
METHOD New( o{cMadreName}, lRequired, cTag, oFather ) CLASS TVF_DateTime 

    hb_default( @lRequired, .F. )
    hb_default( @cTag, 'dateTime' )

    ::__o{cMadreName} := o{cMadreName}
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

        ::__o{cMadreName}:__oReturn:Success := .F.
        ::__o{cMadreName}:__oReturn:Log := 'El dato no es del tipo DateTime UTC para ' + ::__cTag
        Return ( .F. )
            
    Endif

    If ::__lRequired .And. Empty( uData )
            
        ::__o{cMadreName}:__oReturn:Success := .F.
        ::__o{cMadreName}:__oReturn:Log := 'El dato DateTime UTC es requerido ' + ::__cTag 
        Return ( .F. )
    
    Endif

Return ( .T. )

METHOD BuildXml( oFather) CLASS TVF_DateTime 
    
    If ::HasData()
    
        oFather:NewChild( '{PREFIJO_TAGS}' + ::__cTag, hb_ValToStr( ::__dateTime ) )

    Endif

Return  ( Self )
    ENDTEXT

    cDateTimeClass := hb_StrReplace( cDateTimeClass, {;
                                                        '{PREFIJO_TAGS}' => PREFIJO_TAGS,;
                                                        '{cMadreName}'=>cMadreName;
                                                    })

    hb_MemoWrit( cFile , cDateTimeClass )
    
Return ( Nil )