package app.controller.example;

import sys.io.File;
import ufront.web.Controller;
import ufront.web.result.*;
import ufront.web.url.filter.*;

class MailExampleController extends Controller {

	static var parents = [{ name: "Examples", url: "/examples/" }];
	static var baseUri = '/examples/mail';
	
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
			title: "Mail Examples",
			header: "Mail Examples",
			description: "Ufront provides email functionality through the `ufront-mail` library.  A basic SMTP mailer is provided, and the interface is flexible so you can replace it with a different implementation.",
			parents: parents,
			links: ExampleController.links,
			introduction: CompileTime.readMarkdownFile( '/examplecontent/mail/Introduction.md' ),
			examples: examples,
			baseUri: baseUri,
			active: "/examples/mail/"
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