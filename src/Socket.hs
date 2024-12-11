{-# LANGUAGE QuasiQuotes #-}

module Socket where

import Text.Hamlet (shamlet)
import Text.Blaze.Html.Renderer.String (renderHtml)
socket :: Int
socket = 2

htmlfoo :: [Char]
htmlfoo = do 
      renderHtml [shamlet|
        <b>
          first html from haskell!
       |] 

