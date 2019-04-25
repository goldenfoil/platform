{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeOperators #-}

module Lib ( webAppEntry ) where

import           Data.Aeson                           (FromJSON, ToJSON)
import           GHC.Generics                         (Generic)
import           Network.Wai                          (Application)
import           Network.Wai.Handler.Warp             (run)
-- import           Network.Wai.Middleware.Cors          (simpleCors)
import           Network.Wai.Middleware.RequestLogger (logStdoutDev)
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

server :: Server UserAPI
server = authResult :<|> pure balanceResponse

userAPI :: Proxy UserAPI
userAPI = Proxy

app :: Application
app = serve userAPI server

webAppEntry :: IO ()
webAppEntry = run 3000 $ simpleCors $ logStdoutDev app
