/// класс для работы с API Telegram
Class Telegram.API Extends %RegisteredObject
{

Property Token as %String;

Parameter SERVER = "api.telegram.org";

Property SSLConfiguration as %String;

Method GetRequestObj() as %Net.HttpRequest [Private ]
{
	#dim request as %Net.HttpRequest
	set request = ##class(%Net.HttpRequest).%New()
	set request.Server = ..#SERVER
	set request.SSLConfiguration = ..SSLConfiguration
	set request.Https = 1 
	return request
}

Method ExecuteRequest(request as %Net.HttpRequest, method as %String) as %DynamicObject [Private ]
{
	set st = request.Post("bot"_..Token_"/"_method)
	if ($$$ISERR(st)) {
		throw ##class(%Exception.StatusException).CreateFromStatus(st)
	}
	return ##class(%Library.DynamicObject).%FromJSON(request.HttpResponse.Data)
} 

Method %OnNew(token as %String, ssl as %String) as %Status [Private ]
{
	return:(token="" || ssl="") 0
	set ..Token = token
	set ..SSLConfiguration = ssl
	return $$$OK
}

Method GetMe() as %DynamicObject 
{
	return ..ExecuteRequest(..GetRequestObj(), "getMe")
}

Method GetUpdates(offset as %Integer = "", limit as %Integer = 100, timeout as %Integer = 0) as %DynamicObject 
{
	#dim request as %Net.HttpRequest
	set request = ..GetRequestObj()
	if (offset'="") {
		do request.InsertFormData("offset",offset)
	}
	do request.InsertFormData("limit",limit)
	do request.InsertFormData("timeout",timeout)
	return ..ExecuteRequest(request, "getUpdates")
}

Method SendMessage(chatId as %Integer, 
					text as %String, 
					parseMode as %String = "", 
					disableWebPagePreview as %Boolean = 0, 
					disableNotification as %Boolean = 0, 
					replyToMessageId as %Integer = 0, 
					replyMarkup as %DynamicObject = 0) as %DynamicObject 
{
	#dim request as %Net.HttpRequest
	set request = ..GetRequestObj()
	do request.InsertFormData("chat_id",chatId)
	do request.InsertFormData("text",text)
	if (replyMarkup'=0) {
		do request.InsertFormData("reply_markup",replyMarkup.%ToJSON())
	}
	return ..ExecuteRequest(request, "sendMessage")
}
/// First create instance of Telegram.API: 
///    set api = ##class(Telegram.API).%New(token, <ssl_configuration_name)
/// Set webhook with
///    write api.SetWebhook(url,certificate_folder, certificate_filename).%ToJSON()
Method SetWebhook(url as %String, filedir as %String, filename as %String) as %DynamicObject
{
	Set SentHttpRequest=..GetRequestObj()
	
	Set RootMIMEPart = ##class(%Net.MIMEPart).%New()
	
	Set BinaryMIMEPart = ##class(%Net.MIMEPart).%New()
    Set contentdisp = "form-data; name="_$CHAR(34)_"certificate"_$CHAR(34)_"; filename="
                    _$CHAR(34)_""_filename_""_$CHAR(34)
    Do BinaryMIMEPart.SetHeader("Content-Disposition",contentdisp)
    
    Set stream=##class(%FileBinaryStream).%New()
    Set stream.Filename=filedir_filename
    Do stream.LinkToFile(filedir_filename)
     
    Set BinaryMIMEPart.Body=stream
    Do BinaryMIMEPart.SetHeader("Content-Type","text/plain")   
     
    Do RootMIMEPart.Parts.Insert(BinaryMIMEPart)
    
    Set TextMIMEPart=##class(%Net.MIMEPart).%New()
    Set TextMIMEPart.Body=##class(%GlobalCharacterStream).%New()
    Do TextMIMEPart.Body.Write(url)
    
    Set contentdisp = "form-data; name="_$CHAR(34)_"url"_$CHAR(34)_";"
    Do TextMIMEPart.SetHeader("Content-Disposition",contentdisp)
    
    Do RootMIMEPart.Parts.Insert(TextMIMEPart)
    
    Set writer=##class(%Net.MIMEWriter).%New()
    
    Set status=writer.OutputToStream(SentHttpRequest.EntityBody)
    if $$$ISERR(status) {do $SYSTEM.Status.DisplayError(status) Quit}

    Set status=writer.WriteMIMEBody(RootMIMEPart)
    if $$$ISERR(status) {do $SYSTEM.Status.DisplayError(status) Quit}
       
     
	//do SentHttpRequest.InsertFormData("url",url)
	
	Set ContentType= "multipart/form-data; boundary="_RootMIMEPart.Boundary
    Set SentHttpRequest.ContentType=ContentType
    
    set st = SentHttpRequest.Post("bot"_..Token_"/setWebhook")
    

    return ##class(%Library.DynamicObject).%FromJSON(SentHttpRequest.HttpResponse.Data)
}

Method DeleteWebhook() as %DynamicObject
{
	return ..ExecuteRequest(..GetRequestObj(), "deleteWebhook")
}

Method GetWebhookInfo() as %DynamicObject
{
	return ..ExecuteRequest(..GetRequestObj(), "getWebhookInfo")
}

}