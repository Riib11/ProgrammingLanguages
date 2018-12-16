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
compile_source lang srccode = return
    $ arrange_blocks lang
    $ interpret_blocks lang
    $ separate lang
    $ srccode

-- separates SourceCode into Tokens, splitting by
-- the tokens reserved by the Language
separate :: Language -> SourceCode -> [Token]
separate lang srccode =
    let helper :: SourceCode -> [Token] -> Token -> [Token]
        helper srccode lang_tkns work_tkn = case (srccode, lang_tkns) of
            -- finished all of the srccode.
            -- append work_tkn if its non-empty.
            ("", _) -> if work_tkn == ""
                then []
                else [work_tkn]
            -- have gone through all tokens, so add the front char
            -- to the work_tkn, and recurse through all of
            -- the lang tokens.
            (c:s, []) -> helper s all_lang_tkns (work_tkn++[c])
            -- check to see if t extracts from s. if so, then
            -- prepend t and then restart recurse on rest of srccode.
            -- prepend work_tkn before the newfound token, if work_tkn
            -- is non-empty
            (s, t:ts) -> case t `extracted_from` s of
                Nothing -> helper s ts work_tkn
                Just s_rest -> if work_tkn == ""
                    then t : helper s_rest all_lang_tkns ""
                    else work_tkn : t : helper s_rest all_lang_tkns ""
        all_lang_tkns = reserved_tokens lang
    in helper srccode all_lang_tkns ""

-- breaks Token list into a Block tree
interpret_blocks :: Language -> [Token] -> Block
interpret_blocks _ _ = unimplemented

-- arranges the Block tree into the finalized TargetCode
arrange_blocks :: Language -> Block -> SourceCode
arrange_blocks _ _ = unimplemented

-- if target is a substring of string and starts at the beginning of string,
-- then is Just the rest of string after target ends.
-- otherwise, is Nothing
extracted_from :: String -> String -> Maybe String
target `extracted_from` string =
    case (target, string) of
        ("", s ) -> Just s
        (_ , "") -> Nothing
        (x:xs, s:ss) -> if s == x
            then xs `extracted_from` ss
            else Nothing

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\end{document}
%-------------------------------------------------------------------------------
