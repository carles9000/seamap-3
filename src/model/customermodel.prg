
//----------------------------------------------------------------------------//

CLASS CustomerModel

	DATA oWdo

   METHOD New()             CONSTRUCTOR
   METHOD Count()          
   METHOD Add()          
   METHOD Delete( nId )          
   METHOD Edit( nId )          
   METHOD Save( nId, hData )          
   
   METHOD ErrorValidate( nId, hData, aMsgError )          
        
   METHOD Browse()          


ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS CustomerModel

	LOCAL hCfg 	:= Config_ADO()
	
	::oWdo := WDO():ADO( hCfg, .T. )

return Self

//----------------------------------------------------------------------------//

METHOD Count() CLASS CustomerModel

	LOCAL oRs := ::oWdo:Query( 'SELECT * FROM CUSTOMER' ) 
		
RETU oRs:Count()


//----------------------------------------------------------------------------//

METHOD Add() CLASS CustomerModel

	LOCAL oRs 		:= ::oWdo:Query( 'SELECT * FROM CUSTOMER' ) 
	LOCAL nRecno 

	oRs:Append() 

	oRs:FieldPut( oRs:FieldPos( 'first' ), 'Aa Mercury' )
	oRs:FieldPut( oRs:FieldPos( 'last' ), 'Creado => ' + time() )	

	oRs:Save()


RETU oRs:Recno()

//----------------------------------------------------------------------------//

METHOD Edit( nId ) CLASS CustomerModel

	LOCAL oRs 		:= ::oWdo:Query( 'SELECT * FROM CUSTOMER WHERE ID = ' + nId ) 
	LOCAL hData 	:= {=>}
	
	//hData[ "fields" ] 	:= oRs:GetFields()
	hData[ "values" ] 	:= oRs:Row()
	hData[ "struct" ] 	:= oRs:aStruct
	hData[ "id"] := nId	

RETU hData

//----------------------------------------------------------------------------//

METHOD Delete( nId ) CLASS CustomerModel

	::oWdo:Query( 'DELETE FROM CUSTOMER WHERE ID = ' + nId  ) 	

RETU NIL 

//----------------------------------------------------------------------------//

METHOD Save( nId, hData, hError ) CLASS CustomerModel

	LOCAL oRs 		:= ::oWdo:Query( 'SELECT * FROM CUSTOMER WHERE ID = ' + nId ) 
	LOCAL lSave 	:= oRs:Save( hData )
	
	
	IF !lSave	
		hError[ 'values' ] := hData
		hError[ 'struct' ] := oRs:aStruct
		hError[ 'error' ] 	:= oRs:cError
		hError[ 'id' ] 	:= nId
	ENDIF

RETU lSave

//----------------------------------------------------------------------------//

//	Si tenemos un error en el Validator crearemos la estructura que debemos
//	devolver a la vista de edicion: [ values, struct, error, id ]


METHOD ErrorValidate( nId, hData, cError ) CLASS CustomerModel

	LOCAL oRs 		:= ::oWdo:Query( 'SELECT * FROM CUSTOMER WHERE ID = ' + nId ) 	
	LOCAL nI
	LOCAL hError 	:= {=>}

	hError[ 'values' ] := hData
	hError[ 'struct' ] := oRs:aStruct
	hError[ 'error' ] 	:= cError
	hError[ 'id' ] 	:= nId

RETU hError

//----------------------------------------------------------------------------//

METHOD Browse( nPage, nRows ) CLASS CustomerModel

	local oRs
	local aHeaders	:= {}		
	local hData 	:= {=>} 
	local cSql 
	LOCAL nStart
	
	DEFAULT nPage  TO 0
	DEFAULT nRows  TO 10
	
	nStart := nPage * nRows 
	
	cSql 	:= 'SELECT *, ROW_NUMBER() OVER (ORDER BY FIRST) AS RowNum FROM CUSTOMER ORDER BY FIRST OFFSET ' + ltrim(str(nStart)) + ' ROWS FETCH NEXT ' + ltrim(str(nRows)) + ' ROWS ONLY'			

	oRs 	:= ::oWdo:Query( cSql )
	
	for n = 1 to oRs:FCount()
		AAdd( aHeaders, oRs:FieldName( n ) )
	next
	
	hData[ "headers" ] 	:= aHeaders
	hData[ "rows" ] 	:= oRs:FetchAll( .f. )

return hData 

//----------------------------------------------------------------------------//
{% memoread( HB_GETENV( 'PRGPATH' ) + "/config/cfg_ado.prg" ) %}