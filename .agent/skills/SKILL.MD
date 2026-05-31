Skill Name: HexaShiftFlutterBuilder

Purpose: Generate a fully functional 2D puzzle game in Flutter based on Hexa Shift. AI must follow clean architecture principles, separate UI, model, and logic, and implement all game rules, tile behaviors, and board mechanics.

Instructions:

1. **Board & Tile Models**
- HexBoard: holds all HexTile objects.
- HexTile: properties:
  - row, col (position)
  - direction (ArrowDirection enum: up, down, upLeft, upRight, downLeft, downRight)
  - cleared (bool)
- HexBoard methods:
  - moveTile(tile): move tile along its arrow, apply chain reactions to adjacent tiles
  - getTile(row, col)
  - isCleared(): return true if all tiles are cleared
- Tiles only move along arrows; invalid moves blocked.
- Chain reaction logic: moving a tile may rotate or flip neighbor tiles.

2. **UI & Rendering**
- Use CustomPainter to draw hex tiles with arrows and colors based on cleared state.
- Animate tile movement and flips using AnimationController or TweenAnimationBuilder.
- Highlight valid moves when a tile is tapped.
- Board scales dynamically to screen size; handle portrait and landscape.

3. **Coordinates & Layout**
- Use axial coordinates for hex grid: q = column, r = row
- Compute hex center: x = radius * 3/2 * col, y = radius * sqrt(3) * (row + 0.5 * (col % 2))
- Tiles aligned precisely, maintain hexagonal spacing.

4. **Game Logic**
- Game goal: clear all tiles by moving along arrows.
- Moving order matters; wrong sequence can deadlock board.
- Undo/redo moves functionality.
- Detect win: board.isCleared() == true.
- Difficulty levels: configurable small → large boards.

5. **Architecture**
- Maintain clean separation:
  - Model: HexTile, HexBoard, ArrowDirection
  - UI: HexBoardWidget, HexBoardPainter
  - Logic: moveTile, chainReaction, undo/redo
- Use Provider, Riverpod, or similar state management.
- Save/load board state with JSON or local storage.

6. **Extras**
- Easily extendable for new tile types, arrow behaviors, or special tiles.
- Smooth animations for all tile interactions.
- Clear comments explaining all logic and calculations.
- Output full Flutter project structure: main.dart, models, widgets, utils, assets.

Output Requirements:
- Complete Flutter code that runs without manual modifications.
- Board example: at least 5x5 tiles with arrows in initial positions.
- Comments for each method explaining purpose.
- Code must be readable, maintainable, scalable.

AI Execution:
- Always follow this skill prompt when generating Hexa Shift game code.
- Do not skip any board, tile, logic, or animation requirements.
- Maintain clean architecture and Flutter best practices.