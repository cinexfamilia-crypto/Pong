-- PONG HUB FINAL ESTÁVEL

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- CONFIG
local MAX_SPEED = 8
local paused = false
local playerScore = 0
local aiScore = 0
local aiDifficulty = 0.5
local canScore = true
local dragging = false

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "PongHub"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 500, 0, 300)
main.Position = UDim2.new(0.5,-250,0.5,-150)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true

local scoreLabel = Instance.new("TextLabel", main)
scoreLabel.Size = UDim2.new(1,0,0,30)
scoreLabel.BackgroundTransparency = 1
scoreLabel.TextColor3 = Color3.new(1,1,1)
scoreLabel.TextScaled = true

local gameArea = Instance.new("Frame", main)
gameArea.Position = UDim2.new(0,0,0,30)
gameArea.Size = UDim2.new(1,0,1,-30)
gameArea.BackgroundColor3 = Color3.fromRGB(10,10,10)
gameArea.ClipsDescendants = true

-- PADDLES
local playerPaddle = Instance.new("Frame", gameArea)
playerPaddle.Size = UDim2.new(0,10,0,60)
playerPaddle.Position = UDim2.new(0,10,0.5,-30)
playerPaddle.BackgroundColor3 = Color3.new(1,1,1)

local aiPaddle = Instance.new("Frame", gameArea)
aiPaddle.Size = UDim2.new(0,10,0,60)
aiPaddle.Position = UDim2.new(1,-20,0.5,-30)
aiPaddle.BackgroundColor3 = Color3.new(1,1,1)

-- BOLAS
local balls = {}

local function newBall()
	local b = Instance.new("Frame", gameArea)
	b.Size = UDim2.new(0,10,0,10)
	b.BackgroundColor3 = Color3.new(1,1,1)
	b.Position = UDim2.new(0.5,-5,0.5,-5)

	table.insert(balls,{
		obj = b,
		speedX = (math.random(0,1)==0 and -4 or 4),
		speedY = math.random(-3,3)
	})
end

newBall()

local function resetBall(ball)
	ball.obj.Position = UDim2.new(0.5,-5,0.5,-5)
	ball.speedX = (math.random(0,1)==0 and -4 or 4)
	ball.speedY = math.random(-3,3)
end

-- CONTROLE SUAVE MOBILE
UIS.InputBegan:Connect(function(input)
	if paused then return end

	if input.UserInputType == Enum.UserInputType.Touch then
		local pos = input.Position
		local areaPos = gameArea.AbsolutePosition
		local areaSize = gameArea.AbsoluteSize

		if pos.X >= areaPos.X and pos.X <= areaPos.X+areaSize.X then
			dragging = true
		end
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if paused then return end
	if not dragging then return end

	if input.UserInputType == Enum.UserInputType.Touch then
		local y = input.Position.Y - gameArea.AbsolutePosition.Y
		y = math.clamp(y - playerPaddle.AbsoluteSize.Y/2,0,gameArea.AbsoluteSize.Y-playerPaddle.AbsoluteSize.Y)
		playerPaddle.Position = UDim2.new(0,10,0,y)
	end
end)

