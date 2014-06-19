import sys.db.Mysql;
import ufront.app.DispatchApplication;
import ufront.app.UfrontApplication;
import ufront.handler.ErrorPageHandler;
import ufront.view.TemplatingEngines;
import ufront.view.UFTemplate;
import ufront.cache.MemoryCache;
import ufront.cache.UFCache;
import ufront.middleware.InlineSessionMiddleware;
import ufront.web.result.ViewResult;
import ufront.ufadmin.controller.*;
import ufront.mailer.*;
import ufront.auth.*;
import ufront.web.*;
import app.*;

class Server
{
	public static var ufrontApp:UfrontApplication;

	static function main() {
		// If we are using mod_neko or mod_tora, we can enable caching between requests.
		// This will keep the modules loaded in memory, and re-execute `run()` for each request.
		// Any static variables can also be kept alive between requests.
		// This makes a HUGE difference to the speed of each request.
		#if (neko && !debug)
			neko.Web.cacheModule(run);
		#end

		run();
	}

	static function run() {
		
		// If neko caching is enabled, init() will only need to run once.
		init();

		// Start a DB connection and execute the current request.
		sys.db.Transaction.main( Mysql.connect( Config.server.db ), function() {
			ufrontApp.execute();
		});
	}

	static function init() {
		if ( ufrontApp==null ) {

			// Create our ufrontApp and keep it in a static variable so that it is set up once and can be re-used for each request.
			ufrontApp = 
				new UfrontApplication({
					// The UfrontApplication constructor takes a `ufront.web.UfrontConfiguration` object.
					// You can include as many or as few properties as are relevant to you.

					// Which controller is our "index" controller where web page requests start?
					indexController: Routes,

					// Do we have an API we want to share through remoting?
					remotingApi: Api,

					// If we specify a logFile, it will contain traces for each request, as well as details of the requests going in.
					// In future we should add a "logLevel" property so that we can log important events, but not minor traces etc.
					#if debug
						logFile: "log/ufront.log",
					#end

					// Ufront has a concept of the "contentDirectory" - a directory writeable by the web server.
					// This could be used for handling uploads, log files, file based session handling etc.
					contentDirectory: "../uf-content/",

					// We can filter out cruft from our URIs to allow for different web server setups.

					// Enable PathInfoUrlFilter, so we can check for "uri/path.html" rather than "index.n/uri/path.html" etc.
					// Leaving this as the default (true) and using mod_rewrite or similar is usually easiest, we turn it off here for demonstration purposes.
					urlRewrite: false,
					
					// If the app is running in a subdirectory, we can have our routes use "/some/path.html" even if the URI is "/basePath/some/path.html".
					basePath: '/',
				})
				
				// Add support for certain templating engines to use in our views.
				// See `ufront.view.TemplatingEngines` for examples, it should be easy to add more.
				.addTemplatingEngine( TemplatingEngines.haxe )
				.addTemplatingEngine( TemplatingEngines.hxtemplo )
				.addTemplatingEngine( TemplatingEngines.mustache )

			;

			// We set a default layout to wrap any of our ViewResults with.
			// The layout will need a `::viewContent::` variable to insert the view for each action into.
			// If you don't set a default layout, your views will not be wrapped by default.
			ViewResult.setDefaultLayout( "layout.html" );

			// We're going to use a SMTP server in our app to send emails.
			// We could also replace it with a DBMailer (which saves fake emails to a database for testing) or an API such as Mandrill etc.
			var smtp = Config.server.smtp;
			var mailer = new SMTPMailer( smtp.host, smtp.port, smtp.user, smtp.pass );

			// Ufront supports dependency injection, which is great for unit testing and for providing swappable components.
			// For example, here we inject a UFMailer (used for sending email). Later we could change to use a different email provider.
			// We also inject a variable called "defaultLayout", which is used to tell the view engine which 
			ufrontApp.inject( UFMailer, mailer );

			// Should we start a session for every visitor, or only when somebody tries to log in?
			// For the sake of some of our examples, let's do every user.
			InlineSessionMiddleware.alwaysStart = true;

			// Include all the models, so none are DCE'd (we need them for our DBAdminController...)
			CompileTime.importPackage("app.model");
			CompileTime.getAllClasses(ufront.db.Object);
		}
	}
}
