module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Config
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Task
import Time exposing (..)



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
    = Failure String
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
                    ( { model | weatherStatus = Failure "Error: Couldn't retrieve weather data" }
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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 10 Tick



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Startpage"
    , body =
        [ div [ class "container" ]
            [ viewTime model.clockTime
            , viewDate model.clockTime
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
        Failure errorMsg ->
            text errorMsg

        Loading ->
            text "Loading weather..."

        Success weather ->
            text (getDesc weather ++ " | " ++ getTemp weather)


getWeather : Cmd Msg
getWeather =
    Http.get
        { url = Config.weatherApi ++ ("&q=" ++ Config.city) ++ ("&units=" ++ Config.unit) ++ ("&appid=" ++ Config.apiKey)
        , expect = Http.expectJson GotWeather weatherDecoder
        }


weatherDecoder : Json.Decoder Weather
weatherDecoder =
    Json.map2 Weather
        (Json.field "weather" (Json.index 0 (Json.field "description" Json.string)))
        (Json.field "main" (Json.field "temp" Json.float))


getTemp : Weather -> String
getTemp weather =
    String.fromInt (round weather.temperature) ++ " ??C "


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



-- Time


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



-- Date


viewDate : ClockTime -> Html Msg
viewDate clockTime =
    let
        weekday =
            Time.toWeekday clockTime.zone clockTime.time

        day =
            Time.toDay clockTime.zone clockTime.time

        month =
            Time.toMonth clockTime.zone clockTime.time

        year =
            Time.toYear clockTime.zone clockTime.time
    in
    div [ id "date" ] [ text (toEnglishWeekday weekday ++ ", " ++ String.fromInt day ++ " " ++ toEnglishMonth month ++ "  " ++ String.fromInt year) ]


toEnglishWeekday : Time.Weekday -> String
toEnglishWeekday weekday =
    case weekday of
        Mon ->
            "Monday"

        Tue ->
            "Tuesday"

        Wed ->
            "Wednesday"

        Thu ->
            "Thursday"

        Fri ->
            "Friday"

        Sat ->
            "Saturday"

        Sun ->
            "Sunday"


toEnglishMonth : Time.Month -> String
toEnglishMonth month =
    case month of
        Jan ->
            "January"

        Feb ->
            "February"

        Mar ->
            "March"

        Apr ->
            "April"

        May ->
            "May"

        Jun ->
            "June"

        Jul ->
            "July"

        Aug ->
            "August"

        Sep ->
            "September"

        Oct ->
            "October"

        Nov ->
            "November"

        Dec ->
            "December"



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
