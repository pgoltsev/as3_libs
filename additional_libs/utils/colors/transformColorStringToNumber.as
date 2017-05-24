package utils.colors {

	/**
	 * @author Павел Гольцев
	 */
	public function transformColorStringToNumber(color:String):Number {
		if (color.substr(0, 1) == "#") color = "0x" + color.substr(1);
		else if (color.substr(0, 2) != "0x")  color = "0x" + color;
			
		return Number(color);
	}
}
