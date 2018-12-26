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

The function \tc{compile} takes a Translator file name, \tc{T.atf\_trans}, and a list of source file names, \tc{x1.atf\_src, ..., xN.atf\_src}, and does the following:

\begin{enumerate}
    \item Parse \tc{T.atf\_trans}.
    \item Compile the parse \tc{T.atf\_trans} into an ATF translator specification. This specification, $T$, specifies the source syntax to be parsed and the target text format to write the compiled source as. The same $T$ will be used for transpiling each of the \tc{xi.atf\_src}.
    \item For each \tc{xi.atf\_src}, do the following.
        \begin{enumerate}
            \item Parse \tc{xi.atf\_src}.
            \item Compile \tc{xi.atf\_src} into $x_i$, which is interpreted abstractly as in the framework of the target format specified by $L$.
            \item Translate $x_i$ into text format, written into \tc{xi.atf\_tgt}, where ``\tc{atf\_tgt}'' is the target file format specified by $T$.
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
compile fp_trans fp_srcs = do
    putStrLn $ "compiling translator: " ++ fp_trans
    transcode <- readFile fp_trans
    trans <- compile_translator fp_trans
    foldl (>>) (putStr "") $
        map (\fp_src -> do
            putStrLn $ "compiling source: " ++ fp_src
            srccode <- readFile fp_src
            tgtcode <- compile_sourcecode trans srccode
            writeFile (trans_convert_filepath trans fp_src) tgtcode)
        fp_srcs

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\section{Compiling Translator}

% TODO: description

%///////////////////////////////////////////////
\begin{code}

type SourceCode = String
type TransCode  = String

data Translator = Translator -- TODO: implementation
    -- , trans_convert_filepath :: FilePath -> FilePath }

compile_translator :: TransCode -> IO Translator
compile_translator transcode = -- TODO: implementation
    return trans_example
    -- return trans_md_to_html

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\section{Example Translator}

% TODO: description

%///////////////////////////////////////////////
\begin{code}

trans_example = error "undefined"

trans_md_to_html = error "undefined"

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\section{Compiling Source}

% TODO: description

%///////////////////////////////////////////////
\begin{code}

compile_sourcecode :: Translator -> SourceCode -> IO TargetCode
compile_sourcecode = error "undefined"

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

% TODO: description

%///////////////////////////////////////////////
\begin{code}

type Token = String

type Block = [BlockChild]

type BlockChild
    = ChildCode  SourceCode
    | ChildBlock Block

block_title :: Block -> String
block_title b = case b of
    (ChildCode  t:_) -> t
    (ChildBlock _:_) -> error "block title must be string"
    _                -> error "block has no title"

add_child :: Block -> BlockChild -> Block
add_child cs child = case child of
    -- new child is code
    ChildCode x -> case cs of
        -- if most recent child is code, append x to that
        (ChildCode y : cs_) -> ChildCode (y ++ x) : cs_
        -- otherwise, append to children
        _ -> ChildCode x : cs
    -- new child is a block
    ChildBlock x -> x : cs

add_parition :: Block -> Block
add_parition cs = case cs of
    ("":_) -> cs
    _ -> "":cs

sourcecode_to_blocktree :: SourceCode -> IO Block
sourcecode_to_blocktree sourcecode =
    let root_block = []
        empty_block = []
        helper :: Block -> SourceCode -> IO (Block, SourceCode)
        helper block srccode = case srccode of
            -- end of sourcecode
            "" -> return (block, "")
            -- begin block
            ('<':'|':xs) -> do
                (new_block, xs_rest) <- helper empty_block xs
                debug $ "begin block: " ++ (block_title new_block)
                helper block xs_rest
            -- end current block
            ('|':'>':xs) -> do
                debug $ "end block: " ++ (block_title block)
                return (block, xs)
            -- add partition to current block
            ('|':xs) ->
                let new_block = add_parition block
                in do
                    debug $ "part block: " ++ (block_title new_block)
                    helper new_block xs
            -- add normal character
            (x:xs) ->
                let new_block = add_child block (ChildCode [x])
                in do
                    debug $ "add char: " ++ [x] 
                    helper new_block xs

    in helper sourcecode root_block

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\end{document}
%-------------------------------------------------------------------------------
