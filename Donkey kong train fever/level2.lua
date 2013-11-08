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

local ball
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
	
	group:insert(rail)
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
				physics.setGravity(0,60)
	local group = display:newGroup()
	self.view:insert(group)
	gr = group
	
	local knapp = display.newRect(380, 0, 100, 100)
	knapp:setFillColor(200)
	self.view:insert(knapp)

	group:addEventListener( "touch", jumpAction )
	group:addEventListener( "key", jumpAction )
	
	physics.setDrawMode("hybrid")
		
	ball = display.newCircle( 10, 0, 10);
	ball:setFillColor( 485 )
	physics.addBody( ball, {density=1.0, friction=0, bounce=0, radius=10} )

	
	rail(group, 0,200, 200,250)
	rail(group, 200,250, 250,250)
	rail(group, 250,250, 300,200)
	rail(group, 400,200, 500,250)
	rail(group, 500,250, 800,250)
	
	group:insert(ball)
	
	local function onLocalCollision( self, event )
		if (event.phase == "began") then
			physics.setGravity(0,0)
			touch = event.other
			ball:setLinearVelocity(300*touch.dx, 300*touch.dy)
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
	 
	ball.collision = onLocalCollision
	ball:addEventListener( "collision", ball )
	knapp:addEventListener( "touch", jumpAction )
end

function gameLoop(event)
	gr.x = 0 - ball.x + 100
end

Runtime:addEventListener("enterFrame", gameLoop)

function jumpAction(event)
	print("HALLO")
	local touchOrSpace = event.phase == "began" or (event.phase == "down" and event.keyName == "space")
   	if ( touchOrSpace and cnt > 0 ) then
		local vx, vy = ball:getLinearVelocity()
		ball:setLinearVelocity(vx, 0)
    	ball:applyForce( 0, -180, ball.x, ball.y )
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