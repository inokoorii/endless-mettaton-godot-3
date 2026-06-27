class_name AudioManagerAudioEntry
extends Reference


"CLASS SIGNALS"
signal audio_stream_changed
signal bus_changed


"CLASS CONSTANTS"
const BUS_INDEX_MASTER: int = 0


"CLASS REGULAR VARIABLES"
var audio_stream: AudioStream\
	setget set_audio_stream

var bus: String = AudioServer.get_bus_name(BUS_INDEX_MASTER)\
	setget set_bus


"CLASS PUBLIC METHODS (PROPERTY SETTERS)"
func set_audio_stream(value: AudioStream) -> void:
	audio_stream = value
	emit_signal("audio_stream_changed")


func set_bus(value: String) -> void:
	bus = value
	emit_signal("bus_changed")
