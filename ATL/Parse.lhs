\documentclass{article}
\usepackage{verbatim}
%-------------------------------------------------------------------------------
\newenvironment{code}{\footnotesize\verbatim}{\endverbatim\normalsize}
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

This module supplies a single function, \tc{parse}, which traslates the lines of an input file into \tc{ParseNode} objects which are easy to transpile using a transpilation blueprint.

\begin{code}

parse_ignore   = []
parse_separate = []

\end{code}

\begin{code}

data ParseItem = ParseItem
    , name       :: String
    , uid        :: Int
    , fields     :: (String, String) }

\end{code}

\begin{code}

parse :: [String] -> [ParseItem]
parse _ = []

\end{code}

%-------------------------------------------------------------------------------
\end{document}
