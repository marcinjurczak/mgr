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
    { clockTime : ClockTime
    , weatherStatus : WeatherStatus
    , searchText : String
    , bookmarks : List Bookmark
    }


type alias ClockTime =
    { zone : Time.Zone
    , time : Time.Posix
    }


type WeatherStatus
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
    ( Model (ClockTime Time.utc (Time.millisToPosix 0)) Loading "" bookmarks
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
            ( { model | clockTime = ClockTime model.clockTime.zone newTime }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model | clockTime = ClockTime newZone model.clockTime.time }
            , Cmd.none
            )

        UpdateWeather ->
            ( { model | weatherStatus = Loading }
            , getWeather
            )

        GotWeather result ->
            case result of
                Ok weather ->
                    ( { model | weatherStatus = Success weather }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | weatherStatus = Failure }
                    , Cmd.none
                    )

        UpdateField searchText ->
            ( { model | searchText = searchText }
            , Cmd.none
            )

        Search ->
            ( model
            , Nav.load ("https://google.com/search?q=" ++ model.searchText)
            )


setTime : Time.Posix -> ClockTime -> ClockTime
setTime newTime clockTime =
    { clockTime | time = newTime }


setZone : Time.Zone -> ClockTime -> ClockTime
setZone newZone clockTime =
    { clockTime | zone = newZone }



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
            [ viewTime model.clockTime
            , viewWeather model.weatherStatus
            , viewSearchBar
            , viewBookmarks model.bookmarks
            ]
        ]
    }



-- Weather


viewWeather : WeatherStatus -> Html Msg
viewWeather weatherStatus =
    div [ class "weather-container" ]
        [ div [ class "row" ]
            [ div [ id "weather-description", class "inline" ]
                [ div [ id "weather-description", class "inline" ]
                    [ viewWeatherStatus weatherStatus ]
                ]
            ]
        ]


viewWeatherStatus : WeatherStatus -> Html Msg
viewWeatherStatus weatherStatus =
    case weatherStatus of
        Failure ->
            text "Error: Couldn't retrieve weather data!"

        Loading ->
            text "Loading weather..."

        Success weather ->
            text (getDesc weather ++ " | " ++ getTemp weather)


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



-- Search


viewSearchBar : Html Msg
viewSearchBar =
    div [ id "search" ]
        [ input
            [ id "search-field"
            , type_ "text"
            , placeholder "Search"
            , onInput UpdateField
            , onEnter Search
            ]
            []
        ]


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



-- Clock


viewTime : ClockTime -> Html Msg
viewTime clockTime =
    let
        hour =
            Time.toHour clockTime.zone clockTime.time

        minute =
            Time.toMinute clockTime.zone clockTime.time

        second =
            Time.toSecond clockTime.zone clockTime.time
    in
    div [ id "clock" ]
        [ text (parseTime hour ++ ":" ++ parseTime minute ++ ":" ++ parseTime second) ]


parseTime : Int -> String
parseTime num =
    if num < 10 then
        "0" ++ String.fromInt num

    else
        String.fromInt num



-- Bookmarks


viewBookmarks : List Bookmark -> Html Msg
viewBookmarks bookmarks =
    div [ id "bookmark-container" ]
        [ div [ class "bookmark-set" ]
            [ div [ class "bookmark-title" ]
                [ text "Bookmarks" ]
            , div [ class "bookmark-inner-container" ]
                [ ul [] (List.map viewBookmark bookmarks) ]
            ]
        ]


viewBookmark : Bookmark -> Html Msg
viewBookmark bookmark =
    li [ class "bookmark" ] [ a [ class "bookmark", href bookmark.url ] [ text bookmark.name ] ]
