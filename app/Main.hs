{-# LANGUAGE QuasiQuotes #-}

module Main where

import Socket
import Text.Hamlet (shamlet)
import Text.Blaze.Html.Renderer.String (renderHtml)


-- what is the hloader
-- load url into files and serve them to the visitor
-- form to get url from the user
-- backend to load file into memory
-- backend to send urlencoded upload to the user

main :: IO ()
main = do
  putStrLn "Hello, Haskell!"
  print $ Socket.socket
  let htmlfoo = [shamlet|
        dasdassadsad
        |] 
  putStrLn $ renderHtml htmlfoo
