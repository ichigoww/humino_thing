extends Node2D

onready var textBox = get_node("TextEdit")
onready var eyes_anim = get_node("eyes_animated_sprite")
onready var mouth_anim = get_node("mouth_animated_sprite")

# Timer and rng for blinking at random intervals of time
onready var timer_blink = get_node("Timer")
var rng = RandomNumberGenerator.new()

# Dictionary for character and audiostreams, used for playing audiofiles
var dict_gojuon = {}

# Dictionary for character vowels, used for mouth animations
var dict_mouth = {
	"あかがさざただなはばぱまやらわ": "a",
	"いきぎしじちぢにひびぴみり": "i",
	"うくぐすずつづぬふぶぷむゆる": "u",
	"えけげせぜてでねへべぺめれ": "e",
	"おこごそぞとどのほぼぽもよろを": "o",
	"ん": "n"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	print(textBox.get_font("font").get_font_data().font_path)
	load_sounds("res://sounds")
	create_timer(0.7, 1.7)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# Event for button
func _on_Button_pressed():
	parse_and_play(textBox.text)

# Parses each character on TextEdit control, and plays audio and mouth animation
func parse_and_play(text):
	for i in text:
		if(dict_gojuon.has(i)):
			dict_gojuon[i].play()
			mouth_anim.play(search_vowel_anim(i))
			yield(dict_gojuon[i], "finished")
	yield(mouth_anim, "animation_finished")
	mouth_anim.play("idle")
	
# Gets the vowel animation for each character, so the corresponding animation
# can be played
func search_vowel_anim(character):
	for mouth_key in dict_mouth.keys():
		if character in mouth_key:
			return dict_mouth[mouth_key]
	return "idle"

# Load soundfiles from a specific path
# (I don't know what happens if there's something else that's not an audio file
# in the specified path, so yes, this isn't very good)
func load_sounds(path):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				var key = file_name.split(".")
				if len(key) == 2:
					var speech_player = AudioStreamPlayer.new()
					get_node("/root/Node2D").add_child(speech_player)
					speech_player.stream = load(path + "/" + file_name)
					speech_player.volume_db = -12.0
					dict_gojuon[key[0]] = speech_player
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	pass

# When timer runs out, play blink animation and start another countdown
func _on_Timer_timeout():
	eyes_anim.play("blink")
	yield(eyes_anim, "animation_finished")
	eyes_anim.stop()
	create_timer(0.7, 1.7)
	
# Creates timer with a random time betwen a lower and upper bound
func create_timer(lower, upper):
	rng.randomize()
	timer_blink.start(rng.randf_range(lower, upper))
