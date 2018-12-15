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
\Huge{ATL Compile}
\\[0.75cm]
\end{center}

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
