{-# LANGUAGE QuasiQuotes #-}

module Server where

import Data.Bits
import Network.Socket
import Network.URI
import Data.List
import System.IO (IOMode (..),  Handle, hClose, hGetLine, hPutStrLn)

import Text.Hamlet (shamlet)
import Text.Blaze.Html.Renderer.String (renderHtml)

server :: IO()
server = do
    addrinfos <- getAddrInfo
                    (Just (defaultHints {addrFlags = [AI_PASSIVE]}))
                    Nothing
                    (Just "9999")
    let serveraddr = head addrinfos
    sock <- socket (addrFamily serveraddr) Stream defaultProtocol -- make socket
    bind sock (addrAddress serveraddr) -- bind socket to port
    listen sock 1 -- set up listener
    (sClient, _) <- accept sock -- accept the socket and save as sClient
    putStrLn "New connection accepted"
    hClient <- socketToHandle sClient ReadWriteMode -- create a handle for the client
    hPutStrLn hClient htmlfoo
    msg <- hGetLine hClient -- recieve message from the client
    putStrLn msg
    close sClient -- close
    close sock
    hClose hClient


htmlfoo :: [Char]
htmlfoo = do 
      renderHtml [shamlet|
        <b>
          first html from haskell!
      |] 

