DAME.SetFloatPrecision(0)

groups = DAME.GetGroups()
groupCount = as3.tolua(groups.length) -1

FileExt = as3.tolua(VALUE_FileExt)
csvDir = as3.tolua(VALUE_CSVDir)

laserstext = ""
movingtext = ""
dialogtext = ""
enemytext = ""
maptextz = "["
gamemode = "headrush"

--Output dialog
--text = DAME.CreateTextForShapes( layer:ShapeLayer, circleText:String, rectangleText:String, textText:String )

-- Output tilemap data

function exportMapCSV( mapLayer, layerFileName)
	-- get the raw mapdata. To change format, modify the strings passed in (rowPrefix,rowSuffix,columnPrefix,columnSeparator,columnSuffix)
	mapText = as3.tolua(DAME.ConvertMapToText(mapLayer,"","\n","",",",""))
	--print("output to "..as3.tolua(VALUE_CSVDir).."/"..layerFileName)
	DAME.WriteFile(csvDir.."/"..layerFileName, mapText);
end



for groupIndex = 0,groupCount do
	group = groups[groupIndex]
	groupName = as3.tolua(group.name)
	groupName = string.gsub(groupName, " ", "_")
	
	
	layerCount = as3.tolua(group.children.length) - 1
	
	
	
	-- Go through each layer and store some tables for the different layer types.
	for layerIndex = 0,layerCount do
		layer = group.children[layerIndex]
		isMap = as3.tolua(layer.map)~=nil
		layerSimpleName = as3.tolua(layer.name)
		layerSimpleName = string.gsub(layerSimpleName, " ", "_")
		
		if as3.tolua(layer.IsShapeLayer()) == true and as3.tolua(layer.name) == "Moving" then
			movingtext = string.sub(as3.tolua(DAME.CreateTextForShapes( layer, "", "", ',{"x":"%xpos%", "y":"%ypos%", "w":"%width%", "h":"%height%", "t":"%text%"}')),2)
		end
		
		if as3.tolua(layer.IsShapeLayer()) == true and as3.tolua(layer.name) ~= "Moving" then
			dialogtext = string.sub(as3.tolua(DAME.CreateTextForShapes( layer, "", "", ',{"x":"%xpos%", "y":"%ypos%", "w":"%width%", "h":"%height%", "t":"%text%"}')),2)
			-- DAME.WriteFile(csvDir.."/".."mapCSV_"..groupName.."_"..layerSimpleName.."."..FileExt, "["..dialogtext.."]")
		end
		
		if as3.tolua(layer.IsPathLayer()) == true then
			-- nodelist
			laserstext = string.sub(as3.tolua(DAME.CreateTextForPaths(layer, ",[%nodelist%]", '"%nodex%","%nodey%"',"", "", ",", "")),2)
			-- DAME.WriteFile(csvDir.."/".."mapCSV_"..groupName.."_"..layerSimpleName.."."..FileExt, "["..laserstext.."]")
		end
		
		if as3.tolua(layer.IsSpriteLayer()) == true then
		-- DAME.CreateTextForSprites( layer:SpriteLayer, defaultCreationText:String, defaultClass:String, bmpfontText:String = "", baseDirectory:String = null )
			enemytext = string.sub(as3.tolua(DAME.CreateTextForSprites(layer,',["%xpos%","%ypos%","%class%"%%if prop:direction%%,"%prop:direction%"%%endprop%%]',"ZBot")),2)
			-- DAME.WriteFile(csvDir.."/".."mapCSV_"..groupName.."_"..layerSimpleName.."."..FileExt, "["..enemytext.."]")
		end
		
		if isMap == true then
			-- mapFileName = "mapCSV_"..groupName.."_"..layerSimpleName.."."..FileExt
			-- Generate the map file.
			-- exportMapCSV( layer, mapFileName )
			mapText = as3.tolua(DAME.ConvertMapToText(layer,"","\n","",",",""))
			mapText = '"'..string.gsub(mapText,"\n",'\\n')..'"]'
			-- mapText = '"'..mapText..'"]'
			-- maptextz = maptextz..',["'..as3.tolua(DAME.GetTextForProperties("%prop:Tilemap%", layer.properties))..'",\n'..mapText
			if layerIndex == 0 then
				maptextz = maptextz..'["'..as3.tolua(DAME.GetTextForProperties("%prop:Tilemap%", layer.properties))..'",\n'..mapText
			end
			if layerIndex ~= 0 then
				maptextz = maptextz..',["'..as3.tolua(DAME.GetTextForProperties("%prop:Tilemap%", layer.properties))..'",\n'..mapText
				if as3.tolua(DAME.GetTextForProperties("%prop:gamemode%", layer.properties)) == "Collide" then
					gamemode = as3.tolua(DAME.GetTextForProperties("%prop:gamemode%", layer.properties))
				end
			end
		end
		
	end
end

lasertext = "["..laserstext.."]"
enemytext = "["..enemytext.."]"
movingtext = "["..movingtext.."]"
dialogtext = "["..dialogtext.."]"
mapname = as3.tolua(DAME.GetProjectName())

finaltext = "["..lasertext..',\n'..enemytext..',\n'..dialogtext..',\n'..maptextz..']'..',\n'..movingtext..',"'..gamemode..'","'..mapname..'"'

-- DAME.WriteFile(csvDir.."/".."level.z21", finaltext)
DAME.WriteFile(as3.tolua(DAME.GetProjectFileLocation()).."/"..as3.tolua(DAME.GetProjectName())..'.hr', finaltext.."]")


return 1
