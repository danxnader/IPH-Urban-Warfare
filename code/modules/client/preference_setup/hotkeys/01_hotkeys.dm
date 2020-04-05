/datum/category_item/player_hotkeys_item/hotkeys
	name = "pAI"
	sort_order = 5

	var/datum/hotkeys/hotkey

/datum/category_item/player_hotkeys_item/ShowKeybindings(mob/user)
	// Create an inverted list of keybindings -> key
	var/list/user_binds = list()
	for(var/key in key_bindings)
		for(var/kb_name in key_bindings[key])
			user_binds[kb_name] += list(key)

	var/list/kb_categories = list()
	// Group keybinds by category
	for(var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		kb_categories[kb.category] += list(kb)

	var/HTML = "<style>label { display: inline-block; width: 200px; }</style><body>"
	HTML += "<br>"
	HTML += "<a href ='?_src_=prefs;preference=keybindings_done'>Close</a>"
	HTML += "<a href ='?_src_=prefs;preference=keybindings_reset'>Reset to default</a>"
	HTML += "<br><br>"
	for(var/category in kb_categories)
		HTML += "<h3>[category]</h3>"
		for(var/i in kb_categories[category])
			var/datum/keybinding/kb = i
			if(!length(user_binds[kb.name]))
				HTML += "<label>[kb.full_name]</label> <a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=["Unbound"]'>Unbound</a>"
				var/list/default_keys = focus_chat ? kb.hotkey_keys : kb.classic_keys
				if(LAZYLEN(default_keys))
					HTML += "| Default: [default_keys.Join(", ")]"
				HTML += "<br>"
			else
				var/bound_key = user_binds[kb.name][1]
				HTML += "<label>[kb.full_name]</label> <a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[bound_key]</a>"
				for(var/bound_key_index in 2 to length(user_binds[kb.name]))
					bound_key = user_binds[kb.name][bound_key_index]
					HTML += " | <a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[bound_key]</a>"
				if(length(user_binds[kb.name]) < MAX_KEYS_PER_KEYBIND)
					HTML += "| <a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name]'>Add Secondary</a>"
				var/list/default_keys = focus_chat ? kb.hotkey_keys : kb.classic_keys
				if(LAZYLEN(default_keys))
					HTML += "| Default: [default_keys.Join(", ")]"
				HTML += "<br>"

	HTML += "<br><br>"
	HTML += "<a href ='?_src_=prefs;preference=keybindings_done'>Close</a>"
	HTML += "<a href ='?_src_=prefs;preference=keybindings_reset'>Reset to default</a>"
	HTML += "</body>"

	winshow(user, "keybindings", TRUE)
	var/datum/browser/popup = new(user, "keybindings", "<div align='center'>Keybindings</div>", 500, 900)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "keybindings", src)

/datum/category_item/player_hotkeys_item/CaptureKeybinding(mob/user, datum/keybinding/kb, old_key)
	var/HTML = {"
	<div id='focus' style="outline: 0;" tabindex=0>Keybinding: [kb.full_name]<br>[kb.description]<br><br><b>Press any key to change<br>Press ESC to clear</b></div>
	<script>
	var deedDone = false;
	document.onkeyup = function(e) {
		if(deedDone){ return; }
		var alt = e.altKey ? 1 : 0;
		var ctrl = e.ctrlKey ? 1 : 0;
		var shift = e.shiftKey ? 1 : 0;
		var numpad = (95 < e.keyCode && e.keyCode < 112) ? 1 : 0;
		var escPressed = e.keyCode == 27 ? 1 : 0;
		var url = 'byond://?_src_=prefs;preference=keybindings_set;keybinding=[kb.name];old_key=[old_key];clear_key='+escPressed+';key='+e.key+';alt='+alt+';ctrl='+ctrl+';shift='+shift+';numpad='+numpad+';key_code='+e.keyCode;
		window.location=url;
		deedDone = true;
	}
	document.getElementById('focus').focus();
	</script>
	"}
	winshow(user, "capturekeypress", TRUE)
	var/datum/browser/popup = new(user, "capturekeypress", "<div align='center'>Keybindings</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "capturekeypress", src)
