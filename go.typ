#set page(width: 5in, height: 4in, margin: 0.2in)
#set text(font: "Libertinus Serif", size: 6.5pt)
#set par(leading: 0.35em)

#columns(2, gutter: 0.12in)[
= Go Project Navigation

== Finding Code
```
go list ./...              # all packages
go doc .                   # package docs
go doc TypeName            # type docs
grep -rn "type Foo struct" # find type
grep -rn "func Bar("       # find function
```

== Building & Running
```
go build ./...             # check all
go build ./cmd/name        # build cmd
go run ./cmd/name          # run cmd
go install ./cmd/name      # install
```

== Testing
```
go test ./...              # all tests
go test -run TestName .    # one test
go test -v ./...           # verbose
go test -tags foo ./...    # with tags
```

== Dependencies
```
go mod tidy                # clean deps
go mod graph               # dep graph
go list -m all             # list modules
```

#colbreak()

= Performance & Profiling

== Benchmarks
```
go test -bench=. ./...           # run all
go test -bench=BenchName .       # run one
go test -bench=. -benchmem .     # +memory
go test -bench=. -count=5 .      # repeat
go test -bench=. -cpuprofile=c.out .
```

== Profiling
```
# generate profiles
go test -cpuprofile=cpu.out -bench=. .
go test -memprofile=mem.out -bench=. .
go test -blockprofile=blk.out -bench=. .
go test -mutexprofile=mtx.out -bench=. .

# analyze with pprof
go tool pprof cpu.out
go tool pprof -http=:8080 cpu.out
```

== pprof Commands (interactive)
```
top              # hottest functions
top -cum         # by cumulative time
list FuncName    # annotated source
web              # open graph in browser
```

== Tracing
```
go test -trace=trace.out -bench=. .
go tool trace trace.out
```

== Race Detection
```
go test -race ./...
go build -race ./cmd/name
```
]
