package app.controller.example;

import ufront.web.Controller;

class ControllerExampleController extends Controller {

	@:route("/") public function basics() {
		// What it looks like
		// Sub controllers
	}
	
	@:route("/routing/*") var routingExample:RoutingExampleController;
	@:route("/args/*") var argsExample:ArgsExampleController;
	@:route("/result/*") var actionResultExample:ActionResultExampleController;
}