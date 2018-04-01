Class Telegram.Msg.ButtonRequest Extends Ens.Request
{
	
	Property ChatId As %Integer;
	/// текст сообщения
	Property Text as %String (MAXLEN=5000);
	/// текст на кнопке
	Property Button as %String;


Storage Default
{
<Data name="ButtonRequestDefaultData">
<Subscript>"ButtonRequest"</Subscript>
<Value name="1">
<Value>ChatId</Value>
</Value>
<Value name="2">
<Value>Text</Value>
</Value>
<Value name="3">
<Value>Button</Value>
</Value>
</Data>
<DefaultData>ButtonRequestDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}