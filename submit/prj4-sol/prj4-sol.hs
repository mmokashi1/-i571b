import Unit  -- crude assertions for unit tests

import Data.List

----------------------------- OrderItem Type ----------------------------
type Sku = String
type Category = String
type NUnits = Int
type UnitPrice = Float

-- an OrderItem is a Haskell record.  Note that Haskell creates
-- accessor functions for each field.  For example, given item :: OrderItem,
-- (itemCategory item) :: Category.
data OrderItem = OrderItem {
  itemSku :: Sku,
  itemCategory :: Category,
  itemNUnits :: NUnits,
  itemUnitPrice :: UnitPrice
} deriving ( Eq, Show )

item1 = OrderItem "cw123" "cookware" 3 12.50
item2 = OrderItem "cw126" "cookware" 2 11.50
item3 = OrderItem "ap723" "apparel" 2 10.50
item4 = OrderItem "cw127" "cookware" 1 9.99
item5 = OrderItem "ap273" "apparel" 3 21.50
item6 = OrderItem "fd825" "food" 1 2.48

cookware = [ item1, item2, item4 ]
apparel = [ item3, item5 ]
food = [ item6 ]
items = [ item1, item2, item3, item4, item5, item6 ]

----------------------------- categoryItems -----------------------------
-- #1: 10-points
-- Given a list items of OrderItem and a Category category, 
-- (categoryItems items category) must return those order-items in
-- items which have itemCategory == category.
-- Restriction: MUST use recursion
categoryItems :: [OrderItem] -> Category -> [OrderItem]
categoryItems [] _ = []
categoryItems (x:xs) category
    | itemCategory x == category = x : categoryItems xs category
    | otherwise = categoryItems xs category

-- categoryItems _ _ = error "TODO"

testCategoryItems = do
  assertEq "categoryItems cookware"
           (categoryItems items "cookware")
           cookware
  assertEq "categoryItems apparel"
           (categoryItems items "apparel")
           apparel
  assertEq "categoryItems food"
           (categoryItems items "food")
           food
  assertEq "categoryItems games"
           (categoryItems items "games")
           []
                 
-------------------------- comprItemOrderItems ---------------------------
-- #2: 10-points
-- comprCategoryItems has same spec as categoryItems.
-- Restriction: MUST be implemented using list comprehension.
comprCategoryItems :: [OrderItem] -> Category -> [OrderItem]
-- comprCategoryItems _ _ = error "TODO"
comprCategoryItems items category = [x | x <- items, itemCategory x == category]

testComprCategoryItems = do
  assertEq "comprCategoryItems cookware"
           (comprCategoryItems items "cookware")
           cookware
  assertEq "comprCategoryItems apparel"
           (comprCategoryItems items "apparel")
           apparel
  assertEq "comprCategoryItems food"
           (comprCategoryItems items "food")
           food


----------------------------- itemsTotal --------------------------------
-- #3: 10-points
-- Given a list items of OrderItem, (itemsTotal items) must
-- return the order total for the order containing items
-- Restriction: May NOT use recursion or list comprehension.
-- Hint: Use fromIntegral n to convert Int n to Float
itemsTotal :: [ OrderItem ] -> Float
-- itemsTotal _ = error "TODO"
itemsTotal items = sum [fromIntegral (itemNUnits x) * itemUnitPrice x | x <- items]


testItemsTotal = do
  assertEq "itemsTotal all"
           (itemsTotal items)
           (fromIntegral (itemNUnits item1) * itemUnitPrice item1
           + fromIntegral (itemNUnits item2) * itemUnitPrice item2
           + fromIntegral (itemNUnits item3) * itemUnitPrice item3
           + fromIntegral (itemNUnits item4) * itemUnitPrice item4
           + fromIntegral (itemNUnits item5) * itemUnitPrice item5
           + fromIntegral (itemNUnits item6) * itemUnitPrice item6)
  assertEq "itemsTotal empty" (itemsTotal []) 0.0


------------------------------ factorial --------------------------------

