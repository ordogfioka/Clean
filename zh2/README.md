# Bináris keresőfa

_A feladatok egymásra épülnek ezért a megadásuk sorrendjében kell ezeket megoldani! A függvények definíciójában lehet, sőt javasolt is alkalmazni a korábban definiált függvényeket._

_Tekintve, hogy a tesztesetek, bár odafigyelés mellett íródnak, nem fedik le minden esetben egy-egy függvény teljes működését, ezért határozottan javasolt még külön próbálgatni a megoldásokat beadás előtt, vagy megkérdezni a felügyelőket!_

_Használható segédanyagok egy [külön oldalon](/files/clean/) találhatóak. Ha bármilyen kérdés, észrevétel felmerül, azt a felügyelőknek kell jelezni, nem a diáktársaknak!_

_A programban ne használjunk beégetett konstansokat, kivéve, ha a feladat kifejezetten erre utasít!_

## A feladat összefoglaló leírása (Összesen: 17 pont)

A bináris keresőfa az informatikában egy rendkívül fontos és gyakran használt adatszerkezet. Tulajdonságai:

*   Minden csúcsnak maximum két rákövetkezője van.

*   Invariáns tulajdonság, hogy minden csúcs bal oldali részfájában az elemek kisebbek, mint az adott csúcs, a jobb oldali részfában pedig minden elem nagyobb.

Az adatszerkezet megvalósításához szükséges, hogy a tartalmazott elemekre létezzen szigorú részbenrendezés, azaz bármely két elem közül el tudjuk dönteni, hogy melyik kisebb.

Valósítsuk meg egy ilyen adatszerkezet egyszerű változatát!

## A feladatban szereplő típusok definiálása (1 pont)

Definiáljuk a `BSTree` algebrai adattípust, mely rendelkezik 1 db. típusparaméterrel és a következő adatkonstruktorokkal:

*   `Empty :: BSTree a`
*   `Node :: a (BSTree a) (BSTree a) -> BSTree a`

_(Az automatikus tesztelés miatt tartsuk meg az itt bevezetett sorrendet az adatkonstruktorok definiálásakor!)_

A feladat későbbi részében szükségünk lesz egy adattípusra, amely segítségével kulcs-érték párokat tudunk reprezentálni. Definiáljuk ezt a típust a következő módon:

*   A típus típuskonstruktora legyen `KeyValue` és legyen két típusparamétere, amelyek a kulcs és az érték típusát fogják jelenteni!

*   Legyen egy `KV :: a b -> KeyValue a b` szigantúrájú adatkonstruktora!

Tegyük lehetővé, hogy az imént definiált típusok, valamit a `Maybe` típus használható legyen generikus egyenlőségvizsgálatban!

A tesztekben az alábbi előredefiniált konstansokat használjuk. (Ezért ezeket ne módosítsuk!)

    testIntBSTree =
      (Node 1 (Node 0 Empty Empty)
      (Node 21 (Node 4 (Node 2 Empty Empty)
      (Node 6 Empty (Node 8 Empty Empty)))
      (Node 63 Empty Empty)))

    testKVBSTree =
      (Node (KV 6 'a')
      (Node (KV 4 'c')
      (Node (KV 3 'l') Empty Empty)
      (Node (KV 5 'y') Empty Empty))
      (Node (KV 9 'r')
      (Node (KV 7 's') Empty
      (Node (KV 8 'q') Empty Empty))
      (Node (KV 10 'p') Empty
      (Node (KV 50 'o') Empty Empty))))

## Üres fák definiálása (1 pont)

Definiáljuk a következő függvényeket, amelyek `Int`, illetve `KeyValue Int Char` típusú értékeket tartalmaznak a csúcsokban!

    BSTree_emptyInt :: BSTree Int
    BSTree_emptyKV  :: BSTree (KeyValue Int Char)

Például:

    test_BSTRe_Empty =
      [ BSTree_emptyInt === Empty
      , BSTree_emptyKV === Empty
      ]

## Elem beillesztése bináris keresőfába (2 pont)

Definiáljuk a `BSTree_insert` függvényt, amely a paraméterként kapott fába beilleszti a paraméterként kapott elemet. Amennyiben az elem már megtalálható a fában, az eredmény legyen az eredeti fa!

    BSTree_insert :: (BSTree a) a -> (BSTree a) | < a

Például:

    test_BSTree_insert =
      [ BSTree_insert BSTree_emptyInt 3 ===
        Node 3 Empty Empty
      , BSTree_insert (BSTree_insert BSTree_emptyInt 3) 5 ===
        Node 3 Empty (Node 5 Empty Empty)
      , BSTree_insert (BSTree_insert BSTree_emptyInt 3) 3 ===
        Node 3 Empty Empty
      , BSTree_insert (BSTree_insert BSTree_emptyInt 3) 1 ===
        Node 3 (Node 1 Empty Empty) Empty
      ]

## Elem keresése a bináris keresőfában (1 pont)

