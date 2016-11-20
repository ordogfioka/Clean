

## Részletes leírás

# Huffman-kódolás

_A feladatok egymásra épülnek ezért a megadásuk sorrendjében kell ezeket megoldani! A függvények definíciójában lehet, sőt javasolt is alkalmazni a korábban definiált függvényeket._

_Tekintve, hogy a tesztesetek, bár odafigyelés mellett íródnak, nem fedik le minden esetben egy-egy függvény teljes működését, ezért határozottan javasolt még külön próbálgatni a megoldásokat beadás előtt, vagy megkérdezni az oktatókat!_

_A feladathoz tartozó [programváz](/files/clean/Huffman.icl) tölthető le. Ebben megtalálhatóak a leírásban szereplő típusdefiníciók, valamint további tesztesetek. Az automatikus tesztelés ezek szerint fogja a beadott megoldást vizsgálni. A feladatban nem szerepel az összes teszt, ezeket közül az összeset a váz tartalmazza._

## A feladat összefoglaló leírása

A Huffman-kódolás egy prefixmentes betűnkénti kódolás, amely a kódolandó szövegben a karakterek gyakorisága alapján rendel kódot az egyes karakterekhez. Amelyik elem sokszor fordul elő egy szövegben, ahhoz rövid kódot rendel, amely kevésszer, ahhoz hosszabbat. Ehhez a folyamathoz egy fát használ, amelynek a levelek szintjén vannak az egyes karakterek, feljebb pedig a csomópontok segítenek a fa megalkotásában (amely alulról felfelé épül).

A feladatban egy olyan program részeit kell elkészítenünk, ahol szövegekből tudunk ilyen kódfákat és kódokat előállítani, valamint ezekből visszállítani egy ilyen módon kódolt szöveget. A kódokat bitekből építjük fel, amelyeket a `Bit` típussal ábrázoljuk:

```
:: Bit = Zero | One
```

A bitek listája lesz a kódokat leíró `Code` típus:

```
:: Code :== [Bit]
```

A kódok segítségével adjuk meg a kódfát ábrázoló `CodeTree` típust:

```
:: CodeTree = Node Int CodeTree CodeTree | Leaf Char
```

A szövegben az egyes karakterek gyakoriságát a `Frequency` típussal írjuk le, amely lényegében karakterek és egész számok párjai lesznek:

```
:: Frequency :== (Char, Int)
```

A kódfa előállítása során folyamatosan gyűjteni fogjuk a gyakoriságokat egy összefoglaló adatszerkezetbe, amelyet a `Frequencies` típussal ábrázolunk:

```
:: Frequencies :== ([Frequency], Int)
```

## Az egyes karakterek gyakoriságának meghatározása

Definiáljuk a `getFrequencies` függvényt, amellyel meg lehet számolni, hogy az egyes karakterekből mennyi található a paramétereként megadott szövegben!

```
getFrequencies :: String -> [Frequency]
```

Például:

```
isEmpty (getFrequencies "")
isMember (getFrequencies "abrak") ('r',1)
isMember (getFrequencies "abrakadabra") ('a',5)
```

## A gyakoriságok átalakítása

Készítsük el a `frequencyToFrequencies` függvényt, amellyel a `getFrequencies` függvénnyel kapott gyakoriságokat tartalmazó listát tudjuk átalakítani egy olyan listává, amelynek az elemei `Frequencies` típusúak! Ez gyakorlatilag azt jelenti, hogy a gyakoriságokat tartalmazó lista párjaiból az első elemeket betesszük egy egyelemű listába, a hozzájuk tárolt értéket pedig átmásoljuk a a listához társított értékként. Ezeket a listákat később majd bővíteni fogjuk.

```
frequencyToFrequencies :: [Frequency] -> [Frequencies]
```

Például:

```
frequencyToFrequencies [('r',2),('k',1),('d',1),('b',2),('a',5)] == [([('r',2)],2),([('k',1)],1),([('d',1)],1),([('b',2)],2),([('a',5)],5)]
```

## Sorbarendezés gyakoriság alapján

