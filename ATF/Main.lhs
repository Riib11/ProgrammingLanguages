\documentclass{article}
%-------------------------------------------------------------------------------
% SETUP
%-------------------------------------------------------------------------------

\usepackage{verbatim}
\newenvironment{code}{\verbatim}{\endverbatim\normalsize}

\newcommand{\tc}[1]{\texttt{#1}}

%-------------------------------------------------------------------------------
\begin{document}
%-------------------------------------------------------------------------------

\begin{center}
\Huge{ATF Main}
\\[0.75cm]
\end{center}

\section{The Main Method}

%------------------------------------------------
\begin{code}

module Main (main) where

import System.Environment
import Help
import Compile

main :: IO ()
main = do
    clargs <- getArgs
    case clargs of
        -- main commands
        "help" : []              -> help "all"
        "help" : topic : []      -> help topic
        "compile" : []           -> help "compile"
        "compile" : fn_lang : xs -> do
            putStrLn $ "-------------------------------------------------------"
            putStrLn $ "compiling with:"
            putStrLn $ "- language: " ++ fn_lang
            putStrLn $ "- sources:  " ++ (list_to_string xs)
            putStrLn $ "-------------------------------------------------------"
            putStrLn $ "compilation status:"
            foldl (>>) (putStr "") $ compile fn_lang xs
        -- other commands
        command : _ -> error $ "unrecognized command: " ++ command
        []          -> error "use `atf help <topic>` for help"

list_to_string :: [String] -> String
list_to_string ss = case ss of
    []       -> ""
    (x:[])   -> x
    (x:y:xs) -> x ++ ", " ++ y ++ (list_to_string xs)

\end{code}
%------------------------------------------------

%-------------------------------------------------------------------------------
\end{document}
%-------------------------------------------------------------------------------
