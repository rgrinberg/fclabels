{- |
Labels for data types in the base package. The lens types are kept abstract to
be fully reusable in custom contexts. Build to be imported qualified.
-}

{-# LANGUAGE
    NoMonomorphismRestriction
  , TemplateHaskell
  , TypeOperators
  #-}

module Data.Label.Base
(
-- * Lenses for lists.
  head
, tail

-- * Lenses for Either.
, left
, right

-- * Lens for Maybe.
, just

-- * Lenses for 2-tuples.
, fst
, snd
, swap

-- * Lenses for 3-tuples.
, fst3
, snd3
, trd3

-- * Read/Show isomorphism.
, readShow
)
where

import Prelude hiding (fst, snd, head, tail)
import Control.Arrow (arr, Kleisli(..), ArrowApply, ArrowZero, ArrowChoice)
import Data.Maybe (listToMaybe)
import Data.Label.Partial (Partial)
import Data.Label

import qualified Data.Label.Mono as Mono
import qualified Data.Label.Poly as Poly
import qualified Data.Tuple      as Tuple

-- | Lens pointing to the head of a list's cons cell. (Partial and monomorphic)

head :: (ArrowZero arr, ArrowApply arr, ArrowChoice arr)
     => Mono.Lens arr [a] a

-- | Lens pointing to the tail of a list's cons cell. (Partial and monomorphic)

tail :: (ArrowZero arr, ArrowApply arr, ArrowChoice arr)
     => Mono.Lens arr [a] [a]

(head, tail) = $(getLabel ''[])

-- | Lens pointing to the left value in an Either. (Partial and polymorphic)

left :: (ArrowZero arr, ArrowApply arr, ArrowChoice arr)
     => Poly.Lens arr (Either a b -> Either o b) (a -> o)

-- | Lens pointing to the right value in an Either. (Partial and polymorphic)

right :: (ArrowZero arr, ArrowApply arr, ArrowChoice arr)
      => Poly.Lens arr (Either a b -> Either a o) (b -> o)

(left, right) = $(getLabel ''Either)

-- | Lens pointing to the value in a Maybe. (Partial and polymorphic)

just :: (ArrowChoice cat, ArrowZero cat, ArrowApply cat)
     => Poly.Lens cat (Maybe a -> Maybe b) (a -> b)

just = $(getLabel ''Maybe)

-- | Lens pointing to the first component of a 2-tuple. (Total and polymorphic)

fst :: ArrowApply arr => Poly.Lens arr ((a, b) -> (o, b)) (a -> o)

-- | Lens pointing to the second component of a 2-tuple. (Total and polymorphic)

snd :: ArrowApply arr => Poly.Lens arr ((a, b) -> (a, o)) (b -> o)

(fst, snd) = $(getLabel ''(,))

-- | Polymorphic lens that swaps the components of a tuple. (Total and polymorphic)

swap :: ArrowApply arr => Poly.Lens arr ((a, b) -> (c, d)) ((b, a) -> (d, c))
swap = let io = Iso (arr Tuple.swap) (arr Tuple.swap) in Poly.iso io io

-- | Lens pointing to the first component of a 3-tuple. (Total and polymorphic)

fst3 :: ArrowApply arr => Poly.Lens arr ((a, b, c) -> (o, b, c)) (a -> o)

-- | Lens pointing to the second component of a 3-tuple. (Total and polymorphic)

snd3 :: ArrowApply arr => Poly.Lens arr ((a, b, c) -> (a, o, c)) (b -> o)

-- | Lens pointing to the third component of a 3-tuple. (Total and polymorphic)

trd3 :: ArrowApply arr => Poly.Lens arr ((a, b, c) -> (a, b, o)) (c -> o)

(fst3, snd3, trd3) = $(getLabel ''(,,))

-- | Partial isomorphism for readable and showable values. Can easily be lifted
-- into a lens by using `iso`.

readShow :: (Read a, Show a) => Iso Partial String a
readShow = Iso r s
  where r = Kleisli (fmap Tuple.fst  . listToMaybe . readsPrec 0)
        s = arr show

