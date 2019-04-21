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


type AuthenticationState
    = Authenticated UserDetails
    | NotAuthenticated FormErrors FormFields Bool -- submitAttempted


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
    AuthenticationState


init : () -> ( Model, Cmd Msg )
init _ =
    ( NotAuthenticated NoError
        { username = FF.create usernameValidation ""
        , password = FF.create passwordValidation ""
        }
        False
    , Cmd.none
    )


usernameValidation =
    [ ( \str -> String.length str >= 5, "Should contain at least 5 characters" )
    , ( String.all Char.isAlphaNum, "Should contain only digits or letters" )
    ]


passwordValidation =
    [ ( \str -> String.length str >= 8, "Should contain at least 8 characters" )
    , ( String.any Char.isDigit, "Should contain digits" )
    , ( String.any Char.isAlpha, "Should contain letters" )
    ]


type Msg
    = ChangeUsername String
    | ChangePassword String
    | Submit
    | AuthResult (Result Http.Error String) -- token
    | ManualSignOut
    | ForceSignOut String -- errorMessage


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        -- Editable -> Editable
        ( NotAuthenticated errors fields submitAttempted, ChangeUsername newUsername ) ->
            NotAuthenticated errors { fields | username = FF.set newUsername fields.username } submitAttempted |> noCommands

        -- Editable -> Editable
        ( NotAuthenticated errors fields submitAttempted, ChangePassword newPassword ) ->
            NotAuthenticated errors { fields | password = FF.set newPassword fields.password } submitAttempted |> noCommands

        -- Submittable -> Pending
        ( NotAuthenticated NoError fields _, Submit ) ->
            if FF.isValid fields.username && FF.isValid fields.password then
                ( NotAuthenticated Pending fields True, performSignIn fields )

            else
                NotAuthenticated NoError fields True |> noCommands

        -- Submittable -> Pending -- TODO: duplicate, remove by moving Pending up
        ( NotAuthenticated (ServerError e) fields _, Submit ) ->
            if FF.isValid fields.username && FF.isValid fields.password then
                ( NotAuthenticated Pending fields True, performSignIn fields )

            else
                NotAuthenticated (ServerError e) fields True |> noCommands

        -- Pending -> Login Successful
        ( NotAuthenticated Pending { username } _, AuthResult (Ok token) ) ->
            Authenticated { username = FF.value username, token = token } |> noCommands

        -- Pending -> Login Failed
        ( NotAuthenticated Pending fields _, AuthResult (Err err) ) ->
            NotAuthenticated (ServerError <| parseError err) fields True |> noCommands

        -- Logged In -> Logged Out
        ( Authenticated { username }, ManualSignOut ) ->
            NotAuthenticated NoError
                { username = FF.create usernameValidation username
                , password = FF.create passwordValidation ""
                }
                False
                |> noCommands

        -- Logged In -> Logged Out
        ( Authenticated { username }, ForceSignOut errorMessage ) ->
            NotAuthenticated (ServerError errorMessage)
                { username = FF.create usernameValidation username
                , password = FF.create passwordValidation ""
                }
                False
                |> noCommands

        -- No other transitions of state are defined, use previous state
        _ ->
            ( model, Cmd.none )


noCommands model =
    ( model, Cmd.none )


apiUrl : String
apiUrl =
    "http://localhost:3000/api/login"


performSignIn : FormFields -> Cmd Msg
performSignIn fields =
    Http.post
        { url = apiUrl
        , body =
            Http.jsonBody (credentialsEncoder fields)
        , expect = Http.expectJson AuthResult (D.field "token" D.string) -- TODO: map error
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
        Authenticated { username } ->
            div []
                [ text ("Welcome, " ++ username)
                , div [] [ button [ onClick ManualSignOut ] [ text "Sign out" ] ]
                ]

        NotAuthenticated formErrors { username, password } submitAttempted ->
            div
                []
                [ div [] [ text "Username" ]
                , viewInput submitAttempted formErrors username ChangeUsername
                , div [] [ text "Password" ]
                , viewInput submitAttempted formErrors password ChangePassword
                , div []
                    [ button [ onClick Submit, disabled (isPendingState formErrors) ] [ text "Sign in" ]
                    ]
                , viewFormErrors formErrors
                ]


viewInput : Bool -> FormErrors -> FormField String -> (String -> Msg) -> Html Msg
viewInput submitAttempted formErrors field msg =
    div []
        [ input
            [ value (FF.value field)
            , onInput msg
            , disabled (isPendingState formErrors)
            ]
            []
        , viewValidationMessages submitAttempted field
        ]


viewValidationMessages : Bool -> FormField a -> Html Msg
viewValidationMessages submitAttempted field =
    if submitAttempted || FF.wasChanged field then
        FF.validationMessages field
            |> Maybe.map (List.intersperse ", " >> String.concat)
            |> Maybe.withDefault "✓"
            |> text

    else
        div [] []


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
            div [] [ text "Signing in..." ]

        ServerError errorMessage ->
            div [] [ text errorMessage ]

        _ ->
            div [] []
