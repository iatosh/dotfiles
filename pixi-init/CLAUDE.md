# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

pixi-init is an interactive CLI tool for generating Python project templates using the Pixi package manager. It's part of a dotfiles collection and provides opinionated project scaffolding with modern Python development tools.

## Common Commands

### Running the Tool

```bash
# Run the interactive project generator
pixi-init

# The tool is located at .local/bin/pixi-init
```

### Development and Testing

Since this is a CLI tool script, there's no traditional build process. To test changes:

```bash
# Run the script directly after making changes
python .local/bin/pixi-init

# Or if you have it in your PATH
pixi-init
```

## Architecture

### Core Components

1. **Main Script** (`.local/bin/pixi-init`): The interactive CLI that orchestrates project generation
2. **Configuration Files** (`.config/pixi-init/`):
   - `tools.yaml`: Defines available development tools and their pixi dependencies
   - `structures.yaml`: Defines project type templates (ML, Custom)
3. **Templates** (`.config/pixi-init/templates/`): Base files like .gitignore and .gitattributes

### Key Design Patterns

- Uses Gum for beautiful terminal UI interactions
- YAML-driven configuration for extensibility
- Template-based file generation with dynamic content based on user selections
- Modular tool selection system where each tool can modify generated files

### Tool Integration Flow

1. User selects project type (ML/Custom)
2. User selects tools from available options
3. Each selected tool:
   - Adds its dependencies to pixi.toml
   - Adds its tasks to pixi.toml
   - May modify source files (e.g., Hydra modifies train.py, WandB adds tracking code)
   - May add configuration files (e.g., mypy.ini, .pre-commit-config.yaml)

### Adding New Tools

To add a new development tool:

1. Add entry to `.config/pixi-init/tools.yaml` with dependencies and tasks
2. If the tool needs to modify generated files, update the relevant logic in the main script
3. Consider if the tool needs special handling for different project types

### Adding New Project Types

To add a new project structure:

1. Add entry to `.config/pixi-init/structures.yaml`
2. Define the directory structure and initial files
3. Update the main script if special file generation logic is needed
