function event(params)
	if params.v[1] == "defaultCamZoom" then
		state.camZoom = tonumber(params.v[2])
	end
end
