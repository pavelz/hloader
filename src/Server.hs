{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE BlockArguments #-}

module Server where

import System.IO (BufferMode(..), hGetLine, hPutStrLn, hSetBuffering)
import Data.Bits
import Network.Socket
import Network.URI (parseURI, nullURI, URI, URIAuth, uriAuthority, uriRegName)
--import Network.HTTP as (http)
import Data.List
import System.IO (IOMode (..),  Handle, hClose, hGetLine, hPutStrLn, openFile, readFile, hSetBuffering)

import Text.Hamlet (shamlet)
import Text.Blaze.Html.Renderer.String (renderHtml)
import Text.Blaze.Html4.FrameSet (object, link, h1)

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
    close sClient -- close:where
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

loadFile :: String -> IO (Maybe String)
loadFile uriLoc = do
  -- parts of href link
    case parseURI uriLoc of
      Just uri -> case uriAuthority uri of
        Just ua -> do
                          let host = uriRegName ua
                          let hints = defaultHints {
                              addrFlags = []
                            , addrSocketType = Datagram
                            , addrFamily = AF_INET
                            }
                          addrs <- getAddrInfo (Just hints) (Just host) (Just "9999")
                          print $ head addrs
                          sock <- socket (addrFamily $ head addrs) Stream defaultProtocol
                          setSocketOption sock KeepAlive 1 
                          connect sock (addrAddress $ head addrs)
                          h <- socketToHandle sock ReadWriteMode
                          hSetBuffering h (BlockBuffering Nothing)
                          
                          return (Just host)
        Nothing -> return Nothing
      Nothing -> return Nothing