-- LOOP
RunService.RenderStepped:Connect(function()
	if paused then return end

	for _,ball in ipairs(balls) do

		local newX = ball.obj.Position.X.Offset + ball.speedX
		local newY = ball.obj.Position.Y.Offset + ball.speedY

		if newY <= 0 or newY >= gameArea.AbsoluteSize.Y - ball.obj.AbsoluteSize.Y then
			ball.speedY = -ball.speedY
		end

		-- PLAYER
		if newX <= playerPaddle.Position.X.Offset + playerPaddle.AbsoluteSize.X then
			if newY + ball.obj.AbsoluteSize.Y >= playerPaddle.Position.Y.Offset
			and newY <= playerPaddle.Position.Y.Offset + playerPaddle.AbsoluteSize.Y then
				ball.speedX = -ball.speedX
			end
		end

		-- AI
		if newX + ball.obj.AbsoluteSize.X >= aiPaddle.Position.X.Offset then
			if newY + ball.obj.AbsoluteSize.Y >= aiPaddle.Position.Y.Offset
			and newY <= aiPaddle.Position.Y.Offset + aiPaddle.AbsoluteSize.Y then
				ball.speedX = -ball.speedX
			end
		end

		ball.speedX = math.clamp(ball.speedX,-MAX_SPEED,MAX_SPEED)
		ball.speedY = math.clamp(ball.speedY,-MAX_SPEED,MAX_SPEED)

		if canScore then
			if newX < 0 then
				canScore = false
				aiScore += 1
				resetBall(ball)
				task.wait(1)
				canScore = true
			elseif newX > gameArea.AbsoluteSize.X then
				canScore = false
				playerScore += 1
				resetBall(ball)
				task.wait(1)
				canScore = true
			end
		end

		ball.obj.Position = UDim2.new(0,newX,0,newY)
	end

	scoreLabel.Text = playerScore.." : "..aiScore

	-- IA simples estável
	local target = balls[1].obj.Position.Y.Offset
	if aiPaddle.Position.Y.Offset < target then
		aiPaddle.Position += UDim2.new(0,0,0,4)
	else
		aiPaddle.Position -= UDim2.new(0,0,0,4)
	end
end)

-- BOTÃO CÓD
local codeBtn = Instance.new("TextButton", main)
codeBtn.Size = UDim2.new(0,50,1,0)
codeBtn.Position = UDim2.new(0,-50,0,0)
codeBtn.Text = "CÓD"

-- MENU CÓDIGOS
local codeMenu = Instance.new("Frame", main)
codeMenu.Size = UDim2.new(1,0,1,0)
codeMenu.BackgroundColor3 = Color3.fromRGB(15,15,15)
codeMenu.Visible = false

local box = Instance.new("TextBox", codeMenu)
box.Size = UDim2.new(0.6,0,0,40)
box.Position = UDim2.new(0.2,0,0.3,0)
box.PlaceholderText = "códigos"

local enter = Instance.new("TextButton", codeMenu)
enter.Size = UDim2.new(0.6,0,0,40)
enter.Position = UDim2.new(0.2,0,0.5,0)
enter.Text = "ENTER"

-- ADMIN ABA SEPARADA
local adminMenu = Instance.new("Frame", main)
adminMenu.Size = UDim2.new(1,0,1,0)
adminMenu.BackgroundColor3 = Color3.fromRGB(35,35,35)
adminMenu.Visible = false

local function makeBtn(txt,pos,func)
	local b = Instance.new("TextButton", adminMenu)
	b.Size = UDim2.new(0.6,0,0,35)
	b.Position = UDim2.new(0.2,0,0,pos)
	b.Text = txt
	b.MouseButton1Click:Connect(func)
end

makeBtn("+ Player",0.1,function() playerScore+=1 end)
makeBtn("- Player",0.2,function() playerScore-=1 end)
makeBtn("+ IA",0.3,function() aiScore+=1 end)
makeBtn("- IA",0.4,function() aiScore-=1 end)

makeBtn("+ Bola 15s",0.55,function()
	newBall()
	task.delay(15,function()
		if #balls>1 then
			balls[#balls].obj:Destroy()
			table.remove(balls,#balls)
		end
	end)
end)

makeBtn("Fechar",0.75,function()
	adminMenu.Visible=false
	gameArea.Visible=true
	paused=false
end)

-- ABRIR CÓD
codeBtn.MouseButton1Click:Connect(function()
	paused=true
	gameArea.Visible=false
	codeMenu.Visible=true
end)

-- ENTER
enter.MouseButton1Click:Connect(function()
	if box.Text=="15" then
		playerScore+=15
	elseif box.Text=="dono" then
		codeMenu.Visible=false
		adminMenu.Visible=true
		return
	end

	box.Text=""
	codeMenu.Visible=false
	gameArea.Visible=true
	paused=false
end)
