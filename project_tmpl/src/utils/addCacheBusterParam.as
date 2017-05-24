package utils {
	/**
	 * @author Павел Гольцев
	 */
	public function addCacheBusterParam(url:String):String {
		var date:Date = new Date();
		url += (url.indexOf("?") == -1 ? "?" : "&") + "cacheBuster=" + date.getTime();
		return url;
	}
}
