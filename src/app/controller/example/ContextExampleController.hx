package app.controller.example;

import sys.io.File;
import ufront.web.HttpCookie;
import ufront.web.Controller;
import ufront.web.context.HttpContext;
import ufront.web.result.*;
import ufront.web.url.filter.*;
import ufront.view.TemplateData;

class ContextExampleController extends Controller {

	static var parents = [{ name: "Examples", url: "/examples/" }];
	static var baseUri = '/examples/context';
	
	@:route("/") public function index() {
		var examples = [
			{
				name: "HttpRequest",
				explanation: CompileTime.readMarkdownFile( '/examplecontent/context/HttpRequest.md' ),
				links: [
					"request/basics",
					"request/params",
					"request/authorization",
					"request/multipart",
				],
				iframe: "request/basics"
			},
			{
				name: "HttpResponse",
				explanation: CompileTime.readMarkdownFile( '/examplecontent/context/HttpResponse.md' ),
				links: [
					'response/hello',
					'response/clear',
					'response/code',
					'response/redirect',
					'response/contenttype',
					'response/header',
					'response/cookie',
				],
				iframe: 'response/hello'
			},
			{
				name: "HttpContext",
				explanation: CompileTime.readMarkdownFile( '/examplecontent/context/HttpContext.md' ),
				links: [
					"httpcontext/basics",
					"httpcontext/tracing",
					"httpcontext/urifilters",
				],
				iframe: "httpcontext/basics"
			},
			{
				name: "ActionContext",
				explanation: CompileTime.readMarkdownFile( '/examplecontent/context/ActionContext.md' ),
				links: [
					"actioncontext/basics",
					"actioncontext/showargs/article/365/",
					"actioncontext/showargs/article/365/some/leftover/uri",
					"actioncontext/showargs/article/365/?msg=Hello World",
				],
				iframe: "actioncontext/basics"
			},
		];
		return ViewResult.create({
			title: "Context Examples",
			header: "Context Examples",
			description: "Examples for HttpRequest, HttpResponse, HttpContext and ActionContext.",
			parents: parents,
			links: ExampleController.links,
			introduction: CompileTime.readMarkdownFile( '/examplecontent/context/Introduction.md' ),
			examples: examples,
			baseUri: baseUri,
			active: "/examples/context/"
		}, "example/index.html" );
	}

	//
	// Request Examples
	//
	@:route("/request/basics/*")
	function requestBasics() {
		var req = context.request;
		return ViewResult.create({
			uri: req.uri,
			queryString: req.queryString,
			postString: req.postString,
			clientIP: req.clientIP,
			hostName: req.hostName,
			userAgent: req.userAgent,
			httpMethod: req.httpMethod,
			scriptDirectory: req.scriptDirectory,
			params: req.params.toString(),
			query: req.query.toString(),
			post: req.post.toString(),
			files: req.files.toString(),
			cookies: req.cookies.toString(),
			clientHeaders: req.clientHeaders.toString(),
			baseUri: '$baseUri/request/basics',
		}).withoutLayout();
	}

	@:route("/request/params/*")
	function requestParams() {
		// Set a cookie for demonstration purposes.  
		// Please note the first time you load this won't show up, because it's only sent to the browser *after* the request has finished.
		context.response.setCookie( new HttpCookie("name","Cookie Monster") );
		context.response.setCookie( new HttpCookie("like","cookies!!!1!! mmmmmmhmm") );

		var req = context.request;
		return ViewResult.create({
			params: req.params.toString(),
			query: req.query.toString(),
			post: req.post.toString(),
			cookies: req.cookies.toString(),
			getName: req.query.get('name'), // `query` stores variables from the query string (used in a GET request)
			postName: req.post['name'], // `post` is for POST requests (usually submitting a form).  Note, you can also use array access instead of `get()`.
			cookieName: req.cookies['name'], // `cookie` is any cookies that were sent from the client/browser.
			paramName: req.params['name'], // "params" is a combination of cookies, query (GET) and post, for when you don't care where it comes from. Any overlaps are added in that order (so `post` will take precedence over `query`, which takes precedence over `cookies`).
			finalLike: req.params.get('like'), // If there is more than one value, `get()` will fetch the last one.
			allLikes: req.params.getAll('like'), // If you are expecting more than one value, you can use `getAll()`.
				// Please note on PHP, you may need to include a "[]" in the name for any parameters with multiple values: eg `like[]`.
			allNames: req.params.getAll('name'), 
			referer: req.clientHeaders['Referer'], // You can also fetch client headers in the same way.
			baseUri: '$baseUri/request/params',
		}).withoutLayout();
	}

