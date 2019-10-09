//----------------------------------------------------------------------------//

CLASS LoginController

    METHOD New( oController )

    METHOD Default( oController ) 
    METHOD Login( oController )    
    METHOD Logout( oController )    


ENDCLASS    

//----------------------------------------------------------------------------//

METHOD New( oController ) CLASS LoginController

    local cAction := oController:oRequest:Post( 'action' )

    do case
		  
       case cAction == "login"
          ::Login( oController )		  
	  
       case cAction == "logout"
          ::Logout( oController )
		  
       otherwise
          ::Default( oController ) 
		  
    endcase

return Self    

//----------------------------------------------------------------------------//

METHOD Default( oController ) CLASS LoginController

   oController:View( "system/login.view" )

return nil    

//----------------------------------------------------------------------------//

METHOD Login( oController ) CLASS LoginController

   local oModelLogin 	:= LoginModel():New()
   local hData 		:= {=>}
   
   hData[ 'user' ] := oController:oRequest:Post( 'user' )
   hData[ 'psw'  ] := oController:oRequest:Post( 'psw' )
	
   hData[ 'user' ] := oController:oRequest:Post( 'user' )
   hData[ 'psw'  ] := oController:oRequest:Post( 'psw' )
	
	if oModelLogin:Validate( hData ) 	
	
		//	Recojo datos de Usuario
		
			hUser := { 'name' => hData[ 'user' ], 'rool' => 'demo' }
			
		//	Creo sistema de verificacion del sistema via middleware
		
			//	Datos que incrustarer en el token...	
			
				hTokenData := { 'entrada' => time(),;
								 'empresa' => 'Intelligence System',;
								 'user' => hUser } 			
		
		//	Inicamos nuestro sistema de Validación del sistema basado en JWT
		
			oController:oMiddleware:SetAutenticationJWT( hTokenData )	
				
		oController:oResponse:SendJson( { 'success' => .t. } )	
	
	else
	
	//	oController:oResponse:SetCookie( 'seamap', '', -1 )
		oController:oResponse:SendJson( { 'success' => .f., 'data' => hData } )
		
	endif

return nil  

//----------------------------------------------------------------------------//

METHOD Logout( oController ) CLASS LoginController

	oController:oMiddleware:CloseJWT()
	
	oController:oResponse:SendJson( { 'logout' => .t. } )

	//oController:View( 'blank.view' )
	//oController:oResponse:Redirect( 'login'  )
	
	//	No se puede hacer un redirect porque enviamos una cookie con el CloseJWT 
	
	//	AP_HeadersOutSet( "Location", "http://localhost/hfw/saturn" )
	//	ErrorLevel( 302 )	

return nil  

//----------------------------------------------------------------------------//

{% include( AP_GETENV( 'PATH_APP' ) + "/src/model/loginmodel.prg" ) %}