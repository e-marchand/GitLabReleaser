// btn_pkg_refresh — Refresh packages list

Form.statusText:="Loading packages…"
Form.packages:=Form.api.listPackages("")
Form.packageFiles:=[]
Form.currentPackage:=Null:C1517
Form.currentPackageIndex:=0

If (Form.api.errors.length>0)
	Form.statusText:="Error: "+String:C10(Form.api.errors[0].message)
Else 
	Form.statusText:=String:C10(Form.packages.length)+" package(s) found"
End if 