Adjuk meg a `sortByFrequencies` függvényt, amellyel karaktereket előfordulásaik szerint tudunk sorbarendezni! Ezt azt jelenti, hogy vesszük a gyakoriságokat is tartalmazó listát és kizárólag azok alapján rendezzük. Természetesen a rendezés során ügyeljünk, hogy a párok első elemei is megmaradjanak a nekik megfelelő gyakorisági értékek mellett!

(Tipp: Az egyszerűség kedvéért célszerű a `sortBy` függvényt használni, ahol a Clean alapkönyvtárában implementált rendezési algoritmussal dolgozhatunk úgy, hogy mindössze az értékek összehasonlítását végző függvényt kell átadnunk paraméterként. Így tehát nem kell saját rendezést megvalósítanunk.)

```
sortFrequencies :: [Frequencies] -> [Frequencies]
```

Például:

```
map snd (sortFrequencies [([('r',2)],2),([('d',1)],1),([('k',1)],1),([('b',2)],2),([('a',5)],5)]) == [1,1,2,2,5]
```

## A Huffman-fa felépítése

A gyakoriságra vonatkozó információk segítségével fel tudunk építeni egy kódfát a következő algoritmus szerint:

*   A karaktereket a gyakoriságaikkal együtt tegyük bele egy listába, majd azt rendezzük a gyakoriságuk szerint, és ezekből képezzünk csomópontokat a fában egy újabb listában.

*   Egészen addig, amíg egynél több elem található ebben a listában, vegyük ki a két legkisebb gyakorisággal rendelkező elemet. A felhasználásukkal hozzunk létre egy újabb csomópontot a fában, ahol a két kivett elem lesz bal-, illetve jobb oldali részfán, és a csomópontban a két elemben tárolt gyakoriságának összege lesz a csomópontban.

*   Tegyük az így létrehozott elemet vissza ebbe a listába, ahol a csomópontokat a bennük könyvelt gyakoriságok szerint rendezetten illesztjük be.

*   Ismételjük az egész folyamatot egészen addig, amíg egyetlen csomópontig el nem jutunk, ez lesz a korábbi lépésekben megszerkesztett fa gyökere.

Készítsük el a `buildTree` függvényt, amellyel ezt az algoritmust megvalósítjuk és előállítunk egy `CodeTree` értéket!

```
buildTree :: [Frequencies] -> CodeTree
```

Például:

```
buildTree [([('a',1)],1)] == Leaf 'a'
buildTree [([('a',1)],1), ([('b',2)],2)] == Node 3 (Leaf 'a') (Leaf 'b') || buildTree [([('a',1)],1), ([('b',2)],2)] == Node 3 (Leaf 'b') (Leaf 'a')
```

## Egy karakter kódjának előkeresése

Írjunk egy függvényt, amely egy adott kódfa mellett egy karakterhez visszaadja a nekik megfelelő kódot! Az előállítandó kódot a `Code` típus szerint kell elkészítenünk, amely tehát egy lista, amely `Bit` típusú értékeket tartalmaz.

A kódot a kódfából úgy tudjuk kiolvasni, hogy elindulunk annak tetejéről, és benne szintenként lefelé haladunk addig, amíg el nem érünk a levelekig és azok közül valamelyiken meg nem találjuk a keresett karaktert. A lefelé haladás során mindig lépésenként építenünk kell egy listát, amelyben a `Bit` típus elemei szerepelnek: a balra irány esetében a `Zero`, a jobbra irány esetében `One` kerüljön a végére. Ezt a listát akkor zárjuk le, amikor a levélben elértük az adott karaktert, ekkor kell visszaadni az addig összegyűlt biteket. A keresés során feltételezhetjük, hogy az adott karakter megtalálható a kódfában valahol.

```
lookupCode :: CodeTree Char -> Code
```

Például:

