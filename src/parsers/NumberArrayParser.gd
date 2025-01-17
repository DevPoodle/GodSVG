# A parser for compressed number arrays, used in TransformListParser and PathDataParser.
class_name NumberArrayParser extends RefCounted

var compress_numbers: bool
var minimize_spacing: bool

static func basic_num_to_text(num: float, precision := 4) -> String:
	var text := String.num(num, precision)
	if text == "-0":
		text = "0"
	return text

func num_to_text(num: float, precision := 4) -> String:
	var text := String.num(num, precision)
	if compress_numbers:
		if text.begins_with("0."):
			text = text.right(-1)
		elif text.begins_with("-0."):
			text = text.erase(1)
	if text == "-0":
		text = "0"
	return text

func numstr_arr_to_text(numstr_arr: Array[String]) -> String:
	var output := ""
	for i in numstr_arr.size() - 1:
		var current_numstr := numstr_arr[i]
		var next_char := numstr_arr[i + 1][0]
		output += current_numstr
		if not minimize_spacing or not (("." in current_numstr and next_char == ".") or\
		next_char in "-+"):
			output += " "
	return output + numstr_arr.back()
