# Szélességi bejárás

_A feladatok egymásra épülnek ezért a megadásuk sorrendjében kell ezeket megoldani! A függvények definíciójában lehet, sőt javasolt is alkalmazni a korábban definiált függvényeket. A megoldást egyetlen, önálló modulként kell beküldeni szövegesen._

_Tekintve, hogy a tesztesetek, bár odafigyelés mellett íródnak, nem fedik le minden esetben egy-egy függvény teljes működését, ezért határozottan javasolt még külön próbálgatni a megoldásokat beadás előtt, vagy megkérdezni az oktatókat!_

_A programban ne használjunk beégetett konstansokat, kivéve, ha a feladat kifejezetten erre utasít!_

## A feladat összefoglaló leírása

A szélességi bejárás (Breadth First Search, vagy röviden BFS algoritmus) az egyik legismertebb gráfalgoritmus. Lényege, hogy egy adott gráfból és kezdőcsúcsból kiindulva feltérképezi a gráfot, mégpedig úgy, hogy mindig az aktuálisan vizsgált csúcs szomszédait dolgozza fel.

Ahhoz, hogy ezt a gráfalgoritmust megvalósíthassuk, szükséges a gráf valamilyen reprezentációja. A legelterjedtebb gráfábrázolási módszerek a szomszédsági mátrix és az éllistás ábrázolás.

*   Szomszédsági mátrixoknál <span class="math inline">n</span> csúcsú gráf esetén egy <span class="math inline">n \times n</span> méretű mátrixszal dolgozunk. Ha az <span class="math inline">i</span> és <span class="math inline">j</span> indexű csúcsok között van él, akkor a mátrix <span class="math inline">[i,j]</span> indexű helyén az él súlya szerepel. Ha nincs, akkor ez <span class="math inline">\infty</span>. (A mátrix főátlója végig nullákból áll, hisz egy csúcsból önmagába eljutni egy 0 költségű út.)

*   Éllistás ábrázolásnál <span class="math inline">n</span> csúcsú gráf esetén ez egy <span class="math inline">n</span> hosszú adatszerkezet amelynek az elemei listák. A lista elemei lesznek az élek, amelyeket párokként ábrázolunk, ahol a pár első eleme az él végpontja, a második eleme pedig az él súlya.

Például, ha van egy háromcsúcsú gráfunk, ahol a csúcsokat nullától sorszámozzuk és a 0-ás és az 1-es indexű csúcsok között van egy 5 súlyú él, akkor ezt a következőképpen ábrázolhatjuk.

Szomszédsági mátrixszal:

```
0 5 ∞
∞ 0 ∞
∞ ∞ 0
```

ahol az ∞ a végtelen értéket jelöli.

Éllistával: `[[(1,5)],[],[]]`

A tesztekben használt egy gráfot fogunk használni, amelyeket az említett ábrázolási módokkal a következőképpen írunk le.

Szomszédsági mátrixszal:

```
listAdj :: [] Adjacency
listAdj =
  [(White,[(Weight 0),(Weight 1),Infinite,Infinite,Infinite,Infinite,Infinite])
  ,(Gray,[(Weight 1),(Weight 0),Infinite,(Weight 1),Infinite,Infinite,(Weight 1)])
  ,(Black,[(Weight 1),Infinite,(Weight 0),Infinite,Infinite,Infinite,Infinite])
  ,(Gray,[Infinite,(Weight 1),Infinite,(Weight 0),(Weight 1),Infinite,Infinite])
  ,(White,[Infinite,Infinite,Infinite,(Weight 1),(Weight 0),Infinite,Infinite])
  ,(Black,[Infinite,Infinite,(Weight 1),Infinite,(Weight 1),(Weight 0),Infinite])
  ,(White,[Infinite,Infinite,Infinite,Infinite,Infinite,(Weight 1),(Weight 0)])
  ]
```

Éllistás ábrázolással:

```
listEdge :: [] EdgeList
listEdge =
  [(White,[(1,(Weight 1))])
  ,(Gray,[(0,(Weight 1)),(3,(Weight 1)),(6,(Weight 1))])
  ,(Black,[(0,(Weight 1))])
  ,(Gray,[(1,(Weight 1)),(4,(Weight 1))])
  ,(White,[(3,(Weight 1))])
  ,(Black,[(2,(Weight 1)),(4,(Weight 1))])
  ,(White,[(5,(Weight 1))])
  ]
```

