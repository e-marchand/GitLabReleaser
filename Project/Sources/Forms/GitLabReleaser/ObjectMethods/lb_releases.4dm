// lb_releases — listbox selection handler
// When a release is selected, load its asset links

var $event : Object:=FORM Event:C1606

Case of 
	: ($event.code=On Selection Change:K2:29) | ($event.code=On Clicked:K2:4)
		
		If (Form.currentRelease#Null:C1517)
			Form.statusText:="Loading links for release "+Form.currentRelease.tag_name+"…"
			Form.releaseLinks:=Form.api.listReleaseLinks(Form.currentRelease.tag_name)
			If (Form.api.errors.length>0)
				Form.statusText:="Error: "+String:C10(Form.api.errors[0].message)
			Else 
				Form.statusText:=String:C10(Form.releaseLinks.length)+" asset link(s)"
			End if 
		Else 
			Form.releaseLinks:=[]
		End if 
		
End case 
