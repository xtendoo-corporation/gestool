#include "fivewin.ch"
#include "factu.ch" 
#include "hdo.ch"

//---------------------------------------------------------------------------//

CLASS Seeders

   DATA oMsg

   DATA hConfig

   METHOD New()

   METHOD runSeederDatos()
   METHOD runSeederEmpresa()

   METHOD getInsertStatement( hCampos, cDataBaseName )

   METHOD SeederUsuarios()
   METHOD insertUsuarios( dbf )

   METHOD SeederSituaciones()
   METHOD getStatementSituaciones( dbfSitua )

   METHOD SeederTiposImpresoras()
   METHOD getStatementTiposImpresoras( dbfTipImp )

   METHOD SeederMovimientosAlmacen()
   METHOD getStatementSeederMovimientosAlmacen( dbfRemMov )

   METHOD SeederMovimientosAlmacenLineas()
   METHOD getStatementSeederMovimientosAlmacenLineas( dbfHisMov )

   METHOD SeederMovimientosAlmacenSeries()
   METHOD getStatementSeederMovimientosAlmacenLineasNumerosSeries( dbfMovSer )

   METHOD SeederSqlFiles()

   METHOD SeederLenguajes()
   METHOD insertLenguaje( dbf )

   METHOD SeederTransportistas()
   METHOD insertTransportista( dbfTransportista )

   METHOD SeederListin()
   METHOD insertListin()

   METHOD SeederEmpresas()
   METHOD insertEmpresas( dbf )

END CLASS

//---------------------------------------------------------------------------//

METHOD New( oMsg ) CLASS Seeders

   ::oMsg            := oMsg

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD runSeederDatos()

   ::oMsg:SetText( "Datos: Ejecutando seeder de usuarios" )
   //::SeederUsuarios()

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD runSeederEmpresa()

   ::oMsg:SetText( "Seeders finalizados" )

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD getInsertStatement( hCampos, cTableName )

   local cStatement  

   cStatement        := "INSERT IGNORE INTO " + cTableName + " ( "

   hEval( hCampos, {| k, v | cStatement += k + ", " } )

   cStatement        := chgAtEnd( cStatement, " ) VALUES ( ", 2 )

   hEval( hCampos, {| k, v | cStatement += v + ", " } )

   cStatement        := chgAtEnd( cStatement, " )", 2 )

RETURN cStatement

//---------------------------------------------------------------------------//
//--LO DEJO CON EL MÉTODO ANTIGUO PORQUE YA SE HA QUITADO EL CÓDIGO DEL TODO-//
//---------------------------------------------------------------------------//

METHOD SeederSituaciones() CLASS Seeders

   local cPath       := cPatDat( .t. )
   local dbfSitua

   if ( file( cPath + "Situa.Old" ) )
      RETURN ( self )
   end if

   if !( file( cPath + "Situa.Dbf" ) )
      msgStop( "El fichero " + cPath + "Situa.Dbf no se ha localizado", "Atención" )  
      RETURN ( self )
   end if 

   USE ( cPath + "SITUA.Dbf" ) NEW VIA ( 'DBFCDX' ) SHARED ALIAS ( cCheckArea( "SITUA", @dbfSitua ) )
   ( dbfSitua )->( ordsetfocus(0) )

   ( dbfSitua )->( dbgotop() )

   while !( dbfSitua )->( eof() )

      getSQLDatabase():Exec( ::getStatementSituaciones( dbfSitua ) )

      ( dbfSitua )->( dbSkip() )

   end while

   if dbfSitua != nil
      ( dbfSitua )->( dbCloseArea() )
   end if

   frename( cPath + "Situa.dbf", cPath + "Situa.old" )
   
RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD getStatementSituaciones( dbfSitua )
   
   local hCampos        := { "nombre" => quoted( ( dbfSitua )->cSitua ) }

RETURN ( ::getInsertStatement( hCampos, "situaciones" ) )

//---------------------------------------------------------------------------//
//--LO DEJO CON EL MÉTODO ANTIGUO PORQUE YA SE HA QUITADO EL CÓDIGO DEL TODO-//
//---------------------------------------------------------------------------//

