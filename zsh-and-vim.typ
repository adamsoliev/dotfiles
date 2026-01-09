#set page(width: 6in, height: 4in, margin: 0.18in, flipped: false)
#set text(font: "Libertinus Serif", size: 7.5pt)
#set columns(4, gutter: 0.14in)
#set par(leading: 0.55em)
#show heading.where(level: 2): it => {
  v(0.1em)
  it
  v(0.1em)
}
#set table(stroke: 0.4pt, inset: 3.5pt)

#columns[
== Zsh: Config
#table(columns: (auto, 1fr),
  [`vz`], [edit .zshrc],
  [`sz`], [source .zshrc],
  [`vv`], [edit .vimrc],
  [`dots`], [sync dotfiles],
)
== Zsh: Search
#table(columns: (auto, 1fr),
  [`grep`], [colorized],
  [`cgrep`], [recursive w/ context],
  [`rgrep`], [ripgrep],
  [`rgs`], [rg with header],
  [`dsstore`], [rm .DS_Store],
)
== Zsh: Multipass
#table(columns: (auto, 1fr),
  [`m`], [multipass],
  [`mdefault`], [4c/4g/25g],
)
== Zsh: Git
#table(columns: (auto, 1fr),
  [`ga`], [add],
  [`gaa`], [add --all],
  [`gb`], [branch],
  [`gba`], [branch -a],
  [`gbd`], [branch -d],
  [`gc`], [commit -v],
  [`gcmsg`], [commit -m],
  [`gco`], [checkout],
  [`gcb`], [checkout -b],
  [`gd`], [diff],
  [`gds`], [diff --staged],
  [`gf`], [fetch],
  [`gl`], [pull],
  [`glog`], [log graph],
  [`gm`], [merge],
  [`gp`], [push],
  [`gst`], [status],
  [`gclean`], [prune gone],
)
== Zsh: Misc
#table(columns: (auto, 1fr),
  [`du`], [disk usage -h],
  [`cheat`], [cheatsheet],
  [`token`], [access token],
)
== Zsh: AI CLI
#table(columns: (auto, 1fr),
  [`updateclaude`], [claude],
  [`updategemini`], [gemini],
  [`updatecodex`], [codex],
)
== Vim: Leader
#table(columns: (auto, 1fr),
  [`SPC f`], [fzf files],
  [`SPC g`], [fzf git files],
  [`SPC r`], [ripgrep],
  [`SPC d`], [diagnostics],
  [`SPC /`], [comment],
  [`SPC w`], [save],
  [`SPC 1-4`], [tab 1-4],
)
== Vim: LSP
#table(columns: (auto, 1fr),
  [`gd`], [go to definition],
  [`gi`], [go to impl],
  [`gr`], [references],
  [`K`], [hover docs],
  [`SPC rn`], [rename],
  [`SPC ca`], [code action],
)
== Vim: Navigation
#table(columns: (auto, 1fr),
  [`j / k`], [wrapped lines],
  [`]d`], [next diag],
  [`[d`], [prev diag],
  [`C-h/j/k/l`], [window nav],
  [`C-o`], [jump back],
  [`C-i`], [jump forward],
)
== Vim: Misc
#table(columns: (auto, 1fr),
  [`jj`], [escape],
  [`:H`], [clear highlight],
)
]
