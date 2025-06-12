//---------------------------------------------------------------------------//

Function SqlOpen()

   local cStatement     := ""

   if Empty( cStatement )
      cStatement        := "SELECT * FROM " + cPatEmp() + "AlbCliT WHERE cSerAlb<>'H'"
   end

Return ( cStatement )

//---------------------------------------------------------------------------//