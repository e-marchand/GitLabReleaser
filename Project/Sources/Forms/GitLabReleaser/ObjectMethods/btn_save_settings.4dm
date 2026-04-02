// btn_save_settings — Save GitLab settings to disk and reconfigure API

If (Form.settings=Null:C1517)
	Form.statusText:="No settings to save"
Else 
	// Update API object with new values
	Form.api.instance:=Choose:C955(Length:C16(Form.settings.instance)>0; Form.settings.instance; "https://gitlab.com")
	Form.api.projectPath:=Form.settings.projectPath
	Form.api.token:=Form.settings.token
	Form.api._encodedPath:=Replace string:C233(Form.api.projectPath; "/"; "%2F")
	
	// Persist
	Form.api.saveSettings()
	
	Form.statusText:="Settings saved — "+Form.api.instance+" / "+Form.api.projectPath
	
	// Clear connection info since token may have changed
	Form.connectionInfo:=""
	Form.api.tokenInfo:=Null:C1517
	Form.api.userInfo:=Null:C1517
End if 
