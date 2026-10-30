local const = {
  games = {
    {
      name = 'Sudoku',
      filename = 'sudoku',
    },
    {
      name = "Minesweeper",
      filename = "minesweeper",
      beginner = { sides = 9, mines = 10},
      intermediate = { sides = 16, mines = 40},
      expert = { sides = 24, mines = 99},
    },
  }
}

return const
