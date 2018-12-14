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
\Huge{ATL Compile}
\\[0.75cm]
\end{center}

%------------------------------------------------
\begin{code}

module Compile
( compile
, Code
) where

import System.Environment
import Parse

type Code = String

data Tag = Tag
    { token_begin :: String
    , token_end   :: String
    , code_begin  :: Code
    , code_end    :: Code }

title = Tag "#" "\n" "<h1>" "</h1>"

compile_tag :: Tag -> [Token] -> Code

compile_tag tag ts =
    let helper [] = ""
        x:xs = if x == token_end
            then code_end ++ compile xs
            else x ++ compile xs
    in helper ts

compile :: [Token] -> Code
compile ts = case ts of
    "#" : ts -> "<h1>" ++
        let helper [] = []
            helper (x:xs) = case x of
                "\n" -> "</h1>\n" ++ compile xs
                _    -> x ++ helper xs
        in helper ts
    _ -> ""

-- =--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=-
-- =--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=-

\end{code}
%------------------------------------------------

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
\end{document}