Implementáljuk a `BSTree_lookup` függvényt, amely a paraméterként kapott fában megkeresi a paraméterként kapott elemet! Amennyiben az elem megtalálható a fában, a művelet eredménye legyen `Just` adakonstruktorral csomagolva, ha nem, akkor legyen az eredmény `Nothing`.

    BSTree_lookup :: (BSTree a) a -> Maybe a | < a

Például:

    test_BSTree_lookup =
      [ BSTree_lookup testIntBSTree 21 === Just 21
      , map (BSTree_lookup testIntBSTree) [3, 7, 50, 100] === repeatn 4 Nothing
      , BSTree_lookup Empty 'x' === Nothing
      , BSTree_lookup testKVBSTree (KV 3 undef) === Just (KV 3 'l')
      ]

## Bináris fa mélységének meghatározása (1 pont)

Definiáljuk a `BSTree_depth` függvényt, amely megadja egy (rész)fa mélységét, azaz, hogy a kiinduló csúcsból kezdve hány szintet tartalmaz lefelé a fa!

    BSTree_depth :: (BSTree a) -> Int

Például:

    test_BSTree_depth =
      [ BSTree_depth BSTree_emptyInt == 0
      , BSTree_depth BSTree_emptyKV == 0
      , BSTree_depth testIntBSTree == 5
      , BSTree_depth testKVBSTree == 4
      ]

## Bináris fa kiegyensúlyozottságának ellenőrzése (1 pont)

A bináris keresőfák akkor tudnak jól működni, ha kiegyensúlyozottak, azaz minden csúcsra igaz, hogy a jobb és baloldali részfa mélysége között a különbség maximum 1\. Írjunk függényt, amel ellenőrzi ezt a tulajdonságot!

    BSTree_isBalanced :: (BSTree a) -> Bool

Például:

    test_BSTree_isBalanced =
      [ BSTree_isBalanced Empty == True
      , BSTree_isBalanced testIntBSTree == False
      , BSTree_isBalanced testKVBSTree == True
      ]

## `Traversable` típusosztály (2 pont)

Definiáljuk a `Traversable` típusosztályt, amely a bináris fák szokásos bejárási stratégiáit tartalmazza a lentebb megadott típusokkal!

A bejárások a `foldl` és `foldr` függvényekhez hasonlóan működnek, azaz paraméterben kapnak egy végrehajtható függvényt, amely `a b -> b` típusú, egy `b` típusú kezdőértéket valamint egy `t a` típusú bejárandó értéket, ahol a `t` `* -> *` kind-ú típus, eredményként pedig `b` típusú lesz.

    inOrder :: (a b -> b) b (t a) -> b

Az `inOrder` bejárás lényege, hogy a paraméterként kapott bináris fában először a bal oldali elemeket dolgozza fel minden csúcsnál, majd magát a csúcsot, utána pedig a jobb oldali elemeket.

    preOrder :: (a b -> b) b (t a) -> b

A `preOrder` bejárás lényege, hogy először a csúcsot dolgozza fel, majd a bal oldali elemeket, majd a jobb oldali elemeket.

    postOrder :: (a b -> b) b (t a) -> b

A `postOrder` bejárás lényege, hogy először a baloldali elemeket dolgozza fel, majd a jobb oldaliakat, végül az aktuális csúcsot.

## A `Traversable` típusosztály megvalósítása a `BSTree` típussal (2 pont)

Valósítsuk meg a `Traversable` típusosztály műveleteit a `BSTree` típusra!

Például:

    instance toString (KeyValue a b) | toString a & toString b
      where
        toString (KV x y) = "key: " +++ toString x +++ ", value: " +++ toString y

    test_Traversable =
      [ inOrder (\x s -> s +++ toString x +++ ", ") "" testKVBSTree ==
        "key: 3, value: l, key: 4, value: c, key: 5, value: y, key: 6, "
        +++"value: a, key: 7, value: s, key: 8, value: q, key: 9, value: r, "
        +++"key: 10, value: p, key: 50, value: o, "
      , preOrder (\x s -> s +++ toString x) "" testIntBSTree == "1021426863"
      , postOrder (\x s -> s +++ toString x) "" testIntBSTree == "0286463211"
      , inOrder (\x s -> s +++ toString x) "" BSTree_emptyInt == ""
      , preOrder (\x s -> s +++ toString x) "" BSTree_emptyInt == ""
      , postOrder (\x s -> s +++ toString x) "" BSTree_emptyInt == ""
      ]

## Rendezés bináris keresőfával (1 pont)

Mivel a bináris keresőfa elemei között definíció szerint létezik a `<` reláció, sorba is rendezhetünk elemeket a segítségével. Ajánlott használni az imént definiált `inOrder` típusú bejárást, hisz az pontosan a fa legkisebb elemétől sorban halad a legnagyobb felé.

Ennek segítségével tehát készítsünk egy függvényt, amely a fa bejárásával előállítja a benne található elemek egy rendezett listáját!

    sortBSTree :: (BSTree a) -> [a]

