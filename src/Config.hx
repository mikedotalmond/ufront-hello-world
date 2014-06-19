/**
	This is site specific config, it can contain anything you decide is relevant to your app.

	Please note this is unrelated to `ufront.web.UfrontConfiguration`, which is used specifically to configure ufront.
	This is all about settings relevant to your app specifically.

	We use `CompileTime.parseJsonFile` which loads our config from a JSON file at compile time.
	This has the advantage of being completely type safe, giving you auto-completion etc.
	You could load the JSON at runtime if that's more your style.
**/
class Config {
	public static var app = CompileTime.parseJsonFile( "conf/app.json" );

	#if server
		// Any config which is server specific I'll hide from the client.
		// This includes anything which might contain database credentials, API keys or similarly private information.
		public static var server = CompileTime.parseJsonFile( "conf/server.json" );
	#end
}