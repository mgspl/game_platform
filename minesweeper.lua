require('helpers')
local Board = require('board')
local DIRECTIONS = {{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}}
local Minesweeper = {}

function Minesweeper.create(config)
  local minesweeper = {}
  minesweeper.config = config

  setmetatable(minesweeper, {
    __index = Minesweeper
  })
  return minesweeper
end

function Minesweeper:run()
  print('Minesweeper is starting...')
  self:chooseDifficulty()
  if self.cheatType == 2 then
    self:cheatPlay()
    self.minesPos = nil
  else
    self:play()
  end
  print('Minesweeper has finished!')
end

function Minesweeper:chooseDifficulty()
  print('Select difficulty:')

  for i, diff in ipairs(self.config.difficulties) do
    print(string.format("%d - %s", i, self.config.difficulties[i].level))
  end

  local choice = readNumber('Choice: ', 1, #self.config.difficulties + 1, 'Invalid choice. Try again.')

  if choice == #self.config.difficulties + 1 then
    self.minesPos = {}
    print("Cheat activated!")
    print("1 - X-Ray | 2 - Auto solve")
    local cheatType = readNumber("Cheat: ", 1, 2, "Invalid choice. Try again.")
    self.cheatType = cheatType

    print('Select difficulty:')
    for i, diff in ipairs(self.config.difficulties) do
      print(string.format("%d - %s", i, self.config.difficulties[i].level))
    end

    choice = readNumber('Choice: ', 1, #self.config.difficulties, 'Invalid choice. Try again.')
  end

  local side = self.config.difficulties[choice].side
  local mines = self.config.difficulties[choice].mines

  self.side = side
  self.mines = mines
  self.flagCount = mines
  self.board = Board.create(side, side, '-')
  self.mineBoard = Board.create(side, side, "-")
  self.movesLeft = (side * side) - mines
end

function Minesweeper:isValid(row, col)
  return row >= 1 and row <= self.side and col >= 1 and col <= self.side
end

function Minesweeper:hasMine(row, col)
  return self.mineBoard:getValue(row, col) == "*"
end

function Minesweeper:hasFlag(row, col)
  return self.board:getValue(row, col) == "F"
end

function Minesweeper:toggleFlag(row, col)
  local flagged = self:hasFlag(row, col)

  if not flagged then
    self.board:setValue(row, col, 'F')
    self.flagCount = self.flagCount - 1
    return
  end

  if flagged then
    self.board:setValue(row, col, "-")
    self.flagCount = self.flagCount + 1
    return
  end
end

function Minesweeper:gameHUD()
  local elapsed = os.time() - self.startTime

  print(string.format("Time: %02d:%02d | Flags remaining: %d | Mines: %d", math.floor(elapsed / 60), elapsed % 60, self.flagCount, self.mines))
  if self.cheatType == 1 then
    print("Mines: " .. table.concat(self.minesPos, " | "))
  end
  self.board:draw()
end

function Minesweeper:makeMove()
  print('Action: 1 - Reveal | 2 - Flag/Unflag')
  local action = readNumber('Choose action: ', 1, 2, 'Invalid action.')
  local row = readNumber('Select row: ', 1, self.side, 'Invalid choice. Try again.')
  local col = readNumber('Select column: ', 1, self.side, 'Invalid choice. Try again.')

  if self.board:getValue(row, col) ~= "-" and not self:hasFlag(row, col) then
    return
  end

  return action, row, col
end

function Minesweeper:placeMines(firstRow, firstCol)
  local placed = 0

  while placed < self.mines do
    local row = math.random(1, self.side)
    local col = math.random(1, self.side)
    local firstMove

    if row == firstRow and col == firstCol then
      firstMove = true
    end

    if not firstMove and not self:hasMine(row, col) then
      placed = placed + 1
      if self.cheatType == 1 then
       self.minesPos[#self.minesPos + 1] = string.format("(%d, %d)", row, col)
      end
      self.mineBoard:setValue(row, col, "*")
    end
  end
end

function Minesweeper:countAdjacentMines(row, col)
  local count = 0
  for _, dir in ipairs(DIRECTIONS) do
    local nr, nc = row + dir[1], col + dir[2]
    if self:isValid(nr, nc) and self:hasMine(nr, nc) then
      count = count + 1
    end
  end
  return count
end

function Minesweeper:revealAllMines()
  for row = 1, self.side do
    for col = 1, self.side do
      if self:hasMine(row, col) and not self:hasFlag(row, col) then
        self.board:setValue(row, col, '*')
      end
    end
  end
end

function Minesweeper:reveal(row, col)
  if not self:isValid(row, col) or self.board:getValue(row, col) ~= '-' then
    return
  end

  local count = self:countAdjacentMines(row, col)
  self.board:setValue(row, col, tostring(count))
  self.movesLeft = self.movesLeft - 1

  if count == 0 then
    for _, dir in ipairs(DIRECTIONS) do
      self:reveal(row + dir[1], col + dir[2])
    end
  end
end

function Minesweeper:cheatChooseMove(validMoves)
  local id = math.random(1, #validMoves)
  local row = validMoves[id][1]
  local col = validMoves[id][2]
  table.remove(validMoves, id)

   return row, col
end

function Minesweeper:cheatPlay()
  local validMoves = {}
  for row = 1, self.side do
    for col = 1, self.side do
      validMoves[#validMoves + 1] = {row, col}
    end
  end

  math.randomseed(os.time())
  self.startTime = os.time()

  local row, col = self:cheatChooseMove(validMoves)
  self:placeMines(row, col)
  self:reveal(row, col)
  self:gameHUD()

  while true do
    self:gameHUD()
    local row, col = self:cheatChooseMove(validMoves)


    if self.board:getValue(row, col) ~= "-" and not self:hasFlag(row, col) then
      print("Invalid move. Try again.")
    end

    if self:hasMine(row, col) and not self:hasFlag(row, col) then
      print("Choose action: 1")
      print("Select row: " .. row)
      print("Select column: " .. col)
      self:toggleFlag(row, col)
      os.execute("sleep 2")
    end

    if not self:hasMine(row, col) and not self:hasFlag(row, col) then
      print("Choose action: 1")
      print("Select row: " .. row)
      print("Select column: " .. col)
      self:reveal(row, col)
      os.execute("sleep 2")
    end

    if self.movesLeft == 0 then
      self:gameHUD()
      print('You won!')
      break
    end
  end
end


function Minesweeper:play()
  math.randomseed(os.time())
  self.startTime = os.time()
  self:gameHUD()

  local action, row, col = self:makeMove()
  self:placeMines(row, col)
  if action == 1 then
    self:reveal(row, col)
  else
    self:toggleFlag(row, col)
  end

  while true do
    self:gameHUD()

    local action, row, col = self:makeMove()

    if not action then
      print("Invalid move. Try again.")
    elseif action == 2 then
      self:toggleFlag(row, col)
    else
      if self:hasMine(row, col) and not self:hasFlag(row, col) then
        self:revealAllMines()
        self:gameHUD()
        print('You lost!')
        break
      end

      self:reveal(row, col)

      if self.movesLeft == 0 then
        self:gameHUD()
        print('You won!')
        break
      end
    end
  end
end

return Minesweeper
