// btn_pkg_download — Download the selected package file

If (Form.currentPackage=Null:C1517)
	Form.statusText:="Please select a package first"
Else 
	If (Form.currentPackageFile=Null:C1517)
		Form.statusText:="Please select a file to download"
	Else 
		// Ask where to save
		var $destFolder : Text:=Select folder:C670("Save to folder")
		
		If (OK=1)
			Form.statusText:="Downloading "+String:C10(Form.currentPackageFile.file_name)+"…"
			
			var $resp : Object:=Form.api.downloadPackage(\
				Form.currentPackage.name; \
				Form.currentPackage.version; \
				Form.currentPackageFile.file_name)
			
			If ($resp.success)
				var $folder : 4D.Folder:=Folder:C1567($destFolder; fk platform path:K87:2)
				var $outFile : 4D.File:=$folder.file(Form.currentPackageFile.file_name)
				$outFile.setContent($resp.body)
				Form.statusText:="Downloaded to "+$outFile.path
				SHOW ON DISK:C922($outFile.platformPath)
			Else 
				Form.statusText:="Download failed: "+String:C10(Form.api.errors[0].message)
			End if 
		End if 
	End if 
End if 
