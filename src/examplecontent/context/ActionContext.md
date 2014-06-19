## ActionContext

An ActionContext holds information about which action was executed during the current request.  It is used in [ActionResult](http://ufront.net/api/ufront/web/result/ActionResult.html), for example our ViewResult class uses it to find a view file automatically based on which controller and action were executed.  

It is also helpful to log which actions have occured or when unit testing, to check that certain requests acted in the way we would expect.

See the [ActionContext API documentation](http://ufront.net/api/ufront/web/context/ActionContext.html).