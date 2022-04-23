-- https://ellie-app.com/6NXVPqPXtxqa1

module ResponsiveText exposing (main)

import Browser
import Browser.Events
import Element exposing (..)
import Element.Font as Font
import Element.Region exposing (..)
import Html exposing (Html)


type Msg
    = OnResize Int Int


type alias Model =
    { width : Int
    , height : Int
    }


type alias Flags =
    { x : Int
    , y : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { width = flags.x
      , height = flags.y
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnResize x y ->
            ( { model | width = x, height = y }, Cmd.none )


view : Model -> Html Msg
view model =
    Element.layout []
        (sampleCopy model)



-- subscriptions : Model -> Sub Msg
-- subscriptions model =
--     Sub.batch [ Browser.Events.onResize  OnResize ]


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Browser.Events.onResize OnResize
        }


sampleCopy : { a | height : Int, width : Int } -> Element Msg
sampleCopy viewport =
    let
        device =
            classifyDevice_ viewport
    in
    Element.textColumn [ spacing 10 |> device.ifTabletAndUp (spacingXY 20 30), padding 10 |> device.ifTabletAndUp (padding 20) ]
        [ el [ heading 1 ] (text "ALICE’S ADVENTURES IN WONDERLAND")
        , paragraph [ Font.size 14 |> device.ifTabletAndUp (Font.size 18) |> device.ifDesktopAndUp (Font.size 24) ] [ text "Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do: once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it, ‘and what is the use of a book,’ thought Alice ‘without pictures or conversations?’" ]
        ]



-- HELPERS


classifyDevice_ :
    { a | height : Int, width : Int }
    ->
        { ifTabletAndUp : Attribute msg -> Attribute msg -> Attribute msg
        , ifDesktopAndUp : Attribute msg -> Attribute msg -> Attribute msg
        }
classifyDevice_ viewport =
    { ifTabletAndUp = ifTabletAndUp viewport
    , ifDesktopAndUp = ifDesktopAndUp viewport
    }


ifTabletAndUp : { a | height : Int, width : Int } -> Attribute msg -> Attribute msg -> Attribute msg
ifTabletAndUp viewport attr1 attr2 =
    let
        device =
            classifyDevice viewport
    in
    case device.class of
        Tablet ->
            attr1

        _ ->
            attr2


ifDesktopAndUp : { a | height : Int, width : Int } -> Attribute msg -> Attribute msg -> Attribute msg
ifDesktopAndUp viewport attr1 attr2 =
    let
        device =
            classifyDevice viewport
    in
    case device.class of
        Desktop ->
            attr1

        _ ->
            attr2



-- Large desktop left as excerise for the reader :)
