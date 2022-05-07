module Config exposing (..)


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
