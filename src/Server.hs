{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE BlockArguments #-}

module Server where
import Data.Typeable
import System.IO (BufferMode(..), hGetContents, hSetBuffering, hGetLine, hPutStrLn, hSetBuffering)
import Data.Char (isSpace)
import Data.Bits
import Network.Socket
import Network.URI (parseURI, nullURI, URI, URIAuth, uriAuthority, uriRegName)
--import Network.HTTP as (http)
import Data.List
import System.IO (IOMode (..),  Handle, hClose, hGetLine, hPutStrLn, openFile, readFile, hSetBuffering, hPutBuf)

import Text.Hamlet (shamlet, HamletSettings (hamletDoctype))
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

hGetLines :: Handle -> IO [String]
hGetLines h = do
  print "wat"
  l <- hGetLine h
  if all isSpace l
    then return []
    else do
      ls <- hGetLines h
      return (l : ls)
 
loadFile :: String -> IO String
loadFile url = do

        h <- getConnectHandle url 
        case h of
              Just h -> do
                        print $ "GET " ++ url
                        hPutStrLn h $ "GET / HTTP/1.1"
                        hPutStrLn h "Host: eu.httpbin.org"
                        hPutStrLn h ""
                        d <- hGetLines h
                        putStrLn $ show(typeOf d)
                        mapM_ putStrLn d
                        let f = (foldr (\a b -> a ++ "\n" ++ b) "" d)
                        hClose h
                        return f
              Nothing -> return ""

        return ""
    
        --case hGetContents h of
                --response -> return response
                --Nothing -> return ""



getConnectHandle :: String -> IO (Maybe Handle)
getConnectHandle uriLoc = do
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
                          addrs <- getAddrInfo (Just hints) (Just host) (Just "80")
                          print $ head addrs
                          sock <- socket (addrFamily $ head addrs) Stream defaultProtocol
                          setSocketOption sock KeepAlive 1 
                          connect sock (addrAddress $ head addrs)
                          h <- socketToHandle sock ReadWriteMode
                          hSetBuffering h LineBuffering
                          
                          return (Just h)
        Nothing -> return Nothing
      Nothing -> return Nothing
