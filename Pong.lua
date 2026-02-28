-- PONG HUB + SISTEMA DE CÓDIGOS + ADMIN

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- VARIÁVEIS
local ballSpeedX = 4
local ballSpeedY = 4
local playerScore = 0
local aiScore = 0
local aiDifficulty = 0.5
local MAX_SPEED = 9
local canScore = true
local paused = false

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "PongHub"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 500, 0, 300)
main.Position = UDim2.new(0.5, -250, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true

-- BOTÃO CÓDIGO
local codeButton = Instance.new("TextButton", main)
codeButton.Size = UDim2.new(0,50,1,0)
codeButton.Position = UDim2.new(0,-50,0,0)
codeButton.Text = "CÓD"
codeButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
codeButton.TextColor3 = Color3.new(1,1,1)

-- SCORE
local scoreLabel = Instance.new("TextLabel", main)
scoreLabel.Size = UDim2.new(1,0,0,30)
scoreLabel.BackgroundTransparency = 1
scoreLabel.TextColor3 = Color3.new(1,1,1)
scoreLabel.TextScaled = true
scoreLabel.Text = "0 : 0"

-- GAME AREA
local gameArea = Instance.new("Frame", main)
gameArea.Position = UDim2.new(0,0,0,30)
gameArea.Size = UDim2.new(1,0,1,-30)
gameArea.BackgroundColor3 = Color3.fromRGB(10,10,10)
gameArea.ClipsDescendants = true

-- PLAYER
local playerPaddle = Instance.new("Frame", gameArea)
playerPaddle.Size = UDim2.new(0,10,0,60)
playerPaddle.Position = UDim2.new(0,10,0.5,-30)
playerPaddle.BackgroundColor3 = Color3.new(1,1,1)

-- AI
local aiPaddle = Instance.new("Frame", gameArea)
aiPaddle.Size = UDim2.new(0,10,0,60)
aiPaddle.Position = UDim2.new(1,-20,0.5,-30)
aiPaddle.BackgroundColor3 = Color3.new(1,1,1)

-- FUNÇÃO CRIAR BOLA
local balls = {}

local function createBall()
	local ball = Instance.new("Frame", gameArea)
	ball.Size = UDim2.new(0,10,0,10)
	ball.BackgroundColor3 = Color3.new(1,1,1)
	ball.Position = UDim2.new(0.5,-5,0.5,-5)

	table.insert(balls,{
		object = ball,
		speedX = (math.random(0,1)==0 and -4 or 4),
		speedY = math.random(-3,3)
	})
end

createBall()

-- RESET
local function resetBall(ballData)
	ballData.object.Position = UDim2.new(0.5,-5,0.5,-5)
	ballData.speedX = (math.random(0,1)==0 and -4 or 4)
	ballData.speedY = math.random(-3,3)
end

-- CONTROLE PLAYER
UIS.InputChanged:Connect(function(input)

	if paused then return end

	if input.UserInputType ~= Enum.UserInputType.Touch
	and input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	local pos = input.Position
	local areaPos = gameArea.AbsolutePosition
	local areaSize = gameArea.AbsoluteSize

	local inside =
		pos.X >= areaPos.X and
		pos.X <= areaPos.X + areaSize.X and
		pos.Y >= areaPos.Y and
		pos.Y <= areaPos.Y + areaSize.Y

	if not inside then return end

	local y = pos.Y - areaPos.Y
	y = math.clamp(y - playerPaddle.AbsoluteSize.Y/2,0,areaSize.Y - playerPaddle.AbsoluteSize.Y)

	playerPaddle.Position = UDim2.new(0,10,0,y)
end)

-- LOOP
RunService.RenderStepped:Connect(function()

	if paused then return end

	for _,ballData in pairs(balls) do

		local ball = ballData.object
		local newX = ball.Position.X.Offset + ballData.speedX
		local newY = ball.Position.Y.Offset + ballData.speedY

		if newY <= 0 or newY >= gameArea.AbsoluteSize.Y - ball.AbsoluteSize.Y then
			ballData.speedY = -ballData.speedY
		end

		if newX <= playerPaddle.Position.X.Offset + playerPaddle.AbsoluteSize.X then
			if newY + ball.AbsoluteSize.Y >= playerPaddle.Position.Y.Offset
			and newY <= playerPaddle.Position.Y.Offset + playerPaddle.AbsoluteSize.Y then
				ballData.speedX = -ballData.speedX * 1.05
			end
		end

		if newX + ball.AbsoluteSize.X >= aiPaddle.Position.X.Offset then
			if newY + ball.AbsoluteSize.Y >= aiPaddle.Position.Y.Offset
			and newY <= aiPaddle.Position.Y.Offset + aiPaddle.AbsoluteSize.Y then
				ballData.speedX = -ballData.speedX * 1.05
			end
		end

		ballData.speedX = math.clamp(ballData.speedX,-MAX_SPEED,MAX_SPEED)
		ballData.speedY = math.clamp(ballData.speedY,-MAX_SPEED,MAX_SPEED)

		if canScore then
			if newX < 0 then
				canScore = false
				aiScore += 1
				resetBall(ballData)
				task.wait(1)
				canScore = true
			elseif newX > gameArea.AbsoluteSize.X then
				canScore = false
				playerScore += 1
				resetBall(ballData)
				task.wait(1)
				canScore = true
			end
		end

		ball.Position = UDim2.new(0,newX,0,newY)
	end

	scoreLabel.Text = playerScore.." : "..aiScore

	-- IA
	local targetY = balls[1].object.Position.Y.Offset - aiPaddle.AbsoluteSize.Y/2
	local aiSpeed = 3 + (aiDifficulty * 3)

	if aiPaddle.Position.Y.Offset < targetY then
		aiPaddle.Position += UDim2.new(0,0,0,aiSpeed)
	else
		aiPaddle.Position -= UDim2.new(0,0,0,aiSpeed)
	end

	local aiY = math.clamp(aiPaddle.Position.Y.Offset,0,gameArea.AbsoluteSize.Y - aiPaddle.AbsoluteSize.Y)
	aiPaddle.Position = UDim2.new(1,-20,0,aiY)

end)

-- MENU CÓDIGOS
local codeFrame = Instance.new("Frame", main)
codeFrame.Size = UDim2.new(1,0,1,0)
codeFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
codeFrame.Visible = false

local box = Instance.new("TextBox", codeFrame)
box.Size = UDim2.new(0.6,0,0,40)
box.Position = UDim2.new(0.2,0,0.3,0)
box.PlaceholderText = "códigos"
box.Text = ""

local enter = Instance.new("TextButton", codeFrame)
enter.Size = UDim2.new(0.6,0,0,40)
enter.Position = UDim2.new(0.2,0,0.5,0)
enter.Text = "ENTER"

local result = Instance.new("TextLabel", codeFrame)
result.Size = UDim2.new(1,0,0,40)
result.Position = UDim2.new(0,0,0.7,0)
result.BackgroundTransparency = 1
result.TextColor3 = Color3.new(1,1,1)
result.TextScaled = true

-- ADMIN PANEL
local adminFrame = Instance.new("Frame", main)
adminFrame.Size = UDim2.new(1,0,1,0)
adminFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
adminFrame.Visible = false

local function makeButton(text,y,callback)
	local b = Instance.new("TextButton", adminFrame)
	b.Size = UDim2.new(0.6,0,0,40)
	b.Position = UDim2.new(0.2,0,0,y)
	b.Text = text
	b.MouseButton1Click:Connect(callback)
end

makeButton("+ Player",0.1,function() playerScore +=1 end)
makeButton("- Player",0.2,function() playerScore -=1 end)
makeButton("+ IA",0.3,function() aiScore +=1 end)
makeButton("- IA",0.4,function() aiScore -=1 end)

makeButton("+ Bola (15s)",0.55,function()
	createBall()
	task.delay(15,function()
		if #balls > 1 then
			local last = balls[#balls]
			last.object:Destroy()
			table.remove(balls,#balls)
		end
	end)
end)

-- BOTÃO CÓD
codeButton.MouseButton1Click:Connect(function()
	paused = true
	gameArea.Visible = false
	codeFrame.Visible = true
end)

-- ENTER
enter.MouseButton1Click:Connect(function()

	if box.Text == "15" then
		playerScore += 15
		result.Text = "succes!"
		task.wait(1)

	elseif box.Text == "dono" then
		codeFrame.Visible = false
		adminFrame.Visible = true
		return

	else
		result.Text = "incorret"
		task.wait(1)
	end

	result.Text = ""
	box.Text = ""
	codeFrame.Visible = false
	gameArea.Visible = true
	paused = false
end)
