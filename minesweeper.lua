require('helpers')
local Board = require('board')
local Minesweeper = {}

function Minesweeper.create(config)
  local minesweeper = {}
  minesweeper.config = config

  minesweeper.side      = 0
  minesweeper.mines     = 0
  minesweeper.realBoard = Board.create(minesweeper.side, minesweeper.side, '-')
  minesweeper.board     = Board.create(minesweeper.side, minesweeper.side, '-')
  minesweeper.mineList  = {}
  minesweeper.movesLeft = minesweeper.side * minesweeper.side - minesweeper.mines

  setmetatable(minesweeper, { __index = Minesweeper })
  return minesweeper
end

function Minesweeper:run()
  print('Minesweeper is starting...')
  self:chooseDifficulty()
  self:play()
  print('Minesweeper has finished!')
end

function Minesweeper:chooseDifficulty()
  print('Select difficulty:')
  print('1 - Beginner')
  print('2 - Intermediate')
  print('3 - Advanced')
  local level = readNumber('Choice: ', 1, 3, 'Invalid choice. Try again.')

  if level == 1 then
    self.side, self.mines = self.config.beginner.sides,  self.config.beginner.mines
  elseif level == 2 then
    self.side, self.mines = self.config.intermediate.sides,  self.config.intermediate.mines
  elseif level == 3 then
    self.side, self.mines = self.config.expert.sides,  self.config.expert.mines
  end

  self.realBoard = Board.create(self.side, self.side, '-')
  self.board     = Board.create(self.side, self.side, '-')
  self.mineList  = {}
  self.movesLeft = self.side * self.side - self.mines
end

function Minesweeper:isValid(row, col)
  return row >= 1 and row <= self.side and col >= 1 and col <= self.side
end

function Minesweeper:hasMine(row, col)
  return self.realBoard:getValue(row, col) == '*'
end

local function formatTime(seconds)
  return string.format('%02d:%02d', math.floor(seconds / 60), seconds % 60)
end

function Minesweeper:printStatus()
  local elapsed = os.time() - self.startTime
  print(string.format('Time: %s', formatTime(elapsed)))
end

function Minesweeper:makeMove()
  local row    = readNumber('Select row: ',    1, self.side, 'Invalid choice. Try again.')
  local column = readNumber('Select column: ', 1, self.side, 'Invalid choice. Try again.')
  return row, column
end

function Minesweeper:countAdjacentMines(row, col)
  local dx    = { -1, -1, -1,  0, 0, 1, 1, 1 }
  local dy    = { -1,  0,  1, -1, 1,-1, 0, 1 }
  local count = 0

  for i = 1, 8 do
    local nr, nc = row + dx[i], col + dy[i]
    if self:isValid(nr, nc) and self:hasMine(nr, nc) then
      count = count + 1
    end
  end
  return count
end

function Minesweeper:placeMines()
  local mark = {}
  local i    = 1

  while i <= self.mines do
    local r   = math.random(1, self.side)
    local c   = math.random(1, self.side)
    local key = r .. ',' .. c

    if not mark[key] then
      self.realBoard:setValue(r, c, '*')
      self.mineList[i]     = { r, c }
      mark[key]            = true
      i = i + 1
    end
  end
end

function Minesweeper:replaceMine(row, col)
  for i = 1, self.side do
    for j = 1, self.side do
      if self.realBoard:getValue(i, j) ~= '*' then
        self.realBoard:setValue(i, j, '*')
        self.realBoard:setValue(row, col, '-')
        return
      end
    end
  end
end

function Minesweeper:gameLoop(row, column)
  local cell = self.board:getValue(row, column)
  if cell ~= '-' then
    return false
  end

  if self:hasMine(row, column) then
    self.board:setValue(row, column, '*')
    for _, m in ipairs(self.mineList) do
      self.board:setValue(m[1], m[2], '*')
    end
    self.board:draw()
    print('You lost!')
    return true
  end

  local count = self:countAdjacentMines(row, column)
  self.movesLeft = self.movesLeft - 1
  self.board:setValue(row, column, tostring(count))

  if count == 0 then
    local dx = { -1, -1, -1,  0, 0, 1, 1, 1 }
    local dy = { -1,  0,  1, -1, 1,-1, 0, 1 }

    for i = 1, 8 do
      local nr, nc = row + dx[i], column + dy[i]
      if self:isValid(nr, nc) and not self:hasMine(nr, nc) then
        if self:gameLoop(nr, nc) then return true end
      end
    end
  end

  return false
end

function Minesweeper:play()
  math.randomseed(os.time())
  self:placeMines()

  self.startTime = os.time()
  local gameOver  = false
  local firstMove = true

  while not gameOver do
    self:printStatus()
    self.board:draw()

    local row, column = self:makeMove()

    if firstMove and self:hasMine(row, column) then
      self:replaceMine(row, column)
    end
    firstMove = false

    gameOver = self:gameLoop(row, column)

    if not gameOver and self.movesLeft == 0 then
      print('You won!')
      gameOver = true
    end
  end
end

return Minesweeper

