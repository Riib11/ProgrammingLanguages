\documentclass{article}
%-------------------------------------------------------------------------------
% SETUP
%-------------------------------------------------------------------------------

\usepackage{verbatim}
\newenvironment{code}{\verbatim}{\endverbatim\normalsize}

\newcommand{\tc}[1]{\texttt{#1}}
\chardef\_=`_

%-------------------------------------------------------------------------------
\begin{document}
%-------------------------------------------------------------------------------

\begin{center}
\Huge{ATL Compile}
\\[0.75cm]
\end{center}

\section{Introduction}

The function \tc{compile} takes a language file name, \tc{L.atf\_lang}, and a list of source file names, \tc{x1.atf\_src, ..., xN.atf\_src}, and does the following:

\begin{enumerate}
    \item Parse \tc{L.atf\_lang}.
    \item Compile the parse \tc{L.atf\_lang} into an ATF language specification. This specification, $L$, specifies the source syntax to be parsed and the target text format to write the compiled source as. The same $L$ will be used for transpiling each of the \tc{xi.atf\_src}.
    \item For each \tc{xi.atf\_src}, do the following.
        \begin{enumerate}
            \item Parse \tc{xi.atf\_src}.
            \item Compile \tc{xi.atf\_src} into $x_i$, which is interpreted abstractly as in the framework of the target format specified by $L$.
            \item Translate $x_i$ into text format, written into \tc{xi.atf\_tgt}, where ``\tc{atf\_tgt}'' is the target file format specified by $L$.
        \end{enumerate}
\end{enumerate}

%------------------------------------------------
\begin{code}

module Compile
( compile
) where

compile :: String -> [String] -> IO ()
compile _ _ = error "unimplemented"

\end{code}
%------------------------------------------------

%-------------------------------------------------------------------------------
\end{document}
%-------------------------------------------------------------------------------