## A szükséges típusok definiálása

A gráf különböző ábrázolási módjaihoz szükség lesz a következő típusokra:

*   `Weight` : algebrai adattípus, melynek két típuskonstruktora van:

    *   `Weight :: Int-> Weight` : a nem végtelen súly ábrázolása.
    *   `Infinite :: Weight` : a végtelen súly ábrázolása, azaz nincs él a két csúcs között.
*   `Color` : algebrai adattípus, mely a gráf csúcsainek színezésére szolgál, típuskonstruktorai a következők:

    *   `White :: Color`
    *   `Gray :: Color`
    *   `Black :: Color`

Ezeken felül definiáljuk még a következő típusszinonímákat:

*   `Vertex`, amely az `Int` típusnak felel meg.
*   `EdgeList`, amely a `(Color, [(Vertex, Weight)])` pár megfelelője.
*   `Adjacency`, amely a `(Color, [Weight])` pár megfelelője.

Az `EdgeList` és az `Adjacency` típusok egy csúcs adatait tartalmazzák, első komponensként, hogy az adott csúcs milyen színű, másodikként pedig az adott csúcs szomszédait.

## Generikus egyenlőség

A `Color` és a `Weight` típusaink vizsgálatához használjunk a Clean `GenEq` modulját, amely generikusan képes vizsgálni egyenlőséget, anélkül, hogy nekünk az erre vonatkozó típusosztály példányait egyesével meg kellene írnunk! A `GenEq` modulból érhető el az `===` operátor, ezt fogjuk alkalmazni a tesztekben is.

## A `Node` típusosztály

Adott a `Node` típusosztály, amely azt mondja meg, hogy egy típusnak milyen műveletekkel kell rendelkeznie ahhoz, hogy egy gráf csúcsaként használható legyen. Implementáljuk ezeket a függvényeket mind az `Adjacency`, mind az `EdgeList` típusra!

```
class Node t where
  newNode      :: Int -> t
  getColor     :: t -> Color
  color        :: t Color -> t
  neighbours   :: t -> [Vertex]
  add          :: t -> t
  addNeighbour :: t Vertex Weight -> t
```

Ennek részeként tehát:

### `newNode`

Definiáljuk a `newNode` függvényt, amely előállít egy új csúcsot a paraméterként adott szám alapján! A szám azt jelzi, hogy egy mekkora gráfban szeretnénk majd használni ezt a csúcsot. (Valójában a szomszédsági mátrixos ábrázolásnál van jelentősége.) Feltételezhetjük, hogy az újonnan létrehozott csúcs mindig a legutolsó lesz majd a gráfban, azaz ha eddig a gráf 5 csúcsot tartalmazott (azaz 4-es indexű volt az utoljára beillesztett csúcs), akkor ez az új csúcs 5-ös indexet fog kapni.

Például:

```
test_newNode =
  [ adj 2  === (White, [Infinite, Infinite, Weight 0])
  , adj 0  === (White, [Weight 0])
  , edge 0 === (White, [])
  ]
  where
    adj :: Int -> Adjacency
    adj x = newNode x

    edge :: Int -> EdgeList
    edge x = newNode x
```

### `getColor`

Készítsük el a `getColor` függvényt, amely le tudja kérdezni a paraméterként kapott csúcs színét!

Például:

```
test_getColor =
  [ map fst listAdj === [White,Gray,Black,Gray,White,Black,White]
  , map fst listAdj === map fst listEdge
  ]
```

### `color`

Készítsük el a `color` függvényt, amely beállítja a paraméterként kapott csúcs színét a paraméterként kapott színre!

Például:

```
test_color =
  [ color adj Gray === (Gray, [Weight 0, Infinite])
  , color adj Black === (Black, [Weight 0, Infinite])
  , color (color adj Black) White === (White, [Weight 0, Infinite])
  , color edge Black === (Black, [(1, Weight 2)])
  , color (color edge Gray) Black === (Black, [(1, Weight 2)])
  ]
  where
    adj :: Adjacency
    adj = (White, [Weight 0, Infinite])

    edge :: EdgeList
    edge = (White, [(1, Weight 2)])
```

