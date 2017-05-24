package utils.convert {

	/**
	 * Создает массив и заполняет его элементами из объекта XMLList.
	 * 
	 * @param list Объект, элементами которого нужно заполнить массив. 
	 * 
	 * @author Павел Гольцев
	 */
	public function createArrayOfXMLFromXMLList(list:XMLList):Array {
		var result:Array = new Array();
		
		if (list) {
			var num:uint = list.length();
			for (var i:uint = 0; i < num; i++) {
				result.push(list[i]);
			}
		}
		
		return result;
	}
}
