local const = {
  games = {
    {
      name = 'Sudoku',
      filename = 'sudoku',
    },
    {
      name = "Minesweeper",
      filename = "minesweeper",
      difficulties = {
        { level = "Beginner", rows = 9, columns = 9, mines = 10 },
        { level = "Intermediate",  rows = 16, columns = 16, mines = 40 },
        { level = "Expert", rows = 16, columns = 30, mines = 99 },
      },
    },
  }
}

return const
