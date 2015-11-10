module Save where

import Json.Encode as JsEnc
import Json.Decode as JsDec
import Task exposing (Task)

import Http

import Model exposing (..)

-- Json encoding

encode : List Todo -> String
encode todos =
  JsEnc.encode 4 (encodeTodoList todos)


encodeTodoList : List Todo -> JsEnc.Value
encodeTodoList todos =
  JsEnc.list (List.map encodeTodo todos)


encodeTodo : Todo -> JsEnc.Value
encodeTodo todo =
  JsEnc.object
    [ ("text", JsEnc.string todo.text)
    , ("done", JsEnc.bool todo.done)
    ]

-- saving

save : List Todo -> Task String ()
save todos =
  Http.send
    Http.defaultSettings
    { verb = "POST"
    , headers = [("Content-Type", "application/json")]
    , url = "//localhost:8088/saveTodos"
    , body = Http.string (encode todos)
    }
  |> Task.mapError toString
  |> Task.map (always ())
