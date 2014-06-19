package app.model;

import ufront.db.Object;
import sys.db.Types;

/**
	This model describes a "Subscription" which gets saved to our database.

	`ufront.db.Object` is very similar to `sys.db.Object`, which has some documentation here: <http://old.haxe.org/manual/spod>

	The main difference here is that this code will compile on the server AND the client.
	It will also serialize and deserialize nicely between the two, so you can use it with remoting.
	
	We've also added some nice add-ons, like relationships, for example, a `User` model may have these relationships:

	- var group:BelongsTo<Group>
	- var post:HasMany<Post>
	- var profile:HasOne<UserProfile>
	- var itemsPurchased:ManyToMany<User,Product>

	Finally, we have some added macro magic, such as @:validate metadata.
	This won't save to the DB unless all your validations pass.
	(If you're wondering, an _ in the validation refers to the current field.  You could also type it out in full.)
**/
class Subscription extends Object
{
	/** Fairly naive email checker taken from the Haxe Manual. **/
	static var emailRegex = ~/[A-Z0-9._%-]+@[A-Z0-9.-]+.[A-Z][A-Z][A-Z]?/i;

	/** Store the email address. Column in database only holds 255. We have some validation magic too. **/
	@:validate( _.length<255 && emailRegex.match(_), "Please enter a valid email address less than 255 characters long." )
	public var email:SString<255>;

	/** Rather than delete a user when they unsubscribe, we'll flag them. This way we can make sure someone doesn't sign up with their email again by accident. **/
	public var subscribed:Bool;

	public var name:SString<20>;
	public var date:SDate;
}