module Test.ArrayUtil (run) where

import Prelude
import ArrayUtil as A
import Data.Array (length)
import Data.Foldable (all)
import Data.Int (pow)
import Effect (Effect)
import Effect.Class.Console (log)
import Effect.Unsafe (unsafePerformEffect)
import Test.QuickCheck (Result, quickCheck, (<?>))
import Test.QuickCheck.Arbitrary (class Arbitrary, arbitrary)

newtype PosInt = PosInt Int
newtype PosInt50 = PosInt50 Int
newtype PosInt10 = PosInt10 Int
newtype NatNum2k = NatNum2k Int

instance Arbitrary PosInt where
    arbitrary = PosInt <<< (_ + 1) <<< (_ `mod` maxInt) <$> arbitrary
        where maxInt = pow 2 31 - 1

instance Arbitrary PosInt50 where
    arbitrary = PosInt50 <<< (_ + 1) <<< (_ `mod` 50) <$> arbitrary

instance Arbitrary PosInt10 where
    arbitrary = PosInt10 <<< (_ + 1) <<< (_ `mod` 10) <$> arbitrary

instance Arbitrary NatNum2k where
    arbitrary = NatNum2k <<< (_ `mod` 2000) <$> arbitrary

prop_ZeroArray :: NatNum2k -> Result
prop_ZeroArray (NatNum2k len) =
    (length arr == len) && (all (_ == 0) arr) <?> msg
    where
    arr = A.buildZeroArray len
    msg = "len = " <> show len
       <> "\nbuildZeroArray len:\n" <> show arr

prop_ZeroArray2D :: PosInt50 -> PosInt50 -> Result
prop_ZeroArray2D (PosInt50 rows) (PosInt50 cols) =
    (length arr == rows) && (all (\row -> length row == cols) arr) <?> msg
    where
    arr = A.buildZeroArray2D rows cols
    msg = "rows = " <> show rows <> "\n"
       <> "cols = " <> show cols <> "\n"
       <> "buildZeroArray2D rows cols:\n" <> show arr

prop_randIntRange :: PosInt -> Result
prop_randIntRange (PosInt n) = x >= 0 && x < n <?> msg
    where
    x = unsafePerformEffect $ A.randInt n
    msg = "        n = " <> show n <> "\n"
       <> "randInt n = " <> show x

prop_randInt1 :: Result
prop_randInt1 = x == 0 <?> msg
    where
    x = unsafePerformEffect $ A.randInt 1
    msg = "randInt 1 = " <> show x

prop_CubeArray :: PosInt10 -> Result
prop_CubeArray (PosInt10 n) =
    (length cube == n) && (all check2DSubarr cube) <?> msg
    where
    cube = unsafePerformEffect $ A.buildRandCubeArray n
    check2DSubarr arr = (length arr == n) && (all check1DSubarr arr)
    check1DSubarr arr = (length arr == n) && (all inRange arr)
    inRange k = 0 <= k && k < n
    msg = "buildRandomCubeArray " <> show n <> ":\n" <> show cube

prop_ColorArray :: NatNum2k -> Result
prop_ColorArray (NatNum2k len) =
    (length arr == len) && (all validColor arr) <?> msg
    where
    arr = unsafePerformEffect $ A.buildRandColorArray len
    validColor bs = (length bs == 3) && (all isByte bs)
    isByte b = 0 <= b && b < 256
    msg = "buildRandColorArray " <> show len <> ":\n" <> show arr

run :: Effect Unit
run = do
    log "Test: buildZeroArray"
    quickCheck prop_ZeroArray
    log "Test: buildZeroArray2D"
    quickCheck prop_ZeroArray2D
    log "Test: 0 <= randInt n < n (for positive n)"
    quickCheck prop_randIntRange
    log "Test: randInt 1 == 0"
    quickCheck prop_randInt1
    log "Test: buildRandCubeArray"
    quickCheck prop_CubeArray
    log "Test: buildRandColorArray"
    quickCheck prop_ColorArray

