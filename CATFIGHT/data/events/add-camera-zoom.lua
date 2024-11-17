function event(params)
	if params.v[1] ~= "" then
		game.camera.zoom = game.camera.zoom + tonumber(params.v[1])
	end
	if params.v[2] ~= "" then
		state.camHUD.zoom = state.camHUD.zoom + tonumber(params.v[2])
		state.camNotes.zoom = state.camHUD.zoom
	end
end