METHOD SeederTiposImpresoras() CLASS Seeders

   local cPath       := cPatDat( .t. )
   local dbfTipImp

   if ( file( cPath + "TipImp.old" ) )
      RETURN ( self )
   end if

   if !( file( cPath + "TipImp.Dbf" ) )
      msgStop( "El fichero " + cPath + "TipImp.Dbf no se ha localizado", "Atención" )  
      RETURN ( self )
   end if 

   USE ( cPath + "TipImp.Dbf" ) NEW VIA ( 'DBFCDX' ) SHARED ALIAS ( cCheckArea( "TipImp", @dbfTipImp ) )
   ( dbfTipImp )->( ordsetfocus(0) )
   
   ( dbfTipImp )->( dbgotop() )
   while !( dbfTipImp )->( eof() )

      getSQLDatabase():Exec( ::getStatementTiposImpresoras( dbfTipImp ) )

      ( dbfTipImp )->( dbSkip() )

   end while

   if dbfTipImp != nil
      ( dbfTipImp )->( dbCloseArea() )
   end if

   frename( cPath + "TipImp.dbf", cPath + "TipImp.old" )
   
RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD getStatementTiposImpresoras( dbfTipImp )

   local hCampos        := { "nombre" => quoted( ( dbfTipImp )->cTipImp ) }

RETURN ( ::getInsertStatement( hCampos, "tipos_impresoras" ) )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

