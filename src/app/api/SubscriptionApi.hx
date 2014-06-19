package app.api;

import app.model.Subscription;
import app.Permissions;
using tink.CoreApi;

class SubscriptionApi extends ufront.api.UFApi {
	
	/**
		Subscribe a new email address to our newsletter.

		Rather than throw an error if something breaks, I'm going to use `tink.core.Outcome`.
		This forces me to take care of both the working and the not-working cases when I call this function, I can't ignore it.
		See <https://github.com/haxetink/tink_core#outcome>
	**/
	public function subscribe( email:String ):Outcome<Noise,String> {
		try {
			var existing = Subscription.manager.select( $email==email );
			if ( existing==null ) {
				// Yay, sign them up!
				var s = new Subscription();
				s.email = email;
				s.subscribed = true;
				s.save();
				return Success(Noise);
			}
			else if ( existing.subscribed==false ) {
				// They signed up once, but unsubscribed...
				var email = Config.app.supportEmail;
				return Failure( 'You were signed up once, but because you unsubscribed, we will need you to email $email to get back on the list.' );
			}
			else return Failure( 'The email address <strong>$email</strong> is already on our list!' );
		}
		catch ( e:Dynamic ) return Failure( 'We ran into a server error: $e' );
	}
	
	/**
		Unsubscribe a user.
	**/
	public function unsubscribe( email:String ):Outcome<Noise,String> {
		try {
			var existing = Subscription.manager.select( $email==email );
			if ( existing!=null ) {
				existing.subscribed = false;
				existing.save();
				return Success(Noise);
			}
			else return Failure( 'This address <strong>$email</strong> was not subscribed in the first place!' );
		}
		catch ( e:Dynamic ) return Failure( 'We ran into a server error: $e' );
	}
	
	/**
		Get the list
	**/
	public function getList():Outcome<List<Subscription>,String> {
		auth.requirePermission( CanViewSubscriberList );
		try {
			var subscriptions = Subscription.manager.search( $subscribed==true );
			return Success( subscriptions );
		}
		catch ( e:Dynamic ) return Failure( 'We ran into a server error: $e' );
	}
}
