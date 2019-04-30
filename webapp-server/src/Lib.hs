module Lib ( webAppEntry ) where

import           Data.Aeson                           (FromJSON, ToJSON)
import           GHC.Generics                         (Generic)
import           Network.HTTP.Types                   (status200)
import           Network.Wai                          (Application, responseLBS)
import           Network.Wai.Handler.Warp             (run)
import           Network.Wai.Middleware.RequestLogger (logStdoutDev)
import           Servant

type UserAPI = Raw

apiServer :: Server UserAPI
apiServer = serveDirectoryWebApp "./static"
-- TODO: index.html не отдается сам

apiProxy :: Proxy UserAPI
apiProxy = Proxy

app :: Application
app = logStdoutDev
    $ serve apiProxy apiServer

webAppEntry :: IO ()
webAppEntry = run 11001 app
