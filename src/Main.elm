module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Task
import Time



-- MAIN


main : Program (List Bookmark) Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { status : Status
    , zone : Time.Zone
    , time : Time.Posix
    , text : String
    , bookmarks : List Bookmark
    }


type Status
    = Failure
    | Loading
    | Success Weather


type alias Weather =
    { description : String
    , temperature : Float
    }


type alias Bookmark =
    { name : String
    , url : String
    }


init : List Bookmark -> ( Model, Cmd Msg )
init bookmarks =
    ( Model Loading Time.utc (Time.millisToPosix 0) "" bookmarks
    , Cmd.batch [ Task.perform AdjustTimeZone Time.here, getWeather ]
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | UpdateWeather
    | GotWeather (Result Http.Error Weather)
    | UpdateField String
    | Search


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )

        UpdateWeather ->
            ( { model | status = Loading }
            , getWeather
            )

        GotWeather result ->
            case result of
                Ok weather ->
                    ( { model | status = Success weather }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | status = Failure }
                    , Cmd.none
                    )

        UpdateField text ->
            ( { model | text = text }
            , Cmd.none
            )

        Search ->
            ( model
            , Nav.load ("https://google.com/search?q=" ++ model.text)
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 10 Tick



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Startpage"
    , body =
        [ div [ class "container" ]
            [ div [ id "clock" ]
                [ viewTime model ]
            , div [ class "weather-container" ]
                [ div [ class "row" ]
                    [ div [ id "weather-description", class "inline" ]
                        [ div [ id "weather-description", class "inline" ]
                            [ viewWeather model ]
                        ]
                    ]
                ]
            , div [ id "search" ]
                [ input
                    [ id "search-field"
                    , type_ "text"
                    , placeholder "Search"
                    , onInput UpdateField
                    , onEnter Search
                    ]
                    []
                ]
            , div [ id "bookmark-container" ]
                [ div [ class "bookmark-set" ]
                    [ div [ class "bookmark-title" ]
                        [ text "Bookmarks" ]
                    , div [ class "bookmark-inner-container" ]
                        [ viewBookmarks model.bookmarks ]
                    ]
                ]
            ]
        ]
    }


viewWeather : Model -> Html Msg
viewWeather model =
    case model.status of
        Failure ->
            text "Error: Couldn't retrieve weather data"

        Loading ->
            text "Loading weather..."

        Success weather ->
            text (getDesc weather ++ " | " ++ getTemp weather)


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.succeed msg

            else
                Json.fail "not ENTER"
    in
    on "keydown" (Json.andThen isEnter keyCode)


viewTime : Model -> Html Msg
viewTime model =
    let
        hour =
            Time.toHour model.zone model.time

        minute =
            Time.toMinute model.zone model.time

        second =
            Time.toSecond model.zone model.time
    in
    text (parseTime hour ++ ":" ++ parseTime minute ++ ":" ++ parseTime second)


parseTime : Int -> String
parseTime num =
    if num < 10 then
        "0" ++ String.fromInt num

    else
        String.fromInt num


viewBookmarks : List Bookmark -> Html Msg
viewBookmarks bookmarks =
    ul [] (List.map viewBookmark bookmarks)


viewBookmark : Bookmark -> Html Msg
viewBookmark bookmark =
    li [ class "bookmark" ] [ a [ class "bookmark", href bookmark.url ] [ text bookmark.name ] ]



-- HTTP


getWeather : Cmd Msg
getWeather =
    Http.get
        { url = "https://api.openweathermap.org/data/2.5/weather?appid=ad058b50a02f29f63724fade627da689&q=Gdansk&units=metric"
        , expect = Http.expectJson GotWeather weatherDecoder
        }


weatherDecoder : Json.Decoder Weather
weatherDecoder =
    Json.map2 Weather
        (Json.field "weather" (Json.index 0 (Json.field "description" Json.string)))
        (Json.field "main" (Json.field "temp" Json.float))


getTemp : Weather -> String
getTemp weather =
    String.fromInt (round weather.temperature) ++ " °C "


getDesc : Weather -> String
getDesc weather =
    weather.description
