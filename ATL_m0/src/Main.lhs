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
\Huge{ATL Main}
\\[0.75cm]
\end{center}

%------------------------------------------------
\begin{code}

module Main where

import System.Environment
import Parse
import Compile

-- =--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=-
-- =--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=-

data Args
    = Normal String [String]    -- language, sources
    | Help   String             -- help topic
    | Error  String             -- error message

help_msg = "usage: ./Main "
        ++ "x1.ATLsrc ... xN.ATLsrc "
        ++ "-l L.ATLlang"

-- =--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=-
-- =--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=-

default_args = Normal "" []

parse_args :: [String] -> Args
parse_args cl_args = let
    helper ls args = case args of
        Help  _ -> args
        Error _ -> args
        Normal lang ss -> case ls of
            []                -> args
            "-h" : topic : _  -> Help topic
            "-h" : []         -> Help "all"
            "-l" : lang  : ls -> helper ls $ Normal lang ss
            s    : ls         -> helper ls $ Normal lang (ss++[s])
    in helper cl_args default_args

-- =--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=-
-- =--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=-

show_list :: [String] -> String
show_list ls = case ls of
    []    -> ""
    x:[]  -> x
    x:xs  -> case x of
        " " -> show_list xs
        _ -> x ++ " " ++ show_list xs

main = do
    cl_args <- getArgs
    putStrLn "---------------------------------------------------------"
    putStrLn $ "cmd line args: " ++ show_list cl_args
    case parse_args cl_args of
        Help   help_msg  -> putStrLn help_msg
        Error  err_msg   -> putStrLn err_msg
        Normal lang srcs -> do
            -- input files
            putStrLn "---------------------------------------------------------"
            putStrLn $ "languages: " ++ lang
            putStrLn $ "  sources: " ++ show_list srcs
            -- input text
            putStrLn "---------------------------------------------------------"
            input_text <- readFile $ head srcs
            putStrLn $ "input text:\n" ++ input_text
            -- parse
            putStrLn "---------------------------------------------------------"
            putStrLn $ "parsed tokens:\n" ++
                let parsed_tokens = Parse.parse input_text
                in show_list parsed_tokens
            -- compile
            putStrLn "---------------------------------------------------------"
            putStrLn $ "compiled code:\n" ++
                let compiled_code = Compile.compile $ parsed_tokens
                    parsed_tokens = Parse.parse input_text
                in compiled_code
            putStrLn "---------------------------------------------------------"
                


\end{code}
%------------------------------------------------

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
\end{document}
