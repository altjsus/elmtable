module Airtable exposing (getRecord, getRecords, createRecord, changeRecord, deleteRecord, decodeDeletionResponce, DB, DeletionResponse)

{-| Package for Airtable integration. Just Http wrapper around calls. Watch https://airtable.com/api

  # Database type
  @docs DB
  
  # API wrappers
  @docs getRecord, getRecords, createRecord, changeRecord, deleteRecord

  # Deletion reponse type and wrapper
  @docs DeletionResponse, decodeDeletionResponce

-}

import Http
import Url.Builder

import Json.Decode exposing (..)

import Http exposing (..)

{-| Airtable database representation 
-}
type alias DB = {apiKey : String, database : String, table : String}

{-| Responce from deletion request handler
    
    Example response:
    {
      "id": "recuK4bC2bEf6d3xQ",
      "deleted": true
    }
-}
type alias DeletionResponse = {id : String, deleted : Bool}

{-| Deletion responce Json decoder
-}
decodeDeletionResponce : Decoder DeletionResponse
decodeDeletionResponce = 
  Json.Decode.map2 DeletionResponse
    (field "id" string)
    (field "deleted" bool)

{-| Get records with db, view, maxRecords, pageSize, offset, expect provided. maxRecords = max (pageSize) = 100 (from https://airtable.com/api)
-}
getRecords : DB -> String -> Int -> Int -> Int -> Expect msg -> Cmd msg
getRecords db view maxRecords pageSize offset expect =
    Http.request {
        method = "GET"
        , headers = [Http.header "Authorization" ("Bearer " ++ db.apiKey)]
        , url = "https://api.airtable.com/v0" ++
          (Url.Builder.absolute [db.database, db.table] 
            [
              Url.Builder.int "maxRecords" maxRecords, 
              Url.Builder.string "view" view,
              Url.Builder.int "pageSize" pageSize, 
              Url.Builder.int "offset" offset
            ]
          )
        , expect = expect
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
    }

{-| Get record by ID
-}
getRecord : DB -> String -> Expect msg -> Cmd msg
getRecord db id expect = 
  Http.request {
        method = "GET"
        , headers = [Http.header "Authorization" ("Bearer " ++ db.apiKey)]
        , url = "https://api.airtable.com/v0" ++ (Url.Builder.absolute [db.database, db.table, id] [ ])
        , expect = expect
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
    }

{-| Creates a new record
-}
createRecord : DB -> Value -> Expect msg -> Cmd msg
createRecord db json expect = 
  Http.request {
    method = "POST"
    , headers = [Http.header "Authorization" ("Bearer " ++ db.apiKey)]
    , url = "https://api.airtable.com/v0" ++ (Url.Builder.absolute [db.database, db.table] [ ])
    , expect = expect
    , body = Http.jsonBody json
    , timeout = Nothing
    , tracker = Nothing
  }

{-| Changes record.
   Uses "PATCH" for changing the record only by changing certain fields (fields that are not included won't be updated). From https://airtable.com/api
-}
changeRecord : DB -> Value -> Expect msg -> Cmd msg
changeRecord db json expect =
  Http.request {
    method = "PATCH"
    , headers = [Http.header "Authorization" ("Bearer " ++ db.apiKey)]
    , url = "https://api.airtable.com/v0" ++ (Url.Builder.absolute [db.database, db.table] [ ])
    , expect = expect
    , body = Http.jsonBody json
    , timeout = Nothing
    , tracker = Nothing
  }

{-| Deletes record and expects DeletionResponse or and error. Example deletion response:
    {
      "id": "recuK4bC2bEf6d3xQ",
      "deleted": true
    }
-}
deleteRecord : DB -> String -> (Result Http.Error DeletionResponse -> msg) -> Cmd msg
deleteRecord db id expect = 
 Http.request {
    method = "DELETE"
    , headers = [Http.header "Authorization" ("Bearer " ++ db.apiKey)]
    , url = "https://api.airtable.com/v0" ++ (Url.Builder.absolute [db.database, db.table, id] [ ])
    , expect = Http.expectJson expect decodeDeletionResponce
    , body = Http.emptyBody
    , timeout = Nothing
    , tracker = Nothing
  }