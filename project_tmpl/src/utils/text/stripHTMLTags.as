package utils.text {
	/**
	 * Удаляет все html-тэги из строки, кроме перечисленных.
	 * @param htmlText Текст, из которого нужно удалить тэги.
	 * @param tagsToBeKept Тэги, которые не нужно удалять.
	 * @author Павел Гольцев
	 */
	public function stripHTMLTags(htmlText:String, tagsToBeKept:Array = null):String {
		var tagsToKeep:Array;
		if (tagsToBeKept && tagsToBeKept.length > 0) {
			tagsToKeep = new Array();
			for (var i:int = 0; i < tagsToBeKept.length; i++) {
				if (tagsToBeKept[i] != null && tagsToBeKept[i] != "")
					tagsToKeep.push(tagsToBeKept[i]);
			}
		}

		var toBeRemoved:Array = new Array();
		var tagRegExp:RegExp = new RegExp("<([^>\\s]+)(\\s[^>]+)*>", "g");

		var foundedStrings:Array = htmlText.match(tagRegExp);
		for (i = 0; i < foundedStrings.length; i++) {
			var tagFlag:Boolean = false;
			if (tagsToKeep != null) {
				for (var j:int = 0; j < tagsToKeep.length; j++) {
					var tmpRegExp:RegExp = new RegExp("<\/?" + tagsToKeep[j] + "( [^<>]*)*>", "i");
					var tmpStr:String = foundedStrings[i] as String;
					if (tmpStr.search(tmpRegExp) != -1)
						tagFlag = true;
				}
			}
			if (!tagFlag) {
				toBeRemoved.push(foundedStrings[i]);
			}
		}
		for (i = 0; i < toBeRemoved.length; i++) {
			var tmpRE:RegExp = new RegExp("([\+\*\$\/])", "g");
			var tmpRemRE:RegExp = new RegExp((toBeRemoved[i] as String).replace(tmpRE, "\\$1"), "g");
			htmlText = htmlText.replace(tmpRemRE, "");
		}
		return htmlText;
	}
}
