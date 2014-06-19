# Dependency Injection

Dependency injection lets a class say what it needs, and the injector provides it.

### Why would you use dependency injection?

* Benefits

	* Makes your code easy to test
	* It lets you change your mind later

* Example 1: Mail

	* If you want to send email, you might use SMTPMailer.
	* Later, you might change your mind and use an API service, like Mandrill, so you can track email open statistics etc.
	* If you hard coded to use SMTPMailer, you would need to change everywhere.
	* If instead you use "UFMailer", you could use SMTPMailer at first, and swap it for MandrillMailer later.
	* If you are running tests, and would rather not send any email, you could use NullMailer.
	* You can swap it as many times as you want from one place in your code, not many places.

* Example 2: Unit Testing

	* Let's say you have an API that tries to scrape data from a 3rd party website.
	* Sometimes your API works, but sometimes if the website is down, it might not work.
	* In your controller, you handle both cases - and show the result if it works, or a nice message if it fails.
	* You want to unit test your controller, and check it will work if the API is working or not working.
	* We can't control if the 3rd party website will work or not, so we create a "mock" API that can mock a success or a failure.
	* Because we injected the API, rather than hard code it, in our unit tests we can inject the mock API instead of the real one.
	* Then we can easily test if the controller works for all different values that the API might return.

* Example 3: Seamless API Remoting

	* This isn't ready yet, but this is something I want to implement:
	* You have an API in your app.
	* You can call this API on the server, or from the client, using remoting. 
	* In fact, you could call it from JS (browser) OR a Neko task client, both through remoting.
	* What if in your controller, you could say "Give me the MailAPI".
	* If you're on the server, it injects the MailAPI directly.
	* If you're on the client, it injects a MailAPI object that behaves the same, but uses remoting.
	* Then your controller works on server OR client, in the exact same way.

* Example 4: Writing a ufront library

	* Say you want to create a library "FileBrowser" that lets you browser the filesystem.
	* You want to limit it to only users with the "CanBrowseFS" permission.
	* You don't know which auth system the app will be using, so you just ask for a generic `UFAuthHandler` using `@inject public var auth:UFAuthHandler`
	* You then use `auth.requirePermission( CanBrowseFS );`
	* Your library will now work, even if the app they're building uses a different auth system to you.

### Injection in ufront

We use minject.

You set up your injector at the entry point to your app - for example in Server.hx.  You tell the application what mappings you want.

Some mappings are included by default:

* Controllers
* APIs
* "contentDirectory"
* "scriptDirectory"
* messages
* context
* auth

Then we have injection in the following places:

* Controller
* UFTaskSet
* UFApi
* Middleware? Handlers?
* ActionResults?
* You can access it through `context.injector` to perform injection manually.

### What it looks like

Mapping a value

Using injection from a controller or API

Manually getting an injection from `context.injector`

### Runtime safety

Sadly, dependency injection with minject doesn't provide compile time safety at this time - so if you ask for an object that isn't injected, you won't know about it until runtime, and it may result in errors in your app.

I'm trying to think of a macro solution to that problem.