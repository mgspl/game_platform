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
        { level = "Beginner", side = 9, mines = 10 },
        { level = "Intermediate",  side = 16, mines = 40 },
        { level = "Expert", side = 24, mines = 99 },
      },
    },
  }
}

return const