Például:

    test_sortBSTree =
      [ sortBSTree BSTree_emptyInt == []
      , map (\(KV k v) -> v) (sortBSTree testKVBSTree) == ['l','c','y','a','s','q','r','p','o']
      , sortBSTree testIntBSTree == sort (sortBSTree testIntBSTree)
      , length (sortBSTree testIntBSTree) == 8
      ]

## A `MapKV` típus definiálása (1 pont)

A továbbiakban olyan bináris kersőfákkal fogunk dolgozni, amelyek kulcs-érték párokat tartalmaznak. Valósítsuk meg ezt az algebrai adattípust a következő módon:

*   A típus neve `MapKV` és két típusparamétert vár, amely a kulcs és az érték típusa lesz.

*   Egyetlen adatkonstruktora van: `M :: BSTree (KeyValue k v) -> MapKV k v`.

Tegyük lehetővé, hogy a `MapKV` típus használható legyen generikus egyenlőségvizsgálatban!

Ennek a típusnak a használatához szükségünk lesz a `<` típusosztály `KeyValue k v` típusának példányára, amelyről tudjuk, hogy a `<` értelmezett a `k` típusra. Implementáljuk ezt a példányt!

## `MapKV` típus értékének frissítése (2 pont)

Mivel a `MapKV` típusú fában kulcsok szerint rendezünk, a kulcshoz tartozó érték megváltozatása nem rontja el a fa rendezettségét. Definiáljuk a `MapKV_update` nevű függvényt, amelynek a segítségével frissíthetünk egy kulcshoz tartozó értéket!

A függvény paraméterei a frissítendő fa és kulcs, valamint egy függvény, amely alapján frissíteni szeretnénk az értéket. Amennyiben ennek a függvénynek az értéke `Nothing`, ne módosítsunk az értéken! Ha az adott kulcs nem található a fában, ne történjen változás! Feltehetjük, hogy a kulcsokra értelmezett a `<` művelet.

    MapKV_update :: (MapKV k v) k (v -> Maybe v) -> MapKV k v | < k

Például:

    test_MapKV_update =
      [ MapKV_update (M BSTree_emptyKV) 4 (\_ -> Just 'a') === M BSTree_emptyKV
      , MapKV_update (M (Node (KV 5 'a') (Node (KV 3 's') Empty (Node (KV 4 'r') Empty Empty)) Empty)) 5 (\_ -> Just 't') ===
        M ((Node (KV 5 't') (Node (KV 3 's') Empty (Node (KV 4 'r') Empty Empty)) Empty))
      , MapKV_update (M (Node (KV 5 'a') (Node (KV 3 's') Empty (Node (KV 4 'r') Empty Empty)) Empty)) 5 (\_ -> Nothing) ===
        M ((Node (KV 5 'a') (Node (KV 3 's') Empty (Node (KV 4 'r') Empty Empty)) Empty))
      ]

## Elem keresése egy `MapKV` típusú értékben (1 pont)

Definiáljuk a `MapKV_lookup` függvényt, amely egy `MapKV` típusú adatszerkezetben képes megkeresni egy elemet a kulcs alapján!

Amennyiben az adott kulcs megtalálható a fában, az eredmény legyen a hozzá tartozó `KeyValue` érték, amennyiben nem, az eredmény legyen `Nothing`! Feltehetjük, hogy a kulcsokra értelmezett a `<` művelet.

    MapKV_lookup :: (MapKV k v) k -> Maybe (KeyValue k v) | < k

Például:

    test_MapKV_lookup =
      [ MapKV_lookup (M BSTree_emptyKV) 3 === Nothing
      , MapKV_lookup (M testKVBSTree) 7 === Just (KV 7 's')
      ]

## Elem beillesztése egy `MapKV` típusú értékbe (1 pont)

Definiáljuk a `MapKV_insert` függvényt, amelynek segítségével a paraméterül kapott fába beilleszthetjük a szintén paraméterül kapott kulcsot és értéket! Feltehetjük, hogy a kulcsokra értelmezett a `<` művelet.

_Tipp:_ Használjuk a korábban definiált `BSTree_insert` műveletet!

    MapKV_insert :: (MapKV k v) k v -> (MapKV k v) | < k

Például:

    test_MapKV_insert =
      [ foldl (\x (k,v) -> MapKV_insert x k v) (M BSTree_emptyKV)
        [(6,'a'),(4,'c'),(9,'r'),(5,'y'),(3,'l'),(7,'s'),(8,'q'),
        (10,'p'),(50,'o')] === M testKVBSTree
      , MapKV_insert (M BSTree_emptyKV) 4 'a' === M (Node (KV 4 'a') Empty Empty)
      , MapKV_insert (MapKV_insert (M BSTree_emptyKV) 4 'a') 4 'b' ===
        M (Node (KV 4 'a') Empty Empty)
      ]


