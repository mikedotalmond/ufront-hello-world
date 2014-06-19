# Context

Almost every web app is based on HTTP requests: somebody, using a browser, makes a Http Request - they ask a server for a page.  In return, the server offers a Http Response - some content to send back to the client.  Client requests, server responds, client requests, server responds - this is the life cycle of a web app.  

In Ufront, we wrap this combination of request and response, as well as some data about what ufront is doing with each request and response, into a *context*.  