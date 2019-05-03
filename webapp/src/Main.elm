module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Colors exposing (..)
import Css exposing (..)
import Css.Animations as Animations
import Css.Transitions as Transitions
import FormField as FF exposing (FormField)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as A exposing (css)
import Html.Styled.Events exposing (onClick, onInput)
import Http
import Json.Decode as D
import Json.Encode as E


main =
    Browser.element { init = init, update = update, subscriptions = subscriptions, view = view >> toUnstyled }


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
            viewAuthenticated username

        NotAuthenticated formErrors formFields submitAttempted ->
            viewNotAuthenticated formErrors formFields submitAttempted


viewAuthenticated : String -> Html Msg
viewAuthenticated username =
    div []
        [ text ("Welcome, " ++ username)
        , div [] [ button [ onClick ManualSignOut ] [ text "Sign out" ] ]
        ]


wrapperStyle : Style
wrapperStyle =
    batch
        [ displayFlex
        , flexDirection column
        , alignItems center
        , Css.height (vh 100)
        , position relative
        , fontFamilies [ "Roboto" ]
        , backgroundImage (url "/background.jpg")
        , backgroundRepeat noRepeat
        , backgroundPosition center
        , backgroundSize cover
        , before
            [ property "content" "''"
            , position absolute
            , Css.width (pct 100)
            , Css.height (pct 100)
            , left zero
            , right zero
            , top zero
            , bottom zero
            , backgroundColor (alphaBlack 0.4)
            , zIndex (int 1)
            ]
        ]


headerStyle : Style
headerStyle =
    batch
        [ fontSize (px 50)
        , marginBottom (px 20)
        , fontWeight (int 400)
        ]


loginFormStyle : Style
loginFormStyle =
    batch
        [ Css.width (px 800)
        , marginTop (px 40)

        -- , color (alphaWhite 0.9)
        , color (alphaBlack 0.9)
        , padding (px 25)
        , borderRadius (px 3)
        , backgroundColor white
        , zIndex <| int 2
        ]


submitStyle : Style
submitStyle =
    batch
        [ fontSize (px 18)
        , cursor pointer
        ]


viewNotAuthenticated : FormErrors -> FormFields -> Bool -> Html Msg
viewNotAuthenticated formErrors { username, password } submitAttempted =
    div [ css [ wrapperStyle ] ]
        [ div [ css [ loginFormStyle ] ]
            [ h1 [ css [ headerStyle ] ]
                [ text "Hello" ]
            , viewInput submitAttempted formErrors username ChangeUsername False "username"
            , viewInput submitAttempted formErrors password ChangePassword True "password"
            , div [ css [ rowWrapper ] ]
                [ div [ css [ borderWrapper, wrapSubmit ] ]
                    [ input
                        [ onClick Submit
                        , A.type_ "submit"
                        , A.value "Sign in"
                        , A.disabled (isPendingState formErrors)
                        , css [ allInputs, submitStyle ]
                        ]
                        []
                    ]
                ]
            , viewFormErrors formErrors
            ]
        ]


rowWrapper : Style
rowWrapper =
    batch
        [ displayFlex
        , marginBottom (px 15)
        , alignItems center
        , height (px 73)
        ]


borderWrapper : Style
borderWrapper =
    batch
        [ displayFlex
        , alignItems center
        , height (px 40)
        ]


wrapSubmit : Style
wrapSubmit =
    marginTop (px 20)


wrapText : Style
wrapText =
    marginRight (px 15)


allInputs : Style
allInputs =
    let
        focusActiveHover =
            [ borderColor (alphaBlack 0.4)
            , borderWidth (px 2)
            , color black
            ]
    in
    batch
        [ border3 (px 1) solid (alphaBlack 0.4)
        , borderRadius (px 5)
        , outline none
        , height (px 38)
        , display block
        , minWidth (px 250)
        , backgroundColor transparent
        , fontSize (px 16)
        , fontWeight (int 300)
        , property "transition" "all ease .3s"
        , color (alphaBlack 0.9)
        , focus focusActiveHover
        , active focusActiveHover
        , hover focusActiveHover
        ]


textInput : Style
textInput =
    let
        focusActiveHover =
            [ textIndent (px 14) ]
    in
    batch
        [ textIndent (px 15)
        , focus focusActiveHover
        , active focusActiveHover
        , hover focusActiveHover
        , pseudoElement "placeholder"
            [ color (alphaBlack 0.6)
            , fontSize (px 18)
            ]
        ]


viewInput : Bool -> FormErrors -> FormField String -> (String -> Msg) -> Bool -> String -> Html Msg
viewInput submitAttempted formErrors field msg hideChars placeholderText =
    div [ css [ rowWrapper ] ]
        [ div [ css [ borderWrapper, wrapText ] ]
            [ input
                [ A.value (FF.value field)
                , A.type_
                    (if hideChars then
                        "password"

                     else
                        "text"
                    )
                , onInput msg
                , A.disabled (isPendingState formErrors)
                , A.placeholder placeholderText
                , css [ allInputs, textInput ]
                ]
                []
            ]
        , viewValidationMessages submitAttempted field
        ]


validationMessageStyle : Style
validationMessageStyle =
    let
        alertBackground =
            hex "F9E79F"
    in
    batch
        [ displayFlex
        , flexDirection column
        , alignItems flexStart
        , padding2 (px 8) (px 15)
        , borderRadius (px 5)
        , backgroundColor alertBackground
        , position relative
        , lineHeight (pct 120)
        , fontWeight (int 300)
        , before
            [ property "content" "''"
            , position absolute
            , left (px -10)
            , top <| calc (pct 50) minus (px 5)
            , width zero
            , height zero
            , borderTop3 (px 5) solid transparent
            , borderRight3 (px 10) solid alertBackground
            , borderBottom3 (px 5) solid transparent
            ]
        ]


viewValidationMessages : Bool -> FormField a -> Html Msg
viewValidationMessages submitAttempted field =
    if submitAttempted || FF.wasChanged field then
        FF.validationMessages field
            |> Maybe.map (List.map (\s -> li [] [ text s ]))
            |> Maybe.map (ul [ css [ validationMessageStyle ] ])
            |> Maybe.withDefault (div [] [])

    else
        div [] []


isPendingState : FormErrors -> Bool
isPendingState errs =
    case errs of
        Pending ->
            True

        _ ->
            False


errorContainerStyle : Style
errorContainerStyle =
    height (px 20)

viewFormErrors : FormErrors -> Html Msg
viewFormErrors errs =
    case errs of
        Pending ->
            div [ css [ errorContainerStyle, color (hex "34495E") ] ] [ text "Signing in..." ]

        ServerError errorMessage ->
            div [ css [ errorContainerStyle, color (hex "CB4335") ] ] [ text errorMessage ]

        _ ->
            div [ css [ errorContainerStyle ] ] []
