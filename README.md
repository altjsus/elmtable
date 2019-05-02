# Nonofficial Airtable API module for ELM
Nonofficial and raw [Airtable API](https://airtable.com/api) module. 
Just an Http wrapper for the calls. My first elm package and opensource repo. 

Following example is not guaranteed to work copypasted. It's just an abstraction of how could the module work.
```elm
import Airtable exposing (..)
import Json.Decode exposing (..)

myDB = Airtable.DB "myKey" "myDB" "myTable"

type Msg a = Request | Data (Result Http.Error (List a))

view : Model -> Html Msg
view model = Grid.container [] [ CDN.stylesheet , Grid.row [] [ Grid.col [] [ viewTestMessage model.name ] ] ]

init : () -> (Model, Cmd Msg)
init _ = ({ data = Ok []}, Task.perform identity <| Task.succeed Request)

{- | Where `a` is your type
-}
yourJsonDecoder : Decoder a
yourJsonDecoder =
    Json.Decode.map2 a
        (field "id" string)
        (at ["fields", "Name"] string)

{-| NB: field "records" should be always put because of airtable response format [https://airtable.com/api]
-}

getRecs = getRecords testDB "Grid view" 100 100 0 <| Http.expectJson Data <| field "records" <| Json.Decode.list yourJsonDecoder

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Request ->
      (model, getRecs)
    Data r -> 
      case r of 
        Ok data -> ({ model | data = Ok data}, Cmd.none)
        Err e -> (model, Cmd.none)
```