package utils.colors {
	import flash.geom.ColorTransform;
	import flash.display.DisplayObject;
	
	/**
	 * Перекрашивает указанный клип в указанный цвет, используя для этого трансформацию цвета.
	 * 
	 * @author Павел Гольцев
	 * @param clp Клип, который необходимо перекрасить.
	 * @param color Цвет, в который необходимо перекрасить клип.
	 */
	public function setColor(clp:DisplayObject, color:Number):void {
		var colorTrns:ColorTransform = new ColorTransform();
		if (!isNaN(color)) colorTrns.color = color;
		clp.transform.colorTransform = colorTrns;
	}
}