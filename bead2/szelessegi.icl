module szelessegi

import GenEq
import StdEnv

:: Weight = Infinite | Weight Int 
:: Color = White | Gray | Black
:: Vertex :== Int
:: Adjacency :== (Color, [Weight]) 
:: EdgeList :== (Color, [(Vertex, Weight)])

listAdj =
  [(White,[(Weight 0),(Weight 1),Infinite,Infinite,Infinite,Infinite,Infinite])
  ,(Gray,[(Weight 1),(Weight 0),Infinite,(Weight 1),Infinite,Infinite,(Weight 1)])
  ,(Black,[(Weight 1),Infinite,(Weight 0),Infinite,Infinite,Infinite,Infinite])
  ,(Gray,[Infinite,(Weight 1),Infinite,(Weight 0),(Weight 1),Infinite,Infinite])
  ,(White,[Infinite,Infinite,Infinite,(Weight 1),(Weight 0),Infinite,Infinite])
  ,(Black,[Infinite,Infinite,(Weight 1),Infinite,(Weight 1),(Weight 0),Infinite])
  ,(White,[Infinite,Infinite,Infinite,Infinite,Infinite,(Weight 1),(Weight 0)])
  ]

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

derive gEq Color,Weight

class Node t where
  newNode      :: Int -> t
  getColor     :: t -> Color
  color        :: t Color -> t
  neighbours   :: t -> [Vertex]
  add          :: t -> t
  addNeighbour :: t Vertex Weight -> t



/****************ADJACENCY********************/  
instance Node Adjacency where
  newNode a = (White,repeatn a Infinite ++ [Weight 0])
  getColor node = fst node
  color node color =  (color,snd node)  
  neighbours node = [nr \\ nr<-[0..(length (snd node))] & weight <-(snd node) | not (weight === Infinite || weight === Weight 0)]
  add node = (fst node,(snd node)++[Infinite])
  addNeighbour node vertex weight = (fst node,take vertex (snd node) ++ [weight] ++ drop (vertex+1) (snd node))

/****************EDGELSIT********************/  
instance Node EdgeList where
  newNode a = (White,[])
  getColor node = fst node
  color node color =  (color,snd node) 
  neighbours node = map fst (snd node) 
  add node = node
  addNeighbour node vertex weight = (fst node, insert f (vertex,weight) (snd node))
    where 
      f (v1,w1) (v2,w2) = v1<v2 
/********************CONVECSIONS********************/
adj :: Int -> Adjacency
adj x = newNode x

edge :: Int -> EdgeList
edge x = newNode x 

arrayAdj :: {} Adjacency
arrayAdj = { x \\ x <- listAdj }

arrayEdge :: {} EdgeList
arrayEdge = { x \\ x <- listEdge }

/********************START********************/
Start = test_addNeighbour

/********************TESTS********************/
test_addNeighbour =
  [ addNeighbour (adj 2) 1 (Weight 3) === (White, [Infinite, Weight 3, Weight 0])
  , addNeighbour (addNeighbour (adj 2) 1 (Weight 3)) 0 (Weight 5) === (White, [Weight 5, Weight 3, Weight 0])
  , addNeighbour (edge 2) 1 (Weight 3) === (White, [(1, Weight 3)])
  , addNeighbour (addNeighbour (addNeighbour (edge 3) 2 (Weight 3)) 0 (Weight 5)) 1 (Weight 6) === (White, [(0,Weight 5),(1, Weight 6), (2, Weight 3)])
  ]
test_add =
  [ add (adj 0)  === (White, [Weight 0, Infinite])
  , add (edge 0) === edge 0
  , add (adj 2)  === (White, [Infinite, Infinite, Weight 0, Infinite])
  , add (edge 5) === edge 3
  ]

 
test_neighbours =
  [ map neighbours listAdj  === [[1],[0,3,6],[0],[1,4],[3],[2,4],[5]]
  , map neighbours listEdge === [[1],[0,3,6],[0],[1,4],[3],[2,4],[5]]
  ] 
 
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
    
test_getColor =
  [ map fst listAdj === [White,Gray,Black,Gray,White,Black,White]
  , map fst listAdj === map fst listEdge
  ]

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
