module String.Interpolate exposing (interpolate, interpolateWithDict)

{-| String.Interpolate provides a convenient method `interpolate` for injecting
values into a string. This can be useful for i18n of apps and construction of
complex strings in views.

@docs interpolate

-}

import Array exposing (Array, fromList, get)
import Dict exposing (Dict)
import Maybe exposing (andThen, withDefault)
import Regex exposing (Match, Regex, fromString, never, replace)
import String exposing (dropLeft, dropRight, toInt)


{-| Inject other strings into a string in the order they appear in a List
interpolate "{0} {2} {1}" ["hello", "!!", "world"]
"{0} {2} {1}" `interpolate` ["hello", "!!", "world"]
-}
interpolate : String -> List String -> String
interpolate string args =
    let
        asArray =
            fromList args
    in
    replace interpolationRegex (applyInterpolation asArray) string


interpolateWithDict : String -> Dict String String -> String
interpolateWithDict string dict =
    replace dictInterpolationRegex (applyDictInterpolation dict) string


interpolationRegex : Regex
interpolationRegex =
    fromString "\\{\\d+\\}" |> withDefault never


applyInterpolation : Array String -> Match -> String
applyInterpolation replacements { match } =
    let
        ordinalString =
            (dropLeft 1 << dropRight 1) match
    in
    ordinalString
        |> toInt
        |> andThen (\value -> get value replacements)
        |> withDefault ""


dictInterpolationRegex : Regex
dictInterpolationRegex =
    fromString "\\{[\\w+\\s]*\\}" |> withDefault never


applyDictInterpolation : Dict String String -> Match -> String
applyDictInterpolation replacements { match } =
    let
        ordinalString =
            (dropLeft 1 << dropRight 1) match
    in
    Dict.get ordinalString replacements
        |> withDefault ""
