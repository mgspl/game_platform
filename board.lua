local Board = {}

function Board.create(rows, columns, defaultValue)
  local board = {}
  board.rows = rows
  board.columns = columns
  board.data = {}

  for i=1,rows do
    board.data[i] = {}
    for j=1,columns do
      board.data[i][j] = defaultValue
    end
  end

  setmetatable(board, {
    __index = Board
  })
  return board
end

function Board:draw()
  local buf = {}
   buf[#buf + 1] = "  "
  for i=1,self.columns do
    buf[#buf + 1] = " "
    buf[#buf + 1] = tostring(i)
  end
  buf[#buf + 1] = "\n"
  for i=1,self.rows do
    local row = self.data[i]
    buf[#buf + 1] = " "
    buf[#buf + 1] = tostring(i)
    for j=1,#row do
      buf[#buf + 1] = " "
      buf[#buf + 1] = row[j]
    end
    buf[#buf + 1] = "\n"
  end
  print(table.concat(buf))
end

function Board:setValue(row, column, value)
  self.data[row][column] = value
end

function Board:getValue(row, column)
  return self.data[row][column]
end

return Board
