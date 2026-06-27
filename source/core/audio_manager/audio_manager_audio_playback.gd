class_name AudioManagerAudioPlayback
extends Reference


"CLASS SIGNALS"
signal audio_played
signal audio_stopped
signal audio_finished

signal bus_changed


"CLASS CONSTANTS"
const BUS_INDEX_MASTER: int = 0


"CLASS REGULAR VARIABLES"
# TODO: Expose more properties from `AudioStreamPlayer`.
var bus: String = AudioServer.get_bus_name(BUS_INDEX_MASTER)\
	setget set_bus

var _audio_stream_player: AudioStreamPlayer


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _init(audio_stream_player: AudioStreamPlayer) -> void:
	_audio_stream_player = audio_stream_player
	
	if not is_instance_valid(_audio_stream_player):
#		TODO: Push an error message here, probably.
		return
	
	_audio_stream_player.connect("finished", self, "_on_audio_stream_player_finished")
	bus = _audio_stream_player.bus


"CLASS PUBLIC METHODS"
func play(from_position: float = 0.0) -> void:
	if not is_instance_valid(_audio_stream_player):
		push_error(str(
			"AudioManagerAudioPlayback: Cannot call method 'play()' on '_audio_stream_player'; ",
			"node is null or has been freed."
		))
		return
	
	_audio_stream_player.play(from_position)
	emit_signal("audio_played")


func seek(to_position: float) -> void:
	if not is_instance_valid(_audio_stream_player):
		push_error(str(
			"AudioManagerAudioPlayback: Cannot call method 'seek()' on '_audio_stream_player'; ",
			"node is null or has been freed."
		))
		return
	
	_audio_stream_player.seek(to_position)


func stop() -> void:
	if not is_instance_valid(_audio_stream_player):
		push_error(str(
			"AudioManagerAudioPlayback: Cannot call method 'stop()' on '_audio_stream_player'; ",
			"node is null or has been freed."
		))
		return
	
	_audio_stream_player.stop()
	emit_signal("audio_stopped")


"CLASS PRIVATE METHODS (SIGNAL CONNECTIONS)"
func _on_audio_stream_player_finished() -> void:
	emit_signal("audio_finished")


"CLASS PUBLIC METHODS (PROPERTY SETTERS)"
func set_bus(value: String) -> void:
	bus = value
	
	if not is_instance_valid(_audio_stream_player):
		push_error(str(
			"AudioManagerAudioPlayback: Cannot set member '_audio_stream_player.bus'; ",
			"node is null or has been freed."
		))
		return
	
	_audio_stream_player.bus = bus
	emit_signal("bus_changed")
