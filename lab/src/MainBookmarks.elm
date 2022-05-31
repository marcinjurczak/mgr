module MainBookmarks exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, andThen, fail, field, float, index, map2, string, succeed)
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
    { dateTime : DateTime
    , weatherStatus : WeatherStatus
    , searchText : String
    , bookmarks : List Bookmark
    }


type alias DateTime =
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
    ( Model (DateTime Time.utc (Time.millisToPosix 0)) Loading "" bookmarks
    , Cmd.batch [ Task.perform AdjustTimeZone Time.here, Task.perform Tick Time.now, getWeather ]
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
            ( { model | dateTime = DateTime model.dateTime.zone newTime }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model | dateTime = DateTime newZone model.dateTime.time }
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
    Time.every 1000 Tick



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Hello"
    , body =
        [ viewTime model.dateTime
        , viewDate model.dateTime
        , viewWeather model.weatherStatus
        , viewSearchBar
        , viewBookmarks model.bookmarks
        ]
    }



-- Time


viewTime : DateTime -> Html Msg
viewTime dateTime =
    let
        hour =
            Time.toHour dateTime.zone dateTime.time

        minute =
            Time.toMinute dateTime.zone dateTime.time

        second =
            Time.toSecond dateTime.zone dateTime.time
    in
    div [] [ text (parseTime hour ++ ":" ++ parseTime minute ++ ":" ++ parseTime second) ]


parseTime : Int -> String
parseTime num =
    if num < 10 then
        "0" ++ String.fromInt num

    else
        String.fromInt num



-- Date


viewDate : DateTime -> Html Msg
viewDate dateTime =
    let
        weekday =
            Time.toWeekday dateTime.zone dateTime.time

        day =
            Time.toDay dateTime.zone dateTime.time

        month =
            Time.toMonth dateTime.zone dateTime.time

        year =
            Time.toYear dateTime.zone dateTime.time
    in
    div [] [ text (toEnglishWeekday weekday ++ ", " ++ String.fromInt day ++ " " ++ toEnglishMonth month ++ "  " ++ String.fromInt year) ]


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



-- Weather


viewWeather : WeatherStatus -> Html Msg
viewWeather weatherStatus =
    div [] [ viewWeatherStatus weatherStatus ]


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
        { url = weatherApi ++ ("&q=" ++ city) ++ ("&units=" ++ unit) ++ ("&appid=" ++ apiKey)
        , expect = Http.expectJson GotWeather weatherDecoder
        }


weatherDecoder : Decoder Weather
weatherDecoder =
    map2 Weather
        (field "weather" (index 0 (field "description" string)))
        (field "main" (field "temp" float))


apiKey : String
apiKey =
    "ad058b50a02f29f63724fade627da689"


city : String
city =
    "Gdansk"


weatherApi : String
weatherApi =
    "https://api.openweathermap.org/data/2.5/weather?"


type Unit
    = Celsius
    | Fahrenheit
    | Kelvin


unitForTemp : Unit
unitForTemp =
    Celsius


unit : String
unit =
    case unitForTemp of
        Celsius ->
            "metric"

        Fahrenheit ->
            "imperial"

        Kelvin ->
            ""


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
                succeed msg

            else
                fail "not ENTER"
    in
    on "keydown" (andThen isEnter keyCode)



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
