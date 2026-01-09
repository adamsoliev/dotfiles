#set text(font: "Libertinus Serif", size: 8pt)
#set par(leading: 0.35em)
#show heading: set text(size: 8pt)

#columns(2, gutter: 0.12in)[
== Zsh: Config
```
vz                # edit .zshrc
sz                # source .zshrc
vv                # edit .vimrc
dots              # sync dotfiles
```

== Zsh: Search
```
grep              # colorized
cgrep             # recursive w/ context
rgrep             # ripgrep
rgs               # rg with header
dsstore           # rm .DS_Store
```

== Zsh: Git
```
ga / gaa          # add / add --all
gb / gba          # branch / branch -a
gbd               # branch -d
gc / gcmsg        # commit -v / commit -m
gco / gcb         # checkout / checkout -b
gd / gds          # diff / diff --staged
gf / gl / gp      # fetch / pull / push
glog              # log graph
gm                # merge
gst               # status
gclean            # prune gone
```

== Zsh: Misc
```
m                 # multipass
mdefault          # 4c/4g/25g
du                # disk usage -h
cheat             # cheatsheet
token             # access token
updateclaude      # update claude
updategemini      # update gemini
updatecodex       # update codex
```

#colbreak()

== Leader (SPC)
```
SPC f             # fzf files
SPC g             # fzf git files
SPC r             # ripgrep
SPC d             # diagnostics
SPC /             # comment
SPC w             # save
SPC 1-4           # tab 1-4
SPC rn            # rename
SPC ca            # code action
```

== LSP
```
gd                # go to definition
gi                # go to impl
gr                # references
K                 # hover docs
```

== Navigation
```
j / k             # wrapped lines
]d / [d           # next/prev diag
C-h/j/k/l         # window nav
C-o / C-i         # jump back/forward
```

== Misc
```
jj                # escape
:H                # clear highlight
```
]