	@:route("/request/authorization")
	function requestAuthorization():ActionResult {
		var auth = context.request.authorization;
		if ( auth==null || auth.user!="username" || auth.pass!="password" ) {
			context.response.requireAuthentication( "Please login (username,password)" );
			return new EmptyResult();
		}
		else {
			context.response.setUnauthorized();
			return new ContentResult( 'You are logged in with username "${auth.user}"' );
		}
	}

	@:route("/request/multipart")
	function requestMultipartHandling() {
		return "Multipart handling (and therefore uploads) still have a few issues to be worked out. We will update this with an example when it's working!";
	}

	//
	// Response Examples
	//

	@:route("/response/hello")
	function responseHello() {
		context.response.write( "Hello" );
		
		// One advantage of using a response object rather than directly using `Sys.print` is that all the content is cached until the end.
		// This allows you to set headers or redirects after writing content, save traces for the end of the request, or clear your output at the last minute.
		// For example, this will trace as JS at the end of the request, not in the middle of your output.
		ufTrace( 'This trace is added as a JS snippet at the end of the request.' );

		context.response.writeChar( "!".charCodeAt(0) );

		// When writing to the response directly, for now you need to use an "EmptyResult" return type from your controllers.
		// This means you are writing to the response directly, and ufront should not attempt to write it's own response.
		// We'll explain more about this when we talk about ActionResults.
		return new EmptyResult();
	}

	@:route("/response/clear")
	function responseClear() {
		context.response.write( "I think you smell funny!" );
		context.response.clear();
		context.response.write( "How nice to see you! (I'm glad you didn't hear what I said before.)" );
		return new EmptyResult();
	}

	@:route("/response/code")
	function responseCode() {
		context.response.status = 404;
		context.response.setNotFound(); // Same thing, but in case you can't remember the codes.
		context.response.write( "This page has a 404 Not Found status! (If you look in your browser's console, you'll notice this request has a 404 code!)" );
		return new EmptyResult();
	}

	@:route("/response/redirect")
	function responseRedirect() {
		context.response.redirect( "http://haxe.org/" );
		return new EmptyResult();
	}

	@:route("/response/contenttype")
	function responseContentType() {
		context.response.contentType = "text/plain";
		context.response.write( "Plain text!" );

		// One thing worth noting is that a trace won't appear on any type other than text/html:
		ufTrace( 'This will not be sent to the client...' );

		return new EmptyResult();
	}

	@:route("/response/header")
	function responseHeader() {
		context.response.setHeader( "X-Powered-By", "Ufront" );
		context.response.write( "We set a HTTP Header!" );
		return new EmptyResult();
	}

	@:route("/response/cookie")
	function responseCookie() {
		var name = "Type-of-cookie";
		var value = "Double Choc";
		var expiry = DateTools.delta( Date.now(), 5*60*1000 ); // Expire 5 min from now.
		var domain = null; // Use the default domain.
		var path = "/"; // Use this cookie anywhere on this domain.
		var c = new HttpCookie( name, value, expiry, domain, path );
		context.response.setCookie( c );
		context.response.write("We set a cookie! You better eat it soon, it'll disappear in 5 minutes.");
		return new EmptyResult();
	}

	//
	// HttpContext
	//
	
