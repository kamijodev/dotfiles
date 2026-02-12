typeset -A MISSING_TOOLS
MISSING_TOOLS=()

# pacman
command -v nvim &> /dev/null || MISSING_TOOLS[neovim]="pacman -S neovim"
command -v jq &> /dev/null || MISSING_TOOLS[jq]="pacman -S jq"
command -v notify-send &> /dev/null || MISSING_TOOLS[libnotify]="pacman -S libnotify"
command -v alacritty &> /dev/null || MISSING_TOOLS[alacritty]="pacman -S alacritty"
command -v wezterm &> /dev/null || MISSING_TOOLS[wezterm]="pacman -S wezterm"
command -v nautilus &> /dev/null || MISSING_TOOLS[nautilus]="pacman -S nautilus"
command -v grim &> /dev/null || MISSING_TOOLS[grim]="pacman -S grim"
command -v slurp &> /dev/null || MISSING_TOOLS[slurp]="pacman -S slurp"
command -v satty &> /dev/null || MISSING_TOOLS[satty]="pacman -S satty"
command -v wl-copy &> /dev/null || MISSING_TOOLS[wl-clipboard]="pacman -S wl-clipboard"
command -v websocat &> /dev/null || MISSING_TOOLS[websocat]="pacman -S websocat"

# AUR
command -v google-chrome-canary &> /dev/null || MISSING_TOOLS[google-chrome-canary]="paru -S google-chrome-canary"
command -v wl-screenrec &> /dev/null || MISSING_TOOLS[wl-screenrec]="paru -S wl-screenrec"
command -v lotion &> /dev/null || MISSING_TOOLS[lotion]="paru -S lotion-bin"

# pip (asdf python)
command -v gcalcli &> /dev/null || MISSING_TOOLS[gcalcli]="pip install gcalcli"

# CLI tools
command -v claude &> /dev/null || MISSING_TOOLS[claude]="https://docs.anthropic.com/en/docs/claude-code"

if (( ${#MISSING_TOOLS[@]} > 0 )); then
  echo "Missing tools:"
  for tool url in ${(kv)MISSING_TOOLS}; do
    echo "  $tool: $url"
  done
fi
