Részletes leírás
----------------

A feladatok egymásra épülnek ezért a megadásuk sorrendjében kell ezeket
megoldani! A függvények definíciójában lehet, sőt javasolt is alkalmazni
a korábban definiált függvényeket.

Tekintve, hogy a tesztesetek, bár odafigyelés mellett íródnak, nem
fedik le minden esetben a függvény teljes működését, határozottan
javasolt még külön próbálgatni a megoldásokat beadás előtt, vagy
megkérdezni a felügyelőket!

A megoldásban ne használjunk beégetett konstansokat, hacsak a feladat
szövege nem utasít erre!

Ha bármilyen kérdés, észrevétel felmerül, azt a felügyelőknek kell
jelezni, nem a diáktársaknak!

Használható segédanyagok egy [külön
oldalon](https://bead.inf.elte.hu/files/clean/) találhatóak.

A tesztekben használt `undef` egy, más programozási nyelvekben a null
pointerhez hasonló függvény, amely minden típussal polimorf, értéke
viszont nincs. Funkcionális környezetben a lusta kiértékelés miatt
használhatjuk nem definiált értékek helyettesítésére.

A feladat rövid leírása (Összesen: 15 pont)
-------------------------------------------

A feladatban egy egyszerű hasítótáblát fogunk megvalósítani. A mi
általunk megírandó hasítótábla az alábbiak szerint működik:

-   A hasítótábla vödröket tartalmaz, ezen vödrök nullától indexeltek.

-   A hasítótábla elemeire értelmezett egy hasítófüggvény, amely alapján
    az említett vödrökbe helyezzük az elemeket.

-   Az elemek egyediek, azaz nem szerepel kétszer ugyanaz az érték a
    táblában.

A feladatban szereplő típusok definiálása (1 pont)
--------------------------------------------------

Definiáljuk a `KeyVal` algebrai adattípust a következő módon:

-   Két típusparamétere van, az első a kulcs típusát fogja jelenteni, a
    második az értékét.

-   Egy darab adatkonstruktora van (`KV`), melynek típusa a következő:
    `KV :: k v -> KeyVal k v`, ahol a `k` a kulcs típusa, a `v` pedig az
    értéké.

-   Tegyük lehetővé, hogy a `KeyVal` típusú értékekre elvégezhessük a
    generikus egyenlőségvizsgálatot!

A hasítótáblához használjuk a `HashTable t` típust, amely a `[[t]]`
típus szinonimája és `t` a hasítótáblában tárolt elemek típusát jelenti.

A feladatban szükségünk lesz rá, hogy el tudjunk végezni két `KeyVal`
típusú elem közötti egyenlőségvizsgálatot. Két ilyen elemet egyenlőnek
tekintünk, ha a kulcsaik megegyeznek. A kulcsokról tudjuk, hogy az `==`
operátorral összehasonlíthatóak. Definiáljuk a `==` típusosztály
példányát a `KeyVal` típusra!

Például:

``` {.clean}
test_KeyVal =
  [ getKey (KV 4 5) == 4
  , getValue (KV "sadd" 'c') == 'c'
  , KV 3 'x' == KV 3 'y'
  , KV 3 'x' <> KV 4 'x'
  ]
    where
      getKey (KV x _) = x
      getValue (KV _ y) = y
```

A tesztekben használt hasítótáblák legyenek a következők (ezeket
módosítás nélkül másoljuk be a forrásba!):

``` {.clean}
hashTable_testInt =
  [[5,243,89,12,0]
  ,[43,57,34]
  ,[345]
  ,[59,3]
  ,[46]
  ]

hashTable_testKV =
  [[(KV 5 "asd"),(KV 243 "fre"),(KV 89 "as"),(KV 12 "t"),(KV 0 "i")]
  ,[(KV 43 "sdg"),(KV 57 "a"),(KV 34 "ewr")]
  ,[(KV 345 "elte")]
  ,[(KV 59 "xyz"),(KV 3 "fd")]
  ,[(KV 46 "gr")]]
```

A `Hashable` típusosztály (2 pont)
----------------------------------

Definiáljuk a `Hashable` típusosztályt, amely egyetlen típusparaméterrel
rendelkezik és egyetlen művelete a következő függvény:

``` {.clean}
hash :: t -> Int
```

Implementáljuk ennek a típusosztálynak a példányait `Int` és `KeyVal`
típusú értékekre a következő módon:

-   `Int` esetén az eredmény legyen a paraméter 7-tel vett maradéka.
    (Ehhez használjuk a `rem` függvényt!)

-   `KeyVal` típus esetén tudjuk, hogy a kulcs-ra értelmezett a
    `Hashable` típusosztály (megkötés a példány definiálásakor), a
    `hash` függvény értéke legyen a kulcs `hash` értéke!

Például:

``` {.clean}
test_hash =
  [ hash 5 == 5
  , hash 0 == 0
  , hash 123 == 4
  , hash (KV 12 undef) == 5
  ]
```

Üres hasítótábla létrehozása (1 pont)
-------------------------------------

Definiáljuk a `hashTable_empty` függvényt, amely a paraméterben kapott
egész szám alapján előállít egy üres hasítótáblát úgy, hogy a tábla a
paraméterben kapott számú üres listát (vödröt) tartalmazzon.
(Feltételezhetjük, hogy a paraméter egy nullánál nagyobb egész szám.)

``` {.clean}
hashTable_empty :: Int -> HashTable t
```

Például:

``` {.clean}
test_hashTable_empty =
  [ length (hashTable_empty 3) == 3
  , length (hashTable_empty 5) == 5
  , sum (map length (hashTable_empty 125)) == 0
  ]
```

Keresés a hasítótáblában (2 pont)
---------------------------------

Definiáljunk egy függvényt, amely egy adott elemet megkeres a
hasítótáblában. Az elem benne van a táblában, ha a megtalált elem igazat
ad az `==` függvénnyel a paraméterrrel összehasonlítva. Ez esetben adjuk
vissza az elemet `Just` konstruktorba csomagolva, egyéb esetben az
eredmény legyen `Nothing`!

A keresés menete a következő:

-   Kiszámoljuk a paraméterként kapott elem `hash` értékét, majd vesszük
    ennek a számnak a maradékát a táblánk vödreinek számával osztva. Az
    így kapott indexű vödörben keresendő az elem.

-   Az adott vödörben lineáris kereséssel kereshetjük meg az elemet.

``` {.clean}
hashTable_find :: (HashTable t) t -> Maybe t | Hashable t & == t
```

Például:

``` {.clean}
test_hashTable_find =
  [ hashTable_find hashTable_testKV (KV 3 "") == Just (KV 3 "fd")
  , hashTable_find hashTable_testKV (KV 1 undef) == Nothing
  ]
```

Egy vödör frissítése (3 pont)
-----------------------------

Implementáljunk egy magasabbrendű függvényt, amely paraméterként kap egy
`t` típusú elemeket tartalmazó hasítótáblát, egy `t` típusú elemet,
valamint egy `[t] -> [t]` típusú függvényt. A függvény feladata, hogy a
paraméterként kapott elemből a `hashTable_find` függvénynél leírt módon
kiszámoljuk, melyik vödörben van az elem, majd frissítjük a
paraméterként kapott függvénnyel.

``` {.clean}
hashTable_process :: (HashTable t)  t ([t] -> [t]) -> (HashTable t) | Hashable t & == t
```

Például:

``` {.clean}
test_hashTable_process =
  [ (hashTable_process hashTable_testInt 5 (filter (\x -> x rem 2 == 0))) !! 0 == [12,0]
  , hashTable_process hashTable_testInt 345 (\x->x) == hashTable_testInt
  , hashTable_process hashTable_testKV (KV 345 undef) (map (\(KV k v)->(KV k (v +++ " ")))) ===
    updateAt 2 (updateAt 0 (KV 345 "elte ") (hashTable_testKV !! 2)) hashTable_testKV
  ]
```

Egy elem eltávolítása a hasítótáblából (2 pont)
-----------------------------------------------

Implementáljuk a `hashTable_delete` függvényt, amelynek segítségével egy
elemet törölhetünk a hasítótáblából! A teljes pontszám megszerzéséhez
használjuk az imént definiált `hashTable_process` függvényt!

``` {.clean}
hashTable_delete :: (HashTable t) t -> HashTable t | Hashable t & == t
```

Például:

``` {.clean}
test_hashTable_delete =
  [ not (isMember (KV 43 "sdg") ((hashTable_delete hashTable_testKV (KV 43 "asd")) !! 1))
  , not (isMember (KV 43 "sdg") (hashTable_delete hashTable_testKV (KV 43 undef) !! 1))
  , hashTable_delete hashTable_testInt 233 == hashTable_testInt
  ]
```

Egy elem módosítása a hasítótáblában (3 pont)
---------------------------------------------

Implementáljuk a `hashTable_update` műveletet, amely a
`hashTable_process` segítségével a következőképpen frissíti a
hasítótáblát:

-   Ha az adott hashkódú elem megtalálható a táblában, akkor az elemet
    lecseréli a paraméterben kapott elemre.

-   Ha az adott elem még nem szerepel a táblában, akkor a kiszámolt
    vödör (lista) végére illeszti az új elemet.

(A teljes pontszám megszerzéséhez használjuk a `hashTable_process`
függvényt!)

``` {.clean}
hashTable_update :: (HashTable t) t -> HashTable t | Hashable t & == t
```

Például:

``` {.clean}
test_hashTable_update =
  [ foldl (\ht x -> hashTable_update ht x) (hashTable_empty 5) [5,243,43,345,57,59,46,89,12,0,34,3,5,43,57]
    === hashTable_testInt
  , foldl (\ht (x,y) -> hashTable_update ht (KV x y)) (hashTable_empty 5)
    [(5,"asd"),(243,"fre"),(43,"sdg"),(345,"erg"),(57,"a"),(59,"xyz"),(46,"gr")
    ,(89,"as"),(12,"t"),(0,"i"),(34,"ewr"),(3,"fd"),(345,"elte")] === hashTable_testKV
  , hashTable_update (hashTable_update (hashTable_empty 11) (KV 3 undef)) (KV 3 'c')
    === [[],[],[],[(KV 3 'c')],[],[],[],[],[],[],[]]
  ]
```

A hasítótábla listává alakítása (1 pont)
----------------------------------------

Definiáljuk a `hashTable_toList` függvényt, amely a paraméterül kapott
hasítótáblát listává alakítja úgy, hogy a tartalmazott vödröket egymás
után fűzi.

``` {.clean}
hashTable_toList :: (HashTable t) -> [t]
```

Például:

``` {.clean}
test_hashTable_toList =
  [ hashTable_toList hashTable_testInt == [5,243,89,12,0,43,57,34,345,59,3,46]
  , hashTable_toList hashTable_testKV ===
    [(KV 5 "asd"),(KV 243 "fre"),(KV 89 "as"),(KV 12 "t"),
    (KV 0 "i"),(KV 43 "sdg"),(KV 57 "a"),(KV 34 "ewr"),
    (KV 345 "elte"),(KV 59 "xyz"),(KV 3 "fd"),(KV 46 "gr")]
  ]
```