### `neighbours`

Implementáljunk a `neighbours` függvényt, amely lekérdezi a paraméterként kapott csúcs szomszédait, azaz a függvény eredménye azoknak a csúcsoknak az indexe, amelyekbe vezet él a az adott csúcsból!

Például:

```
test_neighbours =
  [ map neighbours listAdj  === [[1],[0,3,6],[0],[1,4],[3],[2,4],[5]]
  , map neighbours listEdge === [[1],[0,3,6],[0],[1,4],[3],[2,4],[5]]
  ]
```

### `add`

Ha egy új csúcsot veszünk a gráfhoz, szomszédsági mátrixos ábrázolás esetén meg kell növelni a mátrixot. Erre szolgál az `add` függvény. Azaz a gráfban egy új csúcs hozzáadásakor minden, a gráfban szereplő, csúcsra meg kell hívni ezt a függvényt. Szomszédsági mátrixos ábrázolás esetén a paraméterként kapott csúcs és az új csúcs közötti távolságot végtelenre állítja, éllistás ábrázolás esetén nincs hatása.

Valósítsuk meg ezt!

Például:

```
test_add =
  [ add (adj 0)  === (White, [Weight 0, Infinite])
  , add (edge 0) === edge 0
  , add (adj 2)  === (White, [Infinite, Infinite, Weight 0, Infinite])
  , add (edge 5) === edge 3
  ]
  where
    adj :: Int -> Adjacency
    adj x = newNode x

    edge :: Int -> EdgeList
    edge x = newNode x
```

#### `addNeighbour`

Implementáljunk az `addNeighbour` függvényt, amelynek segítségével új élt hozhatunk létre két csúcs között! Paraméterei a csúcs, ahonnan az él indul, a célcsúcs indexe és az él súlya. Feltételezhetjük, hogy a paraméterek helyesek, azaz léteznek a csúcsok, amelyek közé élt akarunk húzni. Továbbá feltételezhetjük, hogy a csúcsok között még nincs él.

(A könnyebb tesztelhetőség kedvéért éllistás ábrázolás esetén is tartsunk sorrendet, mégpedig a célcsúcs indexe alapján. Azaz, ha egy csúcsból az 1-es és a 2-es indexű csúcsba is vezet él, akkor az `(White, [(1,Weight 1),(2,Weight 1)])` formában tároljuk, nem pedig `(White, [(2,Weight 1),(1,Weight 1)])`.)

Például:

```
test_addNeighbour =
  [ addNeighbour (adj 2) 1 (Weight 3) === (White, [Infinite, Weight 3, Weight 0])
  , addNeighbour (addNeighbour (adj 2) 1 (Weight 3)) 0 (Weight 5) === (White, [Weight 5, Weight 3, Weight 0])
  , addNeighbour (edge 2) 1 (Weight 3) === (White, [(1, Weight 3)])
  , addNeighbour (addNeighbour (addNeighbour (edge 3) 2 (Weight 3)) 0 (Weight 5)) 1 (Weight 6) === (White, [(0,Weight 5),(1, Weight 6), (2, Weight 3)])
  ]
  where
    adj :: Int -> Adjacency
    adj x = newNode x

    edge :: Int -> EdgeList
    edge x = newNode x
```

## A `Graph` típusosztály

A `Node` típusosztályhoz hasonlóan most csináljunk egy `Graph` típusosztályt, amely a gráfok interfészeként fog szolgálni! Ennek a típusosztálynak két típusparamétere lesz, az első egy olyan típus, amely maga is vár még egy típusparamétert, a második pedig a csúcs ábrázolásához használt típus. Azaz megadjuk, hogy a csúcsokat hogyan ábrázoljuk és azt is, hogy ezeket milyen konténertípusban tároljuk.

Itt szükségünk lesz tömb segítségével ábrázolt példagráfokra is, amelyek ugyanazt a gráfot fogják jelenteni, mint a listával ábrázolt párjuk.

```
arrayAdj :: {} Adjacency
arrayAdj = { x \\ x <- listAdj }

arrayEdge :: {} EdgeList
arrayEdge = { x \\ x <- listEdge }
```

Implementáljuk a `Graph` típusosztályt láncolt listára (`[]`) és tömbre (`{}`) is!

