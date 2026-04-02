// btn_pkg_delete — Delete the selected package

If (Not:C34(Form.api.hasWriteAccess()))
	ALERT:C41("Your token lacks write access (api scope required).\nCurrent scopes: "+Form.api.getScopes().join(", "))
	return
End if 

If (Form.currentPackage=Null:C1517)
	Form.statusText:="Please select a package to delete"
Else 
	CONFIRM:C162("Delete package "+String:C10(Form.currentPackage.name)+" (ID: "+String:C10(Form.currentPackage.id)+")?")
	
	If (OK=1)
		Form.statusText:="Deleting package…"
		var $resp : Object:=Form.api.deletePackage(Form.currentPackage.id)
		
		If ($resp.success)
			Form.statusText:="Package deleted"
			// Refresh
			Form.packages:=Form.api.listPackages("")
			Form.packageFiles:=[]
			Form.currentPackage:=Null:C1517
			Form.currentPackageIndex:=0
		Else 
			Form.statusText:="Delete failed: "+String:C10(Form.api.errors[0].message)
		End if 
	End if 
End if 
