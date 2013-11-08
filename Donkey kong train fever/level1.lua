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
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	physics.setDrawMode( "hybrid" )

	local group = self.view

	-- create a grey rectangle as the backdrop
	local background = display.newRect( 0, 0, screenW, screenH )
	background:setFillColor( 128 )


	local spriteGraphics = graphics.newImageSheet( "train.png", {
    --array of tables representing each frame (required)
    frames =
    {
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

	local train = display.newSprite( spriteGraphics, { 
		name = "normalRun",  --name of animation sequence
	    start = 1,  --starting frame index
	    count = 3,  --total number of frames to animate consecutively before stopping or looping
	    time = 800,  --optional, in milliseconds; if not supplied, the sprite is frame-based
	    loopCount = 0,  --optional. 0 (default) repeats forever; a positive integer specifies the number of loops
	    loopDirection = "forward"  --optional, either "forward" (default) or "bounce" which will play forward then backwards through the sequence of frames
	})  --if defining more sequences, place a comma here and proceed to the next sequence sub-table )
	train.x, train.y = 58, 58
	train:play()
	
	-- add physics to the crate
	physics.addBody( train, { density=1.0, friction=0.3, bounce=0.3 } )
	
	-- all display objects must be inserted into group
	group:insert( background )

	addRail(group, 0, halfH + 30)
	addRail(group, 50, halfH + 30)

	group:insert( train)

end

function addRail(group, x , y)
	-- create a grass object and add physics (with custom shape)
	local rail = display.newImageRect( "singlerail.png", 50, 29 )
	rail:setReferencePoint( display.BottomLeftReferencePoint )
	rail.x, rail.y = x, y
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local railShape = { -24, -14, 24, -14, 24, 14, -24, 14 }
	physics.addBody( rail, "static", { friction=0.3, shape=railShape } )

	group:insert( rail)

end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	physics.start()
	
end

-- Called when scene is about to move offscreen:
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