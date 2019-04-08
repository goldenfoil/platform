module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Css exposing (..)
import Html
import Html.Events exposing (onClick)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Html.Styled.Events exposing (onClick)


main =
    Browser.sandbox { init = init, update = update, view = view >> toUnstyled }



-- MODEL


type alias Model =
    Int


init : Model
init =
    0


type HuiProssysh
    = H Int
    | ZZ


a : HuiProssysh
a =
    H 3


b : HuiProssysh
b =
    H 2


add : HuiProssysh -> HuiProssysh -> HuiProssysh
add aa bb =
    case aa of
        ZZ ->
            ZZ

        H x ->
            case bb of
                H y ->
                    H (x * y)

                ZZ ->
                    ZZ


showHuiProssysh : HuiProssysh -> String
showHuiProssysh xx =
    case xx of
        ZZ ->
            "ZZ"

        H x ->
            "H " ++ String.fromInt x


c : HuiProssysh
c =
    a
        |> add b
        |> add ZZ
        |> add (H 12)


type Dela
    = Prohuhlo
    | Ok Int
    | Zamerzlo



-- UPDATE


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1



-- VIEW


buttonStyle =
    css
        [ backgroundColor (hex "eeeeee")
        , padding (px 5)
        , width (px 50)
        , borderRadius (px 3)
        , hover
            [ backgroundColor (hex "ffffff") ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ button
            [ onClick Decrement, buttonStyle ]
            [ text "-" ]
        , div [] [ text (String.fromInt model) ]
        , button [ onClick Increment, buttonStyle ] [ text "+" ]
        , div [] [ text (showHuiProssysh c) ]
        ]
