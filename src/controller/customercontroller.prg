#define DEFAULT_ROWS 		10
#define adAffectCurrent 	1
#define adResyncAllValues		2 	// default
//----------------------------------------------------------------------------//

CLASS CustomerController

    METHOD New( oController )

    METHOD Default( oController )
	
    METHOD Add( oController )
    METHOD Edit( oController )
    METHOD Save( oController )
    METHOD Del( oController )
	
    METHOD Info( oController )	
	
    METHOD First( oController )
    METHOD Last( oController )
    METHOD Next( oController )
    METHOD Prev( oController )


ENDCLASS    

//----------------------------------------------------------------------------//

METHOD New( oController ) CLASS CustomerController

    local cAction

	oController:Middleware( 'jwt', 'autenticate'  )		//	View/Route
	
	cAction := lower( oController:oRequest:Post( 'action' ) )	

    do case
	
		case cAction == "add"
			::Add( oController )
			
		case cAction == "edit"
			::Edit( oController )	

		case cAction == 'save'
			::Save( oController )	

		case cAction == 'del'
			::Del( oController )					
			
		case cAction == 'cancel'
			::Default( oController )
			
		case cAction == 'info'
			::Info( oController )			
			
		//	Browse...
		  
		case cAction == "first"
			::First( oController )	
			
		case cAction == "last"
			::Last( oController )				
			
		case cAction == "next"
			::Next( oController )
			
		case cAction == "prev"
			::Prev( oController )			
		  
		otherwise
		  ::Default( oController ) 
		  
    endcase

return Self    

//----------------------------------------------------------------------------//

METHOD Default( oController ) CLASS CustomerController

   local oModelCustomer	:= CustomerModel():New()
   local hData 			:= oModelCustomer:Browse()
   
   oController:View( "customer/customer.view", hData )

return nil 

//----------------------------------------------------------------------------//

METHOD Add( oController ) CLASS CustomerController

    local oModelCustomer 	:= CustomerModel():New()
    local nId 				:= oModelCustomer:Add()
		
	::Default( oController )

return nil  
//----------------------------------------------------------------------------//

METHOD Del( oController ) CLASS CustomerController

    local oModelCustomer 	:= CustomerModel():New()
	local nId				:= oController:oRequest:Post( 'id' )
	
	oModelCustomer:Delete( nId )
	
	::Default( oController )	

return nil   

//----------------------------------------------------------------------------//

METHOD Edit( oController ) CLASS CustomerController

    local oModelCustomer 	:= CustomerModel():New()
	local nId 				:= oController:oRequest:Post( 'id' )
    local hData 			:= oModelCustomer:Edit( nId )	

    oController:View( "customer/customer_edit.view", hData )	

return nil    


//----------------------------------------------------------------------------//

METHOD Save( oController ) CLASS CustomerController

    local oModelCustomer 	:= CustomerModel():New()
	local nId 				:= oController:oRequest:Post( 'ID' )
	local oValidator 		:= TValidator():New()		
	local hRoles 			:= { 'STATE' => 'len:2', 'AGE' => 'max:120' }
	local hData 			:= {=>}
	local cError 			:= ''
	local hError 			:= {=>}
	local lSave			:= .F.

	//	Recupero Datos...
	
		hData[ 'ID' ]		:= nId	
		hData[ 'FIRST' ]	:= oController:oRequest:Post( 'FIRST' )		//	1
		hData[ 'LAST' ] 	:= oController:oRequest:Post( 'LAST'  )
		hData[ 'STREET' ] 	:= oController:oRequest:Post( 'STREET' )
		hData[ 'CITY' ] 	:= oController:oRequest:Post( 'CITY'  )
		hData[ 'STATE' ] 	:= oController:oRequest:Post( 'STATE' )								
		hData[ 'ZIP' ] 		:= oController:oRequest:Post( 'ZIP' )								
		hData[ 'HIREDATE' ]	:= oController:oRequest:Post( 'HIREDATE' )	//	7								
		hData[ 'MARRIED' ] 	:= oController:oRequest:Post( 'MARRIED' )								
		hData[ 'AGE' ] 		:= oController:oRequest:Post( 'AGE' )								
		hData[ 'SALARY' ] 	:= oController:oRequest:Post( 'SALARY' )								
		hData[ 'NOTES' ] 	:= oController:oRequest:Post( 'NOTES' )
		
	//	Validamos datos de la edicion. Importantisimo !!!
	
		IF ! oValidator:Run( hRoles )
		
			hError := oModelCustomer:ErrorValidate( nId, hData, oValidator:ErrorString() )
			
			oController:View( "customer/customer_edit.view", hError )				
			RETU NIL
		ENDIF						
	
	//	Salvamos datos...

		lSave := oModelCustomer:Save( nId, hData, @hError ) 
		
		
	//	Generamos salida...
	
		IF ! lSave
			oController:View( "customer/customer_edit.view", hError )	
		ELSE
			::Default( oController )
		ENDIF


