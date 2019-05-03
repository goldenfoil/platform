module Colors exposing (..)

import Css exposing (..)

alphaWhite : Float -> Color
alphaWhite alpha =
    rgba 255 255 255 alpha


alphaBlack : Float -> Color
alphaBlack alpha =
    rgba 0 0 0 alpha