```
class Graph t1 t2 | Node t2 where
  resetGraph  :: (t1 t2) -> (t1 t2)
  graphSize   :: (t1 t2) -> Int
  getNode     :: (t1 t2) Vertex -> t2
  addNode     :: (t1 t2) -> (t1 t2)
  updateGraph :: (t1 t2) Vertex t2 -> (t1 t2)
```

Ennek részeként tehát:

#### `resetGraph`

Definiáljunk a `resetGraph` függényt, amely "alaphelyzetbe állítja" a paraméterként kapott gráfot, azaz minden csúcs színét fehérre (`White`) színezi!

Például:

```
test_resetGraph =
  [ map getColor (resetGraph listAdj) === repeatn 7 White
  , map getColor (resetGraph listEdge) === repeatn 7 White
  , [getColor x \\ x <-: (resetGraph arrayAdj)] === repeatn 7 White
  , [getColor x \\ x <-: (resetGraph arrayEdge)] === repeatn 7 White
  ]
```

#### `graphSize`

Írjunk meg a `graphSize` függvényt, amely megmondja egy gráf méretét, azaz a csúcsok számát!

Például:

```
test_graphSize =
  [ graphSize listAdj == 7
  , graphSize arrayAdj == 7
  ]
```

#### `getNode`

Írjunk meg a `getNode` függvényt, amely paraméterként kap egy gráfot és egy számot, és ezek alapján visszaadja a gráf adott indexű elemét!

Például:

```
test_getNode =
  [ getNode listAdj 1 === (Gray,[(Weight 1),(Weight 0),Infinite,(Weight 1),Infinite,Infinite,(Weight 1)])
  , map (getNode listAdj) [0..6] === map (getNode arrayAdj) [0..6]
  , getNode listEdge 3 === (Gray,[(1,(Weight 1)),(4,(Weight 1))])
  , map (getNode listEdge) [0..6] === map (getNode arrayEdge) [0..6]
  ]
```

#### `addNode`

Definiáljunk az `addNode` függvényt, amely a paraméterként kapott gráfba beilleszt egy új csúcsot! Az új csúcs indexe eggyel nagyobb lesz, mint az eddig a gráfban szereplő csúcsok indexeinek a maximuma.

Például:

```
test_addNode =
  [ getNode (addNode listAdj) (graphSize listAdj) === (White, [Infinite,Infinite,Infinite,Infinite,Infinite,Infinite,Infinite,Weight 0])
  , graphSize (addNode (addNode listEdge)) == 9
  , getNode (addNode (addNode arrayEdge)) (graphSize arrayEdge) === (White, [])
  ]
```

#### `updateGraph`

Írjunk meg az `updateGraph` függvényt, amely frissít egy gráfot! Azaz paraméterként kap egy gráfot, egy indexet és egy csúcsot, és ezek alapján a gráfban az adott indexű csúcsot frissíti a paramétreben kapott csúccsal.

Például:

```
test_updateGraph =
  [ getNode (updateGraph listAdj 1 na) 1 === na
  , getNode (updateGraph listEdge 1 ne) 1 === ne
  , getNode (updateGraph arrayAdj 1 na) 1 === na
  , getNode (updateGraph arrayEdge 1 ne) 1 === ne
  ]
  where
    ne :: EdgeList
    ne = (White, [])

    na :: Adjacency
    na = (Gray,[(Weight 1),(Weight 0),Infinite,(Weight 1),(Weight 2),Infinite,(Weight 1)])
```

## Színezetlen szomszédok lekérdezése

Definiáljunk egy függvényt, amely paraméterként kapott gráf és index alapján egy listában visszaadja az adott indexű elem `White` jelölésű szomszédait.

A függvény típusa legyen a következő:

```
whiteNeighbours :: (t1 t2) Vertex -> [Vertex] | Graph t1 t2
```

Néhány példa a működésére:

```
test_whiteNeighbours =
  [ whiteNeighbours listAdj 1 == [0,6]
  , whiteNeighbours listEdge 2 == [0]
  , map (whiteNeighbours listAdj) [0..6] == map (whiteNeighbours arrayAdj) [0..6]
  , map (whiteNeighbours listEdge) [0..6] == map (whiteNeighbours arrayEdge) [0..6]
  ]
```

## Él hozzáadása a gráfhoz

