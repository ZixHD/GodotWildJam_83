extends Node

var dialog_data = {}
var speakers = {}

func load_dialog_data(path: String) -> void:
	print("file_path", path)
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		dialog_data = JSON.parse_string(content)
		speakers = dialog_data.keys()
	else:
		push_error("Failed to open dialogue file: %s" % path)
		

func get_message() -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	for speaker in dialog_data.keys():
		var messages = dialog_data[speaker]
		if messages is Array:
			for msg in messages:
				if msg is String:
					result.append({
						"speaker": speaker,
						"text": msg
					})
				else:
					push_warning("Unrecognized dialog entry for '%s': %s" % [speaker, str(msg)])
		else:
			push_warning("Value for key '%s' is not an array." % speaker)

	return result
