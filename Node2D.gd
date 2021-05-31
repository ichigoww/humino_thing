extends Node2D

onready var textBox = get_node("TextEdit")
onready var player = get_node("player")
onready var eyes_anim = get_node("eyes_animated_sprite")
onready var mouth_anim = get_node("mouth_animated_sprite")

# Timer and rng for blinking at random intervals of time
onready var timer_blink = get_node("Timer")
var rng = RandomNumberGenerator.new()

# why dictionaries? less trouble (i think...)
var dict_gojuon = {}
var dict_mouth = {
	"あかがさざただなはばぱまやらわ": "a",
	"いきぎしじちぢにひびぴみり": "i",
	"うくぐすずつづぬふぶぷむゆる": "u",
	"えけげせぜてでねへべぺめれ": "e",
	"おこごそぞとどのほぼぽもよろを": "o",
	"ん": "n"
}

# TODO 1?: っ, some kind of pause before the next sound? maybe based on the starting
# consonant i could chop some audio and create a sound file for each case
# then i could throw it on the same dictionary and code the condition, looking
# ahead each time a っ is found
# something like
# change for -> while:
#	if i == "っ" or i == "ッ" and i+1 < len(text):
#		get next character
#		get the っ+next_character audio stream
#		play it

# TODO 2?: small characters? how the fuck am i gonna do that :thinking:

# TODO 3?: Katakana!!!!!11 this one should be easier? should i even bother though?
#	- to avoid having to recreate every fucking audio file, i'll just have a 
#	function that translates katakana to hiragana
#	- for this i need another dictionary that has every character and it's 
#	equivalent
#	- then, after translating i'll just replace the characters of
#	the original text :sunglasses:

# TODO 4?:
#	- make eyes move so it doesnt feel too static

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

# Parses each character on input text, and plays audio and animation
func parse_and_play(text):
	for i in text:
		if(dict_gojuon.has(i)):
			dict_gojuon[i].play()
			mouth_anim.play(search_vowel_anim(i))
			yield(dict_gojuon[i], "finished")
	yield(mouth_anim, "animation_finished")
	mouth_anim.play("idle")
	
# Gets vowel for current character, used for playing a mouth animation
func search_vowel_anim(character):
	for mouth_key in dict_mouth.keys():
		if character in mouth_key:
			return dict_mouth[mouth_key]
	return "idle"

# Load soundfiles from a path
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
