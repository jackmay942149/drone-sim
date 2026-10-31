# Overview
Simulation GSEE for drone project.

# Compilation
## Build and Run (Recommended)
In root directory: 
`odin run .`

## Build
In root directory: 
`odin build .`

# Dependencies
| Name | Version | Installation | Status |
| :---: | :---: | :---: | :---: |
| Odin | dev-2026-10-nightly | scoop | Confirmed |

# Controls
`r` - Resets scene
`g` - Toggles gravity
`q` - Apply anticlockwise torque
`e` - Apply clockwise torque
`[space]` - Pauses simulation

# Modules
## Physics
Is responsible for managing a physics simulation and must be independent of rendering to provide the ability for visualisations, automations, training, testing, and playback


