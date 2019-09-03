{-# LANGUAGE TypeSynonymInstances #-}

-- 型シノニムの引数が足りない
-- 複数宣言できない
-- take 100 $ output $ run example

class Monad' m where
    (>>==) :: m a -> (a -> m b) -> m b
    return' :: a -> m a

class Monad' m => Writer' m where
    write :: String -> m ()

data W' a = W' (a, String)

instance Monad' W' where
    W' (a, s) >>== k = let W' (b, s') = k a in W' (b, s++s')
    return' x = W' (x, "")

instance Writer' W' where
    write s = W' ((), s)

output :: W' a -> String
output (W' (a, s)) = s

class Monad'Trans t where
    lift :: Monad' m => m a -> (t m) a



-- type C' a = (a -> Action) -> Action
data C' m a = C' ((a -> Action m) -> Action m)

instance Monad' m => Monad' (C' m) where
    (C' f) >>== k = C' $ \c -> f (\a -> let C' k' = k a in k' c)
    return' x = C' $ \c -> c x

data Action m
    = Atom (m (Action m))
    | Fork (Action m) (Action m)
    | Stop
action :: Monad' m => C' m a -> Action m
action (C' m) = m (\a -> Stop)

atom :: Monad' m => m a -> C' m a
atom m = C' $ \c -> Atom (m >>== (return' . c))

stop :: Monad' m => C' m a
stop = C' $ \c -> Stop

fork :: Monad' m => C' m a -> C' m ()
fork m = C' $ \c -> Fork (action m) (c ())

instance Monad'Trans C' where
    lift = atom

instance Writer' m => Writer' (C' m) where
    write [] = return' ()
    write (c:s) = lift (write [c]) >>== \_ -> write s

round' :: Monad' m => [Action m] -> m ()
round' [] = return' ()
round' (a:as) = case a of
    Atom am -> am >>== (round' . (\a -> as++[a]))
    Fork a1 a2 -> round' (as ++ [a1, a2])
    Stop -> round' as

run :: Monad' m => C' m a -> m ()
run m = round' [action m]

loop :: Writer' m => String -> m ()
loop s = write s >>== \_ -> loop s

example :: Writer' m => C' m ()
example = write "start!" >>== \_ -> fork (loop "fish") >>== \_ -> loop "cat"

main = do
    print $ output $ run example
