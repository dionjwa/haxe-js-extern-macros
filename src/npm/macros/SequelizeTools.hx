package npm.macros;

import haxe.DynamicAccess;
import haxe.Json;

import npm.sequelize.ColumnOptions;
import npm.Sequelize;
import npm.sequelize.DataType;

using Lambda;
using StringTools;

class SequelizeTools
{
	/**
	 * I haven't been able to get a compile-time macro to output the column
	 * type function calls (and defaultValue), so they have to get added at runtime.
	 * @param  obj :DynamicAccess<{type}> [description]
	 * @return     (attributes) : Dynamic<ColumnOptions>
	 */
	public static function ensureCorrectTypes(obj :Dynamic) :DynamicAccess<ColumnOptions>
	{
		var keys = Reflect.fields(obj);
		var sql = Sequelize;
		keys.iter(function(key) {
			var colOpts :{type:String,?defaultValue:String} = Reflect.field(obj, key);
			var typeString = colOpts.type;
			colOpts.type = cast getSequelizeTypeFromString(typeString);

			if (colOpts.defaultValue != null) {
				colOpts.defaultValue = cast getSequelizeTypeFromString(colOpts.defaultValue);
			}
		});
		return cast obj;
	}

	/**
	 * Converts a string to a Sequelize data type.
	 * @param  typeString :String       e.g. STRING(20) or CHAR(20, true)
	 * @return            Sequelize.DataType
	 */
	public static function getSequelizeTypeFromString(typeString :String) :DataType
	{
		//Ensure there are no package names
		typeString = typeString.split('.')[typeString.split('.').length - 1];
		var tokens = typeString.split('(');
		var type = tokens.shift();
		var parenthesesContent = tokens.join('');
		parenthesesContent = parenthesesContent.replace(')', '');
		var args :Array<Dynamic> = [];
		if (parenthesesContent.length > 0) {
			var parenthesesTokens = parenthesesContent.split(',').map(function(s) {
				return s.trim();
			});
			args = parenthesesTokens.map(function(s) {
				if (s != null && s.length > 0) {
					return Json.parse(s);
				} else {
					return null;
				}
			});
			args.filter(function(e) return e != null);
		}

		switch(type) {
			case 'STRING':
				switch(args.length) {
					case 0: return Sequelize.STRING();
					case 1: return Sequelize.STRING(args[0]);
					case 2: return Sequelize.STRING(args[0], args[1]);
					default: throw 'Too many arguments';
				}
			case 'CHAR':
				switch(args.length) {
					case 0: return Sequelize.CHAR();
					case 1: return Sequelize.CHAR(args[0]);
					case 2: return Sequelize.CHAR(args[0], args[1]);
					default: throw 'Too many arguments';
				}
			case 'INTEGER':
				switch(args.length) {
					case 0: return Sequelize.INTEGER();
					case 1: return Sequelize.INTEGER(args[0]);
					default: throw 'Too many arguments';
				}
			case 'BIGINT':
				switch(args.length) {
					case 0: return Sequelize.BIGINT();
					case 1: return Sequelize.BIGINT(args[0]);
					default: throw 'Too many arguments';
				}
			case 'FLOAT':
				switch(args.length) {
					case 0: return Sequelize.FLOAT();
					case 1: return Sequelize.FLOAT(args[0]);
					case 2: return Sequelize.FLOAT(args[0], args[1]);
					default: throw 'Too many arguments';
				}
			case 'DECIMAL':
				switch(args.length) {
					case 0: return Sequelize.DECIMAL();
					case 1: return Sequelize.DECIMAL(args[0]);
					case 2: return Sequelize.DECIMAL(args[0], args[1]);
					default: throw 'Too many arguments';
				}
			case 'TEXT':
				return Sequelize.TEXT();
			case 'NUMBER':
				return Sequelize.NUMBER();
			case 'BOOLEAN':
				return Sequelize.BOOLEAN();
			case 'TIME':
				return Sequelize.TIME();
			case 'DATE':
				return Sequelize.DATE();
			case 'DATEONLY':
				return Sequelize.DATEONLY();
			case 'HSTORE':
				return Sequelize.HSTORE();
			case 'JSON':
				return Sequelize.JSON();
			case 'JSONB':
				return Sequelize.JSONB();
			case 'NOW':
				return Sequelize.NOW();
			case 'BLOB':
				switch(args.length) {
					case 0: return Sequelize.BLOB();
					case 1: return Sequelize.BLOB(args[0]);
					default: throw 'Too many arguments';
				}
			case 'RANGE':
				switch(args.length) {
					case 1: return Sequelize.RANGE(args[0]);
					default: throw 'Too many arguments';
				}
			case 'UUID':
				return Sequelize.UUID();
			case 'UUIDV1':
				return Sequelize.UUIDV1();
			case 'UUIDV4':
				return Sequelize.UUIDV4();
			case 'VIRTUAL':
				return Sequelize.VIRTUAL();
			case 'ENUM':
				switch(args.length) {
					case 0: return Sequelize.ENUM();
					case 1: return Sequelize.ENUM(args[0]);
					case 2: return Sequelize.ENUM(args[0], args[1]);
					case 3: return Sequelize.ENUM(args[0], args[1], args[2]);
					case 4: return Sequelize.ENUM(args[0], args[1], args[2], args[3]);
					case 5: return Sequelize.ENUM(args[0], args[1], args[2], args[3], args[4]);
					case 6: return Sequelize.ENUM(args[0], args[1], args[2], args[3], args[4], args[5]);
					default: throw 'Need to increase ENUM arguments here';
				}
			case 'ARRAY':
				switch(args.length) {
					case 1: return Sequelize.ARRAY(args[0]);
					default: throw 'Too many arguments';
				}
			default: throw 'Unknown Sequelize type $type';
		}
	}
}