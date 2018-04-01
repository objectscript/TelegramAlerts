Class Telegram.TelegramOutboundAdapter  Extends Ens.OutboundAdapter
{
Property TelegramToken As %String;

Property SSLConfiguration As %String;

Property API as Telegram.API [ Private ];

Parameter SETTINGS = "TelegramToken,SSLConfiguration";

Method OnInit() As %Status
{
	set ..API = ##class(Telegram.API).%New(..TelegramToken, ..SSLConfiguration)
	if '$isobject(..API) {
		return 0
	}
	return $$$OK
}

Method SendMessage(chatId as %String,text as %String, removeKeyboard as %Boolean = 0) as %Integer
{
	if (removeKeyboard) {
		set obj = {"remove_keyboard":true}
		set res = ..API.SendMessage(chatId,text,,,,,obj)
	} else {
		set res = ..API.SendMessage(chatId,text)
	}
	
	if (res.ok) {
		return res.result."message_id"
	}
	return $$$ERROR($$$GeneralError, "Error while sending a message")
}

Method SendButton(chatId as %String, text as %String, buttonText as %String = "", getPhone as %Boolean = 0) as %Status
{
	set button = {}
	if (getPhone=1) {
		do button.%Set("request_contact",1,"boolean") 
	} 
	set button.text = buttonText
	
	set buttons = []
	do buttons.%Push(button)
	
	set obj = {"one_time_keyboard":true,"resize_keyboard":true}
	set obj.keyboard = []
	do obj.keyboard.%Push(buttons)
	set res = ..API.SendMessage(chatId,text,,,,,obj)
	
	if (res.ok) {
		return res.result."message_id"
	}
	return $$$ERROR($$$GeneralError, "Error while sending a button")
}
}