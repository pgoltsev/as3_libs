package utils.colors {
	import flash.display.DisplayObject;
	
	/**
	 * Перекрашивает указанный клип в указанный цвет, используя для этого трансформацию цвета.
	 * 
	 * @author Павел Гольцев
	 * @param clp Клип, который необходимо перекрасить.
	 * @param color Цвет, в который необходимо перекрасить клип. Цвет задается строкой в шестнадцатиричном формате
	 * без префикса 0x.
	 * 
	 * @example Например, чтобы задать красный цвет, вызов функции необходимо производить так <br/>
	 * <code>setColorByHexString(clp, "ff0000");</code><br/>
	 * а не так <br/>
	 * <code>setColorByHexString(clp, "0xff0000");</code>
	 */
	public function setColorByHexString(clp:DisplayObject, color:String):void {
		setColor(clp, transformColorStringToNumber(color));
	}
}