// btn_open_token_page — Open GitLab personal access token creation page in browser

var $instance : Text:=Choose:C955(Length:C16(Form:C1466.settings.instance)>0; Form:C1466.settings.instance; "https://gitlab.com")
var $url : Text:=$instance+"/-/user_settings/personal_access_tokens"

OPEN URL:C673($url; "")
