extends "res://dictionaries.gd"

# Node with input text
onready var textBox = $TextEdit
# Node for animating eyes
onready var eyes_anim = $eyes_animated_sprite
# Node for animating mouth
onready var mouth_anim = $mouth_animated_sprite

# Timer and rng for blinking at random intervals of time
onready var timer_blink = $Timer
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_size = OS.get_screen_size(0)
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	create_timer(0.7, 1.7)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	OS.get_window_size()
	pass

# Function called on button press
func _on_Button_pressed():
	parse_and_play(textBox.text)

# Parses each character on 'TextEdit', plays audio and animates mouth based
# on input
func parse_and_play(text):
	for i in text:
		if(dict_translate.has(i)):
			var translate = dict_translate[i]
			# Playing sounds with SoundManager addon because creating
			# an audiostream manager is a pain in the ass
			SoundManager.play_bgm("res://sounds/" + translate + ".wav")
			mouth_anim.play(search_vowel_anim(i))
			# Wait until the audio finishes playing to continue
			yield(SoundManager.Audiostreams[0], "finished_playing")
		else:
			print("Character " + i + " not valid")
	yield(mouth_anim, "animation_finished")
	mouth_anim.play("idle")
	
# Gets vowel for each character (for example: ぱ->a, へ->e, ゆ ->u, and so on)
# This way we can animate the mouth based on specific vowels
func search_vowel_anim(character):
	for mouth_key in dict_mouth.keys():
		if character in mouth_key:
			return dict_mouth[mouth_key]
	return "idle"

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
