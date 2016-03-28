-- fingerPaint Library for Corona SDK v1.5
-- Copyright (c) 2015 Jason Schroeder
-- http://www.jasonschroeder.com
-- http://www.twitter.com/schroederapps

--[[ Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. ]]--

------------------------------------------------------------------------------------
-- HOW TO USE THIS MODULE
------------------------------------------------------------------------------------
-- Step One: put this lua file in your project's root directory
-- Step Two: require the module in your project as such:
	-- local fingerPaint = require("fingerPaint")
-- Step Three: create a finger painting "canvas" object as such:
	-- local canvas = fingerPaint.newCanvas()
	-- You can customize your canvas by including a single table as an argument when calling fingerPaint.newCanvas(). The table can include any of the following key/value pairs (but none are required):
		-- width: the width of your canvas. Defaults to the full screen width.
		-- height: the height of your canvas. Defaults to the full screen height.
		-- strokeWidth: the width of your fingerpainting "strokes," or the lines that the user draws. Defaults to 10 pixels.
		-- canvasColor: a table containing 4 numbers between 0 and 1, representing the RBGA values of your canvas' background color. Defaults to {1, 1, 1, 1} (white). TIP: Set the 4th value to 0 for a canvas with a transparent background.
		-- paintColor: a table containing 4 numbers between 0 and 1, representing the RBGA values of the "paint" color. Defaults to {0, 0, 0, 1} (black).
		-- segmented: a boolean (true/false) that, when set to true, results in paint strokes that are comprised of separate line object segments. USE WITH CAUTION: setting this value to true can substantially increase the memory usage of your app. Defaults to false.
		-- x: the x coordinate where you want your canvas to be placed. Defaults to the horizontal center of the screen.
		-- y: the y coordinate where you want your canvas to be placed. Defaults to the vertical center of the screen.
		-- isActive: a boolean (true/false) that disables painting when set to false, and enables painting when set to true. Defaults to true.
		
-- Step Four: you can adjust the behavior of your finger painting canvas using the following methods:
	-- canvas:setPaintColor() will change the paint color for all future paint strokes (older paint strokes will be unaffected). You must pass a single table into the function containing 4 numbers between 0 and 1, representing the RBGA values of the new paint color.
	-- canvas:setCanvasColor() will change the canvas' background color. You must pass a single table into the function containing 4 numbers between 0 and 1, representing the RBGA values of the new background color. TIP: Set the 4th value to 0 for a canvas with a transparent background.
	-- canvas:setStrokeWidth() will change the width of future paint strokes (older paint strokes will be unaffected). You must pass a single number into the function, representing the new stroke width.
	-- canvas:undo() will remove existing paint strokes, in reverse order, one at a time.
	-- canvas:redo() will restore "undone" paint strokes, in the order in which they were created, one at a time.
	-- canvas:erase() will remove all paint strokes from the canvas. It cannot be undone.
	-- canvas.isActive is a boolean (true/false) property of the canvas object that can be changed as needed to enable or disable painting.

------------------------------------------------------------------------------------
-- CREATE TABLE TO HOLD MODULE
------------------------------------------------------------------------------------
local fingerPaint = {}