-- #4: 10-points
-- Given a non-negative integer n, (factorial n) should return
-- the factorial of n.
-- Restriction: May NOT use recursion or list comprehension
-- Hint: [1..n] generates a list of the integers from 1 to n
factorial :: Integer -> Integer
factorial n
  | n < 0     = error "Input must be non-negative"
  | otherwise = loop 1 n
  where loop acc 0 = acc
        loop acc i = loop (acc * i) (i - 1)
-- factorial _ = error "TODO"

testFactorial = do
  assertEq "factorial 0" (factorial 0) 1
  assertEq "factorial 1" (factorial 1) 1
  assertEq "factorial 2" (factorial 2) 2
  assertEq "factorial 4" (factorial 4) 24
  assertEq "factorial 6" (factorial 6) 720


-------------------------------- factNums -------------------------------

-- #5: 10-points
-- Return list of all factorials 1, 1, 2, 6, 24, ...
-- Hint: Use earlier factorial function
factNums :: [Integer]
factNums = map factorial [0..]

testFactNums = do
  assertEq "factNums first 6" (take 6 factNums) [1, 1, 2, 6, 24, 120]
  assertEq "factNums first 10"
           (take 10 factNums)
           [1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880]

  


------------------------------------ assoc ------------------------------

-- An assoc-list is a list of pairs; normally uses to represent a
-- key-value Map with the first element of each pair representing
-- the key and the second element representing a value
type AssocList a b = [(a, b)]


-- #6: 10-points.
-- If there is a pair (key, value) in assocList, then (assoc key assocList)
-- should return (Just value) else it should return Nothing
-- Hint: recurse through assocList testing each pair against key
assoc :: Eq a => a -> AssocList a b -> Maybe b
assoc _ [] = Nothing
assoc key ((k, v):rest)
  | key == k  = Just v
  | otherwise = assoc key rest

-- assoc _ _ = error "TODO"

testAssoc = do
  assertEq "assoc first"
           (assoc "a" [("a", 1.0), ("b", 2.0), ("c", 3.0)])
           (Just 1.0)
  assertEq "assoc second"
           (assoc "b" [("a", "1"), ("b", "2"), ("c", "3")])
           (Just "2")
  assertEq "assoc last"
           (assoc "c" [("a", "1"), ("b", "2"), ("c", "3")])
           (Just "3")
  assertEq "assoc fail"
           (assoc "d" [("a", "1"), ("b", "2"), ("c", "3")])
           Nothing


--------------------------- Terms and Bindings --------------------------

-- A Term represents a Prolog term, where names are represented as
-- Haskell strings.
type VarName = String
type Atom = String
data Term =
  Var VarName |
  Struct Atom [Term]
  deriving (Eq, Show)

-- A binding associates a Term with a variable (represented by its name)
type Binding = (VarName, Term)

------------------------------ sortBindings -----------------------------

-- #7: 10-points
-- Given a list of Binding, return list sorted by the VarName component
-- of each binding.
-- Hint: use sortBy and compare
sortBindings :: [Binding] -> [Binding]
sortBindings xs = sortBy compareVar xs
  where compareVar (var1, _) (var2, _) = compare var1 var2
-- sortBindings _ = error "TODO"

testSortBindings = do
  assertEq "empty" (sortBindings []) []
  assertEq "singleton"
           (sortBindings [("X", (Struct "a" []))])
           [("X", (Struct "a" []))]
  assertEq "triple"
           (sortBindings [("C", (Struct "c" [])),
                          ("A", (Struct "a" [])),
                          ("B", (Struct "b" []))])
           [("A", (Struct "a" [])),
            ("B", (Struct "b" [])),
            ("C", (Struct "c" []))]
  assertEq "multiple"
           (sortBindings [("C", (Struct "c" [])),
                          ("E", (Struct "e" [])),
                          ("F", (Struct "f" [])),
                          ("D", (Struct "d" [])),
                          ("G", (Struct "g" [])),
                          ("B", (Struct "b" []))])
            [("B", (Struct "b" [])),           
             ("C", (Struct "c" [])),
             ("D", (Struct "d" [])),
             ("E", (Struct "e" [])),
             ("F", (Struct "f" [])),
             ("G", (Struct "g" []))]


