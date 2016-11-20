module Vigenere

import StdEnv, StdLib

alphaCodeCharacters :: [Char]
alphaCodeCharacters = stringToList "abcdefghijklmnopqrstuvwxyz"

randomCodeCharacters ::[Char]
randomCodeCharacters = stringToList "s?adi79fug346_+!]"

commonCharacters ::[Char]
commonCharacters = stringToList "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-+ .,?!_"

isValidCharacter :: [Char] Char -> Bool
isValidCharacter codeChars c = (filter (\x-> x == c) codeChars) <> []

stringToList :: String -> [Char]
stringToList a = [x\\x<-:a]

stringFromList :: [Char] -> String
stringFromList l = toString l

makeLongKey :: String Int -> String
makeLongKey key s 
 | key == "" = ""
             = stringFromList(take s (stringToList(makeLongKeyHelper key s)))
 where 
 makeLongKeyHelper key s
  | length (stringToList key) < s = makeLongKey (key +++ key) s
   								 = key
  
  

removeBadCharacters :: String [Char] -> String
removeBadCharacters str codeChars = stringFromList(filter (isValidCharacter codeChars ) (stringToList str))

getIndex :: Char [Char] -> Int
getIndex c codeChars = getIndexHelper c (stringFromList codeChars) 0
 where
  getIndexHelper c codeChars nr
   | codeChars.[nr] == c = nr
   				        = getIndexHelper c codeChars (nr+1)
   
   
encodeChar :: Char Char [Char] -> Char
encodeChar a b codeChars = (stringFromList codeChars).[((getIndex a codeChars) + (getIndex b codeChars)) rem (length codeChars)]

encodeText :: String String [Char] -> String
encodeText textToCode key codeChars =  stringFromList ([encodeChar (encodeMe.[i]) (newKey.[i]) codeChars \\ i<- [0..((length (stringToList encodeMe) )-1)]] )
 where
 encodeMe = (removeBadCharacters  textToCode codeChars)
 newKey = makeLongKey key (length (stringToList encodeMe))

decodeChar :: Char Char [Char] -> Char
decodeChar a b codeChars = (stringFromList codeChars).[(length codeChars + (getIndex a codeChars) - (getIndex b codeChars)) rem (length codeChars)]

decodeText :: String String [Char] -> String
decodeText codedText key codeChars = stringFromList ([decodeChar (decodeMe.[i]) (newKey.[i]) codeChars \\ i<- [0..((length (stringToList decodeMe) )-1)]] )
 where 
  decodeMe = (removeBadCharacters  codedText codeChars)
  newKey = makeLongKey key (length (stringToList decodeMe))

translateChar :: Char Char [Char] (Int Int -> Int) -> Char
translateChar a b codeChars fun = (stringFromList codeChars).[(fun (getIndex a codeChars)  (getIndex b codeChars)) ]

translateText :: String String [Char] (Int Int -> Int) -> String
translateText str key codeChars fun = stringFromList ([translateChar (encodeMe.[i]) (newKey.[i]) codeChars fun\\ i<- [0..((length (stringToList encodeMe) )-1)]] )
 where
 encodeMe = (removeBadCharacters  str codeChars)
 newKey = makeLongKey key (length (stringToList encodeMe))

encodeText2 :: String String [Char] -> String
encodeText2 textToCode key codeChars = translateText textToCode key codeChars calculate
  where
    calculate x y = (x + y) rem (length codeChars)

decodeText2 :: String String [Char] -> String
decodeText2 codedText key codeChars = translateText codedText key codeChars calculate
  where
    calculate x y = ((length codeChars) + (x - y)) rem (length codeChars)
Start = (and (flatten alltests), alltests)
alltests =
  [ test_stringToList
  , test_stringFromList
  , test_isValidCharacter
  , test_makeLongKey
  , test_removeBadCharacters
  , test_getIndex
  , test_encodeChar
  , test_decodeChar
  , test_encodeText
  , test_decodeText
  , test_translate
  ]

