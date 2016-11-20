## Részletes leírás

# Vigenére-kódolás

_A feladatok egymásra épülnek ezért a megadásuk sorrendjében kell ezeket megoldani! A függvények definíciójában lehet, sőt javasolt is alkalmazni a korábban definiált függvényeket._

_Tekintve, hogy a tesztesetek, bár odafigyelés mellett íródnak, nem fedik le minden esetben egy-egy függvény teljes működését, ezért határozottan javasolt még külön próbálgatni a megoldásokat beadás előtt, vagy megkérdezni a felügyelőket!_

_A feladathoz tartozó [programváz](/files/clean/Vigenere.icl) tölthető le. Ebben megtalálhatóak a leírásban szereplő típusdefiníciók, valamint további tesztesetek. Az automatikus tesztelés ezek szerint fogja a beadott megoldást vizsgálni._

_Használható segédanyagok egy [külön oldalon](/files/clean/) találhatóak. Ha bármilyen kérdés, észrevétel felmerül, azt a felügyelőknek kell jelezni, nem a diáktársaknak!_

_Jó munkát!_

## A feladat leírása (Összesen: 14 pont)

A Vigenére-kódolás vagy Vigenére-rejtjelezés egy olyan titkosítás, amely karakterek eltolásán alapul. Lényege, hogy egy kódolandó szöveget egy jelszó alapján karakterenként kódolunk. A jelszót olyan hosszúra alakítjuk, mint a kódolandó szöveg, úgy, hogy annyiszor írjuk egymás után, míg meg nem kapjuk a kapott hosszt (ha nem egész számú többszöröse, akkor az utolsót csonkoljuk). Ezután a Vigenére-tábla alapján karakterenként kódolunk úgy, hogy a kódolandó karakter oszlopának és a jelkarakter sorának metszetében lévő akrakter lesz a kódolt karakter.

Például: a "adbcd" szöveget akarjuk kódolni az "ef" jelszóval.

Első lépésben megfelelő hosszúra alakítjuk a jelszót, vagyis ebből az lesz, hogy "efefe". Utána karakterenként megkeressük a kódolt karaktert:

'a' 'e' <span class="math inline">\to</span> 'e' (a oszlop, e sor)
'd' 'f' <span class="math inline">\to</span> 'c' (d oszlop, f sor)
'b' 'e' <span class="math inline">\to</span> 'f' (b oszlop, e sor) ...
"adbcd" "efefe" <span class="math inline">\to</span> "ecfbb"

A kódoláshoz tehát ezt a táblázatot használtuk:

```
 a | b c d e f
---------------
 b | c d e f a
 c | d e f a b
 d | e f a b c
 e | f a b c d
 f | a b c d e
```

A kódolás eredileg csak az angol ábécé betűire működött. A feladat a kódolásnak egy olyan kiterjesztése, hogy a használható karakterkészletet bemenetként tartalmazza a program.

## Teszthez használt konstansok

A következő előredefiniált karaktersorozatok a tesztekhez kellenek, hagyjuk ezeket változatlanul.

```
alphaCodeCharacters :: [Char]
alphaCodeCharacters = stringToList "abcdefghijklmnopqrstuvwxyz"

randomCodeCharacters ::[Char]
randomCodeCharacters = stringToList "s?adi79fug346_+!]"

commonCharacters ::[Char]
commonCharacters = stringToList "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-+ .,?!_"
```

## String konverziók (1 pont)

Cleanben a `String` típus igazából karakterek tömbje, azaz `{#Char}`. Hogy könnyebben tudjunk bánni velük, írjunk függvényt, amely karakterek listájává alakítja ezt!

```
stringToList :: String -> [Char]
```

Például:

```
stringToList "asd" == ['a','s','d']
```

Írjuk meg ennek a függvénynek a párját, amely karakterek listájából egy `String` típusú értéket állít elő!

```
stringFromList :: [Char] -> String
```

Például:

```
stringFromList ['a','s','d'] == "asd"
```

## Karakter előfordulásának ellenőrzése (1 pont)

Vigenére-kódolással csak olyan karaktert tudunk kódolni, és csak olyan szerepelhet a jelszóban is, amely szerepel a karakterkészletünkben. Írjunk egy függvényt, amely ellenőrzi, hogy egy karakter szerepel-e az aktuális karakterkészletben!

```
isValidCharacter :: [Char] Char -> Bool
```

Például:

```
isValidCharacter alphaCodeCharacters 'a'
```

## Jelszó megfelelő hosszúságúvá alakítása (1 pont)

Alakítsuk megfelelő hosszúságúra a jelszót úgy, hogy annyiszor írjuk egymás után, ahányszor kell.

_Tipp:_ használjuk a `take` és a `repeat` függvényeket!

```
makeLongKey :: String Int -> String
```

Például:

```
makeLongKey "" 1 == ""
makeLongKey "a" -5 == ""
makeLongKey "asdf" 13 == "asdfasdfasdfa"
```

## Nem megfelelő karakterek eltávolítása (1 pont)

