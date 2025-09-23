extends Control

# To review data in JSON DATA
# Press: Windows + R
# Type: %APPDATA%\Godot\app_userdata\

# Node references - using RichTextLabel instead of ItemList
@onready var habit_display: RichTextLabel
@onready var habit_input: LineEdit
@onready var add_button: Button
@onready var save_button: Button
@onready var load_button: Button

var habits_data = []
const SAVE_FILE = "user://habits.save"

func _ready():
	habit_display = $VBoxContainer/ScrollContainer/RichTextLabel
	habit_input = $VBoxContainer/HBoxContainer/LineEdit
	add_button = $VBoxContainer/HBoxContainer/ButtonAdd
	save_button = $VBoxContainer/HBoxContainer/ButtonSave
	load_button = $VBoxContainer/HBoxContainer/ButtonLoad
	
	# Debug: Check if nodes were found
	print("RichTextLabel found: ", habit_display != null)
	
	# Connect button signals
	add_button.pressed.connect(_on_add_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	
	# Load existing data
	load_habits()
	
	# Test display
	update_habit_display()
	
# stip_edge to remove white SPACEEE!
func _on_add_button_pressed():
	var habit_text = habit_input.text.strip_edges()
	
	if habit_text == "":
		print("Empty habit text - returning")
		return
	
	# Get current date/time
	var datetime = Time.get_datetime_dict_from_system()
	var date_string = "%s %s %02d %02d:%02d:%02d PDT %d" % [
		get_day_name(datetime.weekday),
		get_month_name(datetime.month),
		datetime.day,
		datetime.hour,
		datetime.minute,
		datetime.second,
		datetime.year
	]
	
	print("Adding habit: ", habit_text, " at: ", date_string)
	
	# Add to data array
	var habit_entry = {"habit": habit_text, "date": date_string}
	habits_data.append(habit_entry)
	
	print("Total habits now: ", habits_data.size())
	
	# Update the display
	update_habit_display()
	
	# Clear input field
	habit_input.text = ""
	
	# Auto-save
	save_habits()

func update_habit_display():
	print("=== UPDATING HABIT DISPLAY ===")
	print("Number of habits to display: ", habits_data.size())
	
	var text = "[center][b][font_size=18]Habit List[/font_size][/b][/center]\n\n"
	
	if habits_data.size() == 0:
		text += "[center][i]No habits yet. Add one below![/i][/center]"
	else:
		for i in range(habits_data.size()):
			var entry = habits_data[i]
			text += "[b]" + str(i + 1) + ". " + entry.habit + "[/b]\n"
			text += "[color=gray][font_size=12]" + entry.date + "[/font_size][/color]\n\n"
	
	habit_display.text = text
	print("Display updated with text: ", text.substr(0, 100), "...")
	print("=========================")

func _on_save_button_pressed():
	save_habits()

func _on_load_button_pressed():
	load_habits()

func save_habits():
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(habits_data)
		file.store_string(json_string)
		file.close()
		print("Habits saved successfully!")
	else:
		print("Error: Could not save habits")

func load_habits():
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				habits_data = json.data
				update_habit_display()
				print("Habits loaded successfully!")
			else:
				print("Error parsing saved data")
		else:
			print("Error: Could not load habits file")
	else:
		print("No save file found - starting fresh")
		

func get_day_name(day_index):
	var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	return days[day_index]

func get_month_name(month_index):
	var months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun","Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	return months[month_index]
