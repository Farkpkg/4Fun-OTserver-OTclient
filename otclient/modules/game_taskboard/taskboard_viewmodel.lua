TaskBoardViewModel = TaskBoardViewModel or {}

function TaskBoardViewModel.build(state)
  local selectedTab = state.ui.selectedTab

  return {
    selectedTab = selectedTab,
    bounty = {
      showDifficultyGate = state.board.boardState == 'WAITING_DIFFICULTY',
      difficulties = state.board.difficulties,
      selectedDifficulty = state.board.difficulty
    }
  }
end
