package npm.macros;

import haxe.DynamicAccess;

import npm.sequelize.ColumnOptions;
import npm.Sequelize;

using Lambda;
using StringTools;

class SequelizeTools
{
	/**
	 * I haven't been able to get a compile-time macro to output the column
	 * type function calls, so they have to get added at runtime.
	 * @param  obj :DynamicAccess<{type}> [description]
	 * @return     [description]
	 */
	public static function ensureCorrectTypes(obj :Dynamic) :DynamicAccess<ColumnOptions>
	{
		var keys = Reflect.fields(obj);
		var sql = Sequelize;
		keys.iter(function(key) {
			var colOpts = Reflect.field(obj, key);
			var typeString :String = untyped colOpts.type;
			var type = typeString.replace('()', '').replace(';', '').split('.').pop();
			if (Reflect.field(sql, type) == null) {
				throw 'Failed to get Sequelize type: "${type}"';
			}
			colOpts.type = Reflect.callMethod(sql, Reflect.field(sql, type), []);
		});
		return cast obj;
	}
}