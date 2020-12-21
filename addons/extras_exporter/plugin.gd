tool
extends EditorPlugin

class Exporter extends EditorExportPlugin:
	var build_path: String
	var build_dir: String

	var macos_build: bool

	func _export_begin(features, is_debug, path, flags):
		if OS.has_feature("Windows"):
			printerr("[Extras Exporter] Running on Windows; export of additional files disabled")
			return

		build_path = path
		build_dir = path.get_base_dir() + "/"
		macos_build = "OSX" in features

	func _export_end() -> void:
		if OS.has_feature("Windows"):
			return

		var include_files: PoolStringArray = ProjectSettings.get_setting(
			"extras_exporter/files_to_include")

		print("[Extras Exporter] Build directory: ", build_dir)

		var output = []

		OS.execute("pwd", [], true, output)
		print("[Extras Exporter] Working directory: ", output[0])

		for file in include_files:
			if macos_build:
				print("[Extras Exporter] Adding %s to macOS archive" % file)
				OS.execute("/usr/bin/zip", ["-rq", build_path, file], true, output, true)
			else:
				print("[Extras Exporter] Copying %s to build directory" % file)
				OS.execute("/usr/bin/cp", ["-fR", file, build_dir], true, output, true)
			for s in output:
					if !s.empty():
						printerr("[Extras Exporter] ", s)

		print("[Extras Exporter] Finished")

var exporter = Exporter.new()

func _enter_tree():
	add_export_plugin(exporter)
	if !ProjectSettings.has_setting("extras_exporter/files_to_include"):
		ProjectSettings.set_setting(
			"extras_exporter/files_to_include",
			PoolStringArray())
	ProjectSettings.set_initial_value(
		"extras_exporter/files_to_include",
		PoolStringArray())

func _exit_tree():
	remove_export_plugin(exporter)