-- #8: 10-points
-- Given a Term term and a list bindings of Binding,
-- (substTerm term bindings) should return term with all
-- Var-terms in term replaced by its binding in Bindings.
-- (if there is no binding for a var in term, then it
-- should remain unchanged
-- Assumption: there are no recursive bindings like [(X, f(X))] or
-- [(X, f(Y)), (Y, f(X))]
-- Hints: Use structural recursion on term.
--        When term is a Var, look up the VarName in bindings using assoc
--        if found, then return the corresponding binding; if not found
--        return term unchanged.
--        Use a case expression to pattern-match the Maybe result of assoc
--        When term is a Struct, simply return the term resulting from
--        applying substTerm over the arguments.
substTerm :: Term -> [Binding] -> Term
substTerm (Var x) bindings =
  case lookup x bindings of
    Just t -> substTerm t bindings
    Nothing -> Var x
substTerm (Struct atom terms) bindings =
  Struct atom (map (\term -> substTerm term bindings) terms)


-- substTerm _ _ = error "TODO"

testSubstTerm =
  let bindings = [
          ("A", Struct "a" []),
          ("C", Struct "c" []),
          ("B", Struct "b" []),
          ("E", (Var "A")),
          ("D", Struct "f" [(Var "E"), (Var "C")])] in
   do
      assertEq "nop" (substTerm (Var "X") bindings) (Var "X")
      assertEq "f(A) => f(a)"
               (substTerm (Struct "f" [(Var "A")]) bindings)
               (Struct "f" [(Struct "a" [])])
      assertEq "f(A, B, C) => f(a, b, c)"
               (substTerm (Struct "f" [(Var "A"), (Var "B"), (Var "C")])
                          bindings)
               (Struct "f" [(Struct "a" []), (Struct "b" []), (Struct "c" [])])
      assertEq "f(E) => f(a)"
               (substTerm (Struct "f" [(Var "E")]) bindings)
               (Struct "f" [(Struct "a" [])])
      assertEq "f(g(A, D)) => f(g(a, f(a, c)))"
               (substTerm (Struct "f" [Struct "g" [Var "A", Var "D"]]) bindings)
               (Struct "f" [Struct "g" [Struct "a" [],
                                        Struct "f" [Struct "a" [],
                                                    Struct "c" []]]])
-- #9: 5-points
-- (normalizeBindings binding) returns sorted bindings with each
-- term in bindings replaced by (substTerm term bindings).
normalizeBindings :: [Binding] -> [Binding]
normalizeBindings bindings =
  let substitutedBindings = map (\(var, term) -> (var, substTerm term bindings)) bindings
  in sortBindings substitutedBindings

-- normalizeBindings _ = error "TODO"

testNormalizeBindings =   
  let bindings = [
          ("A", Struct "a" []),
          ("C", Struct "c" []),
          ("B", Struct "b" []),
          ("E", (Var "A")),
          ("D", Struct "f" [(Var "E"), (Var "C")])] in
  do
    assertEq "normalizeBindings"
             (normalizeBindings bindings)
             [("A", Struct "a" []),
              ("B", Struct "b" []),
              ("C", Struct "c" []),
              ("D", Struct "f" [(Struct "a" []), (Struct "c" [])]),
              ("E", Struct "a" [])] 


-- #10: 15 points
-- if term1 and term2 unify, then (unify term1 term2) should return
-- (Just bindings) where bindings is a normalized list of bindings
-- for the variables in term1 and term2 which make them identical;
-- if term1 and term2 do not unify, then Nothing should be returned.
-- Hints: Define unify in terms of an auxiliary function which takes
--        an additional argument representing the bindings seen so far.
--        An additonal auxiliary function for unifying lists of terms may
--        also prove useful.  Make sure your definition covers all
--        possible cases for the two lists.
--        Again, use case expressions to handle Maybe results.
unify :: Term -> Term -> Maybe [Binding]
unify t1 t2 = unifyWithBindings t1 t2 []

unifyWithBindings :: Term -> Term -> [Binding] -> Maybe [Binding]
unifyWithBindings t1 t2 b =
  case (t1, t2) of
    (Var x, Var y) ->
      if x == y
      then Just b
      else case lookup x b of
             Just t' -> unifyWithBindings t' (Var y) b
             Nothing -> Just $ normalizeBindings ((x, Var y) : b)
    (Var x, t) ->
      case lookup x b of
        Just t' -> unifyWithBindings t' t b
        Nothing -> Just $ normalizeBindings ((x, t) : b)
    (t, Var x) -> unifyWithBindings (Var x) t b
    (Struct s1 ts1, Struct s2 ts2) ->
      if s1 == s2
      then unifyTerms ts1 ts2 b
      else Nothing

unifyTerms :: [Term] -> [Term] -> [Binding] -> Maybe [Binding]
unifyTerms [] [] b = Just b
unifyTerms (t1:ts1) (t2:ts2) b =
  let
    mb' = unifyWithBindings t1 t2 b
  in
    case mb' of
      Just b' -> unifyTerms ts1 ts2 b'
      Nothing -> Nothing
unifyTerms _ _ _ = Nothing

-- unify _ _ = error "TODO"

testUnify = do
  assertEq "unify: X = Y => [(X, Y)]"
           (unify (Var "X") (Var "Y"))
           (Just [("X", Var "Y")])
  assertEq "unify: X = X => []"
           (unify (Var "X") (Var "X"))
           (Just [])
  assertEq "unify: X = a => [(X, a)]"
           (unify (Var "X") (Struct "a" []))
           (Just [("X", Struct "a" [])])
  assertEq "unify: a = X => [(X, a)]"
           (unify (Struct "a" []) (Var "X") )
           (Just [("X", Struct "a" [])])
  assertEq "unify: a = a => []"
           (unify (Struct "a" []) (Struct "a" []))
           (Just [])
  assertEq "unify: a \\= b => fail"
           (unify (Struct "a" []) (Struct "b" []))
           Nothing
  assertEq "unify: f(X) = f(a) => [(X, a)]"
           (unify (Struct "f" [(Var "X")]) (Struct "f" [(Struct "a" [])]))
           (Just [("X", Struct "a" [])])
  assertEq "unify: f(X) \\= f => fail"
           (unify (Struct "f" [(Var "X")]) (Struct "f" []))
           Nothing
  assertEq "unify: f(X, a) = f(a, X) => [(X, a)]"
           (unify (Struct "f" [(Var "X"), (Struct "a" [])])
                  (Struct "f" [(Struct "a" []), (Var "X")]))
           (Just [("X", Struct "a" [])])
  assertEq "unify: f(X, a) \\= f(b, X) => fail"
           (unify (Struct "f" [(Var "X"), (Struct "a" [])])
                  (Struct "f" [(Struct "b" []), (Var "X")]))
           Nothing
  assertEq "unify: f(g(X), a) \\= f(g(a), X) => [(X, a)]"
           (unify (Struct "f" [(Struct "g" [(Var "X")]), (Struct "a" [])])
                  (Struct "f" [(Struct "g" [(Struct "a" [])]), (Var "X")]))
           (Just [("X", Struct "a" [])])
  assertEq "unify: f(g(X), b) \\= f(g(a), X) => fail"
           (unify (Struct "f" [(Struct "g" [(Var "X")]), (Struct "b" [])])
                  (Struct "f" [(Struct "g" [(Struct "a" [])]), (Var "X")]))
           Nothing 
  assertEq "unify: f(g(X), a) = f(g(Y), X) => [(X, a), (Y, a)]"
           (unify (Struct "f" [(Struct "g" [(Var "X")]), (Struct "a" [])])
                  (Struct "f" [(Struct "g" [(Var "Y")]), (Var "X")]))
           (Just [("X", Struct "a" []), ("Y", Struct "a" [])])
           




----------------------------- Run All Tests -----------------------------

testAll = do
  testCategoryItems
  testComprCategoryItems
  testItemsTotal
  testFactorial
  testFactNums
  testAssoc
  testSortBindings
  testSubstTerm
  testNormalizeBindings
  testUnify