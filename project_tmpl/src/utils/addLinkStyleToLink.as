package utils {
	/**
	 * @author Павел Гольцев
	 */
	public function addLinkStyleToLink(text:String, color:Number = -1):String {
		if (color < 0) color = 0x0066FF;
		text = text.split("<a ").join("<u><font color=\"#" + color.toString(16) + "\"><a ");
		text = text.split("</a>").join("</a></font></u>");
		return text;
	}
}
