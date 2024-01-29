extends Node2D

# All of the audio files.
# You will need to provide your own sound files.
var autopsy = preload("res://sound/music/1-Dark_Fantasy_Studio-_Autopsy_(seamless).ogg")
var prisma = preload("res://sound/music/9-Dark_Fantasy_Studio-_Prisma_(seamless).ogg")

@onready var audio_node = $"AudioStreamPlayer"

var sound_track = [autopsy, prisma]
var playback = AudioStreamPlayback
var track = 0

func _ready():
	#audio_node = $AudioStreamPlayer
	audio_node.finished.connect(play_next)
	play_music()

func play_music():
	audio_node.stream = sound_track[track]
	audio_node.play(0.0)

func play_next():
	track += 1
	if track >= sound_track.size():
		track = 0
	play_music()
	 
