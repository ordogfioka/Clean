module hash
import GenEq,StdLib,StdEnv
:: KeyVal k v = KV k v
:: HashTable t :== [[t]] 

derive gEq KeyVal

instance == (KeyVal a b) | == a 
where 
  (==)  (KV a b) (KV c d) = a==c

class Hashable t where 
    hash :: t -> Int
	
instance Hashable Int where 
    hash a = (a rem 7) 
    
instance Hashable (KeyVal a b) | Hashable a where 
    hash (KV a b) = hash a

hashTable_empty :: Int -> HashTable t
hashTable_empty a = take a (repeat [])


hashTable_find :: (HashTable t) t -> Maybe t | Hashable t & == t
hashTable_find table elem = ff elem (getList table elem)
  where 
  getList table elem = table !! ((hash elem) rem (length table) )
  ff :: t [t] -> Maybe t | == t
  ff _ []= Nothing
  ff elem [x:xs] 
    | elem == x = Just elem
     			 = ff elem xs  

hashTable_process :: (HashTable t)  t ([t] -> [t]) -> (HashTable t) | Hashable t & == t
hashTable_process table elem f = updateAt (getIndex table elem) (f (getList table elem)) table
  where 
  getList table elem = table !! ((hash elem) rem (length table) )
  getIndex table elem = ((hash elem) rem (length table) )
  
hashTable_delete :: (HashTable t) t -> HashTable t | Hashable t & == t
hashTable_delete table elem = hashTable_process table elem (\list = filter (\x = not(x==elem)) list )

hashTable_update :: (HashTable t) t -> HashTable t | Hashable t & == t
hashTable_update table elem = hashTable_process table elem myFun
where
  // myFun :: [t] -> [t]
  myFun list 
    | hashTable_find table elem == Nothing = list ++ [elem]
                                           = map (\ x = (f x)) list
    where
    f x
    | x ==elem = elem
               = x

hashTable_toList :: (HashTable t) -> [t]
hashTable_toList table = flatten table

Start = (and (flatten alltests),alltests)
alltests = [ test_KeyVal
		   , test_hash
		   , test_hashTable_empty
		   , test_hashTable_find
		   , test_hashTable_process
		   , test_hashTable_delete
		   , test_hashTable_update
		   , test_hashTable_toList ]
test_KeyVal =
  [ getKey (KV 4 5) == 4
  , getValue (KV "sadd" 'c') == 'c'
  , KV 3 'x' == KV 3 'y'
  , KV 3 'x' <> KV 4 'x'
  ]
    where
      getKey (KV x _) = x
      getValue (KV _ y) = y
      
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
  
test_hash =
  [ hash 5 == 5
  , hash 0 == 0
  , hash 123 == 4
  , hash (KV 12 undef) == 5
  ]
  
test_hashTable_empty =
  [ length (hashTable_empty 3) == 3
  , length (hashTable_empty 5) == 5
  , sum (map length (hashTable_empty 125)) == 0
  ]
  
test_hashTable_find =
  [ hashTable_find hashTable_testKV (KV 3 "") == Just (KV 3 "fd")
  , hashTable_find hashTable_testKV (KV 1 undef) == Nothing
  ]
  
test_hashTable_process =
  [ (hashTable_process hashTable_testInt 5 (filter (\x -> x rem 2 == 0))) !! 0 == [12,0]
  , hashTable_process hashTable_testInt 345 (\x->x) == hashTable_testInt
  , hashTable_process hashTable_testKV (KV 345 undef) (map (\(KV k v)->(KV k (v +++ " ")))) ===
    updateAt 2 (updateAt 0 (KV 345 "elte ") (hashTable_testKV !! 2)) hashTable_testKV
  ]
  
test_hashTable_delete =
  [ not (isMember (KV 43 "sdg") ((hashTable_delete hashTable_testKV (KV 43 "asd")) !! 1))
  , not (isMember (KV 43 "sdg") (hashTable_delete hashTable_testKV (KV 43 undef) !! 1))
  , hashTable_delete hashTable_testInt 233 == hashTable_testInt
  ]
  
test_hashTable_update =
  [ foldl (\ht x -> hashTable_update ht x) (hashTable_empty 5) [5,243,43,345,57,59,46,89,12,0,34,3,5,43,57]
    === hashTable_testInt
  , foldl (\ht (x,y) -> hashTable_update ht (KV x y)) (hashTable_empty 5)
    [(5,"asd"),(243,"fre"),(43,"sdg"),(345,"erg"),(57,"a"),(59,"xyz"),(46,"gr")
    ,(89,"as"),(12,"t"),(0,"i"),(34,"ewr"),(3,"fd"),(345,"elte")] === hashTable_testKV
  , hashTable_update (hashTable_update (hashTable_empty 11) (KV 3 undef)) (KV 3 'c')
    === [[],[],[],[(KV 3 'c')],[],[],[],[],[],[],[]]
  ]
  
test_hashTable_toList =
  [ hashTable_toList hashTable_testInt == [5,243,89,12,0,43,57,34,345,59,3,46]
  , hashTable_toList hashTable_testKV ===
    [(KV 5 "asd"),(KV 243 "fre"),(KV 89 "as"),(KV 12 "t"),
    (KV 0 "i"),(KV 43 "sdg"),(KV 57 "a"),(KV 34 "ewr"),
    (KV 345 "elte"),(KV 59 "xyz"),(KV 3 "fd"),(KV 46 "gr")]
  ]