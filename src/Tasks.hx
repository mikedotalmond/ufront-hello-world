import haxe.rtti.Meta;
import haxe.web.Dispatch;
import ufront.auth.model.*;
import ufront.auth.*;
import sys.db.TableCreate;
import ufront.api.UFApi;
import sys.db.Manager;
import ufront.tasks.UFTaskSet;
import sys.FileSystem;
import sys.db.Mysql;
import ufront.mailer.*;
import tasks.*;
import app.Permissions;
import ufront.ufadmin.UFAdminPermissions;


/**
	This is our Command Line Interface (CLI) tool to help administer our web app.

	It's build on UFTaskSet, which itself builds upon the excellent MCLI library, see: <https://github.com/waneck/mcli>.
	The main thing we add is some dependency injection so we can inject all the things we need for our APIs to play nicely.
	In future, we'll also be able to run these through the ufadmin web interface, or even call tasks on remote servers from your development machine.
**/
class Tasks extends UFTaskSet
{
	/**
		This is the boilerplate to launch the CLI app.
		You could add / remove things as needed, the key line is `new Tasks().execute()`
	**/
	static function main() {
		// Only access the command line runner from the command line, not the web.
		if ( !neko.Web.isModNeko ) {

			// Connect to the database
			Manager.cnx = Mysql.connect(Config.server.db);

			// Set up the mailer
			var smtp = Config.server.smtp;
			var mailer = new SMTPMailer( smtp.host, smtp.port, smtp.user, smtp.pass );

			// Create our tasks, inject the useful things, turn on logging, execute.
			// I think I would like to change this in future to use something more similar to `ufront.web.UfrontConfiguration`.
			// Injection isn't compile-time checked and so this worries me slightly ;)
			var tasks = new Tasks()
				.inject( String, "../uf-content/", "contentDirectory" ) // the content directory in case we need to write to it
				.inject( UFAuthHandler, new YesBossAuthHandler() ) // this is an auth system that lets you do anything regardless of permissions, handy for CLI tools
				.inject( UFMailer, mailer ) // inject our mailer so we can send emails
				.useCLILogging( "log/ufront.log" ) // make sure traces go to both the log file and to `Sys.println`
			;
			for ( api in CompileTime.getAllClasses(UFApi) ) {
				tasks.inject( api );
			}
			tasks.execute( Sys.args() );
		}
	}

	public function new() super();

	/**
		Run the initial setup - create the database tables and add a user.
	**/
	public function setup( username:String, password:String ) {

		// Create the table for each database if it doesn't exist yet
		CompileTime.importPackage("app.model");
		CompileTime.importPackage("ufront.auth.model");
		for ( model in CompileTime.getAllClasses(sys.db.Object) ) {
			var meta = Meta.getType(model);
			var manager = Reflect.field(model,"manager");
			if ( Reflect.hasField(meta,"noTable")==false && manager!=null && TableCreate.exists(manager)==false ) {
				// It should have a table and it doesn't.  Let's create it.
				ufLog( 'Creating table '+Type.getClassName(model) );
				TableCreate.create( manager );
			}
		}

		// Set up the admin user
		var u = User.manager.select( $username==username );
		if ( u==null ) {
			ufLog( 'Creating user $username' );
			u = new User(username, password);
		}
		else {
			ufLog( 'Setting password for user $username' );
			u.setPassword( password );
		}
		u.save();

		ufLog( 'Granting permissions to user $username' );
		Permission.grantPermission( u, UFACanAccessAdminArea );
		Permission.grantPermission( u, CanViewSubscriberList );
	}
}
