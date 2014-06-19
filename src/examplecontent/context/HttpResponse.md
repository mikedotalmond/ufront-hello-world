## HttpResponse

A HttpResponse object is responsible for writing the output of a request back to the client. It can send back text, html, JSON, a redirect, some cookies, binary data, or anything that is a valid HTTP response.  Each platform must implement the "flush()" method, which takes all the response data and actually writes it to the client.

See the [HttpResponse API documentation](http://ufront.net/api/ufront/web/context/HttpResponse.html).