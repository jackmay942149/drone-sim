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
		rl.ClearBackground(rl.WHITE)
		rl.DrawText("Hello, World!", 200, 200, 20, rl.LIGHTGRAY)
		rl.EndDrawing()
	}
}

