# Politician Sim - iOS Game

A political life simulation game built with SwiftUI for iOS.

## Project Status

**Phase 1: Foundation & Early Life** (In Progress)

### Completed
- ✅ Xcode project structure
- ✅ Core data models (Character, GameState, Event, Country)
- ✅ GameManager singleton with state management
- ✅ Basic app setup with SwiftUI
- ✅ Constants and color system

### In Progress
- 🔄 UI component library
- 🔄 Character creation flow
- 🔄 Time system implementation

## Requirements

- **iOS:** 16.0+
- **Xcode:** 15.0+
- **Swift:** 5.9+

## Project Structure

```
PoliticianSim/
├── App/
│   ├── PoliticianSimApp.swift      # Main app entry point
│   └── ContentView.swift            # Root view
├── Models/
│   ├── Character.swift              # Character data model
│   ├── GameState.swift              # Game state management
│   ├── Stats.swift                  # Stat tracking
│   ├── Event.swift                  # Event system
│   └── Country.swift                # Country/government systems
├── ViewModels/
│   └── GameManager.swift            # Singleton game manager
├── Views/
│   ├── Home/                        # Home view components
│   ├── Profile/                     # Profile view components
│   ├── Career/                      # Career progression views
│   ├── Shared/                      # Shared UI components
│   └── Components/                  # Reusable UI components
├── Services/
│   ├── SaveManager.swift            # Save/load functionality
│   ├── EventEngine.swift            # Event triggering logic
│   └── TimeManager.swift            # Time progression
├── Resources/
│   ├── Events/                      # JSON event files
│   └── Countries/                   # Country configuration files
└── Utilities/
    ├── Constants.swift              # App constants
    └── Extensions/                  # Swift extensions
```

## Architecture

- **Pattern:** MVVM (Model-View-ViewModel)
- **State Management:** Combine framework with @Published properties
- **Data Persistence:** Codable JSON files
- **UI Framework:** SwiftUI with SF Symbols

## Key Features

### Phase 1 (Current)
- Character creation with customization
- Time progression system (Day/Week skip)
- Early life simulation (ages 0-17)
- Event system with choices and consequences
- Save/load functionality with autosave

### Future Phases
- Career progression (Community Organizer → President)
- Election system
- Scandal and policy mechanics
- Multi-country support (10 countries)
- Warfare and territory management

## Building

1. Open `PoliticianSim.xcodeproj` in Xcode
2. Select target device (iPhone or simulator)
3. Press ⌘R to build and run

## Documentation

See project root for comprehensive documentation:
- [GDD.md](../GDD.md) - Complete game design document
- [UI.md](../UI.md) - UI/UX specifications
- [gameplan.md](../gameplan.md) - Development roadmap

## License

Copyright © 2024 Politician Sim. All rights reserved.
