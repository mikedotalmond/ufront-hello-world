package app.controller;

import ufront.web.Controller;
import ufront.web.Dispatch;
import ufront.web.result.*;
import app.api.SubscriptionApi;
import Config;
using tink.CoreApi;

/**
	This is an example of a fairly typical controller.

	We respond to HTTP requests on a certain route, talk to the API to actually do something, and then return a view to the client.
**/
class SubscriptionController extends Controller {
	
	/**
		This is the API we are going to use.
		We could write to the database directly from the controller, and send welcome emails directly from here, but doing it from the API leaves us flexible.
		It means we can do things like run the same API call from the command line, not via a HTTP Request.
		Or one day run this controller from the client, and just talk to the API over remoting.
	**/
	@inject public var subscriptionApi:SubscriptionApi;
	
	/**
		Listen to /subscribe/ POST requests.
	
		Notice the @:route metadata has the "POST" keyword - this action will never trigger for a "GET" request.

		Also the "args" parameter describes which GET/POST variables must be specified in the request.  
		An error will occur if the values are not all supplied.
	**/
	@:route(POST, "/subscribe/")
	public function subscribeThankYou( args:{ email:String } ):ActionResult {

		var header:String, paragraph:String;

		// Make the API call.  
		// Because I used an Outcome for the return type, I use a switch statement to check if it worked, and show the appropriate message.
		switch subscriptionApi.subscribe( args.email ) {
			case Success(_):
				header = "Thank you!";
				paragraph = 'We\'ll email <strong>${args.email}</strong> the next time we have something exciting or important to share.';
			case Failure(msg):
				header = "Whoops:";
				paragraph = msg;
		}

		// I create a new ViewResult, using the "/home/subscription.html" view and supplying these variables.
		return ViewResult.create({
			title: "Subscribe to the newsletter",
			email: args.email,
			header: header,
			paragraph: paragraph
		}, "subscription/message.html");
	}
	
	@:route(GET, "/unsubscribe/$email/")
	public function unsubscribe( email:String ):ActionResult {
		
		var header:String, paragraph:String;

		switch subscriptionApi.unsubscribe( email ) {
			case Success(_):
				header = "Sorry to see you go!";
				paragraph = 'We won\'t email our newsletter to <strong>$email</strong> anymore.';
			case Failure(msg):
				header = "Whoops:";
				paragraph = msg;
		}

		return ViewResult.create({
			header: header,
			paragraph: paragraph,
			title: "Unsubscribe from the newsletter",
			email: email
		}, "subscription/message.html");
	}

	@:route("/list/")
	public function list():ActionResult {
		// Because end users shouldn't see this page, I don't care about handling the failure.
		// I'll use tink.CoreApi's "sure()" to throw an error if it's a failure.
		var list = subscriptionApi.getList().sure();
		return ViewResult.create({
			title: "List of subscribers",
			list: list
		});
	}
}
