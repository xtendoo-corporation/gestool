function InicioHRB( oMateriaPrima )
   
   /*if Empty( oMateriaPrima:oDbfVir:cCodCat )
      setAlertTextDialog( "C�digo de categor�a es obligatorio", oMateriaPrima:oDlg )
      oMateriaPrima:oFld:SetOption( 2 )
      oMateriaPrima:oGetCatalogo:SetFocus()
      Return .f.
   else
      endAutoTextDialog()
   end if*/

   if Empty( oMateriaPrima:oDbfVir:cCodTmp )
      setAlertTextDialog( "C�digo de temporada es obligatorio", oMateriaPrima:oDlg )
      oMateriaPrima:oFld:SetOption( 2 )
      oMateriaPrima:oGetTemporada:SetFocus()
      Return .f.
   else
      endAutoTextDialog()
   end if

return .t.

//---------------------------------------------------------------------------//