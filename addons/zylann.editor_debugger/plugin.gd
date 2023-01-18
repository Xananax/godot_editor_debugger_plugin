@tool
extends EditorPlugin

const Dock := preload("res://addons/zylann.editor_debugger/dock.gd")
const DockScene: PackedScene = preload("res://addons/zylann.editor_debugger/dock.tscn")
var _dock: Dock = null


func _enter_tree() -> void:
	_dock = DockScene.instantiate()
	_dock.node_selected.connect(_on_EditorDebugger_node_selected)
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, _dock)
	
	var editor_settings := get_editor_interface().get_editor_settings()
	editor_settings.settings_changed.connect(_on_EditorSettings_settings_changed)
	call_deferred("_on_EditorSettings_settings_changed")


func _exit_tree() -> void:
	remove_control_from_docks(_dock)
	_dock.free()
	_dock = null


func _on_EditorDebugger_node_selected(node: Node) -> void:
	if _dock.is_inspection_enabled():
		# Oops.
		get_editor_interface().inspect_object(node)


func _on_EditorSettings_settings_changed() -> void:
	var editor_settings := get_editor_interface().get_editor_settings()
	
	var enable_rl := editor_settings.get_setting("docks/scene_tree/draw_relationship_lines")
	var rl_color := editor_settings.get_setting("docks/scene_tree/relationship_line_color")
	
	var tree := _dock.get_tree_view()
	
	if enable_rl:
		tree.add_theme_constant_override("draw_relationship_lines", 1)
		tree.add_theme_color_override("relationship_line_color", rl_color)
		tree.add_theme_constant_override("draw_guides", 0)
	else:
		tree.add_theme_constant_override("draw_relationship_lines", 0)
		tree.add_theme_constant_override("draw_guides", 1)