// tesztek

test_stringToList =
  [ stringToList "asd" == ['a','s','d']
  , stringToList "" == []
  ]

test_stringFromList =
  [ stringFromList ['a','s','d'] == "asd"
  , stringFromList [] == ""
  ]

test_isValidCharacter =
  [ isValidCharacter alphaCodeCharacters 'a'
  , isValidCharacter alphaCodeCharacters 'z'
  , isValidCharacter randomCodeCharacters '+'
  , not (isValidCharacter alphaCodeCharacters '+')
  ]
  
test_makeLongKey =
  [ makeLongKey "" 1 == ""
  , makeLongKey "a" 5 == "aaaaa"
  , makeLongKey "a" -5 == ""
  , makeLongKey "asdf" 13 == "asdfasdfasdfa"
  , makeLongKey "some_long_original_key" 2 == "so"
  ]

test_removeBadCharacters =
  [ removeBadCharacters "af]g3i" randomCodeCharacters == "af]g3i"
  , removeBadCharacters "a.g," randomCodeCharacters == "ag"
  , removeBadCharacters "...56" alphaCodeCharacters == ""
  ]

test_getIndex =
  [ getIndex 'a' alphaCodeCharacters == 0
  , getIndex 'A' commonCharacters == 26
  , getIndex '+' randomCodeCharacters == 14
  ]

test_encodeChar =
  [ encodeChar 'a' 'a' alphaCodeCharacters == 'a'
  , encodeChar 'a' 'a' randomCodeCharacters == 'i'
  , encodeChar 'c' 'd' commonCharacters == 'f'
  ]

test_decodeChar =
  [ decodeChar 'a' 'a' alphaCodeCharacters == 'a'
  , decodeChar 'i' 'a' randomCodeCharacters == 'a'
  , decodeChar 'f' 'c' commonCharacters == 'd'
  ]

test_encodeText =
  [ encodeText "" "xsd" randomCodeCharacters == ""
  , encodeText "af]g3i" "a_]" randomCodeCharacters == "id!49d"
  , encodeText "functional programming is fun!" "pw_123" commonCharacters == "uQm3d+DJ_ WaGKfa2?BEm7W+Hqed?1"
  , encodeText "test_with_invalid:characters. " "asd" alphaCodeCharacters == "twvtoltzlnndlagczdrsftwus"
  ]

test_decodeText =
  [ decodeText "" "xsd" randomCodeCharacters == ""
  , decodeText "id!49d" "a_]" randomCodeCharacters == "af]g3i"
  , decodeText "uQm3d+DJ_ WaGKfa2?BEm7W+Hqed?1" "pw_123" commonCharacters == "functional programming is fun!"
  , decodeText "twvtoltzlnndlagczdrsftwus" "asd" alphaCodeCharacters == "testwithinvalidcharacters"
  ]
  
test_translate =
  [ encodeText2 "" "xsd" randomCodeCharacters == ""
  , encodeText2 "af]g3i" "a_]" randomCodeCharacters == "id!49d"
  , encodeText2 "functional programming is fun!" "pw_123" commonCharacters == "uQm3d+DJ_ WaGKfa2?BEm7W+Hqed?1"
  , encodeText2 "test_with_invalid:characters. " "asd" alphaCodeCharacters == "twvtoltzlnndlagczdrsftwus"
  , decodeText2 "" "xsd" randomCodeCharacters == ""
  , decodeText2 "id!49d" "a_]" randomCodeCharacters == "af]g3i"
  , decodeText2 "uQm3d+DJ_ WaGKfa2?BEm7W+Hqed?1" "pw_123" commonCharacters == "functional programming is fun!"
  , decodeText2 "twvtoltzlnndlagczdrsftwus" "asd" alphaCodeCharacters == "testwithinvalidcharacters"
  ]