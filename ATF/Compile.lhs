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
import Utilities

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\section{The Compile Function}

% TODO: description

%///////////////////////////////////////////////
\begin{code}

type SourceCode = String
type TransCode  = String
type TargetCode = String

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

data Translator = Translator
    { trans_blocks           :: [Block]
    , trans_root_block       :: Block
    , trans_convert_filepath :: FilePath -> FilePath }

data Block = Block
    { block_title     :: String
    , block_children  :: [BlockChild]
    , block_format    :: [TargetCode] -> TargetCode
    , block_does_nest :: Bool }

data BlockChild
    = ChildCode  SourceCode
    | ChildBlock Block

instance Show Block where
    show block
        = "{ " ++ (block_title block) ++ " : "
        ++ (show $ reverse $ block_children block) ++ " }"

instance Show BlockChild where
    show child = case child of
        ChildCode x -> "\"" ++ x ++ "\""
        ChildBlock x -> show x

compile_translator :: TransCode -> IO Translator
compile_translator transcode = -- TODO: implementation
    return trans_example

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\section{Example Translator}

% TODO: description

%///////////////////////////////////////////////
\begin{code}

-- title children format nest

make_block :: String -> ([TargetCode] -> TargetCode) -> Bool -> Block
make_block title block_format does_nest = Block title [] block_format does_nest

join_comment :: ([TargetCode] -> TargetCode)
join_comment _ = ""

join_span :: String -> ([TargetCode] -> TargetCode)
join_span classname = join_container
    ("<span class=\"" ++ classname ++ "\">") ("</span>")

join_div :: String -> ([TargetCode] -> TargetCode)
join_div classname = join_container
    ("<div class=\"" ++ classname ++ "\">") ("</div>\n")

join_tag_class :: String -> String -> ([TargetCode] -> TargetCode)
join_tag_class tag classname = join_container
    ("<" ++ tag ++ " class=\"" ++ classname ++ "\">") ("</" ++ tag ++ ">")

join_tag_attr :: String -> String -> ([TargetCode] -> TargetCode)
join_tag_attr tag_begin tag_end = join_container
    ("<" ++ tag_begin ++ ">") ("</" ++ tag_end ++ ">")

join_tag :: String -> ([TargetCode] -> TargetCode)
join_tag tag = join_container ("<" ++ tag ++ ">") ("</" ++ tag ++ ">")

join_js :: ([TargetCode] -> TargetCode)
join_js [x] = "<script type=\"text/javascript\">" ++ x ++ "</script>" 

join_js_src :: ([TargetCode] -> TargetCode)
join_js_src [x] = "<script type=\"text/javascript\" src=\""
                  ++ x ++ "\"></script>"

join_css :: ([TargetCode] -> TargetCode)
join_css [x] = "<style type=\"text/css\">" ++ x ++ "</style>" 

join_css_src :: ([TargetCode] -> TargetCode)
join_css_src [x] = "<link rel=\"stylesheet\" type=\"text/css\" href=\""
                   ++ x ++ "\">"

join_html_body :: ([TargetCode] -> TargetCode)
join_html_body ls =
    let helper :: [TargetCode] -> TargetCode
        helper [] = ""
        helper (x:xs) = x ++ helper xs
    in "<body>\n" ++ (helper ls) ++ "\n</body>"


join_inline_math :: ([TargetCode] -> TargetCode)
join_inline_math [x] = "$$$$$" ++ x ++ "$$$$$"

join_block_math :: ([TargetCode] -> TargetCode)
join_block_math [x] = "$$$$$$$$$$" ++ x ++ "$$$$$$$$$$"

join_row :: ([TargetCode] -> TargetCode)
join_row tgtcode =
    let helper :: [TargetCode] -> TargetCode
        helper ls = case ls of
            [] -> ""
            (x:xs) -> "<td>" ++ x ++ "</td>" ++ helper xs
    in "<tr class=\"row\">" ++ helper tgtcode ++ "</tr>"

join_hrow :: ([TargetCode] -> TargetCode)
join_hrow tgtcode =
    let helper :: [TargetCode] -> TargetCode
        helper ls = case ls of
            [] -> ""
            (x:xs) -> "<th>" ++ x ++ "</th>" ++ helper xs
    in "<tr class=\"hrow\">" ++ helper tgtcode ++ "</tr>"

join_image :: ([TargetCode] -> TargetCode)
join_image [src,alt] = "<img src=\"" ++ src ++ "\" alt=\"" ++ alt ++ "\">"
join_image [src] = "<img src=\"" ++ src ++ "\">"

trans_example = Translator
    ( -- scopes
        [ make_block "--"       join_comment                         False
        
        , make_block "head"     (join_tag "head")                    True

        , make_block "js-src"   join_js_src                          False
        , make_block "js"       join_js                              False
        , make_block "css-src"  join_css_src                         False
        , make_block "css"      join_css                             False
        , make_block "title"    (join_tag "title")                   False

        , make_block "body"     join_html_body                       True
        
        , make_block "#####"    (join_div  "header-5")               True
        , make_block "####"     (join_div  "header-4")               True
        , make_block "###"      (join_div  "header-3")               True
        , make_block "##"       (join_div  "header-2")               True
        , make_block "#"        (join_div  "header-1")               True
        , make_block "p"        (join_div "paragraph")               True
        , make_block "$$"       join_block_math                      False
        , make_block "$"        join_inline_math                     False
        , make_block "```"      (join_tag_class "pre" "block-code")  False
        , make_block "`"        (join_span "inline-code")            False
        , make_block "img"      join_image                           False
        , make_block ">"        (join_div "block-quote")             True
        , make_block "-"        (join_div "line-bullet")             True
        , make_block "*"        (join_span "inline-bold")            True
        , make_block "_"        (join_span "inline-italic")          True
        , make_block "~"        (join_span "inline-strike")          True

        , make_block "table"    (join_tag_class "table" "table")     True
        , make_block "hr"       join_hrow                            True
        , make_block "tr"       join_row                             True
        ] )
    ( -- root scope
        make_block "root" (join_tag_attr "!DOCTYPE html><html" "html") True )
    ( -- convert filepath
        \fp -> fp ++ ".html" )

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\section{Compiling SourceCode}
% TODO: description

