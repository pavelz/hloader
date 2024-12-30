{-# LANGUAGE QuasiQuotes #-}

module Server where

import Data.Bits
import Network.Socket
import Network.URI
import Data.List
import System.IO (IOMode (..),  Handle, hClose, hGetLine, hPutStrLn, openFile, readFile)

import Text.Hamlet (shamlet)
import Text.Blaze.Html.Renderer.String (renderHtml)
import Text.Blaze.Html4.FrameSet (object)

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
    file <- htmlfoo "file.htm"
    hPutStrLn hClient file
    msg <- hGetLine hClient -- recieve message from the client
    putStrLn msg
    close sClient -- close
    close sock
    hClose hClient

htmlfoo :: FilePath -> IO String
htmlfoo filePath = do
      textfile <- readFile filePath
      return $ renderHtml [shamlet|
        <b>
          Merry Christmas!
          #{textfile}
        |] 
        

loadFile :: FilePath -> IO String
loadFile filePath = do
    -- connect
    -- load 
    -- return file object
    return ""
