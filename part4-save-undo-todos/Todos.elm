module Todos where

import Signal exposing (Signal)
import Task exposing (Task)
import Time exposing (Time)
import Debug

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events.Extra exposing (..)
import StartApp as StartApp
import Effects exposing (Effects)

import Model exposing (..)
import Save

-- controller

type Action
  = UpdateText String
  | AddTodo
  | MarkDone TodoId Bool
  | Delete TodoId
  | Undo
  | Redo
  | Save
  | SaveFailed
  | SaveSucceeded
  | ClearFlashMessage FlashMessageId
  | NoOp


update : Action -> Model -> (Model, Effects Action)
update action model =
  Debug.crash "TODO"


clearAfterTimeout : FlashMessageId -> Task x Action
clearAfterTimeout id =
  Debug.crash "TODO"


-- view

view : Signal.Address Action -> Model -> Html
view addr model =
  Debug.crash "TODO"


viewTodo : Signal.Address Action -> Todo -> Html
viewTodo addr todo =
  Debug.crash "TODO"


-- wiring

config : StartApp.Config Model Action
config =
  { init = (initialModel initialTodos, Effects.none)
  , view = view
  , update = update
  , inputs = []
  }


app : StartApp.App Model
app =
  StartApp.start config


port initialTodos : List { text : String, done : Bool }


port tasks : Signal (Task Effects.Never ())
port tasks =
  app.tasks


main : Signal Html
main =
  app.html
