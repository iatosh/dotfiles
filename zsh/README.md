# ZSH Configuration

Modern ZSH setup with Zinit plugin manager and optimized for fast startup.

## Structure

```
zsh/
├── .zprofile         # Homebrew setup (login shell only)
├── .zshrc           # Main entry point
└── .zsh/
    ├── env.zsh      # Environment variables, PATH, options
    ├── plugins.zsh  # Zinit and plugins
    ├── aliases.zsh  # Command shortcuts
    ├── functions.zsh # Custom functions
    └── tools.zsh    # External tools (fzf, nvm, zoxide, etc.)
```

## Features

### Smart Plugin Management
- **Zinit** with Turbo Mode for lazy loading
- **Powerlevel10k** prompt theme
- Syntax highlighting and autosuggestions
- Auto-installs on first run

### Enhanced Commands
- `ls` → eza (with icons and git status)
- `cat` → bat (syntax highlighting)
- `Ctrl+R` → fzf history search

## Customization

### Add Aliases
Edit `aliases.zsh`:
```bash
alias gs='git status'
alias dc='docker-compose'
```

### Add Functions
Edit `functions.zsh`:
```bash
myfunction() {
    echo "Hello $1"
}
```

### Add Tools
Edit `tools.zsh`:
```bash
if command -v newtool &>/dev/null; then
    eval "$(newtool init zsh)"
fi
```

### Private Variables
Create `.secrets` in dotfiles root:
```bash
export OPENAI_API_KEY="sk-..."
```

## Useful Functions

- `mkcd` - Make directory and cd into it
- `extract` - Extract any archive format
- `fcd` - Fuzzy find and cd
- `fe` - Fuzzy find and edit file
- `fbr` - Switch git branches with fzf
- `serve` - Start HTTP server in current directory

## Tips

- Type directory name directly to cd (no need for `cd` command)
- Use `k` for detailed directory listing with git info
- Press `Alt+C` to fuzzy search directories
- Use `z <partial-name>` to jump to frequently used directories

## Troubleshooting

### Slow startup?
```bash
# Check startup time
time zsh -i -c exit

# Common causes:
# - NVM loading (already optimized in this config)
# - Too many things in PATH
```

### Missing commands?
```bash
# Install required tools
brew install eza bat fzf zoxide

# Reinstall plugins
zinit delete --clean
exec zsh
```