	@:route("/httpcontext/basics")
	function httpContextBasics() {
		// The HttpContext is a single object that is used to package everything to do with this request.
		// It is used extensively in ufront-mvc code for letting middleware, request handlers, error handlers, action results etc manage requests easily.
		
		// The current HttpContext is available on all controllers as the local variable "context".
		// It has shortcuts to the most important things for each request.
		context; // The current HttpContext
		context.response; // The current HttpResponse
		context.request; // The current HttpRequest
		context.session; // The current UFHttpSessionState, if you have session configured.
		context.auth; // The current UFAuthHandler, if you have auth configured.
		context.actionContext; // The current ActionContext

		// Let's do some stuff things...
		var scriptDir = context.request.scriptDirectory;
		var hasPermission = context.auth.hasPermission( ufront.ufadmin.UFAdminPermissions.UFACanAccessAdminArea );
		var hits:Null<Int> = context.session.get( "pageVisitsFromThisSession" );
		hits = (hits==null) ? 1 : hits+1;
		context.session.set( "pageVisitsFromThisSession", hits );
		context.response.setHeader( "X-Powered-By", "coffee" );

		// The content directory is a path (specified in your UfrontConfiguration, relative to the scriptDirectory) that we can write to.
		// It is useful for writing log files, handling uploads, creating thumbnails, etc.
		// In future I may consider abstracting this away further so we have a generic FileSystem object that can also write to cloud services, remote file systems, etc.
		// If you're going to write to the file system, it's a good idea to limit it to a single directory so you can lock down your permissions as much as possible.
		var contentDir = context.contentDirectory;
		File.saveContent( contentDir+"last_visited.log", 'Last visited ${Date.now()}' );

		// The `completion` property of HttpContext isn't something you'll have to use often.
		// Basically it lets ufront modules (middleware, request handlers etc.) specify what stage of the request they're up to.
		// It's an `EnumFlags` object, so you can use `has`, `set`, and `unset` to check / change things.
		var complete = [];
		if ( context.completion.has(CRequestMiddlewareComplete) ) complete.push("Request middleware complete.");
		if ( context.completion.has(CRequestHandlersComplete) ) complete.push("Request handler complete.");
		if ( context.completion.has(CResponseMiddlewareComplete) ) complete.push("Response middleware complete.");
		if ( context.completion.has(CLogHandlersComplete) ) complete.push("Log handlers complete.");
		if ( context.completion.has(CFlushComplete) ) complete.push("Flush complete.");
		if ( context.completion.has(CErrorHandlersComplete) ) complete.push("Error handlers complete.");

		// An example of it's usage: you have a cache middleware which runs at the start of a request.
		// It realizes we have a cached version of the page, and doesn't need to run the request handler again.
		// So we mark the request handlers as done, and it'll skip them: 
		//   context.completion.set( CRequestHandlersComplete );

		return ViewResult.create({
			scriptDir: scriptDir,
			contentDir: contentDir,
			hasPermission: hasPermission,
			hits: hits,
			isSessionActive: context.isSessionActive(),
			sessionID: context.sessionID,
			currentUserID: context.currentUserID,
			currentUser: context.currentUser,
			complete: complete.join(",<br/>")
		}).withoutLayout();
	}

