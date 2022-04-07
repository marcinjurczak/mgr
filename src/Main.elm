module Main exposing (Model(..), Msg(..), getWeather, init, main, update, view, viewWeather, weatherDecoder)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, float, index, list, map4, string)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Model
    = Failure
    | Loading
    | Success Weather


type alias Weather =
    { description : String
    , temperature : Float
    , city : String
    , icon : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, getWeather )



-- UPDATE


type Msg
    = UpdateWeather
    | GotWeather (Result Http.Error Weather)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateWeather ->
            ( Loading, getWeather )

        GotWeather result ->
            case result of
                Ok weather ->
                    ( Success weather, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ nav [ class "navbar navbar-expand navbar-dark bg-primary" ]
            [ div [ class "container" ]
                [ a [ class "navbar-brand", href "/" ] [ text "WAPF" ]
                , ul [ class "navbar-nav me-auto" ]
                    [ li [ class "nav-item" ]
                        [ a [ class "nav-link", href "#" ] [ text "Podstawy" ] ]
                    , li [ class "nav-item" ]
                        [ a [ class "nav-link", href "#" ] [ text "ELMa" ]
                        ]
                    ]
                ]
            ]
        , div [ class "container my-2" ]
            [ viewWeather model ]
        ]


viewWeather : Model -> Html Msg
viewWeather model =
    case model of
        Failure ->
            div []
                [ text "Nie udało się załadować pogody"
                , button [ onClick UpdateWeather ] [ text "Jeszcze raz!" ]
                ]

        Loading ->
            div [] [ text "Odczytywanie..." ]

        Success weather ->
            div [ class "d-flex justify-content-left" ]
                [ div [ class "card rounded shadow", style "width" "20rem" ]
                    [ div [ class "card-body" ]
                        [ h3 [ class "card-title" ] [ text ("Pogoda  " ++ getIcon weather) ]
                        , p [ class "card-text" ] [ text (getCity weather ++ " → " ++ getTemp weather) ]
                        , button [ class "btn btn-primary", onClick UpdateWeather ] [ text "Zaktualizuj" ]
                        ]
                    ]
                ]



-- HTTP


getWeather : Cmd Msg
getWeather =
    Http.get
        { url = "https://api.openweathermap.org/data/2.5/weather?appid=ad058b50a02f29f63724fade627da689&q=Gdansk&units=metric"
        , expect = Http.expectJson GotWeather weatherDecoder
        }


weatherToString : Weather -> String
weatherToString weather =
    weather.city ++ " -> " ++ weather.description ++ " | " ++ String.fromFloat weather.temperature ++ " °C "


weatherDecoder : Decoder Weather
weatherDecoder =
    map4 Weather
        (field "weather" (index 0 (field "description" string)))
        (field "main" (field "temp" float))
        (field "name" string)
        (field "weather" (index 0 (field "icon" string)))


getTemp : Weather -> String
getTemp weather =
    String.fromFloat weather.temperature ++ " °C "


getCity : Weather -> String
getCity weather =
    weather.city


getDesc : Weather -> String
getDesc weather =
    weather.description


getIcon : Weather -> String
getIcon weather =
    case weather.icon of
        "01d" ->
            "☀"

        "01n" ->
            "☀"

        "02d" ->
            "🌤"

        "02n" ->
            "🌤"

        "03d" ->
            "🌥"

        "03n" ->
            "🌥"

        "04d" ->
            "☁"

        "04n" ->
            "☁"

        "09d" ->
            "🌧"

        "09n" ->
            "🌧"

        "10d" ->
            "🌦"

        "10n" ->
            "🌦"

        "11d" ->
            "🌩"

        "11n" ->
            "🌩"

        "13d" ->
            "❄"

        "13n" ->
            "❄"

        "50d" ->
            "🌫"

        "50n" ->
            "🌫"

        _ ->
            "X"
