# Haxe macros for working with JS npm externs

Macros utilities for making it easier/faster when working with npm libraries, such as [sequelize](http://docs.sequelizejs.com/).

NPM modules supported so far:

 - [sequelize](http://docs.sequelizejs.com/)

Haxe macros are particularly useful in generating boilerplate code from other code or configuration, allowing compiler type checking, and ensuring correct arguments in an otherwise runtime-only checked language (Javascript).

## [Sequelize](http://docs.sequelizejs.com/)

Generate the attributes for your models, so you can keep model variables type checked.

MyModel.hx:

	#if !macro
	import npm.sequelize.ModelInstance;
	#end

	extern class MyModel
	#if !macro
		extends ModelInstance<MyModel>
	#end
	{
		@db({allowNull: false, primaryKey: true})
		var id :String;
		@db({allowNull: false})
		var name :String;
		@db({type:'npm.Sequelize.JSONB'})
		var blob :SomeTypeDef;
	}


Then in your Sequelize initialization:

	var sequelize :Sequelize = new Sequelize(<your db config options>);

	var MyModel = sequelize.define('mymodel',
			SequelizeTools.ensureCorrectTypes(
				SequelizeMacros.getSequelizeFieldAttributes(MyModel)));

This will generate the model attributes defined in the [sequelize docs](http://docs.sequelizejs.com/manual/tutorial/models-definition.html).

This means you do not have to write separately the fields in the model configuration that are already specified in your model class. Writing the same thing in two places means a human has to validate something that should be the job of the compiler.

