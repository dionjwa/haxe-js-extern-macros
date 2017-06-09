package npm.macros;

import haxe.DynamicAccess;
import haxe.rtti.Meta;

import Type in StdType;
import haxe.macro.Expr;

import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.ComplexTypeTools;
import haxe.macro.TypeTools;
import haxe.macro.MacroStringTools;
import haxe.macro.Printer;

using StringTools;
using Lambda;

class SequelizeMacros
{
	inline static var DB = 'db';

	/**
	 * Get sequelize fields and parameters from metadata decorated properties
	 * on an extern class. Runtime metadata doesn't work on extern classes
	 * so it has to be processed with compile-time macros.
	 * @param  classExpr    Class type
	 * @return              http://docs.sequelizejs.com/manual/tutorial/models-definition.html
	 */
	macro public static function getSequelizeFieldAttributes(classExpr: Expr)
	{
		var pos = haxe.macro.Context.currentPos();

		var className = util.macros.MacroUtil.getClassNameFromClassExpr(classExpr);

		var rpcType = haxe.macro.Context.getType(className);
		var fields = [];
		switch(rpcType) {
			case TInst(t, params):
				fields = fields.concat(t.get().fields.get());
			default:
		}

		var sequelizeAttributes :haxe.DynamicAccess<Dynamic> = {};

		for (field in fields) {
			if (field.meta.has(DB)) {
				var fieldParams :haxe.DynamicAccess<Dynamic> = {};
				sequelizeAttributes[field.name] = fieldParams;
				var meta = field.meta.extract(DB).find(function(x) return x.name == DB);
				if (meta.params != null) {
					for (param in meta.params) {
						switch(param.expr) {
							case EObjectDecl(expr):
								for (metaObjectField in expr) {
									if (metaObjectField.field == 'type') {
										switch(metaObjectField.expr.expr) {
											case EConst(c):
												switch(c) {
													case CString(v):
														fieldParams['type'] = $i{v};
													default:
														Context.error('The "type" value must be a string that will become a code expression', pos);
												}
											default: trace(metaObjectField.expr.expr);
										}
									} else if (metaObjectField.field == 'defaultValue') {
										switch(metaObjectField.expr.expr) {
											case EConst(c):
												switch(c) {
													case CString(v):
														fieldParams['defaultValue'] = $e{v};
													default:
														Context.error('The "defaultValue" value must be a string that will become a code expression', pos);
												}
											default: trace(metaObjectField.expr.expr);
										}
									} else  {
										switch(metaObjectField.expr.expr) {
											case EConst(c):
												switch(c) {
													case CInt(v),CFloat(v),CString(v),CIdent(v): fieldParams[metaObjectField.field] = v;
													default: Context.error('@db{ ${metaObjectField.field}:?} is not not one of [Int|Float|String|Bool], not sure what it should be', pos);
												}
											case EArrayDecl(a):
												var newArr = [];
												fieldParams[metaObjectField.field] = newArr;
												for (e in a) {
													switch(e.expr) {
														case EConst(c):
															switch(c) {
																case CInt(v),CFloat(v),CString(v),CIdent(v): newArr.push(v);
																default: Context.error('@db{ ${metaObjectField.field}:[${c}]} is not one of [Int|Float|String|Bool], not sure what it should be', pos);
															}
														default: Context.error('@db{ ${metaObjectField.field}:?} is not one of [Int|Float|String|Bool], not sure what it should be', pos);
													}
												}
											default: Context.error('@db{ ${metaObjectField.field}:?} is not one of [Int|Float|String|Bool], not sure what it should be ${metaObjectField.expr.expr}', pos);
										}
									}
								}
							default:
								Context.error('Expecting an object {}', pos);
						}
					}
				}
				if (!fieldParams.exists('type')) {
					switch(TypeTools.follow(field.type)) {
						case TInst(type, params):
							switch(type.get().name) {
								case 'String': fieldParams['type'] = $e{'npm.Sequelize.STRING()'};
								case 'Date': fieldParams['type'] = $e{'npm.Sequelize.DATE()'};
								case 'Bool': fieldParams['type'] = $e{'npm.Sequelize.BOOLEAN()'};
								case 'Int': fieldParams['type'] = $e{'npm.Sequelize.INTEGER()'};
								case 'Float': fieldParams['type'] = $e{'npm.Sequelize.DECIMAL()'};
								default: Context.error('@db{ type:?} is not one of [Int|Float|String|Bool], cannot infer type ${field.name}', pos);
							}
						default: Context.error('"@db{ type:?} var ${field.name}" is not one of [Int|Float|String|Bool], cannot infer type', pos);
					}
				}
			}
		}
		return macro $v{sequelizeAttributes};
	}
}
