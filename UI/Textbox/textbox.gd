extends CanvasLayer

@onready var textbox_container: MarginContainer = $TextboxContainer
@onready var label: Label = $TextboxContainer/MarginContainer/HBoxContainer/Label
@onready var start_symbol: Label = $TextboxContainer/MarginContainer/HBoxContainer/Start
@onready var end_symbol: Label = $TextboxContainer/MarginContainer/HBoxContainer/End

const LOWRES_PIXEL_REGULAR = preload("res://Assets/Font/LowresPixel-Regular.otf")



const CHAR_READ_RATE = 0.05

enum State{
	READY,
	READING,
	FINISHED
}

var current_state = null
var text_queue = []
var active_tween = null
var speaker: String = ""
var text: String = ""
var font_flag: bool = false;
signal dialog_started
signal dialog_finished
# Called when the node enters the scene tree for the first time.
func _ready():
	hide_textbox()
	current_state = State.READY

func _update_state():
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				display_text()
				emit_signal("dialog_started")
			pass
		State.READING:
			if Input.is_action_just_pressed("enter"):
				label.visible_characters = len(label.text)
				if active_tween != null:
					active_tween.stop() 
				end_symbol.text = "v"
				change_state(State.FINISHED)
			pass
		State.FINISHED:
			if Input.is_action_just_pressed("enter"):
				change_state(State.READY)
				hide_textbox()
				if(text_queue.is_empty()):
					emit_signal("dialog_finished")
					
			pass	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_update_state()

func set_font() ->void:
	start_symbol.add_theme_font_override("font", LOWRES_PIXEL_REGULAR)
	label.add_theme_font_override("font", LOWRES_PIXEL_REGULAR)
	
func queue_text(new_text):
	if(current_state != State.FINISHED):
		text_queue.push_back(new_text)
		
	
func hide_textbox():
	start_symbol.text = ""
	end_symbol.text = ""
	label.text = ""
	textbox_container.hide()

func show_textbox():
	start_symbol.text = speaker
	textbox_container.show()

	
func display_text():
	
	var next_text = str(text_queue.pop_front())
	parse_json(next_text)
	label.text = text
	change_state(State.READING)
	show_textbox() 
	active_tween = get_tree().create_tween()
	active_tween.tween_property(label, "visible_characters", len(text), len(text) * CHAR_READ_RATE).from(0).finished
	active_tween.connect("finished", Callable(self, "on_tween_finished"))
	end_symbol.text = "..."
	
func parse_json(json) -> void:
	var parsed = JSON.parse_string(json)
	if typeof(parsed) == TYPE_DICTIONARY:
		speaker = parsed["speaker"]
		text = parsed["text"]
	else:
		push_error("Failed to parse JSON.")
		
func on_tween_finished():
	print("finished tween")
	end_symbol.text = "<-"
	change_state(State.FINISHED)

	
func change_state(next_state):
	current_state = next_state
	
func start_dialog():
	current_state = State.READY
