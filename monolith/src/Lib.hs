{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module Lib ( webAppEntry ) where

import           Data.Aeson                             (FromJSON, ToJSON)
import           GHC.Generics                           (Generic)
import           Network.Wai                            (Application)
import           Network.Wai.Handler.Warp               (run)
import           Network.Wai.Middleware.Cors
import           Network.Wai.Middleware.RequestLogger   (logStdoutDev)
import           Network.Wai.Middleware.Servant.Options
import           Servant

type UserAPI =
  "api" :> "login" :> ReqBody '[JSON] PasswordAuth
                   :> Post '[JSON] AuthResult
  :<|> "api" :> "balance" :> Get '[JSON] Balance

newtype AuthResult = AuthResult {
  token :: String
} deriving (Eq, Show, Generic)

instance ToJSON AuthResult
instance FromJSON AuthResult

data PasswordAuth = PasswordAuth
  { username :: String
  , password :: String
  } deriving (Eq, Show, Generic)

instance ToJSON PasswordAuth
instance FromJSON PasswordAuth

newtype Balance = Balance { balance :: Float } deriving (Eq, Show, Generic)

instance ToJSON Balance
instance FromJSON Balance


authResult :: PasswordAuth -> Handler AuthResult
authResult _ = pure AuthResult { token = "some_token" }

balanceResponse :: Balance
balanceResponse = Balance { balance = 42.042 }

apiServer :: Server UserAPI
apiServer = authResult :<|> pure balanceResponse

apiProxy :: Proxy UserAPI
apiProxy = Proxy

app :: Application
app = logStdoutDev $ cors (const $ Just policy)
    $ provideOptions apiProxy
    $ serve apiProxy apiServer
  where
  policy = simpleCorsResourcePolicy
            { corsRequestHeaders = [ "content-type" ] }

webAppEntry :: IO ()
webAppEntry = run 3000 app
