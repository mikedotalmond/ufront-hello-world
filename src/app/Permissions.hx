package app;

/**
	Ufront's auth system uses an enum-based permission strategy.
	Basically, we create an enum value for each different permission we want to assign.
	Here I have a list of permissions for this app.
	You can have as many enums or as many enum constructors as you want.
	Enum constructors which have parameters are not supported.
	TODO: Document that whole feature ;)
**/
enum Permissions {
	CanViewSubscriberList;
}