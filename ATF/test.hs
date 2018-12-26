beheaded_by :: String -> String -> Maybe String
string `beheaded_by` target = case (string, target) of
    (s, "")      -> Just s
    ("", x:xs)   -> Nothing
    (s:ss, x:xs) -> if s == x
        then ss `beheaded_by` xs
        else Nothing
