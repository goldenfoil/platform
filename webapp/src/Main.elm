module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import FormField exposing (FormField, isValid, validationMessages)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http


main =
    Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type LoginState
    = LoggedIn UserDetails
    | NotLoggedIn FormErrors FormFields


type alias UserDetails =
    { username : Username
    , token : Token
    }


type FormErrors
    = NoError
    | ServerError String -- errorMessage
    | Pending


type alias FormFields =
    { username : FormField Username
    , password : FormField String
    }


type alias Token =
    String


type alias Username =
    String


type alias ServerError =
    Maybe String


type alias Model =
    LoginState


usernameValidation =
    [ ( \str -> String.length str >= 3, "length should be 3 or more characters" )
    , ( \str -> String.length str >= 5, "length should be 5 or more characters" )
    ]


passwordValidation =
    [ ( \str -> String.length str >= 3, "length should be 3 or more characters" ) ]


init : () -> ( Model, Cmd Msg )
init _ =
    ( NotLoggedIn NoError
        { username = FormField.create usernameValidation ""
        , password = FormField.create passwordValidation ""
        }
    , Cmd.none
    )


type Msg
    = ChangeLogin Username
    | ChangePassword String
    | Submit
    | LoginResult (Result Http.Error Token)
    | ManualLogout
    | ForceLogout String -- errorMessage


noCommands model =
    ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        -- Editable -> Editable
        ( NotLoggedIn errors fields, ChangeLogin newUsername ) ->
            NotLoggedIn errors { fields | username = FormField.set newUsername fields.username } |> noCommands

        -- Editable -> Editable
        ( NotLoggedIn errors fields, ChangePassword newPassword ) ->
            NotLoggedIn errors { fields | password = FormField.set newPassword fields.password } |> noCommands

        -- Submittable -> Pending
        ( NotLoggedIn NoError fields, Submit ) ->
            if isValid fields.username && isValid fields.password then
                ( NotLoggedIn Pending fields, performLogin )

            else
                model |> noCommands

        -- Submittable -> Pending (duplicate, remove by moving Pending up)
        ( NotLoggedIn (ServerError _) fields, Submit ) ->
            if isValid fields.username && isValid fields.password then
                ( NotLoggedIn Pending fields, performLogin )

            else
                model |> noCommands

        -- Pending -> Login Successful
        ( NotLoggedIn Pending { username }, LoginResult (Ok token) ) ->
            LoggedIn { username = FormField.value username, token = token } |> noCommands

        -- Pending -> Login Failed
        ( NotLoggedIn Pending fields, LoginResult (Err err) ) ->
            NotLoggedIn (ServerError <| parseError err) fields |> noCommands

        -- Logged In -> Logged Out
        ( LoggedIn details, ManualLogout ) ->
            NotLoggedIn NoError
                { username = FormField.create usernameValidation details.username
                , password = FormField.create passwordValidation ""
                }
                |> noCommands

        -- Logged In -> Logged Out
        ( LoggedIn details, ForceLogout errorMessage ) ->
            NotLoggedIn (ServerError errorMessage)
                { username = FormField.create usernameValidation details.username
                , password = FormField.create passwordValidation ""
                }
                |> noCommands

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
                    [ input [ value <| FormField.value username, onInput ChangeLogin, disabled (isPendingState editingState) ] []
                    , viewValidationMessages username
                    ]
                , div [] [ text "Password" ]
                , div []
                    [ input [ value <| FormField.value password, onInput ChangePassword, disabled (isPendingState editingState) ] []
                    , viewValidationMessages password
                    ]
                , div []
                    [ button [ onClick Submit, disabled <| isPendingState editingState ] [ text "Submit" ]
                    ]
                , viewFormErrors editingState
                ]


viewValidationMessages : FormField a -> Html Msg
viewValidationMessages ff =
    validationMessages ff
        |> Maybe.map (List.intersperse ", " >> String.concat)
        |> Maybe.withDefault "👍"
        |> text


isPendingState : FormErrors -> Bool
isPendingState st =
    case st of
        Pending ->
            True

        _ ->
            False


isSubmittableState : FormErrors -> Bool
isSubmittableState st =
    case st of
        NoError ->
            True

        _ ->
            False


viewFormErrors : FormErrors -> Html Msg
viewFormErrors st =
    case st of
        Pending ->
            div [] [ text "logging in..." ]

        ServerError errorMessage ->
            div [] [ text errorMessage ]

        _ ->
            div [] []
