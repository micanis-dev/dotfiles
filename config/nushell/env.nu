# Nushell environment — sourced before config.nu

# PATH (devbox/direnv handle per-project tools)
$env.PATH = ($env.PATH | split row (char esep) | prepend [
    ($env.HOME | path join ".local" "bin")
] | uniq)

# Editor
$env.EDITOR = "hx"
$env.VISUAL = "hx"

# True color (24-bit) — Linux 環境で Helix のテーマカラーが 256 色に丸められないように明示
$env.COLORTERM = "truecolor"

$env.DIRENV_LOG_FORMAT = ""
