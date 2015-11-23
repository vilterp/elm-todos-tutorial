module Main where

import Signal exposing (Signal)
import Debug

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import StartApp.Simple as StartApp

-- model & view

type alias Model =
  Int


type Action
  = Increment
  | Decrement


view : Signal.Address Action -> Model -> Html
view addr model =
  Debug.crash "TODO"


update : Action -> Model -> Model
update action model =
  Debug.crash "TODO"


-- wiring

config : StartApp.Config Model Action
config =
  { model = 0
  , view = view
  , update = update
  }


main : Signal Html
main =
  StartApp.start config