METHOD SeederUsuarios()

   local dbf
   local cPath    := ( fullCurDir() + cPatDat() + "\" )

   if !( file( cPath + "Users.Dbf" ) )
      msgStop( "El fichero " + cPath + "\Users.Dbf no se ha localizado", "Atención" )  
      RETURN ( self )
   end if

   USE ( cPath + "Users.Dbf" ) NEW VIA ( 'DBFCDX' ) SHARED ALIAS ( cCheckArea( "Users", @dbf ) )
   ( dbf )->( ordsetfocus( 0 ) )

   ( dbf )->( dbeval( {|| ::insertUsuarios( dbf ) } ) )

   ( dbf )->( dbCloseArea() )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD insertUsuarios( dbf )

   local hBuffer

   hBuffer        := SQLUsuariosModel():loadBlankBuffer()

   hset( hBuffer, "uuid",              ( dbf )->Uuid     )
   hset( hBuffer, "codigo",            ( dbf )->cCodUse  )
   hset( hBuffer, "nombre",            ( dbf )->cNbrUse  )
   hset( hBuffer, "password",          SQLUsuariosModel():Crypt( ( dbf )->cClvUse )  )

   SQLUsuariosModel():insertIgnoreBuffer( hBuffer )

RETURN ( self )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

METHOD SeederListin()

   local dbf
   local cPath    := ( fullCurDir() + cPatDat() + "\" )

   if !( file( cPath + "Agenda.Dbf" ) )
      msgStop( "El fichero " + cPath + "\Agenda.Dbf no se ha localizado", "Atención" )  
      RETURN ( self )
   end if

   USE ( cPath + "Agenda.Dbf" ) NEW VIA ( 'DBFCDX' ) SHARED ALIAS ( cCheckArea( "Agenda", @dbf ) )
   ( dbf )->( ordsetfocus( 0 ) )

   ( dbf )->( dbeval( {|| ::insertListin( dbf ) } ) )

   ( dbf )->( dbCloseArea() )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD insertListin( dbf )

   local hBuffer
   local nId

   hBuffer        := SQLListinModel():loadBlankBuffer()

   hset( hBuffer, "uuid",              ( dbf )->Uuid     )
   hset( hBuffer, "nombre",            ( dbf )->cApellidos  )
   hset( hBuffer, "dni",               ( dbf )->cNif  )

   nId            := SQLListinModel():insertIgnoreBuffer( hBuffer )

   if empty( nId )
      RETURN ( self )
   end if 

   // Direcciones--------------------------------------------------------------

   hBuffer        := SQLDireccionesModel():loadBlankBuffer()

   hset( hBuffer, "parent_uuid",    ( dbf )->Uuid         )
   hset( hBuffer, "nombre",         ( dbf )->cApellidos   )
   hset( hBuffer, "direccion",      ( dbf )->cDomicilio   )
   hset( hBuffer, "poblacion",      ( dbf )->cPoblacion   )
   hset( hBuffer, "provincia",      ( dbf )->cProvincia   )
   hset( hBuffer, "codigo_postal",  ( dbf )->cCodpostal   )
   hset( hBuffer, "telefono",       ( dbf )->cTel         )
                        
   nId            := SQLDireccionesModel():insertIgnoreBuffer( hBuffer )

RETURN ( self )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

METHOD SeederLenguajes()

   local dbf
   local cPath    := ( fullCurDir() + cPatDat() + "\" )

   if !( file( cPath + "LENGUAJE.Dbf" ) )
      msgStop( "El fichero " + cPath + "\LENGUAJE.Dbf no se ha localizado", "Atención" )  
      RETURN ( self )
   end if

   USE ( cPath + "LENGUAJE.Dbf" ) NEW VIA ( 'DBFCDX' ) SHARED ALIAS ( cCheckArea( "LENGUAJE", @dbf ) )
   ( dbf )->( ordsetfocus( 0 ) )

   ( dbf )->( dbeval( {|| ::insertLenguaje( dbf ) } ) )

   ( dbf )->( dbCloseArea() )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD insertLenguaje( dbf )

   local hBuffer

   hBuffer        := SQLLenguajesModel():loadBlankBuffer()

   hset( hBuffer, "uuid",              ( dbf )->Uuid     )
   hset( hBuffer, "codigo",            ( dbf )->cCodLen  )
   hset( hBuffer, "nombre",            ( dbf )->cNomLen  )

   SQLLenguajesModel():insertIgnoreBuffer( hBuffer )

RETURN ( self )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

METHOD SeederSqlFiles()

   local cStm
   local aFile
   local cPath          := cPatConfig() + "sql\"
   local aDirectory     := directory( cPath + "*.sql" )

   if len( aDirectory ) == 0
      RETURN ( Self )
   end if

   for each aFile in aDirectory

      ::oMsg:SetText( "Procesando fichero " + cPath + aFile[1] )

      cStm              := memoread( cPath + aFile[1] )

      if !empty( cStm )
         getSQLDatabase():Exec( cStm )
      end if

   next

RETURN ( Self )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

METHOD SeederTransportistas()

   local dbf
   local cPath    := ( fullCurDir() + cPatEmp() + "\" )

   SynTransportista()

   if !( file( cPath + "Transpor.Dbf" ) )
      msgStop( "El fichero " + cPath + "\Transpor.Dbf no se ha localizado", "Atención" )  
      RETURN ( self )
   end if 

   USE ( cPath + "Transpor.Dbf" ) NEW VIA ( 'DBFCDX' ) SHARED ALIAS ( cCheckArea( "Transpor", @dbf ) )
   ( dbf )->( ordsetfocus( 0 ) )

   ( dbf )->( dbeval( {|| ::insertTransportista( dbf ) } ) )

   ( dbf )->( dbCloseArea() )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD insertTransportista( dbf )

   local nId
   local hBuffer

   hBuffer        := SQLTransportistasModel():loadBlankBuffer()

   hset( hBuffer, "uuid",              ( dbf )->Uuid     )
   hset( hBuffer, "codigo",            ( dbf )->cCodTrn  )
   hset( hBuffer, "nombre",            ( dbf )->cNomTrn  )
   hset( hBuffer, "dni",               ( dbf )->cDniTrn  )
   hset( hBuffer, "empresa_codigo",    cCodEmp()     )
   hset( hBuffer, "tara",              ( dbf )->nKgsTrn  )
   hset( hBuffer, "matricula",         ( dbf )->cMatTrn  )

   nId            := SQLTransportistasModel():insertIgnoreBuffer( hBuffer )

   if empty( nId )
      RETURN ( self )
   end if

   hBuffer        := SQLDireccionesModel():loadBlankBuffer()

   hset( hBuffer, "principal",      0                    )
   hset( hBuffer, "parent_uuid",    ( dbf )->Uuid        )
   hset( hBuffer, "nombre",         ( dbf )->cNomTrn     )
   hset( hBuffer, "direccion",      ( dbf )->cDirTrn     )
   hset( hBuffer, "poblacion",      ( dbf )->cLocTrn     )
   hset( hBuffer, "provincia",      ( dbf )->cPrvTrn     )
   hset( hBuffer, "codigo_postal",  ( dbf )->cCdpTrn     )
   hset( hBuffer, "telefono",       ( dbf )->cTlfTrn     )
   hset( hBuffer, "movil",          ( dbf )->cMovTrn     )
                        
   nId            := SQLDireccionesModel():insertIgnoreBuffer( hBuffer )

RETURN ( self )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

METHOD SeederMovimientosAlmacen()

   local dbf
   local cLastRec

   if ( file( cPatEmp( , .t. ) + "RemMovT.old" ) )
      RETURN ( self )
   end if

   if !( file( cPatEmp( , .t. ) + "RemMovT.Dbf" ) )
      msgStop( "El fichero " + cPatEmp( , .t. ) + "\RemMovT.Dbf no se ha localizado", "Atención" )  
      RETURN ( self )
   end if 

   USE ( cPatEmp( , .t. ) + "RemMovT.Dbf" ) NEW VIA ( 'DBFCDX' ) SHARED ALIAS ( cCheckArea( "RemMovT", @dbf ) )
   
   ( dbf )->( ordsetfocus( 0 ) )

   cLastRec       := alltrim( str( ( dbf )->( lastrec() ) ) )

   ( dbf )->( dbgotop() )

   while !( dbf )->( eof() )

      ::oMsg:SetText( "Seeder de movimientos de almacén " + alltrim( str( ( dbf )->( recno() ) ) ) + " de " + cLastRec )
      
      getSQLDatabase():Exec( ::getStatementSeederMovimientosAlmacen( dbf ) )

      ( dbf )->( dbSkip() )

      sysrefresh()

   end while

   if dbf != nil
      ( dbf )->( dbCloseArea() )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD SeederMovimientosAlmacenLineas()

   local dbf
   local cLastRec

   if ( file( cPatEmp( , .t. ) + "HisMov.old" ) )
      RETURN ( self )
   end if

   if !( file( cPatEmp( , .t. ) + "HisMov.Dbf" ) )
      msgStop( "El fichero " + cPatEmp( , .t. ) + "\HisMov.Dbf no se ha localizado", "Atención" )  
      RETURN ( self )
   end if 

   USE ( cPatEmp( , .t. ) + "HisMov.Dbf" ) NEW VIA ( 'DBFCDX' ) SHARED ALIAS ( cCheckArea( "HisMov", @dbf ) )
   
   ( dbf )->( ordsetfocus(0) )

   cLastRec       := alltrim( str( ( dbf )->( lastrec() ) ) )

   ( dbf )->( dbgotop() )

   while !( dbf )->( eof() )
      
      ::oMsg:SetText( "Seeder de líneas de movimientos de almacén " + alltrim( str( ( dbf )->( recno() ) ) ) + " de " + cLastRec )

      getSQLDatabase():Exec( ::getStatementSeederMovimientosAlmacenLineas( dbf ) )

      ( dbf )->( dbSkip() )

      sysrefresh()

   end while

   if dbf != nil
      ( dbf )->( dbCloseArea() )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD getStatementSeederMovimientosAlmacen( dbfRemMov )

   local hCampos  := {  "empresa" =>            quoted( cCodEmp() ),;
                        "uuid" =>               quoted( ( dbfRemMov )->cGuid ),;
                        "numero" =>             quoted( rjust( ( dbfRemMov )->nNumRem, "0", 6 ) ),;
                        "tipo_movimiento" =>    quoted( ( dbfRemMov )->nTipMov ),;
                        "fecha_hora" =>         quoted( DateTimeFormatTimestamp( ( dbfRemMov )->dFecRem, ( dbfRemMov )->cTimRem ) ),;
                        "almacen_origen" =>     quoted( ( dbfRemMov )->cAlmOrg ),;
                        "almacen_destino" =>    quoted( ( dbfRemMov )->cAlmDes ),;
                        "divisa" =>             quoted( ( dbfRemMov )->cCodDiv ),;
                        "divisa_cambio" =>      quoted( ( dbfRemMov )->nVdvDiv ),;
                        "comentarios" =>        quoted( ( dbfRemMov )->cComMov ),;
                        "empresa_codigo" =>     quoted( cCodEmp() ) }

RETURN ( ::getInsertStatement( hCampos, "movimientos_almacen" ) )

//---------------------------------------------------------------------------//

METHOD getStatementSeederMovimientosAlmacenLineas( dbfHisMov )

   local hCampos  

   hCampos        := {  "uuid"                     => quoted( ( dbfHisMov )->cGuid ),;
                        "parent_uuid"              => quoted( ( dbfHisMov )->cGuidPar ),;
                        "codigo_articulo"          => quoted( ( dbfHisMov )->cRefMov ),;
                        "nombre_articulo"          => quoted( ( dbfHisMov )->cNomMov ),;
                        "codigo_primera_propiedad" => quoted( ( dbfHisMov )->cCodPr1 ),;
                        "valor_primera_propiedad"  => quoted( ( dbfHisMov )->cValPr1 ),;
                        "codigo_segunda_propiedad" => quoted( ( dbfHisMov )->cCodPr2 ),;
                        "valor_segunda_propiedad"  => quoted( ( dbfHisMov )->cValPr2 ),;
                        "lote"                     => quoted( ( dbfHisMov )->cLote ),;
                        "bultos_articulo"          => quoted( str( ( dbfHisMov )->nBultos ) ),;
                        "cajas_articulo"           => quoted( str( ( dbfHisMov )->nCajMov ) ),;
                        "unidades_articulo"        => quoted( str( ( dbfHisMov )->nUndMov ) ),;
                        "precio_articulo"          => quoted( str( ( dbfHisMov )->nPreDiv ) ) }

RETURN ( ::getInsertStatement( hCampos, "movimientos_almacen_lineas" ) )

//---------------------------------------------------------------------------//

METHOD SeederMovimientosAlmacenSeries()

   local dbf
   local cLastRec

   if ( file( cPatEmp( , .t. ) + "MovSer.Old" ) )
      RETURN ( self )
   end if

   if !( file( cPatEmp( , .t. ) + "MovSer.Dbf" ) )
      msgStop( "El fichero " + cPatEmp( , .t. ) + "\MovSer.Dbf no se ha localizado", "Atención" )  
      RETURN ( self )
   end if 

   USE ( cPatEmp( , .t. ) + "MovSer.Dbf" ) NEW VIA ( 'DBFCDX' ) SHARED ALIAS ( cCheckArea( "MovSer", @dbf ) )
   
   ( dbf )->( ordsetfocus(0) )
   
   cLastRec       := alltrim( str( ( dbf )->( lastrec() ) ) )

   ( dbf )->( dbgotop() )

   while !( dbf )->( eof() )
      
      ::oMsg:SetText( "Seeder de líneas de movimientos de almacén " + alltrim( str( ( dbf )->( recno() ) ) ) + " de " + cLastRec )

      getSQLDatabase():Exec( ::getStatementSeederMovimientosAlmacenLineasNumerosSeries( dbf ) )

      ( dbf )->( dbSkip() )

      sysrefresh()

   end while

   if dbf != nil
      ( dbf )->( dbCloseArea() )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD getStatementSeederMovimientosAlmacenLineasNumerosSeries( dbfMovSer )

   local hCampos        

   hCampos        := {  "uuid"            => quoted( ( dbfMovSer )->cGuid ),;
                        "parent_uuid"     => quoted( ( dbfMovSer )->cGuidPar ),;
                        "numero_serie"    => quoted( ( dbfMovSer )->cNumSer ) }

RETURN ( ::getInsertStatement( hCampos, SQLMovimientosAlmacenLineasNumerosSeriesModel():getTableName() ) )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

METHOD SeederEmpresas() CLASS Seeders

   local dbf
   local cPath    := ( fullCurDir() + cPatDat() + "\" )

   if !( file( cPath + "Empresa.Dbf" ) )
      msgStop( "El fichero " + cPath + "\Empresa.Dbf no se ha localizado", "Atención" )  
      RETURN ( self )
   end if 

   USE ( cPath + "Empresa.Dbf" ) NEW VIA ( 'DBFCDX' ) SHARED ALIAS ( cCheckArea( "Empresa", @dbf ) )
   ( dbf )->( ordsetfocus( 0 ) )

   ( dbf )->( dbeval( {|| ::insertEmpresas( dbf ) } ) )

   ( dbf )->( dbCloseArea() )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD insertEmpresas( dbf ) CLASS Seeders

   local nId
   local cSql
   local hBuffer  

   hBuffer        := SQLEmpresasModel():loadBlankBuffer()

   hset( hBuffer, "uuid",              ( dbf )->Uuid      )
   hset( hBuffer, "codigo",            ( dbf )->CodEmp    )
   hset( hBuffer, "nombre",            ( dbf )->cNombre   )
   hset( hBuffer, "nif",               ( dbf )->cNif      )
   hset( hBuffer, "administrador",     ( dbf )->cAdminis  )
   hset( hBuffer, "pagina_web",        ( dbf )->web       )

   nId            := SQLEmpresasModel():insertIgnoreBuffer( hBuffer )

   if empty( nId )
      RETURN ( self )
   end if 

   // Direcciones--------------------------------------------------------------

   hBuffer        := SQLDireccionesModel():loadBlankBuffer()

   hset( hBuffer, "principal",      1                     )
   hset( hBuffer, "parent_uuid",    ( dbf )->Uuid         )
   hset( hBuffer, "direccion",      ( dbf )->cDomicilio   )
   hset( hBuffer, "poblacion",      ( dbf )->cPoblacion   )
   hset( hBuffer, "provincia",      ( dbf )->cProvincia   )
   hset( hBuffer, "codigo_postal",  ( dbf )->cCodPos      )
   hset( hBuffer, "telefono",       ( dbf )->cTlf         )
   hset( hBuffer, "email",          ( dbf )->email        )
                        
   nId            := SQLDireccionesModel():insertIgnoreBuffer( hBuffer )

RETURN ( self )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//