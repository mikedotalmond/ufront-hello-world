package app.controller.example;

import sys.io.File;
import ufront.web.Controller;
import ufront.web.result.*;
import ufront.web.url.filter.*;

class InjectionExampleController extends Controller {

	static var parents = [{ name: "Examples", url: "/examples/" }];
	static var baseUri = '/examples/model';
	
	@:route("/") public function index() {
		var examples = [
			// {
				// name: "Todo List Example",
				// explanation: CompileTime.readMarkdownFile( '/examplecontent/model/FavouriteExample.md' ),
				// links: [
				// 	"basics",
				// ],
				// iframe: "basics"
			// }
		];
		return ViewResult.create({
			title: "Injection Examples",
			header: "Injection Examples",
			description: "Dependency injection in Ufront - what it is, why it matters, how it works.",
			parents: parents,
			links: ExampleController.links,
			introduction: CompileTime.readMarkdownFile( '/examplecontent/injection/Introduction.md' ),
			examples: examples,
			baseUri: baseUri,
			active: "/examples/injection/"
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