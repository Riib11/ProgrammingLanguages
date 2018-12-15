\documentclass{article}
%-------------------------------------------------------------------------------
% SETUP
%-------------------------------------------------------------------------------

\usepackage{verbatim}
\newenvironment{code}{\verbatim}{\endverbatim\normalsize}
\usepackage[margin=1in]{geometry}

\newcommand{\tc}[1]{\texttt{#1}}
\chardef\_=`_

%-------------------------------------------------------------------------------
\begin{document}
%-------------------------------------------------------------------------------

\begin{center}
\Huge{ATL Compile}
\\[0.75cm]
\end{center}

%-------------------------------------------------------------------------------
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

%///////////////////////////////////////////////
\begin{code}

module Compile
( compile
) where

import Debug

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\section{The Compile Function}

% TODO: description

%///////////////////////////////////////////////
\begin{code}

compile :: FilePath -> [FilePath] -> IO ()
compile fp_lang fp_srcs = do
    putStrLn $ "compiling language: " ++ fp_lang
    langcode <- readFile fp_lang
    lang <- compile_language fp_lang
    foldl (>>) (putStr "") $
        map (\fp_src -> do
            putStrLn $ "compiling source: " ++ fp_src
            srccode <- readFile fp_src
            tgtcode <- compile_source lang fp_src
            writeFile (convert_filepath lang fp_src) tgtcode)
        fp_srcs

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\section{Tokens}

% TODO: description

%///////////////////////////////////////////////
\begin{code}

type Token = String

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\section{Compiling Language}

% TODO: description

%///////////////////////////////////////////////
\begin{code}

type SourceCode = String
type LangCode   = String

data Language = Language
    { reserved_tokens :: [Token]
    , convert_filepath :: FilePath -> FilePath
    }

compile_language :: LangCode -> IO Language
compile_language langcode = -- TODO: implementation
    return example_language 

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\section{Example Language}

% TODO: description

%///////////////////////////////////////////////
\begin{code}


example_language = Language
    [ "(", ")" ]
    (\fp -> fp ++ ".exp_tgt")

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\section{Compiling Source}

% TODO: description

%///////////////////////////////////////////////
\begin{code}

type TargetCode = String

data Block = Block

compile_source :: Language -> SourceCode -> IO TargetCode
compile_source lang srccode =
    let
        -- separates SourceCode into Tokens, splitting by
        -- the tokens reserved by the Language
        separate :: SourceCode -> [Token]
        separate _ = unimplemented
        -- breaks Token list into a Block tree
        interpret_blocks :: [Token] -> Block
        interpret_blocks _ = unimplemented
        -- arranges the Block tree into the finalized TargetCode
        arrange_blocks :: Block -> SourceCode
        arrange_blocks _ = unimplemented
    in
        return
            $ arrange_blocks $ interpret_blocks $ separate
            $ srccode


\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\end{document}
%-------------------------------------------------------------------------------
