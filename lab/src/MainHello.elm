module MainHello exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Task



-- MAIN


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { greet : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { greet = "Hello, World!" }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Hello String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Hello greet ->
            ( { model | greet = greet }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Hello"
    , body =
        [ h1 [] [ text model.greet ]
        , button [ onClick (Hello "Hello, again!") ] [ text "Click me!" ]
        ]
    }