------------------------------------------------------------------------------------
-- CREATE NEW FINGERPAINT CANVAS
------------------------------------------------------------------------------------
function fingerPaint.newCanvas(...)
	-- available params are: width, height, strokeWidth, canvasColor, paintColor, segmented, x, y, isActive
	local arguments = {...}
	local params = arguments[1]
	if params == nil then params = {} end

	--print(params.group)
	--print(params.scrollView)
	--print(params.scrollView.isLocked)

	local group = params.group
	local scrollView = params.scrollView
	--local view = scrollView:getView() 

	local statusBar = params.statusBar
	local lineFilter = { categoryBits=2, maskBits=5 } 

	--------------------------------------------------------------------------------
	-- LOCALIZE PARAMS & SET DEFAULTS
	--------------------------------------------------------------------------------
	local width = params.width or _W
	local height = params.height or _H
	local strokeWidth = params.strokeWidth or 10
	local canvasColor = params.canvasColor or {1, 1, 1, 1}
		if canvasColor[4] == nil then canvasColor[4] = 1 end
		local canvasR = canvasColor[1]
		local canvasG = canvasColor[2]
		local canvasB = canvasColor[3]
		local canvasA = canvasColor[4]
	local paintColor = params.paintColor or {0, 0, 0, 1}
		if paintColor[4] == nil then paintColor[4] = 1 end
		local paintR = paintColor[1]
		local paintG = paintColor[2]
		local paintB = paintColor[3]
		local paintA = paintColor[4]
	local segmented = params.segmented or false
	local x = params.x or centerX
	local y = params.y or centerY
	local isActive = params.isActive or true
	local circleRadius = strokeWidth * .5
	local alphaFactor = .5
	local yMin = y - .5*height
	local yMax = y + .5*height
	
	--------------------------------------------------------------------------------
	-- CREATE CANVAS CONTAINER OBJECT
	--------------------------------------------------------------------------------

	local canvas = display.newContainer(width, height)
	canvas.x, canvas.y = x, y
	canvas.isActive = isActive
	canvas.paintR, canvas.paintG, canvas.paintB, canvas.paintA = paintR, paintG, paintB, paintA
	canvas.canvasR, canvas.canvasG, canvas.canvasB, canvas.canvasA = canvasR, canvasG, canvasB, canvasA
	canvas.distanceDrawn = 0
	canvas.totalDistance = params.totalDistance or _W*.3

	print(canvas.distanceDrawn)

	
	--------------------------------------------------------------------------------
	-- CREATE CANVAS BACKGROUND RECT
	--------------------------------------------------------------------------------
	local background = display.newRect(canvas, 0, 0, width, height)
	background:setFillColor(1, 1, 0, .5)
	background.isHitTestable = true

