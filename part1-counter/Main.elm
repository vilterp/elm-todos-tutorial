module Main where

import Signal exposing (Signal)

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
  div
    []
    [ button
        [ onClick addr Decrement ]
        [ text "-" ]
    , text (toString model)
    , button
        [ onClick addr Increment ]
        [ text "+" ]
    ]


update : Action -> Model -> Model
update action model =
  case action of
    Increment ->
      model + 1

    Decrement ->
      model - 1


-- wiring

app : StartApp.Config Model Action
app =
  { model = 0
  , view = view
  , update = update
  }


main : Signal Html
main =
  StartApp.start app