package main

import "core:log"

import rl "vendor:raylib"

main :: proc() {
	context.logger = log.create_console_logger()

	rl.InitWindow(800, 600, "Drone Simulator")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.GRAY)
		rl.DrawRectangle(400 - 100, 300 - 50, 200, 100, rl.GREEN)
		rl.EndDrawing()
	}
}