--	snapshot:toFront()
	--snapshot.anchorX, snapshot.anchorY = 1,1
	--[[local snapshot = display.newSnapshot(_W,_H)
	snapshot:translate( centerX, centerY)
	group:insert(snapshot)
	local circle = display.newCircle( 0, 0, _W*.5)
	snapshot.group:insert( circle ) 
	snapshot.alpha = .5]]
		
	--------------------------------------------------------------------------------
	-- CREATE TABLE TO HOLD PAINT STROKES
	--------------------------------------------------------------------------------
	canvas.strokes = {}
	local strokes = canvas.strokes

	canvas.ghosts = {}
	local ghosts = canvas.ghosts
	
	--------------------------------------------------------------------------------
	-- CREATE TABLE TO HOLD UNDONE PAINT STROKES
	--------------------------------------------------------------------------------
		canvas.undone = {}
	local undone = canvas.undone

	--------------------------------------------------------------------------------
	-- SET VARIABLE TO TEST IF TOUCHES BEGAN ON CANVAS
	--------------------------------------------------------------------------------
	local touchBegan = false

	local function angleBetween(x1,y1,x2,y2)
		return math.rad(math.ceil(math.atan2((y2-y1),(x2-x1))*180*math.pi^-1)+90)
	end

	local function distanceBetween(x1,y1,x2,y2)
		return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
	end
	
	--------------------------------------------------------------------------------
	-- TOUCH EVENT HANDLER FUNCTION
	--------------------------------------------------------------------------------


	
	local function touch(event)

		-- set local variables
		local phase = event.phase
		local target = event.target
		local stroke = strokes[#strokes]

		local canvasX, canvasY = canvas:localToContent(canvas.anchorX, canvas.anchorY)
		local x = event.x
		local y = event.y
		local xStart = event.xStart 
		local yStart = event.yStart 
		
		local function getDistance(x1,y1,x2,y2)
			return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
		end

		local function deleteStroke( event )
    		table.remove(stroke, 1)
			canvas.distanceDrawn = canvas.distanceDrawn - stroke[1].segDistance
  			display.remove(stroke[1])
  			stroke[1] = nil
		end
		
		if target.lastX == nil then
			target.lastX, target.lastY = x, y
			target.prevpnX, target.prevpnY = x,y 
		end

		local pnX = target.prevpnX*( 1 - alphaFactor) + x*alphaFactor
		local pnY = target.prevpnY*( 1 - alphaFactor) + y*alphaFactor
		x = pnX
		y = pnY


		
		local distance = getDistance(x, y, target.lastX, target.lastY)
		
		-- check for event phase & start, update, or end stroke accordingly
		if phase == "began" and canvas.isActive  then

			if #strokes>0 then

				local stroke = strokes[1]
				for i = stroke.numChildren, 1, -1 do
  					--timer.cancel( stroke[i].tm )
				end
				table.remove(strokes, 1)
				display.remove(stroke)
				stroke = nil
				canvas.distanceDrawn = 0

			end

			-- start stroke
			display.getCurrentStage():setFocus(target, event.id)
			touchBegan = true

			strokes[#strokes+1] = display.newGroup()
			stroke = strokes[#strokes]

			local circle = display.newCircle( stroke, x, y, circleRadius)
			circle:setFillColor(paintR, paintG, paintB, paintA)
			circle.segDistance = 0
					
			timer.performWithDelay(2000,
				function() 
					display.remove(circle) 
				end)

			--circle.tm = timer.performWithDelay( 1000, deleteStroke )
		

			
			circle:setFillColor(paintR, paintG, paintB, paintA)
			target.lastX, target.lastY = x, y


		elseif phase=="moved" and touchBegan == true and distance > circleRadius*.5 and y < yMax and y > yMin then 


				if canvas.distanceDrawn >= canvas.totalDistance then


					if stroke.numChildren > 0 then

					while canvas.distanceDrawn >= canvas.totalDistance do

							local child = stroke[1]
							if child~=nil then
								table.remove(stroke, 1)
	  							canvas.distanceDrawn = canvas.distanceDrawn - child.segDistance
	  							child.segDistance = 0
	  							display.remove(child)
	  							child = nil
  							end


					end

					end

				end

		

					canvas.distanceDrawn = canvas.distanceDrawn + distance





					--physics.addBody( stroke.circle, "static", { density=0, friction=0, bounce=0, radius = circleRadius, filter = lineFilter} )

					local line = display.newLine( stroke, target.lastX, target.lastY, x, y)
					line.segDistance = distance
					--print(stroke.line.segDistance)
					line:setStrokeColor(paintR, paintG, paintB, paintA)
					line.strokeWidth = strokeWidth

					--stroke.line.tm = timer.performWithDelay( 1000, deleteStroke )
					timer.performWithDelay(2000,
				function() 
					display.remove(line) 

						canvas.distanceDrawn = canvas.distanceDrawn - line.segDistance

				end)



					local angle = angleBetween( 0, 0 , target.lastX - x, target.lastY - y)
					local cosAngle = math.cos(angle)*circleRadius
					local sinAngle = math.sin(angle)*circleRadius
					local oldX = x - target.lastX
					local oldY = y - target.lastY

					
					local rectShape={
					 cosAngle,  sinAngle,
					-cosAngle, -sinAngle,
					oldX - cosAngle, oldY - sinAngle,
					oldX + cosAngle, oldY + sinAngle }

					physics.addBody( line, "static", { density=1.0 , friction=0, bounce=1, shape = rectShape, filter = lineFilter} )


					local circle = display.newCircle( stroke, x, y, circleRadius)
					circle:setFillColor(paintR, paintG, paintB, paintA)
					circle.segDistance = 0
					
					timer.performWithDelay(2000,
				function() 
					display.remove(circle) 
				end)

					--stroke.circle.tm = timer.performWithDelay( 1000, deleteStroke )
					

					target.lastX, target.lastY = x, y
					target.prevpnX, target.prevpnY = pnX, pnY

					print(canvas.distanceDrawn)

		


		elseif (phase == "cancelled" or phase == "ended") and touchBegan == true then

			display.getCurrentStage():setFocus(nil, event.id)
			touchBegan = false
			if canvas.distanceDrawn <= canvas.totalDistance then

				local line = display.newLine( stroke, target.lastX, target.lastY, x, y)
					line.segDistance = distance
					--print(stroke.line.segDistance)
					line:setStrokeColor(paintR, paintG, paintB, paintA)
					line.strokeWidth = strokeWidth

					--stroke.line.tm = timer.performWithDelay( 1000, deleteStroke )
					timer.performWithDelay(2000,function() display.remove(line) end)

				local circle = display.newCircle( stroke, x, y, circleRadius)
					circle:setFillColor(paintR, paintG, paintB, paintA)
					circle.segDistance = 0
					
					timer.performWithDelay(2000,function() display.remove(circle) end)



				--stroke.circle.tm = timer.performWithDelay( 1000, deleteStroke )


			end

			target.lastX, target.lastY = nil, nil

			return true
		end

	--print(#strokes)
	end

	--------------------------------------------------------------------------------
	-- ADD TOUCH LISTENER TO CANVAS
	--------------------------------------------------------------------------------
	canvas:addEventListener("touch", touch)
	
	--------------------------------------------------------------------------------
	-- FUNCTION TO CHANGE PAINT COLOR
	--------------------------------------------------------------------------------
	function canvas:setPaintColor(r, g, b, a)
		paintR = r
		paintG = g
		paintB = b
		paintA = a or paintA
		canvas.paintR, canvas.paintG, canvas.paintB, canvas.paintA = paintR, paintG, paintB, paintA
	end
	
	--------------------------------------------------------------------------------
	-- FUNCTION TO CHANGE CANVAS COLOR
	--------------------------------------------------------------------------------
	function canvas:setCanvasColor(r, g, b, a)
		background:setFillColor(r,g,b,a)
		canvasR = r
		canvasG = g
		canvasB = b
		canvasA = a or canvasA
		canvas.canvasR, canvas.canvasG, canvas.canvasB, canvas.canvasA = canvasR, canvasG, canvasB, canvasA
	end
	
	--------------------------------------------------------------------------------
	-- FUNCTION TO CHANGE STROKE WIDTH
	--------------------------------------------------------------------------------
	function canvas:setStrokeWidth(newWidth)
		strokeWidth = newWidth
		circleRadius = newWidth * .5
	end
	
	--------------------------------------------------------------------------------
	-- FUNCTION TO UNDO PAINT STROKES
	--------------------------------------------------------------------------------
	function canvas:undo()
		if #strokes>0 then
			local n = #strokes
			local stroke = strokes[n]
			table.remove(strokes, n)
			strokes[n] = nil
			undone[#undone+1] = stroke
			stroke.isVisible = false
		end
	end
	
	--------------------------------------------------------------------------------
	-- FUNCTION TO REDO PAINT STROKES
	--------------------------------------------------------------------------------
	function canvas:redo()
		if #undone>0 then
			local n = #undone
			local stroke = undone[n]
			table.remove(undone, n)
			undone[n] = nil
			strokes[#strokes+1] = stroke
			stroke.isVisible = true
		end
	end
	
	--------------------------------------------------------------------------------
	-- FUNCTION TO ERASE ALL PAINT STROKES
	--------------------------------------------------------------------------------
	function canvas:erase()
		print("ERASING")
		print(#strokes)
		if #strokes>0 then
			for n = #strokes, 1, -1 do
				local stroke = strokes[n]
				table.remove(strokes, n)
				strokes[n] = nil
				display.remove(stroke)
				undone = {}
			end
			canvas.distanceDrawn = 0
		end
	end

	function canvas:ghost()

		--local circle = display.newCircle( 0, 0, _W*.25)
		--snapshot.group:insert( circle ) 
		print(#ghosts)
		if #ghosts>0 then
			for n = #ghosts, 1, -1 do
				local stroke = ghosts[n]
				table.remove(ghosts, n)
				ghosts[n] = nil
				display.remove(stroke)
			end
		end

		if #strokes>0 then
			local snapshot = display.newSnapshot( _W, view.height )
				snapshot:translate( display.contentCenterX, display.contentCenterY )
			for n = #strokes, 1, -1 do

				

				local stroke = strokes[n]
				
				table.remove(strokes, n)
				strokes[n] = nil
				for i=1,stroke.numChildren do
    				physics.removeBody( stroke[i] )

				end 
				stroke.x, stroke.y = stroke.x - centerX, stroke.y - centerY
				ghosts[#ghosts+1] = snapshot
				snapshot.group:insert( stroke ) 
				snapshot.alpha = .5
				group:insert(snapshot)

			end
		canvas.distanceDrawn = 0
		end
	end
	
	return canvas
end

return fingerPaint