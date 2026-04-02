// lb_packages — listbox selection handler
// When a package is selected, load its files

var $event : Object:=FORM Event:C1606

Case of 
	: ($event.code=On Selection Change:K2:29) | ($event.code=On Clicked:K2:4)
		
		If (Form.currentPackage#Null:C1517)
			Form.statusText:="Loading files for package "+String:C10(Form.currentPackage.name)+"…"
			Form.packageFiles:=Form.api.getPackageFiles(Form.currentPackage.id)
			If (Form.api.errors.length>0)
				Form.statusText:="Error: "+String:C10(Form.api.errors[0].message)
			Else 
				Form.statusText:=String:C10(Form.packageFiles.length)+" file(s) in package"
			End if 
		Else 
			Form.packageFiles:=[]
		End if 
		
End case 
