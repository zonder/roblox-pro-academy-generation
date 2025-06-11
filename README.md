# Monster Generation System - Roblox Studio Setup Guide

This guide describes how to properly structure and set up the Monster Generation System in Roblox Studio.

## Overview

The Monster Generation System allows players to create custom monsters by selecting different parts (head, torso, legs, arms) through an interactive UI. The system uses Roblox's GenerationService to create 3D meshes based on text prompts.

## Studio Object Structure

### 1. ReplicatedStorage Setup

Create the following RemoteEvents in ReplicatedStorage:

```
ReplicatedStorage/
├── MeshGenerationEvent (RemoteEvent)
└── GenerationResultEvent (RemoteEvent)
```

**How to create:**
1. In Explorer, right-click on `ReplicatedStorage`
2. Insert → RemoteEvent
3. Rename to `MeshGenerationEvent`
4. Repeat for `GenerationResultEvent`

### 2. ServerScriptService

Place server-side scripts here:

```
ServerScriptService/
└── MeshGenerationServer.luau (Script), run context should be set to Server
```

**Contents:** Handles client requests for mesh generation and communicates with GenerationService.

### 3. StarterPlayer Structure

Client-side modules and scripts:

```
StarterPlayer/
└── StarterCharacterScripts/
    ├── MonsterGenerator.luau (ModuleScript)
    ├── MonsterGenerationEffectHandler.luau (ModuleScript)
    └── PartSelectorUI.luau (ModuleScript)
```

**Module Descriptions:**
- **MonsterGenerator.luau**: Main class that manages the generation process, UI creation, and event handling
- **MonsterGenerationEffectHandler.luau**: Handles visual effects during generation and mesh positioning
- **PartSelectorUI.luau**: Creates the carousel-style part selection interface

### 4. Workspace Structure

Physical game objects:

```
Workspace/
└── MonsterStand/ (Part or Model)
    ├── PromptParent/ (Part)
    │   └── ProximityPrompt (ProximityPrompt)
    └── MonsterGeneratorStand.luau (Script), run context should be set to Client
```

## Setting up a Monster Generation Stand

### Step 1: Create the Stand Structure

1. **Create the main stand part:**
   - Insert a Part in Workspace
   - Name it `MonsterStand` (or any name you prefer)
   - Size and position as desired

2. **Create the prompt part:**
   - Insert a Part inside the stand
   - Name it `PromptParent`
   - This part will contain the ProximityPrompt

3. **Add ProximityPrompt:**
   - Insert a ProximityPrompt inside `PromptParent`
   - Configure properties:
     - `ActionText`: "Generate Monster"
     - `ObjectText`: "Monster Stand"
     - `MaxActivationDistance`: 10 (or desired range)

4. **Add the LocalScript:**
   - Insert a LocalScript inside the main stand part
   - Name it `MonsterGeneratorStand`
   - Copy the contents from `src/Workspace/MonsterStand/MonsterGeneratorStand.luau`

### Step 2: Script Hierarchy

The LocalScript should be placed at the same level as the PromptParent:

```
MonsterStand (Part)
├── PromptParent (Part)
│   └── ProximityPrompt
└── MonsterGeneratorStand (LocalScript) ← Place here
```

## Key Features

### Multi-Stand Support
- Each stand creates a unique ScreenGui to prevent conflicts
- Instance-specific state management
- Copy the stand structure to create multiple generation points

### UI System
- **Normal Mode**: Interactive carousel with navigation arrows
- **Preview Mode**: Read-only display with cyan glow styling
- Bottom-positioned to avoid blocking generated meshes
- Auto-selection for unselected parts (random generation)

### Generation Process
1. Player approaches stand → UI appears
2. Player selects parts or leaves unselected for random
3. Player clicks Generate → UI switches to preview mode
4. Visual effects play during generation
5. Generated mesh appears scaled and positioned on stand

### Visual Effects
- Spinning, pulsing orb during generation
- Particle effects and lighting
- 5x mesh scaling and automatic positioning
- Anchored mesh placement on stand top

## Asset Requirements

The system includes predefined monster part assets. If you want to customize parts, update the `PART_OPTIONS` table in `MonsterGenerator.luau` with your own Roblox asset IDs.

## Testing

1. Ensure all RemoteEvents are created in ReplicatedStorage
2. Place all scripts in their respective locations
3. Create at least one monster stand with proper hierarchy
4. Test in Studio with local server simulation
5. Verify UI appears when approaching the stand
6. Test generation with various part combinations

## Troubleshooting

**UI not appearing:**
- Check ProximityPrompt configuration
- Verify LocalScript is in the correct location
- Ensure all modules are in StarterCharacterScripts

**Generation not working:**
- Verify RemoteEvents exist in ReplicatedStorage
- Check server script is running
- Enable GenerationService in game settings

**Multiple stands interfering:**
- Each stand should have its own LocalScript
- Unique ScreenGui names prevent conflicts
- Instance-specific effect handling

## Learn More

Want to master Roblox development with comprehensive courses and hands-on practice? Check out **[Roblox Pro Academy](https://robloxpro.academy/)** for more in-depth tutorials, interactive learning experiences, and a complete curriculum that takes you from beginner to pro developer!

🎮 **Build Your Dreams** - Watch videos, read guides, and practice in our custom Roblox world alongside thousands of other developers building amazing games.