module Todos where

import Signal exposing (Signal)
import Debug

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events.Extra exposing (..)
import StartApp.Simple as StartApp

-- model

type alias Model =
  { todos : List Todo
  , currentText : String
  , latestId : TodoId
  }


type alias Todo =
  { id : TodoId
  , text : String
  , done : Bool
  }


type alias TodoId =
  Int


initialModel : Model
initialModel =
  { currentText = ""
  , todos = []
  , latestId = 0
  }


{-| Has no effect if the given todo id is not found -}
markDone : TodoId -> Bool -> Model -> Model
markDone id done model =
  let
    update todo =
      if todo.id == id then
        { todo | done = done }
      else
        todo
  in
    { model | todos = List.map update model.todos }


delete : TodoId -> Model -> Model
delete id model =
  { model | todos = List.filter (\todo -> todo.id /= id) model.todos }


-- controller

type Action
  = UpdateText String
  | AddTodo
  | MarkDone TodoId Bool
  | Delete TodoId
  | NoOp


update : Action -> Model -> Model
update action model =
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
  { model = initialModel
  , view = view
  , update = update
  }


main : Signal Html
main =
  StartApp.start config