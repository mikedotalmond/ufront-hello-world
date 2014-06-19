package app.controller.example;

import ufront.web.Controller;
import ufront.web.result.*;
import app.controller.example.*;


class ExampleController extends Controller {

	public static var links = [
		{ name: "Context", url: "/examples/context/" },
		{ name: "Controller", url: "/examples/controller/" },
		{ name: "Views", url: "/examples/views/" },
		{ name: "Models", url: "/examples/models/" },
		{ name: "Auth", url: "/examples/auth/" },
		{ name: "Injection", url: "/examples/injection/" },
		{ name: "Mail", url: "/examples/mail/" },
	];
	
	@:route("/") public function index() {
		return ViewResult.create({
			title: "Examples",
			header: "Ufront Examples",
			description: "To help understand how ufront works, we have some basic examples of usage.  Source code for these can be found in the `ufront-hello-world` repository.",
			parents: [],
			links: links,
			examples: [],
			active: "/examples/",
			introduction: CompileTime.readMarkdownFile( '/examplecontent/Introduction.md' ),
		});
	}

	@:route("/context/*") public var contextExample:ContextExampleController;
	@:route("/controller/*") var controllerExample:ControllerExampleController;
	@:route("/views/*") var viewExample:ViewExampleController;
	@:route("/models/*") var modelExample:ModelExampleController;
	@:route("/auth/*") var authExample:AuthExampleController;
	@:route("/injection/*") var injectionExample:InjectionExampleController;
	@:route("/mail/*") var mailExample:MailExampleController;
}