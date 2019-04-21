module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import FormField as FF exposing (FormField)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as D
import Json.Encode as E


main =
    Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type LoginState
    = LoggedIn UserDetails
    | NotLoggedIn FormErrors FormFields


type alias UserDetails =
    { username : String
    , token : String
    }


type FormErrors
    = NoError
    | ServerError String -- errorMessage
    | Pending


type alias FormFields =
    { username : FormField String
    , password : FormField String
    }


type alias Model =
    LoginState


init : () -> ( Model, Cmd Msg )
init _ =
    ( NotLoggedIn NoError
        { username = FF.create usernameValidation ""
        , password = FF.create passwordValidation ""
        }
    , Cmd.none
    )


usernameValidation =
    [ ( \str -> String.length str >= 8, "Should have length of 8 characters or more" )
    , ( String.all Char.isAlphaNum, "Should contain only digits or letters" )
    ]


passwordValidation =
    [ ( \str -> String.length str >= 8, "Should have length of 8 characters or more" )
    , ( String.any Char.isDigit, "Should contain digits" )
    , ( String.any Char.isAlpha, "Should contain letters" )
    ]


type Msg
    = ChangeLogin String
    | ChangePassword String
    | Submit
    | LoginResult (Result Http.Error String) -- token
    | ManualLogout
    | ForceLogout String -- errorMessage


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        -- Editable -> Editable
        ( NotLoggedIn errors fields, ChangeLogin newUsername ) ->
            NotLoggedIn errors { fields | username = FF.set newUsername fields.username } |> noCommands

        -- Editable -> Editable
        ( NotLoggedIn errors fields, ChangePassword newPassword ) ->
            NotLoggedIn errors { fields | password = FF.set newPassword fields.password } |> noCommands

        -- Submittable -> Pending
        ( NotLoggedIn NoError fields, Submit ) ->
            if FF.isValid fields.username && FF.isValid fields.password then
                ( NotLoggedIn Pending fields, performLogin fields )

            else
                model |> noCommands

        -- Submittable -> Pending -- TODO: duplicate, remove by moving Pending up
        ( NotLoggedIn (ServerError _) fields, Submit ) ->
            if FF.isValid fields.username && FF.isValid fields.password then
                ( NotLoggedIn Pending fields, performLogin fields )

            else
                model |> noCommands

        -- Pending -> Login Successful
        ( NotLoggedIn Pending { username }, LoginResult (Ok token) ) ->
            LoggedIn { username = FF.value username, token = token } |> noCommands

        -- Pending -> Login Failed
        ( NotLoggedIn Pending fields, LoginResult (Err err) ) ->
            NotLoggedIn (ServerError <| parseError err) fields |> noCommands

        -- Logged In -> Logged Out
        ( LoggedIn {username}, ManualLogout ) ->
            NotLoggedIn NoError
                { username = FF.create usernameValidation username
                , password = FF.create passwordValidation ""
                }
                |> noCommands

        -- Logged In -> Logged Out
        ( LoggedIn {username}, ForceLogout errorMessage ) ->
            NotLoggedIn (ServerError errorMessage)
                { username = FF.create usernameValidation username
                , password = FF.create passwordValidation ""
                }
                |> noCommands

        -- No other transitions of state are defined, use previous state
        _ ->
            ( model, Cmd.none )


noCommands model =
    ( model, Cmd.none )


apiUrl : String
apiUrl =
    "http://localhost:3000/api/login"


performLogin : FormFields -> Cmd Msg
performLogin fields =
    Http.post
        { url = apiUrl
        , body =
            Http.jsonBody (credentialsEncoder fields)
        , expect = Http.expectJson LoginResult (D.field "token" D.string) -- TODO: map error
        }


credentialsEncoder : FormFields -> E.Value
credentialsEncoder { username, password } =
    E.object
        [ ( "username", E.string (FF.value username) )
        , ( "password", E.string (FF.value password) )
        ]


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



-- TODO: решить вопрос с тем, чтобы включить оторажение ошибок всех полей по нажатию Submit


view : Model -> Html Msg
view model =
    case model of
        LoggedIn { username } ->
            div [] [ text <| "welcome, " ++ username, button [ onClick ManualLogout ] [ text "Log out" ] ]

        NotLoggedIn editingState { username, password } ->
            div
                []
                [ div [] [ text "Username" ]
                , div []
                    [ input [ value <| FF.value username, onInput ChangeLogin, disabled (isPendingState editingState) ] []
                    , viewValidationMessages username
                    ]
                , div [] [ text "Password" ]
                , div []
                    [ input [ value <| FF.value password, onInput ChangePassword, disabled (isPendingState editingState) ] []
                    , viewValidationMessages password
                    ]
                , div []
                    [ button [ onClick Submit, disabled <| isPendingState editingState ] [ text "Submit" ]
                    ]
                , viewFormErrors editingState
                ]


viewValidationMessages : FormField a -> Html Msg
viewValidationMessages ff =
    FF.validationMessages ff
        |> Maybe.map (List.intersperse ", " >> String.concat)
        |> Maybe.withDefault "✓"
        |> text


isPendingState : FormErrors -> Bool
isPendingState errs =
    case errs of
        Pending ->
            True

        _ ->
            False


viewFormErrors : FormErrors -> Html Msg
viewFormErrors errs =
    case errs of
        Pending ->
            div [] [ text "Logging in..." ]

        ServerError errorMessage ->
            div [] [ text errorMessage ]

        _ ->
            div [] []
