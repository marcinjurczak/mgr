module MainWeather exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Task
import Time exposing (..)



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
    { dateTime : DateTime
    , weatherStatus : WeatherStatus
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


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model (DateTime Time.utc (Time.millisToPosix 0)) Loading
    , Cmd.batch [ Task.perform AdjustTimeZone Time.here, Task.perform Tick Time.now, getWeather ]
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | UpdateWeather
    | GotWeather (Result Http.Error Weather)


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
        ]
    }



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


weatherDecoder : Json.Decoder Weather
weatherDecoder =
    Json.map2 Weather
        (Json.field "weather" (Json.index 0 (Json.field "description" Json.string)))
        (Json.field "main" (Json.field "temp" Json.float))


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