Definiáljunk egy függvényt, amely egy gráfhoz egy új élt ad hozzá! Feltételezhetjük, hogy a bemenő adatok helyesek, azaz az adott indexű csúcsok léteznek és még nincs köztük él.

A függvény típusa legyen a következő:

```
addEdgeToGraph :: (t1 t2) Vertex Vertex Weight -> (t1 t2) | Graph t1 t2
```

Például:

```
test_addEdgeToGraph =
  [ neighbours (getNode (addEdgeToGraph listAdj 3 0 (Weight 5)) 3) == [0,1,4]
  , neighbours (getNode (addEdgeToGraph listEdge 3 0 (Weight 5)) 3) == [0,1,4]
  , neighbours (getNode (addEdgeToGraph arrayAdj 3 0 (Weight 5)) 3) == [0,1,4]
  , neighbours (getNode (addEdgeToGraph arrayEdge 3 0 (Weight 5)) 3) == [0,1,4]
  , getNode (addEdgeToGraph listAdj 4 0 (Weight 5)) 4 === (White,[(Weight 5),Infinite,Infinite,(Weight 1),(Weight 0),Infinite,Infinite])
  ]
```

## Szélességi bejárás

Az eddig implementált függvények segítségével most már a gráf ábrázolási módjától függetlenül tudjuk implementálni a szélességi keresés algoritmusát. Ennek paraméterei egy gráf és egy létező csúcs indexe, amely az algoritmus kezdőpontját adja meg (startcsúcs), menete pedig a következő:

1.  A gráf minden csúcsát fehérre színezzük.

2.  A startcsúcs indexét beletesszük egy listába és a startcsúcsot szürkére színezzük.

3.  Ezután addig fut az algoritmus, ameddig a fent említett lista üres nem lesz, az iterációs lépés pedig a következő:

    *   Kivesszük a lista első elemét.

    *   Ennek a csúcsnak az összes, még eddig színezetlen (`White`) szomszédját szürkére színezzük (`Gray`) és az indexüket beillesztjük a lista végére. (A tesztelhetőség kedvéért itt is tartsuk a csúcsok indexe szerinti sorrendet, de ez az algoritmusnak nem feltétele.)

    *   A kivett indexű csúcsot színezzük feketére (`Black`).

A függvény visszatérési értéke legyen az a sorozat, hogy az algoritmus milyen sorrendben érte el (színezte szürkére) a csúcsokat.

A függvény típusa most a következő legyen:

```
bfs :: (a b) Int -> [Vertex] | Graph a b
```

Például:

```
test_bfs =
  [ bfs listEdge 0 == [0,1,3,6,4,5,2]
  , bfs listAdj 1 == [1,0,3,6,4,5,2]
  , bfs arrayEdge 6 == [6,5,2,4,0,3,1]
  , bfs arrayAdj 4 == [4,3,1,0,6,5,2]
  , bfs (addNode arrayAdj) 4 == [4,3,1,0,6,5,2]
  ]
```

## Algebrai adattípus JSON-né alakítása generikus módon

