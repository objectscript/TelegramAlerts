/// глобал ^Telegram.ProcessedUpdateId используется для хранения ID последнего обработанного сообщения
Class Telegram.TelegramInboundAdapter Extends Ens.InboundAdapter
{
 
Property TelegramToken As %String;

Property SSLConfiguration As %String;

Property API as Telegram.API [ Private ];

Property Updates as %DynamicArray [ Private ];

Parameter SETTINGS = "TelegramToken,SSLConfiguration";

Method OnInit() As %Status
{
	set ..API = ##class(Telegram.API).%New(..TelegramToken, ..SSLConfiguration)
	if '$isobject(..API) {
		return $$$ERROR($$$GeneralError,"API object doesn't created, check Bot token and SSL configuration")
	}
	set ..Updates = []
	return $$$OK
}

Method ProcessUpdates(pOutput) {
	set updateObj = ..Updates.%Get(0) 
	return:(updateObj="") $$$OK
	
	set st = ..BusinessHost.ProcessInput(updateObj,.pOutput)
	if ($$$ISOK(st)) {
		set ^Telegram.ProcessedUpdateId = updateObj."update_id"
		do ..Updates.%Remove(0)
	}
	return st
}

Method OnTask() As %Status
{
	try {
		set updateObj = ..Updates.%Get(0) 
		if (updateObj="") {
			set res = ..API.GetUpdates(1+$Get(^Telegram.ProcessedUpdateId))
			if (res.ok) {
				set ..Updates = res.result
			} else {
				return $$$ERROR($$$GeneralError,"No data received from API, check Bot token")
			}
		}
		
		set st = ..ProcessUpdates(.pOutput)
	} catch e {
		return e.AsStatus()
	}
		
	return st
}

}