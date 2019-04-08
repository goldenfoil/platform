module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


main =
    Browser.sandbox { init = init, update = update, view = view }



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


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , div [] [ text (String.fromInt model) ]
        , button [ onClick Increment ] [ text "+" ]
        , div [] [ text (showHuiProssysh c) ]
        ]
