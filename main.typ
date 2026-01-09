#set page(paper: "us-letter", margin: 0.5in)

#let card(body) = rect(
  width: 5in,
  height: 4in,
  inset: 0.2in,
  stroke: 1pt + black,
  body
)

#grid(
  columns: 1,
  rows: 2,
  gutter: 0.25in,
  card(include "go-content.typ"),
  card(include "zsh-and-vim-content.typ"),
)