```
abrakadabra = Node 11 (Leaf 'a') (Node 6 (Node 4 (Leaf 'r') (Leaf 'b')) (Node 2 (Leaf 'k') (Leaf 'd')))

lookupCode abrakadabra 'a' == [Zero]
lookupCode abrakadabra 'b' == [One,Zero,One]
lookupCode abrakadabra 'd' == [One,One,One]
lookupCode (Leaf 'a') 'a'  == [Zero]
```

Itt a kódfánk (`abrakadabra`) a következőképpen néz ki:

```
      11
    0/  \1
  'a'  __6__
     0/     \1
     4       2
   0/ \1   0/ \1
  'r' 'b' 'k' 'd'
```

A `'b'` karakternek megfelelő kód az az útvonal lesz ebben a fában, ahogyan a gyökértől eljutunk addig a levélig, ahol az megtalálható. Ez most, az ábrán levő címkéket követve az `1, 0, 1` sorozat lesz. Hasonlóan a többi karakter kódja is származtatható.

## Karakter visszakeresése kód alapján

Készítsük el a `lookupPrefix` függvényt, amely egy kód alapján előkeresi a kódfából a neki megfelelő karaktert. Ezt itt most prefixnek hívjuk, mivel a kódjaink valójában prefix kódok. Ez azt jelenti, hogy két kód sosem fedi egymást. Tehát, hogy ha a kódfában a kód szerint kezdünk el navigálni, akkor előbb-utóbb, de egyértelműen egy konkrét karakterhez jutunk el.

```
lookupPrefix :: CodeTree Code -> Char
```

Például:

```
abrakadabra = Node 11 (Leaf 'a') (Node 6 (Node 4 (Leaf 'r') (Leaf 'b')) (Node 2 (Leaf 'k') (Leaf 'd')))

lookupPrefix abrakadabra (lookupCode abrakadabra 'a') == 'a'
lookupPrefix abrakadabra (lookupCode abrakadabra 'b') == 'b'
lookupPrefix abrakadabra (lookupCode abrakadabra 'd') == 'd'
lookupPrefix abrakadabra (lookupCode (Leaf 'a') 'a')  == 'a'
```

Ez a függvény, ahogy a példákban is látszik, tulajdonképpen, az előző, vagyis a `lookupCode` inverze.

## Szöveg kódolása

Írjunk egy `encode` függvényt, amely segítségével egy adott szövegből fel tudunk építeni egy Huffman-kódfát, majd annak alapján kiszámítjuk a kódolt szöveget! Építsük fel a szöveg alapján a kódfát, majd annak egyes karakterein menjünk végig és keressük ki a nekik megfelelő kódokat és abból képezzünk egyetlen kódsorozatot. A feladat megoldása során ezekhez ne felejtsük el alkalmazni a korábban definiált függvényeinket!

```
encode :: String -> (CodeTree, Code)
```

Például:

```
(length o snd) (encode "abrakadabra") == 23
encode "aaaaa" == (Leaf 'a', [Zero,Zero,Zero,Zero,Zero])
```

## Szöveg dekódolása

Készítsük el az `encode` függvény inverzeként viselkedő `decode` függvényt, amely egy kódfa és egy kód alapján előállítja a nekik megfelelő szöveget! Ekkor a paraméterben kapott `Code` típusú értéket valójában egy hosszabb sorozatnak kell tekintenünk, és abból folyamatosan levágni annyit, amennyivel a kódfán keresztül megtalálunk egy-egy karaktert. Ezután folytassuk a feldolgozást a kódsorozat fennmaradó részével egészen addig, amíg el nem fogy! A kikódolás során kapott karaktereket végül össze kell illesztenünk egyetlen `String` értékké.

```
decode :: (CodeTree, Code) -> String
```

Például:

```
abrakadabra = Node 11 (Leaf 'a') (Node 6 (Node 4 (Leaf 'r') (Leaf 'b')) (Node 2 (Leaf 'k') (Leaf 'd')))

decode (encode "Decode function test") == "Decode function test"
decode (encode "Functional programming is fun!") == "Functional programming is fun!"
decode (abrakadabra, [Zero,One,Zero,One,One,Zero,Zero,Zero,One,One,Zero]) == "abrak"
```