	@:route("/httpcontext/tracing")
	function httpContextTracing() {
		// There is a `context.messages` array that stores the messages for this request.
		// You can write to it using `context.ufTrace()`, `context.ufLog()`, `context.ufWarn()`, and `context.ufError()`.
		context.ufTrace( 'Traces are stored in the `context.messages` array and sent to our log handlers at the end of the request.  By default (it is configurable) these will show up in your browser console.' );
		
		// There are also shortcuts set up for `ufTrace()` etc from inside any `ufront.web.Controller` or `ufront.api.UFApi` sub class.
		ufTrace( 'This is a Trace' ); // Will do a `console.log()` in the browser.
		ufLog( 'This is a Log' ); // Will do a `console.info()` in the browser.
		ufWarn( 'This is a Warning' ); // Will do a `console.warn()` in the browser.
		ufError( 'This is an Error' ); // Will do a `console.error()` in the browser.

		// A straight `trace()` will only be sent to the client if `-debug` is true.
		// This is partly so you can easily have traces that show up for you but not for users.
		// The other reason is that when using NodeJS (and possibly mod_tora?), `trace` is static but the HttpContext we need to trace to is an instance.
		// So if two requests were happening at the simultaneously, we wouldn't know which request/response to send our trace statements to - we can guess, but we might trace sensitive information to the wrong user/request.
		trace( 'If you see this in your browser, `-debug` must be enabled! (It should show up in the log file still).' ); 

		return "Check out your browser console! These can also be logged to a file on the server, or you can create your own custom log handlers.";
	}
	
	@:route("/httpcontext/urifilters")
	function httpContextUriFilters() {
		var data:TemplateData = new TemplateData();

		// `request.uri` will give you the raw URI, but `getRequestUri()` will get the filtered URI according to our configuration.
		data["unfilteredUri"] = context.request.uri;
		data["filteredUri"] = context.getRequestUri();

		// We can also use `context.generateUri()` to run those filters in reverse.
		// This allows us to generate links that will fit the URI/redirect settings of our server.
		data["uri1"] = "/somePath";
		data["uri1AfterFilters"] = context.generateUri( data["uri1"] );

		// The same again, but we will change the filters to pretend that our app lives inside a subdirectory.
		// Usually you wouldn't set these filters manually, they are set in `UfrontApplication` depending upon the `UfrontConfiguration` settings you provide.
		var directoryFilter = new DirectoryUrlFilter( "mywebapp" );
		var pathInfoFilter = new PathInfoUrlFilter();
		context.setUrlFilters([ directoryFilter, pathInfoFilter ]);
		data["uri2"] = "/my/path/to/file.html";
		data["uri2AfterFilters"] = context.generateUri( data["uri2"] );

		return ViewResult.create( data ).withoutLayout();
	}
	
	//
	// ActionContext
	//
	
	@:route("/actioncontext/basics/")
	function actionContextBasics() {
		// The current ActionContext is available via `context.actionContext`.
		var ctx = context.actionContext;

		/**
			Other than the shortcuts, the ActionContext stores information about what action was performed during the request.
			As the request goes on, it fills up with data about which request handler , controller, action and args were used.
			Once the request has been handled, the result of the action is also stored.
			This allows us to do a few useful things, such as:
			 - Our "ViewResult" class can tell which controller/action was used, so we can look for a view at `controller/action.html` or similar.
			 - We can log requests, and take note of which action was called, and with which parameters.
		**/

		return ViewResult.create({
			// The UFRequestHandler that dealt with the request. Usually MVCHandler (web request, uses a controller) or RemotingHandler (Haxe remoting request, uses a UFApi)
			handler: ctx.handler,
			
			// The "controller" that handled the request - this might be a `ufront.web.Controller`, or a `ufront.api.UFApi`, or something else, depending on what type of request it was.
			controller: ctx.controller,

			// A string containing the "action" name - the name of the method on the controller/API that was called by the request.
			action: ctx.action,

			// The args which were sent to the action.
			args: ctx.args,

			// The result of the action.
			actionResult: ctx.actionResult,

			// The leftover URI parts once we have gotten to this point in our route.
			// Please note the MVCHandler uses this, but it is not used by the RemotingHandler etc.
			uriParts: ctx.uriParts,

		}, "contextExample/actionContextBasics.html").withoutLayout();
	}

	@:route("/actioncontext/showargs/$arg1/$arg2/*")
	function actionContextShowArgs( arg1:String, arg2:Int, ?args:{ msg:String }, rest:Array<String> ) {
		// Show the exact same template as "actionContextBasics".
		// But because this is the route/action we used, all the data will be different.
		return actionContextBasics();
	}
}