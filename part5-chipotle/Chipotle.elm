module Chipotle where

import String
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import StartApp.Simple as StartApp


type alias Order =
  { burrito : Burrito
  , drink : Maybe Drink
  , chips : Bool
  }


type alias Burrito =
  { container : Container
  , rice : Rice
  -- meat
  -- salsa
  }


type Container
  = Bowl
  | Tortilla


type Rice
  = WhiteRice
  | BrownRice


type Drink
  = Snapple
  | FountainDrink DrinkSize


type DrinkSize
  = Small
  | Large


example : Order
example =
  { burrito =
      { container = Bowl
      , rice = WhiteRice
      }
  , drink = Just (FountainDrink Large)
  , chips = True
  }


-- Top level

type Action
  = ChipUpdate Bool
  | BurritoAction BurritoAction
  | DrinkAction DrinkAction


update : Action -> Order -> Order
update action order =
  case action of
    ChipUpdate hasChips ->
      { order | chips <- hasChips }

    BurritoAction burritoAction ->
      { order | burrito <- updateBurrito burritoAction order.burrito }

    DrinkAction drinkAction ->
      { order | drink <- updateDrink drinkAction order.drink }



view : Signal.Address Action -> Order -> Html
view addr order =
  div
    []
    [ viewOrder addr order
    , span
        [ style [("font-family", "monospace")] ]
        [ text <| toString order ]
    , viewPrice order
    ]


viewOrder : Signal.Address Action -> Order -> Html
viewOrder addr order =
  p
    []
    [ text "I would like "
    , viewBurrito (Signal.forwardTo addr BurritoAction) order.burrito
    , text ", plus "
    , viewDrink (Signal.forwardTo addr DrinkAction) order.drink
    , text " and "
    , viewChips (Signal.forwardTo addr ChipUpdate) order.chips
    , text "."
    ]


type alias Cents =
  Int


price : Order -> Cents
price order =
  burritoPrice order.burrito + drinkPrice order.drink + chipPrice order.chips


-- Burrito

type BurritoAction
  = RiceUpdate Rice
  | ContainerUpdate Container


updateBurrito : BurritoAction -> Burrito -> Burrito
updateBurrito action burrito =
  case action of
    RiceUpdate rice ->
      { burrito | rice <- rice }

    ContainerUpdate container ->
      { burrito | container <- container }


viewBurrito : Signal.Address BurritoAction -> Burrito -> Html
viewBurrito addr burrito =
  let
    (containerText, containerAction) =
      case burrito.container of
        Tortilla ->
          ("burrito", ContainerUpdate Bowl)

        Bowl ->
          ("burrito bowl", ContainerUpdate Tortilla)

    (riceText, riceAction) =
      case burrito.rice of
        WhiteRice ->
          ("white rice", RiceUpdate BrownRice)

        BrownRice ->
          ("brown rice", RiceUpdate WhiteRice)
  in
    span
      []
      [ text "a "
      , span
          [ onClick addr containerAction
          , style editableStyle
          ]
          [ text containerText ]
      , text " with "
      , span
          [ onClick addr riceAction
          , style editableStyle
          ]
          [ text riceText ]
      ]


burritoPrice : Burrito -> Cents
burritoPrice burrito =
  case burrito.container of
    Bowl ->
      700

    Tortilla ->
      750


-- drink

type DrinkAction
  = OrderSnapple
  | OrderFountainDrink DrinkSize
  | OrderNoDrink


updateDrink : DrinkAction -> Maybe Drink -> Maybe Drink
updateDrink action drink =
  case action of
    OrderSnapple ->
      Just Snapple

    OrderFountainDrink size ->
      Just (FountainDrink size)

    OrderNoDrink ->
      Nothing


viewDrink : Signal.Address DrinkAction -> Maybe Drink -> Html
viewDrink addr maybeDrink =
  let
    article =
      span
        [ onClick addr OrderNoDrink
        , style editableStyle
        ]
        [ text "a" ]
  in
    case maybeDrink of
      Just drink ->
        case drink of
          Snapple ->
            span
              []
              [ article
              , text " "
              , span
                  [ onClick addr (OrderFountainDrink Small)
                  , style editableStyle
                  ]
                  [ text "snapple" ]
              ]

          FountainDrink size ->
            span
              []
              [ article
              , text " "
              , case size of
                  Large ->
                    span
                      [ onClick addr (OrderFountainDrink Small)
                      , style editableStyle
                      ]
                      [ text "large" ]

                  Small ->
                    span
                      [ onClick addr (OrderFountainDrink Large)
                      , style editableStyle
                      ]
                      [ text "small" ]
              , text " "
              , span
                  [ onClick addr OrderSnapple
                  , style editableStyle
                  ]
                  [ text "fountain drink" ]
              ]

      Nothing ->
        span
          [ onClick addr (OrderFountainDrink Large)
          , style editableStyle
          ]
          [ text "no drink" ]


drinkPrice : Maybe Drink -> Cents
drinkPrice maybeDrink =
  case maybeDrink of
    Just drink ->
      case drink of
        Snapple ->
          200

        FountainDrink size ->
          case size of
            Large ->
              300

            Small ->
              200

    Nothing ->
      0


-- chips

viewChips : Signal.Address Bool -> Bool -> Html
viewChips addr chips =
  if chips then
    span
      [ onClick addr False
      , style editableStyle
      ]
      [ text "chips" ]
  else
    span
      [ onClick addr True
      , style editableStyle
      ]
      [ text "no chips" ]


chipPrice : Bool -> Cents
chipPrice chips =
  if chips then 200 else 0


editableStyle : List (String, String)
editableStyle =
  [ ("text-decoration", "underline")
  , ("cursor", "pointer")
  ]

-- price

viewPrice : Order -> Html
viewPrice order =
  let
    cents =
      price order
  in
    p
      []
      [ text <|
          "That'll be $" ++ toString (cents // 100) ++ "." ++ toString (cents % 100)
      ]

-- wiring

main : Signal Html
main =
  StartApp.start
    { model = example
    , update = update
    , view = view
    }
