
module Graphics.Gloss.Interface.Display
	(displayInWindow)
where	
import Graphics.Gloss.Color
import Graphics.Gloss.Picture
import Graphics.Gloss.Render.Picture
import Graphics.Gloss.Render.ViewPort
import Graphics.Gloss.Interface.Window
import Graphics.Gloss.Interface.Exit
import Graphics.Gloss.Interface.ViewPort.KeyMouse
import Graphics.Gloss.Interface.ViewPort.Motion
import Graphics.Gloss.Interface.ViewPort.Reshape
import qualified Graphics.Gloss.Render.Options			as RO
import qualified Graphics.Gloss.Interface.ViewPort.State	as VP
import qualified Graphics.Gloss.Interface.ViewPort.ControlState	as VPC
import qualified Graphics.Gloss.Interface.Callback		as Callback
import Data.IORef
import Control.Concurrent


-- | Create a new window and display the given picture.
displayInWindow
	:: String	-- ^ Name of the window.
	-> (Int, Int)	-- ^ Initial size of the window, in pixels.
	-> (Int, Int)	-- ^ Initial position of the window, in pixels.
	-> Color	-- ^ Background color
	-> Picture	-- ^ The picture to draw.
	-> IO ()

displayInWindow name size pos background picture
 =  do
	viewSR		<- newIORef VP.stateInit
	viewControlSR	<- newIORef VPC.stateInit
	renderSR	<- newIORef RO.optionsInit
	
	let renderFun = do
		view	<- readIORef viewSR
		options	<- readIORef renderSR
	 	withViewPort
	 		view
			(renderPicture options view picture)

	let callbacks
	     =	[ Callback.Display renderFun 

		-- Delay the thread for a bit to give the runtime
		--	a chance to switch back to the OS.
		, Callback.Idle	   (threadDelay 1000)

		-- Escape exits the program
		, callback_exit () 
		
		-- Viewport control with mouse
		, callback_viewPort_keyMouse viewSR viewControlSR 
		, callback_viewPort_motion   viewSR viewControlSR 
		, callback_viewPort_reshape ]

	createWindow name size pos background callbacks


