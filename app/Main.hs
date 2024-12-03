module Main where

import Socket

main :: IO ()
main = do
  putStrLn "Hello, Haskell!"
  print $ Socket.socket
