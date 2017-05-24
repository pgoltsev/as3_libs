package utils.text {
	import org.casalib.util.TextFieldUtil;

	import flash.text.TextField;

	/**
	 * @author Павел Гольцев
	 */
	public function removeOverFlow(field:TextField, omissionIndicator:String = "..."):String {
		if (!TextFieldUtil.hasOverFlow(field)) return '';

		omissionIndicator ||= '';

		var originalCopy:String = field.text;
		var lines:Array = field.text.split('. ');
		var isStillOverflowing:Boolean = false;
		var words:Array;
		var lastSentence:String;
		var sentences:String;
		var overFlow:String;

		while (TextFieldUtil.hasOverFlow(field)) {
			lastSentence = String(lines.pop());
			field.text = (lines.length == 0) ? '' : lines.join('. ') + '. ';
		}

		sentences = (lines.length == 0) ? '' : lines.join('. ') + '. ';
		words = lastSentence.split('');
		field.appendText(lastSentence);

		while (TextFieldUtil.hasOverFlow(field)) {
			if (words.length == 0) {
				isStillOverflowing = true;
				break;
			} else {
				words.pop();

				if (words.length == 0)
					field.text = sentences.substr(0, -1) + omissionIndicator;
				else
					field.text = sentences + words.join('') + omissionIndicator;
			}
		}

		if (isStillOverflowing) {
			words = field.text.split('');

			while (TextFieldUtil.hasOverFlow(field)) {
				words.pop();
				field.text = words.join('') + omissionIndicator;
			}
		}

		overFlow = originalCopy.substring(field.text.length);

		return (overFlow.charAt(0) == '') ? overFlow.substring(1) : overFlow;
	}
}
