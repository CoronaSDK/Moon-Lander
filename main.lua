-- Snake Game
-- Developed by Carlos Yanez

-- Hide Status Bar

display.setStatusBar(display.HiddenStatusBar)

-- Physics

local physics = require('physics')
physics.start()
--physics.setGravity(0, 0)

-- Multitouch

system.activate('multitouch')

-- Graphics

-- [Background]

local bg = display.newImage('bg.png')

-- [Title View]

local titleBg
local playBtn
local creditsBtn
local titleView

-- [Credits]

local creditsView

-- [Pad]

local up
local left
local right

-- [Moons]

local m1
local m2
local m3
local bigM

-- Stars

local s1
local s2
local s3
local s4

-- Rocket (player)

local rocket

-- Sounds

local explo = audio.loadSound('explo.mp3')
local star = audio.loadSound('star.mp3')
local goal = audio.loadSound('goal.mp3')

-- Variables

local arrow
local stars = 0
local dir
local hitMoon = false
local starHit
local hitStar = false
local hitGoal = false
local complete

-- Functions

local Main = {}
local startButtonListeners = {}
local showCredits = {}
local hideCredits = {}
local showGameView = {}
local gameListeners = {}
local movePlayer = {}
local update = {}
local onCollision = {}

-- Main Function

function Main()
	titleBg = display.newImage('titleBg.png', display.contentCenterX - 100.5, 20.5)
	creditsBtn = display.newImage('creditsBtn.png', 14, display.contentHeight - 57)
	titleView = display.newGroup(titleBg, creditsBtn)
	
	startButtonListeners('add')
end

function startButtonListeners(action)
	if(action == 'add') then
		titleBg:addEventListener('tap', showGameView)
		creditsBtn:addEventListener('tap', showCredits)
	else
		titleBg:removeEventListener('tap', showGameView)
		creditsBtn:removeEventListener('tap', showCredits)
	end
end

function showCredits:tap(e)
	creditsBtn.isVisible = false
	creditsView = display.newImage('credits.png', -130, display.contentHeight-140)
	transition.to(creditsView, {time = 300, x = 65, onComplete = function() creditsView:addEventListener('tap', hideCredits) end})
end

function hideCredits:tap(e)
	creditsBtn.isVisible = true
	transition.to(creditsView, {time = 300, y = display.contentHeight+creditsView.height, onComplete = function() creditsView:removeEventListener('tap', hideCredits) display.remove(creditsView) creditsView = nil end})
end

function showGameView:tap(e)
	transition.to(titleView, {time = 300, x = -titleView.height, onComplete = function() startButtonListeners('rmv') display.remove(titleView) titleView = nil end})
	
	-- [Add GFX]
	
	-- Moons
	
	m1 = display.newImage('moon.png', 386, 156)
	m2 = display.newImage('moon.png', 252, 99)
	m3 = display.newImage('moon.png', 131, 174)
	
	m1.name = 'moon'
	m2.name = 'moon'
	m3.name = 'moon'
	
	-- Big Moon
	
	bigM = display.newImage('moonBig.png', 10, 53)
	bigM.name = 'moon'
	
	-- Arrow
	
	arrow = display.newImage('arrow.png', 44, 24)
	arrow.name = 'goal'
	
	-- Rocket
	
	rocket = display.newImage('rocket.png', 409.5, 114)
	
	-- Stars
	
	s1 = display.newImage('star.png', 341, 146)
	s2 = display.newImage('star.png', 273, 48)
	s3 = display.newImage('star.png', 190, 234)
	s4 = display.newImage('star.png', 37, 135)
	
	s1.name = 'star'
	s2.name = 'star'
	s3.name = 'star'
	s4.name = 'star'
	
	-- Controls
	
	up = display.newImage('dirBtn.png', 404, 246)
	left = display.newImage('dirBtn.png', 10, 246)
	right = display.newImage('dirBtn.png', 84, 246)
	
	up.name = 'up'
	left.name = 'left'
	right.name = 'right'
	
	up.rotation = 90
	right.rotation = 180
	
	-- Add Physics
	
	physics.addBody(m1, 'static', {radius = 35})
	physics.addBody(m2, 'static', {radius = 35})
	physics.addBody(m3, 'static', {radius = 35})
	
	physics.addBody(bigM, 'static', {radius = 40})
	physics.addBody(arrow, 'static')
	
	physics.addBody(rocket, 'dynamic')
	rocket.isFixedRotation = true
	rocket.isAwake = false --prevents initial explosion sound
	
	physics.addBody(s1, 'static', {radius = 12})
	physics.addBody(s2, 'static', {radius = 12})
	physics.addBody(s3, 'static', {radius = 12})
	physics.addBody(s4, 'static', {radius = 12})
	
	arrow.isSensor = true
	s1.isSensor = true
	s2.isSensor = true
	s3.isSensor = true
	s4.isSensor = true
	
	-- Game Listeners
	
	gameListeners()
end

function gameListeners()
	up:addEventListener('touch', movePlayer)
	left:addEventListener('touch', movePlayer)
	right:addEventListener('touch', movePlayer)
	Runtime:addEventListener('enterFrame', update)
	rocket:addEventListener('collision', onCollision)
end

function movePlayer(e)
	if(e.phase == 'began' and e.target.name == 'up') then
		dir = 'up'
	elseif(e.phase == 'ended' and e.target.name == 'up') then
		dir = 'none'
	elseif(e.phase == 'began' and e.target.name == 'left') then
		dir = 'left'
	elseif(e.phase == 'began' and e.target.name == 'right') then
		dir = 'right'
	elseif(e.phase == 'ended' and e.target.name == 'left') then
		dir = 'none'
	elseif(e.phase == 'ended' and e.target.name == 'right') then
		dir = 'none'
	end
end

function update(e)
	-- Rocket Movement
	
	if(dir == 'up') then
		rocket:setLinearVelocity(0, -80)
	elseif(dir == 'left') then
			rocket:setLinearVelocity(-100, 0)
	elseif(dir == 'right') then
			rocket:setLinearVelocity(100, 0)
	end
	
	-- Rocket-Moon Collision
	
	if(hitMoon) then
		rocket.x = 421.5
		rocket.y = 134
		hitMoon = false
		rocket.isAwake = false
	end
	
	-- Rocket-Star Collision
	
	if(hitStar) then
		display.remove(starHit)
		stars = stars + 1
		hitStar = false
	end
	
	-- Goal
	
	if(hitGoal and stars == 4) then
		rocket.x = 52
		rocket.y = 35
		physics.stop()
		display.remove(arrow)
		audio.play(goal)
		hitGoal = false
		complete = display.newImage('complete.png')
	elseif(hitGoal and stars ~= 4) then
		hitGoal = false
	end
end

function onCollision(e)
	if(e.other.name == 'moon') then
		hitMoon = true
		audio.play(explo)
	elseif(e.other.name == 'star') then
		audio.play(star)
		starHit = e.other
		hitStar = true
	elseif(e.other.name == 'goal') then
		hitGoal = true
	end
end

Main()