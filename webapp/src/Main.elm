import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)


main =
    Browser.sandbox { init = init, update = update, view = view }

type alias Model = 
  { 
    login: String,
    password: String
  }

init : Model
init = 
  {
    login = "",
    password = ""
  }

type Msg
  = ChangeLogin String | ChangePassword String

update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangeLogin newValue ->
      { model | login = newValue}
    ChangePassword newValue ->
      { model | password = newValue}

view : Model -> Html Msg
view model =
  div [][
    input [ value model.login, onInput ChangeLogin] [],
    br [] [],
    br [] [],
    input [ value model.password, onInput ChangePassword] []
  ]

