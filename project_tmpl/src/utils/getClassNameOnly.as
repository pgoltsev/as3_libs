package utils {
	import flash.utils.getQualifiedClassName;

	/**
	 * Возращает строку с именем класса объекта.
	 * @param classObject Класс, интерфейс или любой другой объект.
	 * @return Имя класса без пакета.
	 * @author Павел Гольцев
	 */
	public function getClassNameOnly(classObject:*):String {
		var splitArray:Array = getQualifiedClassName(classObject).split("::");
		return splitArray[splitArray.length - 1];
	}
}
