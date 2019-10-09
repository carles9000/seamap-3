//----------------------------------------------------------------------------//

CLASS LoginModel

   METHOD New()             		CONSTRUCTOR
   
   METHOD Validate( cUser, cPsw )     


ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS LoginModel

   if ! File( hb_GetEnv( "PRGPATH" ) + "/data/users.dbf" )
   
      DbCreate( hb_GetEnv( "PRGPATH" ) + "/data/users.dbf",;
         { { "USER"		, "C", 18, 0 },;
           { "PSW"		, "C", 32, 0 };
		  })
		  
   endif

   if Alias() != "USERS"
      USE ( hb_GetEnv( "PRGPATH" ) + "/data/users" ) SHARED NEW VIA 'DBFCDX'
	  
	  INDEX ON user TAG user TO ( hb_GetEnv( "PRGPATH" ) + "/data/users" )
   endif

   if RecCount() == 0
      APPEND BLANK
      field->user := "demo"
      field->psw  := hb_Md5( '1234' )
   endif    

return Self

//----------------------------------------------------------------------------//

METHOD Validate( hData ) CLASS LoginModel

	local lAutenticate := .F.

	if DbSeek( hData[ 'user' ] ) 
		if field->psw == hb_md5( hData[ 'psw' ] )
			lAutenticate := .T.
		endif
	endif

return lAutenticate

//----------------------------------------------------------------------------//