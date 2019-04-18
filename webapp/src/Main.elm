module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import String exposing (length)


main =
    Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type alias Token =
    String


type alias Username =
    String


type alias ServerError =
    Maybe String


type alias UserDetails =
    { username : Username
    , token : Token
    }


type alias FormFields =
    { username : Username
    , password : String
    }


type EditingState
    = Submittable ServerError
      -- ServerError: either manually touched (Nothing) or rejected by server (Just errorMessage)
    | Invalid
    | Pending


type LoginState
    = LoggedIn UserDetails
    | NotLoggedIn EditingState FormFields


type alias Model =
    LoginState


init : () -> ( Model, Cmd Msg )
init _ =
    ( NotLoggedIn Invalid
        { username = ""
        , password = ""
        }
    , Cmd.none
    )


type Msg
    = ChangeLogin Username
    | ChangePassword String
    | Submit
    | LoginResult (Result Http.Error Token)
    | Logout ServerError -- Either manual login (Nothing) or force logout (Just errorMessage)



-- | LoginFailed String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        -- Editable -> Editable
        ( NotLoggedIn _ fields, ChangeLogin newValue ) ->
            ( updateFields { fields | username = newValue }, Cmd.none )

        -- Editable -> Editable
        ( NotLoggedIn _ fields, ChangePassword newValue ) ->
            ( updateFields { fields | password = newValue }, Cmd.none )

        -- Submittable -> Pending
        ( NotLoggedIn (Submittable _) fields, Submit ) ->
            ( NotLoggedIn Pending fields, performLogin )

        -- Pending -> Login Successful
        ( NotLoggedIn Pending fields, LoginResult (Ok token) ) ->
            ( LoggedIn { username = fields.username, token = token }, Cmd.none )

        -- Pending -> Login Failed
        ( NotLoggedIn Pending fields, LoginResult (Err err) ) ->
            ( NotLoggedIn (Submittable <| Just (parseError err)) fields, Cmd.none )

        -- Logged In -> Logged Out
        ( LoggedIn details, Logout maybeError ) ->
            ( NotLoggedIn (Submittable maybeError) { username = details.username, password = "" }, Cmd.none )

        -- No other transitions of state are defined, use previous state
        _ ->
            ( model, Cmd.none )


apiUrl : String
apiUrl =
    "http://localhost:3000/api/balance"


performLogin =
    Http.get
        { url = apiUrl
        , expect = Http.expectString LoginResult
        }


parseError : Http.Error -> String
parseError err =
    case err of
        Http.BadUrl s ->
            "Bad Url " ++ s

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "Network Error"

        Http.BadStatus x ->
            "Bad Status" ++ String.fromInt x

        Http.BadBody s ->
            "Bad Body " ++ s


checkValidity : FormFields -> EditingState
checkValidity fields =
    if (length fields.username >= 3) && (length fields.password >= 3) then
        Submittable Nothing

    else
        Invalid


updateFields fields =
    NotLoggedIn (checkValidity fields) fields


view : Model -> Html Msg
view model =
    case model of
        LoggedIn details ->
            div [] [ text <| "welcome, " ++ details.username, button [ onClick (Logout Nothing) ] [ text "Log out" ] ]

        NotLoggedIn editingState fields ->
            div
                []
                [ div [] [ text "Username" ]
                , input [ value fields.username, onInput ChangeLogin, disabled (isPendingState editingState) ] []
                , div [] [ text "Password" ]
                , input [ value fields.password, onInput ChangePassword, disabled (isPendingState editingState) ] []
                , div [] [ button [ onClick Submit, disabled <| not <| isSubmittableState editingState ] [ text "Submit" ] ]
                , viewEditingState editingState
                ]


isPendingState : EditingState -> Bool
isPendingState st =
    case st of
        Pending ->
            True

        _ ->
            False


isSubmittableState : EditingState -> Bool
isSubmittableState st =
    case st of
        Submittable _ ->
            True

        _ ->
            False


viewEditingState : EditingState -> Html Msg
viewEditingState st =
    case st of
        Pending ->
            div [] [ text "logging in..." ]

        Submittable (Just errorMessage) ->
            div [] [ text errorMessage ]

        _ ->
            div [] []