Távolítsuk el azokat a karaktereket, amelyek nem szerepelnek az adott karakterkészletben! Használjuk a már korábban definiált `isValidCharacter` függvényt!

```
removeBadCharacters :: String [Char] -> String
```

Például:

```
removeBadCharacters "a.g," randomCodeCharacters == "ag"
removeBadCharacters "...56" alphaCodeCharacters == ""
```

## Karakter sorszámának meghatározása (1 pont)

Írjunk függvényt, amely meghatározza a paraméterként kapott karakter sorszámát a paraméterként kapott karakterkészletben, ahol az indexelés induljon nullától! Biztosra vehetjük, hogy a karakter szerepel a listában, azaz érvénytelen esettel nem kell foglalkoznunk!

```
getIndex :: Char [Char] -> Int
```

Például:

```
getIndex 'a' alphaCodeCharacters == 0
getIndex '+' randomCodeCharacters == 14
```

## Karakter kódolása (1 pont)

A paraméterként kapott kódolandó karakter és kódoló karakter alapján adjuk meg a kódolt karaktert. A kódoláshoz használt képlet:

```
((kódolandó karakter kódja) + (kódoló karakter kódja)) mod (karakterkészlet elemszáma)
```

ahol a `mod` a maradékképzés műveletet jelenti. (Újabb Clean verziókban egy osztás maradékát a `rem` függvénnyel kapjuk meg.)

_Tipp_: Érvénytelen karakter vizsgálatával nem kell foglalkoznunk, hiszen azokat majd eltávolítjuk a `removeBadCharacters` függvénnyel!

```
encodeChar :: Char Char [Char] -> Char
```

Például:

```
encodeChar 'a' 'a' alphaCodeCharacters == 'a'
encodeChar 'a' 'a' randomCodeCharacters == 'i'
```

## Szöveg kódolása (2 pont)

A bemenetként kapott szöveget kódoljuk el az adott jelszó és karakterkészlet segítségével! A jelszót alakítsuk megfelelő hosszúságúra a `makeLongKey` függvény segítségével! Ne felejtsük el eltávolítani az érvénytelen karaktereket a kódolandó szövegből a `removeBadCharacters` függvénnyel!

```
encodeText :: String String [Char] -> String
```

Például:

```
encodeText "" "xsd" randomCodeCharacters == ""
encodeText "test_with_invalid:characters. " "asd" alphaCodeCharacters == "twvtoltzlnndlagczdrsftwus"
```

## Karakter dekódolása (1 pont)

A megadott kódolt karaktert dekódoljuk a kódoló karakter és a karakterkészlet alapján. A dekódoláshoz használt képlet:

```
((karakterkészlet elemszáma) + (kódolandó karakter kódja) - (kódoló karakter kódja)) mod (karakterkészlet elemszáma)
```

ahol a `mod` a maradékképzés műveletet jelenti. (Újabb Clean verziókban egy osztás maradékát a `rem` függvénnyel kapjuk meg.)

_Tipp:_ Érvénytelen karakter vizsgálatával nem kell foglalkoznunk, hisz azokat eltávolítottuk a `removeBadCharacters` függvénnyel!

```
decodeChar :: Char Char [Char] -> Char
```

Például:

```
decodeChar 'f' 'c' commonCharacters == 'd
```

## Szöveg dekódolása (2 pont)

Dekódoljuk a kapott kódolt szöveget a kapott jelszó és karakterkészlet segítségével! Ne feledjük, ehhez majd a jelszót megfelelő hosszúságúra kell alakítanunk a `makeLongKey` függvény segítségével.

```
decodeText :: String String [Char] -> String
```

Például:

```
decodeText "" "xsd" randomCodeCharacters == ""
decodeText "twvtoltzlnndlagczdrsftwus" "asd" alphaCodeCharacters == "testwithinvalidcharacters"
```

## Kódolás és dekódolás általánosítása (3 pont)

Definiáljuk a `translateChar` és a `translateText` magasabbrendű függvényeket, amelyek paraméterben várják az adott karakterek indexén elvégzendő `(Int Int -> Int)` típusú műveletet, ezáltal egységesebb `encode` és `decode` függvényeket definiálhatunk. (Ezeket a programváz tartalmazza.)

```
translateChar :: Char Char [Char] (Int Int -> Int) -> Char
```

Definiáljunk egy függvényt, amely a `translateChar` segítségével szöveget alakít át a paraméterként kapott `(Int Int -> Int)` típusú függvény alapján!

```
translateText :: String String [Char] (Int Int -> Int) -> String
```

Így használhatjuk az `encode` és `decode` függvények új változatát a következő módon:

```
encodeText2 :: String String [Char] -> String
encodeText2 textToCode key codeChars = translateText textToCode key codeChars calculate
  where
    calculate x y = (x + y) rem (length codeChars)

decodeText2 :: String String [Char] -> String
decodeText2 codedText key codeChars = translateText codedText key codeChars calculate
  where
    calculate x y = ((length codeChars) + (x - y)) rem (length codeChars)
```


