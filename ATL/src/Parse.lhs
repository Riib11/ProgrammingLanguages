\documentclass{article}
\usepackage{verbatim}

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------

\newenvironment{code}{\verbatim}{\endverbatim\normalsize}
\newcommand{\tc}[1]{\texttt{#1}}

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
\begin{document}

\begin{center}
\Huge{ATL Parse}
\\[0.75cm]
\end{center}

%-------------------------------------------------
\begin{code}

module Parse
( parse
, Token
) where

\end{code}
%------------------------------------------------

This module supplies a single function, \tc{parse}, which traslates the text of an input file into an array of \tc{ParseItem} which are easy to transpile using a transpilation blueprint (provided during compilation).

%------------------------------------------------
\begin{code}

chars_to_separate :: [Char]
chars_to_separate =
    [ ' ', '\n', '\\'
    , '*', '~', '`', '$'
    , '[', ']', '{', '}' ]

tokens_to_replace :: Token -> Maybe Token
tokens_to_replace t = Just t
-- tokens_to_replace t = case t of
--     "\n" -> Just " "
--     _    -> Just t

-- TODO: unused
begins :: String -> String -> Bool
begins a b = case (a, b) of
    (""  , _   ) -> True
    (_   , ""  ) -> False
    (x:xs, y:ys) -> if x == y
        then xs `begins` ys
        else False

-- TODO: unused
begins_any_of :: String -> [String] -> Bool
begins_any_of a bs = any (\b -> a `begins` b) bs

\end{code}
%------------------------------------------------

Parsing breaks the input file into a list of \tc{Token}s.

%------------------------------------------------
\begin{code}

type Token = String

\end{code}
%------------------------------------------------

To parse the input text, first break into tokens. Tokens are all the strings in the text that are separated by \tc{tokens_to_replace} elements. Of course, there could be problems with how this works if the entries in \tc{chars_to_separate} are overlapping, so make sure not to allow that. Once the text has been split into a list of tokens, can then ignore certain tokens that are entries of \tc{tokens_to_replace}. This is probably not going to be used that much, but that's ok. I like to include this feature since I like to have my programming language ignore newlines.

%------------------------------------------------
\begin{code}

parse :: String -> [Token]
parse text = replace $ separate text

replace :: [Token] -> [Token]
replace []     = []
replace (t:ts) = case tokens_to_replace t of
    Nothing -> replace ts
    Just t  -> t : replace ts

separate :: String -> [Token]
separate input_text = 
    let helper :: String -> Token -> [Token]
        helper [] working_token =
            case working_token of
                "" -> []
                _  -> [working_token]
        helper (c:cs) working_token =
            if c `elem` chars_to_separate
                then case working_token of
                    "" -> [c] : helper cs ""
                    _  -> working_token : [c] : helper cs ""
                else helper cs $ working_token ++ [c]
    in helper input_text ""

\end{code}
%------------------------------------------------

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
\end{document}