%///////////////////////////////////////////////
\begin{code}

compile_sourcecode :: Translator -> SourceCode -> IO TargetCode
compile_sourcecode translator sourcecode = do
    blocktree  <- sourcecode_to_blocktree translator sourcecode 
    debug $ "blocktree: " ++ (show blocktree)
    targetcode <- blocktree_to_targetcode translator blocktree
    debug $ "targetcode: " ++ targetcode
    return targetcode 

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\subsection{SourceCode to Block-tree}
% TODO: description

%///////////////////////////////////////////////
\begin{code}

set_children (Block title _ format does_nest) children =
    Block title children format does_nest

prepend_blockchild (Block title children format does_nest) child =
    Block title (child : children) format does_nest

add_child :: Block -> BlockChild -> Block
add_child block child = case child of
    -- new child is code
    (ChildCode x) -> case (block_children block) of
        -- if most recent child is code, append x to that
        (ChildCode y : cs_) -> set_children block $ ChildCode (y ++ x) : cs_
        -- otherwise, prepend to children
        _ -> prepend_blockchild block $ ChildCode x
    -- new child is a block
    (ChildBlock x) -> prepend_blockchild block $ ChildBlock x

add_parition :: Block -> Block
add_parition block = case (block_children block) of
    (ChildCode "":_) -> block
    _ -> prepend_blockchild block $ ChildCode ""

sourcecode_to_blocktree :: Translator -> SourceCode -> IO Block
sourcecode_to_blocktree trans sourcecode =
    let root_block = trans_root_block trans
        all_blocks = trans_blocks trans
        
        extract_empty_block :: SourceCode -> (Block, SourceCode)
        extract_empty_block srccode =
            let helper :: [Block] -> (Block, SourceCode)
                helper blocks = case blocks of
                    -- none of blocks matched
                    [] -> error $ "no block title found at: " ++ srccode
                    -- check if srccode starts with the scope's title
                    (b:bs) -> case srccode `beheaded_by` (block_title b) of
                        -- this scope matches
                        Just srccode_rest -> (b, srccode_rest)
                        -- this scope does not match
                        Nothing -> helper bs
            in helper all_blocks

        helper :: Block -> SourceCode -> IO (Block, SourceCode)
        helper block srccode = if (block_does_nest block)
            -- parse nesting
            then case srccode of
                -- begin block
                ('<':'|':xs) ->
                    let (empty_block, xs_) = extract_empty_block xs
                    in do
                        (new_block, xs_rest) <- helper empty_block xs_
                        debug $ "begin block: " ++ (block_title new_block)
                        helper (add_child block $ ChildBlock new_block) xs_rest
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
                -- escape character
                ('\\':x:xs) ->
                    let new_block = add_child block (ChildCode [x])
                    in do
                        -- debug $ "add escaped: " ++ [x] 
                        helper new_block xs
                -- add normal character
                (x:xs) ->
                    let new_block = add_child block (ChildCode [x])
                    in do
                        -- debug $ "add char: " ++ [x] 
                        helper new_block xs
                -- end of sourcecode
                "" -> do
                    debug "end of sourcecode"
                    return (block, "")
            -- parse raw; no nesting
            else case srccode of
                -- end current block
                ('|':'>':xs) -> do
                    debug $ "end block: " ++ (block_title block)
                    return (block, xs)
                -- escape character
                ('\\':x:xs) ->
                    let new_block = if x `elem` "|>"
                        then add_child block (ChildCode [x])
                        else add_child block (ChildCode $ '\\':x:[])
                    in helper new_block xs
                -- add normal character
                (x:xs) ->
                    let new_block = add_child block (ChildCode [x])
                    in helper new_block xs
                -- end of sourcecode
                "" -> do
                    debug "end of sourcecode"
                    return (block, "")
    in do
        (block, _) <- helper root_block sourcecode
        return block

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\subsection{Block-tree to TargetCode}
% TODO: description

%///////////////////////////////////////////////
\begin{code}

blocktree_to_targetcode :: Translator -> Block -> IO TargetCode
blocktree_to_targetcode trans block =
    let helper :: [BlockChild] -> IO [TargetCode]
        helper children = case children of
            [] -> return []
            (child:cs) -> case child of
                ChildCode x -> do
                    transed_cs <- helper cs
                    return $ transed_cs
                        ++ (if is_empty_string x then [] else [x])
                ChildBlock x -> do
                    transed_child <- blocktree_to_targetcode trans x
                    transed_cs <- helper cs
                    return $ transed_cs ++ [transed_child]
    in do
        transed_children <- helper (block_children block)
        return $ block_format block $ transed_children

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


%-------------------------------------------------------------------------------
\end{document}
%-------------------------------------------------------------------------------
