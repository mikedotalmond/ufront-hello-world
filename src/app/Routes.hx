package app;

import ufront.web.Controller;
import ufront.ufadmin.controller.UFAdminController;
import ufront.web.result.*;
import app.controller.*;
import app.controller.example.ExampleController;

/**
	Ufront uses `ufront.web.Controller` for routing.

	This is an example of a controller, although it's a bit unusual in that other than `index()` it mostly just points to child controllers.
**/
class Routes extends Controller
{
	#if server
		// When we support client-side one page apps, I want to make sure the ufadmin controller is not included on the client app, only on the server.
		@:route("/ufadmin/*") var ufAdmin:UFAdminController;
	#end

	@:route("/newsletter/*") var newsletter:SubscriptionController;
	@:route("/examples/*") var example:ExampleController;

	/**
		Each controller can have one or more "actions" (methods that respond to a HTTP request).
		Each action is triggered by a specific HTTP request, usually matching a certain route.
		Ufront controllers use `@:route( "/route/goes/here" )` metadata to match.
	**/
	@:route("/")
	public function index() {
		// Show the "index.html" view and insert our "title" variable.
		return ViewResult.create({
			title: "Build web apps in a language you love"
		}, "index.html");
	}


}
