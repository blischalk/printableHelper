module Lib
    ( parseArgs
    ) where

import Data.Bits
import Data.Char
import Debug.Trace
import System.Environment
import System.IO
import System.Exit
import Text.Printf

type Carry                       = Int
type StartingAddress             = Int
type EndingAddress               = Int
type Subtraction                 = Int
type WordInt                     = Int
type BytePlace                   = Int
type MaskedByte                  = Int
type Subtractions                = [Subtraction]
type AddressByteCollection       = [[Int]]
type SearchBytes                 = [[Int]]
type SubtractionColumnCollection = [[Int]]


bitsInByte :: Int
bitsInByte = 8


bytesInWord :: Int
bytesInWord = 4


maximumByteSubtractions :: Int
maximumByteSubtractions = 4


printableBytes :: [Int]
printableBytes = map ord "%_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-"


parseArgs :: IO ()
parseArgs = do
  args <- getArgs
  case args of
    [startingAddress, endingAddress]  ->
      let sa = read startingAddress :: Int
          ea = read endingAddress :: Int
          subtractions = findSubtractions sa ea
      in do
        putStrLn "Calculating required subtractions..."
        putStrLn $ printf "The starting address is: 0x%08x" sa
        mapM_ (\x -> putStrLn $ printf "0x%08x" x) subtractions
        putStrLn $ printf "The ending address is: 0x%08x" ea
    _ -> do
      name <- getProgName
      hPutStrLn stderr $
         "usage: " ++ name ++ " <memory address> <memory address>"
      exitFailure


findSubtractions :: StartingAddress -> EndingAddress -> Subtractions
findSubtractions s e = let bytes         = getBytes s e
                           bytesForWords =
                               calcBytesForWords bytes 0 [] byteCombinations
                           words = buildWords bytesForWords
                       in  words


getBytes :: StartingAddress -> EndingAddress -> AddressByteCollection
getBytes s e = [[extractByte x b | b <- [0..3]]| x <- [s,e]]


extractByte :: WordInt -> BytePlace -> MaskedByte
extractByte word b = let offset          = b * bitsInByte
                         mask            = shift 0xff offset
                         byteFromMasking = shift (word .&. mask) (- offset)
                     in byteFromMasking


calcBytesForWords :: AddressByteCollection
                  -> Carry
                  -> SubtractionColumnCollection
                  -> SearchBytes
                  -> SubtractionColumnCollection
calcBytesForWords ((x:xs) : (y:ys) : _) c r s =
    let match = findMatch x y c s
    in case match of
         [] -> []
         [x] -> calcBytesForWords [xs, ys] newCarry newResults newSearchBytes
             where newCarry       = calcCarry y c (head match)
                   newResults     = r ++ match
                   newSearchBytes = filterSearchSet s match
calcBytesForWords _ _ r _ = r


findMatch :: (Num a, Bits a) => a -> a -> a -> [[a]] -> [[a]]
findMatch sb eb c s =
    take 1 $ filter (\i ->  sb == (0x000000ff .&. (foldl (+) 0 (eb : c : i)))) s


calcCarry :: (Num a, Bits a) => a -> a -> [a] -> a
calcCarry destByte carry row =
    shift (foldl (+) 0 (destByte : carry : row) .&. 0x0000ff00) (- bitsInByte)


filterSearchSet :: (Foldable t, Foldable t1) => [t a] -> [t1 a1] -> [t a]
filterSearchSet s match = filter (\n -> (length n) == (length $ head match)) s


byteCombinations :: SearchBytes
byteCombinations = allPerms printableBytes maximumByteSubtractions


allPerms :: [Int] -> Int -> SearchBytes
allPerms _ 0  = []
allPerms itms n = (allPerms itms (n - 1)) ++ (nLengthPerms itms n)


nLengthPerms :: [Int] -> Int -> [[Int]]
nLengthPerms _ 0    = [[]]
nLengthPerms itms n = concatMap (\c -> map (\x -> c : x) $
                                       nLengthPerms itms (n - 1))
                      itms


buildWords :: [[Int]] -> [Int]
buildWords [] = []
buildWords words = filter (/= 0) $
                   foldl (\coll itm -> (buildWord itm):coll) [] $
                   columnsToBytesForWords [] words


buildWord :: [Int] -> Int
buildWord itm = foldl (.|.) 0 $
                map (\(idx, i) -> shift i (bitsInByte * idx)) $
                zip [0..] itm


columnsToBytesForWords :: [[Int]] -> [[Int]] -> [[Int]]
columnsToBytesForWords r ((w1:w1r) : (w2:w2r) : (w3:w3r) : (w4:w4r) : _) =
    columnsToBytesForWords (r ++ [(w1:w2:w3:w4:[])]) [w1r, w2r, w3r, w4r]
columnsToBytesForWords r _ = r
