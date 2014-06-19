package app;

import ufront.api.UFApiContext;

import app.api.*;

/**
	These APIs will be shared via remoting.

	@TODO: Document properly ;) 
	@TODO: Look at a bit of a refactor to support Async APIs more easily.
**/
class Api extends UFApiContext
{
	public var subscriptionApi:SubscriptionApi;
}
