// {% LoadHrb( "/lib/core_lib.hrb" ) %}
// {% LoadHrb( "/lib/mercury.hrb" ) %}
// {% LoadHrb( "/lib/wdo_lib.hrb" ) %}

function Main()

	local oApp 		:= App()  
	local cFile 	:= HB_GETENV( 'PRGPATH' ) + '/count.txt' 
	local nCount	:= Val( Memoread( cFile ) ) + 1    

		//	Contador de visitas
		
			memowrit( cFile, ltrim(str(nCount)) )		
			
			oApp:Set('count', ltrim(str(nCount)) )
   
		//oApp:lLog := .t.
   
		//	o := WDO():ADO()				
		//	? 'Version WDO', o:Version()
		//	? 'Version Mercury', oApp:Version()				
		
			oApp:oRoute:Map( "GET"	 	, "root"		, "/"			, "@customercontroller.prg" )			
			oApp:oRoute:Map( "GET,POST"	, "customer"	, "customer"	, "@customercontroller.prg" )			
   
			oApp:oRoute:Map( "GET,POST"	, "autenticate"	, "autenticate"	, "@logincontroller.prg" )			
					
			
		//	Definimos nuestro sistema middleware
	
			oApp:oMiddleware:SetAutentication( 'jwt', 'SeaMAP' )
			
	oApp:Init()

return nil


init procedure Config

	SET DATE TO ITALIAN
	SET DATE FORMAT 'DD/MM/YYYY'

retu nil