# haxe-js-extern-macros

Macros utilities for making it easier/faster when working with npm libraries.

## [Sequelize](http://docs.sequelizejs.com/)

Generate the attributes for your models

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

