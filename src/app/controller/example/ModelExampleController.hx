package app.controller.example;

import sys.io.File;
import ufront.web.HttpCookie;
import ufront.web.Controller;
import ufront.web.context.HttpContext;
import ufront.web.result.*;
import ufront.web.url.filter.*;
import ufront.view.TemplateData;

class ModelExampleController extends Controller {

	static var parents = [{ name: "Examples", url: "/examples/" }];
	static var baseUri = '/examples/model';
	
	@:route("/") public function index() {
		var examples = [
			{
				name: "Todo List Example",
				explanation: CompileTime.readMarkdownFile( '/examplecontent/model/FavouriteExample.md' ),
				links: [
					"basics",
				],
				iframe: "basics"
			}
		];
		return ViewResult.create({
			title: "Model Examples",
			header: "Model Examples",
			description: "How to use ufront-orm and Haxe's macro-powered DB records to keep track of data in your web app.",
			parents: parents,
			links: ExampleController.links,
			introduction: CompileTime.readMarkdownFile( '/examplecontent/model/Introduction.md' ),
			examples: examples,
			baseUri: baseUri,
			active: "/examples/models/"
		}, "example/index.html" );
	}

	//
	// Examples
	//

	// Basic example (TODO list)

	@:route("/todolist/*")
	function modelBasics() {
		var req = context.request;
		return ViewResult.create({
			uri: req.uri,
		}).withoutLayout();
	}
}