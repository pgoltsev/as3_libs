package utils.clone {
	import flash.net.URLRequest;

	/**
	 * @author Павел Гольцев
	 */
	public function cloneURLRequest(request:URLRequest):URLRequest {
		var result:URLRequest = new URLRequest(request.url);
		result.contentType = request.contentType;
		result.data = request.data;
		result.digest = request.digest;
		result.method = request.method;
		if (request.requestHeaders) result.requestHeaders = request.requestHeaders.slice();
		// это для AIR
		if (request.hasOwnProperty("authenticate")) result["authenticate"] = request["authenticate"];
		if (request.hasOwnProperty("cacheResponse")) result["authenticate"] = request["cacheResponse"];
		if (request.hasOwnProperty("followRedirects")) result["followRedirects"] = request["followRedirects"];
		if (request.hasOwnProperty("manageCookies")) result["manageCookies"] = request["manageCookies"];
		if (request.hasOwnProperty("useCache")) result["useCache"] = request["useCache"];
		if (request.hasOwnProperty("userAgent")) result["userAgent"] = request["userAgent"];
		// -------------------------
		return result;
	}
}
