-- PONG HUB GUI COMPLETO
-- Coloque em um LocalScript dentro de StarterGui

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- GUI BASE
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "PongHub"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 500, 0, 300)
main.Position = UDim2.new(0.5, -250, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true
main.BorderSizePixel = 0

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
gameArea.BorderSizePixel = 0
gameArea.ClipsDescendants = true

-- PLAYER PADDLE
local playerPaddle = Instance.new("Frame", gameArea)
playerPaddle.Size = UDim2.new(0,10,0,60)
playerPaddle.Position = UDim2.new(0,10,0.5,-30)
playerPaddle.BackgroundColor3 = Color3.new(1,1,1)

-- AI PADDLE
local aiPaddle = Instance.new("Frame", gameArea)
aiPaddle.Size = UDim2.new(0,10,0,60)
aiPaddle.Position = UDim2.new(1,-20,0.5,-30)
aiPaddle.BackgroundColor3 = Color3.new(1,1,1)

-- BALL
local ball = Instance.new("Frame", gameArea)
ball.Size = UDim2.new(0,10,0,10)
ball.Position = UDim2.new(0.5,-5,0.5,-5)
ball.BackgroundColor3 = Color3.new(1,1,1)

-- VARIÁVEIS
local ballSpeedX = 4
local ballSpeedY = 4
local playerScore = 0
local aiScore = 0
local aiDifficulty = 0.5

-- CONTROLE PLAYER (PC + MOBILE)
UIS.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch then
		
		local y = input.Position.Y - gameArea.AbsolutePosition.Y
		y = math.clamp(y - playerPaddle.AbsoluteSize.Y/2, 0, gameArea.AbsoluteSize.Y - playerPaddle.AbsoluteSize.Y)
		
		playerPaddle.Position = UDim2.new(0,10,0,y)
	end
end)

-- RESET BOLA
local function resetBall()
	ball.Position = UDim2.new(0.5,-5,0.5,-5)
	ballSpeedX = (math.random(0,1) == 0 and -4 or 4)
	ballSpeedY = math.random(-4,4)
end

-- LOOP DO JOGO
RunService.RenderStepped:Connect(function()
	
	-- MOVIMENTO BOLA
	local newX = ball.Position.X.Offset + ballSpeedX
	local newY = ball.Position.Y.Offset + ballSpeedY
	
	-- COLISÃO PAREDE SUPERIOR/INFERIOR
	if newY <= 0 or newY >= gameArea.AbsoluteSize.Y - ball.AbsoluteSize.Y then
		ballSpeedY = -ballSpeedY
	end
	
	-- COLISÃO PLAYER
	if newX <= playerPaddle.Position.X.Offset + playerPaddle.AbsoluteSize.X then
		if newY + ball.AbsoluteSize.Y >= playerPaddle.Position.Y.Offset
		and newY <= playerPaddle.Position.Y.Offset + playerPaddle.AbsoluteSize.Y then
			ballSpeedX = -ballSpeedX
		end
	end
	
	-- COLISÃO AI
	if newX + ball.AbsoluteSize.X >= aiPaddle.Position.X.Offset then
		if newY + ball.AbsoluteSize.Y >= aiPaddle.Position.Y.Offset
		and newY <= aiPaddle.Position.Y.Offset + aiPaddle.AbsoluteSize.Y then
			ballSpeedX = -ballSpeedX
		end
	end
	
	-- PONTO
	if newX < 0 then
		aiScore += 1
		aiDifficulty += 0.05
		resetBall()
	end
	
	if newX > gameArea.AbsoluteSize.X then
		playerScore += 1
		resetBall()
	end
	
	scoreLabel.Text = playerScore .. " : " .. aiScore
	
	-- IA ADAPTATIVA
	local targetY = ball.Position.Y.Offset - aiPaddle.AbsoluteSize.Y/2
	local aiSpeed = 3 + (aiDifficulty * 3)
	
	if aiPaddle.Position.Y.Offset < targetY then
		aiPaddle.Position += UDim2.new(0,0,0,aiSpeed)
	else
		aiPaddle.Position -= UDim2.new(0,0,0,aiSpeed)
	end
	
	-- LIMITAR IA
	local aiY = math.clamp(aiPaddle.Position.Y.Offset, 0, gameArea.AbsoluteSize.Y - aiPaddle.AbsoluteSize.Y)
	aiPaddle.Position = UDim2.new(1,-20,0,aiY)
	
	-- APLICAR POSIÇÃO BOLA
	ball.Position = UDim2.new(0,newX,0,newY)
end)

resetBall()
