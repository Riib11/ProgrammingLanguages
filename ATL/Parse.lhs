\documentclass{article}
\usepackage{verbatim}
%-------------------------------------------------------------------------------
% \newenvironment{code}{\footnotesize\verbatim}{\endverbatim\normalsize}
\newenvironment{code}{\verbatim}{\endverbatim\normalsize}
\newcommand{\tc}[1]{\texttt{#1}}
%-------------------------------------------------------------------------------

\title{ATL Parse}
\author{Henry Blanchette}
\date{December 8, 2018}

%-------------------------------------------------------------------------------
\begin{document}

\maketitle


\begin{code}

module Parse (parse) where

\end{code}

This module supplies a single function, \tc{parse}, which traslates the text of an input file into an array of \tc{ParseItem} which are easy to transpile using a transpilation blueprint (provided during compilation).

\begin{code}

strings_to_separate :: [String]
strings_to_separate =
    [" "]

strings_to_ignore :: [String]
strings_to_ignore =
    ["\n"]

begins :: String -> String -> Bool
begins a b = case a, b of
    ""  , _    -> True
    _   , ""   -> False
    x:xs, y:ys -> if x == y
        then xs `begins` ys
        else False

begins_any_of :: String -> [String] -> Bool
begins_any_of a bs = any $ map (\b -> a `begins` b) bs

\end{code}

\begin{code}

data ParseItem = ParseItem
    , name       :: String
    , uid        :: Int
    , fields     :: (String, String) }

\end{code}

\begin{code}

parse :: String -> [ParseItem]
parse lines
    = ignore
    $ separate lines ""

ignore :: [ParseItem] -> [ParseItem]
ignore [] = []
ignore (c:cs)

separate :: String -> String -> [ParseItem]
separate [] _ = []
separate (c:cs) working_s =
    if new_s `begins_any_of` strings_to_separate
        then new_parseitem : separate cs ""

        where new_s = working_s ++ [c]


\end{code}

%-------------------------------------------------------------------------------
\end{document}
