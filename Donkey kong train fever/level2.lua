-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()

local points = 0
local pointText
local pointBanana

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

local train
local touch
local cnt = 0
local gr

function rail(group, x1, y1, x2, y2)

	local rail = display.newRect( x1, y1, 0, 0 )
	rail:setFillColor(230)
	
	local dx = x2-x1
	local dy = y2-y1
	
	rail.dx = dx / math.sqrt(dx*dx+dy*dy)
	rail.dy = dy / math.sqrt(dx*dx+dy*dy)
	
	local railShape = { 0,0, x2-x1, y2-y1, x2-x1, y2-y1+10, 0, 10 }
	rail:setReferencePoint( display.TopLeftReferencePoint )
	physics.addBody( rail, "static", { shape=railShape } )
	rail.type = "rail"
	
	group:insert(rail)
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	physics.setGravity(0,60)
	local group = display:newGroup()
	self.view:insert(group)
	gr = group

	pointText = display.newText( group, points, 50, 10, native.systemFont, 16 )
	pointBanana = addBanana(group, 0, 20)
	
	local knapp = display.newRect(380, 0, 100, 100)
	knapp:setFillColor(200)
	self.view:insert(knapp)

	group:addEventListener( "touch", jumpAction )
	group:addEventListener( "key", jumpAction )
	
	physics.setDrawMode("hybrid")
		
	train = display.newSprite( trainSprite(), { 
		name = "normalRun",  --name of animation sequence
	    start = 1,  --starting frame index
	    count = 3,  --total number of frames to animate consecutively before stopping or looping
	    time = 800,  --optional, in milliseconds; if not supplied, the sprite is frame-based
	    loopCount = 0,  --optional. 0 (default) repeats forever; a positive integer specifies the number of loops
	    loopDirection = "forward"  --optional, either "forward" (default) or "bounce" which will play forward then backwards through the sequence of frames
	})  --if defining more sequences, place a comma here and proceed to the next sequence sub-table )
	train.x, train.y = 58, 58
	train.canJump = 0
	train.type = "train"
	train.collision = onLocalCollision
	train:addEventListener( "collision", train )
	train:play()

	physics.addBody( train, {density=1.0, friction=0, bounce=0, radius=10} )

	
	rail(group, 0,200, 200,250)
	rail(group, 200,250, 250,250)
	rail(group, 250,250, 300,200)
	rail(group, 400,200, 500,250)
	rail(group, 500,250, 800,250)

	addBanana(group, 220, 230)
	
	group:insert(train)

	knapp:addEventListener( "touch", jumpAction )
end

function gameLoop(event)
	gr.x = 0 - train.x + 100
	pointText.text = points
	pointText.x = train.x - 50
	pointBanana.x = train.x - 70
end

Runtime:addEventListener("enterFrame", gameLoop)

function onLocalCollision( self, event )
	local group = self.view

	if event.other.type == "rail" then
		if (event.phase == "began") then
			physics.setGravity(0,0)
			touch = event.other
			train:setLinearVelocity(300*touch.dx, 300*touch.dy)
			cnt = cnt+1
			print("began " .. tostring(event.other))
		end
		if (event.phase == "ended") then
			cnt = cnt-1
			if (cnt == 0) then
				physics.setGravity(0,60)
			end
			print("ended " .. tostring(event.other))
		end
	end
	if event.other.type == "banana" then
		if (event.phase == "began") then
			event.other:removeSelf()
			event.other = nil
			points = points + 1;
			print("Points: " .. points)
		end
	end
end

function jumpAction(event)
	print("HALLO")
	local touchOrSpace = event.phase == "began" or (event.phase == "down" and event.keyName == "space")
   	if ( touchOrSpace and cnt > 0 ) then
		local vx, vy = train:getLinearVelocity()
		train:setLinearVelocity(vx, 0)
    	train:applyForce( 0, -180, train.x, train.y )
   	end
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	physics.start()
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	physics.stop()
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	package.loaded[physics] = nil
	physics = nil
end


function addBanana(group, x , y, r)
	-- create a grass object and add physics (with custom shape)
	local banana = display.newSprite( bananaSprite(), { 
		name = "normalRun",  --name of animation sequence
	    start = 1,  --starting frame index
	    count = 8,  --total number of frames to animate consecutively before stopping or looping
	    time = 800,  --optional, in milliseconds; if not supplied, the sprite is frame-based
	    loopCount = 0,  --optional. 0 (default) repeats forever; a positive integer specifies the number of loops
	    loopDirection = "forward"  --optional, either "forward" (default) or "bounce" which will play forward then backwards through the sequence of frames
	})
	banana.x, banana.y = x, y
	banana.type = "banana"
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local bananaShape = { -7, -7, 7, -7, 7, 7, -7, 7 }
	physics.addBody( banana, "kinematic", { friction=0, shape=bananaShape, isSensor = true } )

	group:insert( banana)
	banana:play()
	return banana
end

function trainSprite()
	return graphics.newImageSheet( "train.png", {
	    --array of tables representing each frame (required)
	    frames = {
		        -- FRAME 1:
		        {
		            --all parameters below are required for each frame
		            x = 0,
		            y = 0,
		            width = 55,
		            height = 58
		        },

		        -- FRAME 2:
		        {
		            x = 56,
		            y = 0,
		            width = 55,
		            height = 58
		        },
		        -- FRAME 3:
		        {
		            x = 113,
		            y = 0,
		            width = 55,
		            height = 58
		        },

		        -- FRAME 3 and so on...
		    },

		    --optional parameters; used for dynamic resolution support
		    sheetContentWidth = 165,
		    sheetContentHeight = 58
		})
end

function bananaSprite()
	return graphics.newImageSheet( "banana.png", {
	    --array of tables representing each frame (required)
	    frames = {
		        {
		            x = 0,
		            y = 0,
		            width = 15,
		            height = 16
		        },

		        {
		            x = 15,
		            y = 0,
		            width = 15,
		            height = 16
		        },
		        {
		            x = 30,
		            y = 0,
		            width = 15,
		            height = 16
		        },
		        {
		            x = 45,
		            y = 0,
		            width = 15,
		            height = 16
		        },

		        {
		            x = 60,
		            y = 0,
		            width = 15,
		            height = 16
		        },
		        {
		            x = 75,
		            y = 0,
		            width = 15,
		            height = 16
		        },
		        {
		            x = 90,
		            y = 0,
		            width = 15,
		            height = 16
		        },

		        {
		            x = 105,
		            y = 0,
		            width = 15,
		            height = 16
		        }

		    },

		    --optional parameters; used for dynamic resolution support
		    sheetContentWidth = 117,
		    sheetContentHeight = 16
		})
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene