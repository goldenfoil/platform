module FormField exposing (FormField, create, isValid, set, validationMessages, value, wasChanged)

-- validation, initialValue, currentValue


type alias Predicate a =
    a -> Bool


type FormField a
    = FormField (List ( Predicate a, String )) a a


create : List ( Predicate a, String ) -> a -> FormField a
create validations x =
    FormField validations x x


value : FormField a -> a
value (FormField _ _ y) =
    y


set : a -> FormField a -> FormField a
set newValue (FormField validations x _) =
    FormField validations x newValue


isValid : FormField a -> Bool
isValid (FormField validations _ y) =
    List.all (\( f, _ ) -> f y) validations


validationMessages : FormField a -> Maybe (List String)
validationMessages (FormField validations _ y) =
    validations
        |> List.map (\( f, str ) -> ( f y, str ))
        |> List.filter (not << Tuple.first)
        |> List.map Tuple.second
        |> (\xs ->
                if List.isEmpty xs then
                    Nothing

                else
                    Just xs
           )


wasChanged : FormField a -> Bool
wasChanged (FormField f x y) =
    x == y
