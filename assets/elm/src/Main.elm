module Main exposing (..)
import Html exposing (h1, text)

name = "Alex" -- set name to your name!

main =
  h1 [] [ text ("Hello " ++ name ++ "!") ]