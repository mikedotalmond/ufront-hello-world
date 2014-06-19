# Model

Ufront takes advantage of Haxe's macro-powered database system. This lets you create objects easily

### What a model looks like

```haxe
import ufront.db.Object;
import sys.db.Types;

class Favourite extends Object {

	// The name of the person. Will be a `VARCHAR(50)` column in the database.
	// We'll validate their name to make sure they only use regular A-Z letters.
	@:validate( ~/^[a-z]+$/i.match(name) )
	public var name:SString<50>;

	// Their favourite 32 bit `UNSIGNED INT`, because we all have one.
	public var number:SUInt;

	// Their favourite poem, in full. We'll use SText (`MEDIUMTEXT` in SQL).
	// This gives us 16MB, in case their poem is very long.
	public var poem:SText;

	// Their favourite color (from our enum of colours)
	public var color:SEnum<Color>;
}
```

### How to interact with a model

```haxe
var f = new Favourite();
f.name = "Jason";
f.number = 2048; // Love that game!
f.poem = "Roses are red, Haxe is orange. Man this poem sucks. I mustn't know many poems...";
f.color = Red;
f.save(); // You can also use f.insert() and f.update()

var allFavourites = Favourite.manager.all();
for ( f in allFavourites ) {
	trace( '${f.name} really likes the number ${f.number}' );
}

var favouritesWithRed = Favourite.manager.search( $color==Red );
var names = [ for (f in favouritesWithRed) f.name ];
trace( 'These people like red: '+names.join(", ") );

var jasonsFavourites = Favourite.manager.select( $name=="Jason" );
if ( jasonsFavourites!=null ) {
	jasonsFavourites.delete();
}

var favourite13 = Favourite.manager.get( 13 );
trace( 'Favourite 13 was: $favourite13' );
```

### Relationships between models

* BelongsTo
* HasOne
* HasMany
* ManyToMany

### Validation

```
@:validate( field.length>0 )
public var name:SString<255>;

@:validate( _.lenght>0 )
public var name:SString<255>;
```

* Automatic null validation.
* `validate_$fieldname()`
* `validate()`
* Validation errors

### Using UFAdmin to create / update your tables.

UFAdmin includes the "dbadmin" by Nicolas Cannasse for administering your database - it lets you browse around your database, and create or update your tables to match the models in your code.

It currently only works with MySQL.

Other platforms can create tables using `sys.db.TableCreate`.

### Supported platforms and databases



### Special metadata

* Changing the table name
* Creating an index

### Compiling to the client

* What works
* Transferring over remoting
* ClientDS