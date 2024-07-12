# defold-astar-hex-example

![A*](/.github/astar-hex.png?raw=true)

Hexagonal Example for [defold-astar](https://github.com/selimanac/defold-astar?tab=readme-ov-file)  
Test it: [https://selimanac.github.io/defold-astar-hex-example/](https://selimanac.github.io/defold-astar-hex-example/)   
  
Art Credit: [Kenny](https://kenney.nl/)   


You can set the map type to odd-r or even-r. odd-q and even-q types are not supported in this example.  
Just set the `map_type` variable on `main.script` file accordingly.  

```lua

-- SET IT TO -> astar.HEX_EVENR or astar.HEX_ODDR to see the difference
-- See: https://github.com/selimanac/defold-astar?tab=readme-ov-file#astarset_map_typetype
local map_type = astar.HEX_ODDR


```

### Dependencies:
- [defold-orthographic](https://github.com/britzl/defold-orthographic/)  
- [defold-astar](https://github.com/selimanac/defold-astar/)   
- [defold-hexagon](https://github.com/selimanac/defold-hexagon/) 
