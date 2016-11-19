module Huffman

import StdEnv, StdLib

:: Bit = Zero | One

:: Frequency :== (Char, Int)

:: Frequencies :== ([Frequency], Int)

:: CodeTree = Node Int CodeTree CodeTree
            | Leaf Char

::Code :== [Bit]

instance == Bit where
  (==) Zero Zero = True
  (==) One One = True
  (==) _ _ = False

instance == CodeTree where
  (==) (Leaf a) (Leaf b) = a == b
  (==) (Node x aLeft aRight) (Node y bLeft bRight) = x == y && aLeft == bLeft && aRight == bRight
  (==) _ _ = False


stringToList :: String ->[Char]
stringToList str = [ char \\ char <-: str ]

getFrequencies :: String -> [Frequency]
getFrequencies str =[ (x,countCharInList x (stringToList str) )\\x <- removeDup (stringToList str) ]
  where 
    countCharInList char list = sum(map (boolToInt char) list)
      where
  	    boolToInt char a 
  	      | char == a = 1
  	  		    	  = 0

frequencyToFrequencies :: [Frequency] -> [Frequencies]
frequencyToFrequencies str= map frequencyToFrequencies str
  where frequencyToFrequencies (a,b) = ([(a,b)],b) 

buildTree :: [Frequencies] -> CodeTree
buildTree x = constructTree(map frequencyToLeaf (sortFrequencies x))
  where 
    frequencyToLeaf ([(char,freq1)],freq) = (freq,Leaf char)

    constructTree [(_,x)] = x
    constructTree [(freq1,tree1):(freq2,tree2):rest] = constructTree ( mergeList (freq1+freq2,Node (freq1+freq2) tree1 tree2) rest )

    mergeList node [] = [node]
    mergeList (freq1,tree1) [(freq2,tree2):tail]
      | freq1 < freq2 = [(freq1,tree1):(freq2,tree2):tail]
                      = [(freq2,tree2)] ++ mergeList (freq1,tree1) tail

sortFrequencies :: [Frequencies] -> [Frequencies]
sortFrequencies frs = sortBy sortFunction frs
  where 
    sortFunction ([(a,b)],c) ([(d,e)],f) = c < f
  
lookupCode :: CodeTree Char -> Code
lookupCode ( Leaf _ ) _ = [Zero]
lookupCode tree ch = getLookupCode tree ch
  where 
    getLookupCode (Leaf _) _ = []  
    getLookupCode (Node _ left right) char 
      |treeContainsChar left char = [Zero] ++ getLookupCode left char
                                  = [One]  ++ getLookupCode right char

    treeContainsChar (Leaf char) baseChar = char == baseChar
    treeContainsChar (Node _ left right) char = (treeContainsChar left char) || (treeContainsChar right char)  

lookupPrefix :: CodeTree Code -> Char
lookupPrefix (Leaf a) _ = a
lookupPrefix (Node _ left rigth) [direction:tail]
  | direction == Zero = lookupPrefix left tail
                      = lookupPrefix rigth tail

encode :: String -> (CodeTree, Code)
encode str = (CodeTree, flatten [ lookupCode CodeTree char \\ char <-: str])
  where
    CodeTree = buildTree (frequencyToFrequencies (getFrequencies  str))

decode :: (CodeTree, Code) -> String
decode (tree, []) = ""
decode (tree, list) = (toString char) +++ decode (tree ,(drop (length (lookupCode tree char)) list)) 
  where
    char = lookupPrefix tree list


abrakadabra = Node 11 (Leaf 'a') (Node 6 (Node 4 (Leaf 'r') (Leaf 'b')) (Node 2 (Leaf 'k') (Leaf 'd')))

Start = sortFrequencies (frequencyToFrequencies (getFrequencies "sokféle karakterbõl álló szöveg"))//(and (flatten allTests), allTests)
  where
    allTests =
      [ test_getFrequencies
      , test_frequencyToFrequencies
      , test_sortFrequencies
      , test_buildTree
      , test_lookupCode
      , test_lookupPrefix
      , test_encode
      , test_decode
      ]

test_getFrequencies =
  [ isEmpty (getFrequencies "")
  , and (map (\x -> isMember x (getFrequencies "abrakadabra")) [('r',2),('k',1),('d',1),('b',2),('a',5)])
  , and (map (\x -> isMember x (getFrequencies "Szeretem a clean-t")) [('z',1),('t',2),('r',1),('n',1),('m',1),('l',1),('e',4),('c',1),('a',2),('S',1),('-',1),(' ',2)])
  , and (map (\x -> isMember x (getFrequencies "adadada")) (getFrequencies "dadadaa"))
  ]

test_frequencyToFrequencies =
  [
    frequencyToFrequencies [('r',2),('k',1),('d',1),('b',2),('a',5)] == [([('r',2)],2),([('k',1)],1),([('d',1)],1),([('b',2)],2),([('a',5)],5)]
  ]

test_sortFrequencies = 
  [ map snd (sortFrequencies [([('r',2)],2),([('d',1)],1),([('k',1)],1),([('b',2)],2),([('a',5)],5)]) == [1,1,2,2,5]
  ]

test_buildTree = 
  [ buildTree [([('a',1)],1)] == Leaf 'a'
  , buildTree [([('a',1)],1), ([('b',2)],2)] == Node 3 (Leaf 'a') (Leaf 'b') || buildTree [([('a',1)],1), ([('b',2)],2)] == Node 3 (Leaf 'b') (Leaf 'a')
  , countNodes (buildTree (frequencyToFrequencies (getFrequencies "sokféle karakterbõl álló szöveg"))) == 37
  ]
    where
      countNodes (Leaf _) = 1
      countNodes (Node _ left right) = 1 + (countNodes left) + (countNodes right)

test_lookupCode = 
  [ lookupCode abrakadabra 'a' == [Zero]
  , lookupCode abrakadabra 'b' == [One,Zero,One]
  , lookupCode abrakadabra 'd' == [One,One,One]
  , lookupCode (Leaf 'a') 'a'  == [Zero]
  ]
  where
    abrakadabra = Node 11 (Leaf 'a') (Node 6 (Node 4 (Leaf 'r') (Leaf 'b')) (Node 2 (Leaf 'k') (Leaf 'd')))

test_lookupPrefix =
  [ lookupPrefix abrakadabra ((lookupCode abrakadabra 'a')) == 'a'
  , lookupPrefix abrakadabra (lookupCode abrakadabra 'b') == 'b'
  , lookupPrefix abrakadabra (lookupCode abrakadabra 'd') == 'd'
  , lookupPrefix abrakadabra (lookupCode (Leaf 'a') 'a')  == 'a'
  ]
  where
    abrakadabra = Node 11 (Leaf 'a') (Node 6 (Node 4 (Leaf 'r') (Leaf 'b')) (Node 2 (Leaf 'k') (Leaf 'd')))

test_encode =
  [ (length o snd) (encode "abrakadabra") == 23
  , encode "aaaaa" == (Leaf 'a', [Zero,Zero,Zero,Zero,Zero])
  ]

test_decode =
  [ decode (encode "Decode function test") == "Decode function test"
  ,  decode (encode "Functional programming is fun!") == "Functional programming is fun!"
  ,  decode (abrakadabra, [Zero,One,Zero,One,One,Zero,Zero,Zero,One,One,Zero]) == "abrak"
  ]
  where
    abrakadabra = Node 11 (Leaf 'a') (Node 6 (Node 4 (Leaf 'r') (Leaf 'b')) (Node 2 (Leaf 'k') (Leaf 'd')))
    