Valósítsuk meg az algebrai adattípusok egy részének a szerializációját, definiáljuk a generikus `gJSON` függvényt, amely valid JSON-né alakít egy algebrai adattípust! Az elkészített JSON string validitása tesztelhető akár az [interneten](http://jsonlint.com/) is.

Típusa:

```
generic gJSON a :: a -> String
```

A típus egyes értékeinek megfelelő JSON objektumot az adattípus struktúrája szerinti rekurzióval adjuk meg:

*   `OBJECT of o` esetén: `{"type":` , majd a típus neve (`o.gtd_name`) idézőjelek között, majd `,"value":` , majd a tartalmazott érték JSON string-je, majd pedig `}`.

*   `PAIR` esetén: az első elem JSON stringje, majd vessző, majd a második elem JSON stringje.

*   `EITHER` esetén:

    *   `LEFT` konstruktor esetén: a tartalmazott érték JSON stringje.
    *   `RIGHT` konstruktor esetén: a tartalmazott érték JSON stringje.
*   `CONS of c` esetén: `{"constructor":` , majd a konstruktor neve (`c.gcd_name`) idézőjelek között, majd `,"params":[` , majd a tartalmazott érték JSON string-je, végül pedig `]}`.

*   `UNIT` esetén: üres string.

*   `Int` esetén: `{"type":"int","value":` , majd a tartalmazott érték string reprezentációja , végül pedig `}`.

*   `Real` esetén: `{"type":"real","value":` , majd a tartalmazott érték string reprezentációja , végül pedig `}`.

*   `String` esetén: `{"type":"string","value":` , majd a tartalmazott string idézőjelek között , végül pedig `}`.

*   `Bool` esetén: `{"type":"bool","value":` , majd a tartalmazott Bool érték kisbetűs string reprezentációja , végül pedig `}`.

*   `Char` esetén: `{"type":"char","value":` , majd a tartalmazott karakter idézőjelek között , végül pedig `}`.

Végül tegyük lehetővé, hogy a `gJSON` generikus függvényünk használható legyen `[]`, `(,)`, `Color` és `Weight` típusú értékekkel!

## JSON-né konvertálás

Írjunk függvényt, mely JSON-né alakít egy olyan adattípust, melyre használható a `gJSON` generikus függvény!

Típusa:

```
toJSON :: a -> String | gJSON {|*|} a
```

Mint például:

```
test_toJSON =
  [ toJSON [(White,[(Weight 0)])]
      ==
    "{\"type\":\"_List\",\"value\":{\"constructor\":\"_Cons\",\"params\":[{\"type\":"
    +++ "\"_Tuple2\",\"value\":{\"constructor\":\"_Tuple2\",\"params\":[{\"type\":\"Color\",\"value\":"
    +++ "{\"constructor\":\"White\",\"params\":[]}},{\"type\":\"_List\",\"value\":{\"constructor\":"
    +++ "\"_Cons\",\"params\":[{\"type\":\"Weight\",\"value\":{\"constructor\":\"Weight\",\"params\":"
    +++ "[{\"type\":\"int\",\"value\":0}]}},{\"type\":\"_List\",\"value\":{\"constructor\":"
    +++ "\"_Nil\",\"params\":[]}}]}}]}},{\"type\":\"_List\",\"value\":{\"constructor\":\"_Nil\",\"params\":[]}}]}}"
  , toJSON [(White,[(1,Weight 1)]), (White,[(0,Weight 1)])]
      ==
    "{\"type\":\"_List\",\"value\":{\"constructor\":\"_Cons\",\"params\":[{\"type\":"
    +++ "\"_Tuple2\",\"value\":{\"constructor\":\"_Tuple2\",\"params\":[{\"type\":\"Color\""
    +++ ",\"value\":{\"constructor\":\"White\",\"params\":[]}},{\"type\":\"_List\",\"value\":"
    +++ "{\"constructor\":\"_Cons\",\"params\":[{\"type\":\"_Tuple2\",\"value\":{\"constructor\":"
    +++ "\"_Tuple2\",\"params\":[{\"type\":\"int\",\"value\":1},{\"type\":\"Weight\",\"value\":"
    +++ "{\"constructor\":\"Weight\",\"params\":[{\"type\":\"int\",\"value\":1}]}}]}},{\"type\":"
    +++ "\"_List\",\"value\":{\"constructor\":\"_Nil\",\"params\":[]}}]}}]}},{\"type\":\"_List\","
    +++ "\"value\":{\"constructor\":\"_Cons\",\"params\":[{\"type\":\"_Tuple2\",\"value\":"
    +++ "{\"constructor\":\"_Tuple2\",\"params\":[{\"type\":\"Color\",\"value\":{\"constructor\":"
    +++ "\"White\",\"params\":[]}},{\"type\":\"_List\",\"value\":{\"constructor\":\"_Cons\",\"params\":"
    +++ "[{\"type\":\"_Tuple2\",\"value\":{\"constructor\":\"_Tuple2\",\"params\":[{\"type\":"
    +++ "\"int\",\"value\":0},{\"type\":\"Weight\",\"value\":{\"constructor\":\"Weight\",\"params\":"
    +++ "[{\"type\":\"int\",\"value\":1}]}}]}},{\"type\":\"_List\",\"value\":{\"constructor\":"
    +++ "\"_Nil\",\"params\":[]}}]}}]}},{\"type\":\"_List\",\"value\":{\"constructor\":\"_Nil\",\"params\":[]}}]}}]}}"
  ]
```



