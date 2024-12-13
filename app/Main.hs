
module Main where

import Socket
import Data.Typeable

-- what is the hloader
-- load url into files and serve them to the visitor
-- form to get url from the user
-- backend to load file into memory
-- backend to send urlencoded upload to the user

main :: IO ()
main = do
  putStrLn "Hello, Haskell!"
  print Socket.socket
  print (typeOf putStrLn)

  putStrLn htmlfoo
