Class Telegram.AlertOperation extends Ens.BusinessOperation {

Parameter ADAPTER = "Telegram.TelegramOutboundAdapter";

Property Adapter As Telegram.TelegramOutboundAdapter;

Parameter INVOCATION = "Queue";

Property TableName as %String;

Parameter SETTINGS = "TableName";

Method SendAlert(pInput As Ens.AlertRequest, Output pOutput As Ens.Response) As %Status
{	
	set tableName = ..TableName
	return:(tableName="") $$$ERROR($$$GeneralError, "TableName не определено")
	
	// находим всех кто подписан на алерты
	&sql(DECLARE chats CURSOR FOR 
		SELECT DataValue FROM Ens_Util.LookupTable WHERE DataValue!='' AND TableName = :tableName)
	&sql(OPEN chats)
	while (1) {
		&sql(FETCH chats INTO :chatId)
		$$$TRACE(SQLCODE)
		quit:(SQLCODE'=0)
		do ..Adapter.SendMessage(chatId,"Alert!"_$$$NL_pInput.SourceConfigName_$$$NL_pInput.AlertText)
	} 
	&sql(CLOSE chats)
	return $$$OK 
}

XData MessageMap {
<MapItems>
    <MapItem MessageType="Ens.AlertRequest">
        <Method>SendAlert</Method>
    </MapItem>
</MapItems>
}


}