return nil 

//----------------------------------------------------------------------------//

METHOD Info( oController ) CLASS CustomerController

    local oModelCustomer 	:= CustomerModel():New()	
	local aInfo := {=>}

	aInfo[ 'name'] := oModelCustomer:oWdo:oCn:Properties( "DBMS Name" ):Value 
	aInfo[ 'provider'] := oModelCustomer:oWdo:oCn:Provider
 
	oController:oResponse:SendJson( aInfo )		

return nil

//----------------------------------------------------------------------------//

METHOD First( oController ) CLASS CustomerController

   local oModelCustomer	:= CustomerModel():New()
   local nRows 			:= oController:oRequest:Post( 'rows' , DEFAULT_ROWS, 'N' )
   local hData, hBrowse
   
   hData 			:= oModelCustomer:Browse( 0, nRows )
   hBrowse			:= { 'page' => 0, 'rows' => nRows }
   
   oController:View( "customer/customer.view", hData, hBrowse )

return nil    

//----------------------------------------------------------------------------//

METHOD Last( oController ) CLASS CustomerController

	local oModelCustomer	:= CustomerModel():New()
	local nRows 			:= oController:oRequest:Post( 'rows' , DEFAULT_ROWS, 'N' )
	local nTotal			:= oModelCustomer:Count()
	local hData, hBrowse, nPage 			
   
	IF nRows <= 0
		nRows := DEFAULT_ROWS 
	ENDIF

    nPage 			:= Int( nTotal / nRows ) 	
	
	IF ( nPage * nRows ) + 1 > nTotal
		nPage--
	ENDIF	
   
	hData 			:= oModelCustomer:Browse( nPage, nRows )
	hBrowse			:= { 'page' => nPage, 'rows' => nRows }

	oController:View( "customer/customer.view", hData, hBrowse )

return nil   

//----------------------------------------------------------------------------//

METHOD Next( oController ) CLASS CustomerController

	local oModelCustomer	:= CustomerModel():New()
	local nTotal			:= oModelCustomer:Count()   
	local nPage 			:= oController:oRequest:Post( 'page',  0, 'N' )		//	Page
	local nRows 			:= oController:oRequest:Post( 'rows' , DEFAULT_ROWS, 'N' )   
	local hData, hBrowse

    IF nRows <= 0
		nRows := DEFAULT_ROWS
	ENDIF
   
    nPage++
   
	If nPage * nRows >= nTotal 
		::Last( oController )
		
	ELSE
	
	   hData 			:= oModelCustomer:Browse( nPage, nRows )
	   hBrowse			:= { 'page' => nPage, 'rows' => nRows }
	   
	   oController:View( "customer/customer.view", hData, hBrowse )
   
   ENDIF

return nil 

METHOD Prev( oController ) CLASS CustomerController

	local oModelCustomer	:= CustomerModel():New()
	local nPage 			:= oController:oRequest:Post( 'page',  0, 'N' )		//	Page
	local nRows 			:= oController:oRequest:Post( 'rows' , DEFAULT_ROWS, 'N' )
	local hData, hBrowse

    nPage--
   
    IF nPage < 0
		nPage := 0
	ENDIF  

    IF nRows <= 0
		nRows := DEFAULT_ROWS
	ENDIF    

	hData 			:= oModelCustomer:Browse( nPage, nRows )
	hBrowse			:= { 'page' => nPage, 'rows' => nRows }

	oController:View( "customer/customer.view", hData, hBrowse )

return nil 


//----------------------------------------------------------------------------//

{% memoread( HB_GETENV( 'PRGPATH' ) + "/src/model/customermodel.prg" ) %}