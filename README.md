# TelegramAlerts

Telegram bot created to get Alerts from Ensemble on your mobile phone

## Steps to add to your Ensemble Production

1. Create your bot using BotFatner (https://telegram.me/BotFatner) and get a token
2. Create client SSL configuration in Management Portal  
3. Import classes (Telegram package)
4. Create Lookup Table in your Ensemble namespace. Add one or more records. Use phone number (without "+" prefix) as a key.
5. Add in your Production business operation TelegramOperation, in its settings, you must specify TelegramToken and SSLConfiguration

For getting updates from Telegram do one of the following (6 or 7):
6. Long polling. Add TelegramService business service to your Production and configure it. Specify TelegramToken, SSLConfiguration, TableName (Lookup table name). Set call interval.
7. Webhook
	* Create web application and Specify Dispatch Class parameter as Telegram.RESTBroker.cls
	* Configure SSL on your Web server
	* Call method SetWebhook of class Telegram.API to set webhook.
	* Add TelegramService business service to your Production. Specify TableName (Lookup table name). Set "Pool Size"=0.
	
8. Add AlertOperation.cls with the name Ens.Alert to the product and configure TelegramToken, SSLConfiguration, TableName
9. Done!
