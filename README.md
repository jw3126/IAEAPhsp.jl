# IAEAPhsp

## Usage
```
using IAEAPhsp
readparticles("path/to/IAEAheader") # read all particles into array
```

```
s = Source("path/to/IAEAheader")  # lazy iterator over particles
for p in s
    doit(p)
end
```
