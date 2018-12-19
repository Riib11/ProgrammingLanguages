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
            tgtcode <- compile_source lang srccode
            writeFile (lang_convert_filepath lang fp_src) tgtcode)
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
    { lang_wrapper_block    :: Block
    , lang_static_blocks    :: [Block]
    , lang_blocks           :: [Block]
    , lang_sections         :: [String]
    , lang_convert_filepath :: FilePath -> FilePath }

type TargetCode = String

type BlockItem = Either Token Block

data Block = Block
    { block_section         :: String
    , block_token_bounds    :: (Token, Token)
    , block_allow_nesting   :: Bool
    , block_format_contents :: [BlockItem] -> TargetCode
    , block_contents        :: [BlockItem] }

instance Show Block where
    show (Block sect (t1, t2) nest form cont) = form cont

add_content :: Block -> BlockItem -> Block
add_content (Block sect tkbs nest form cont) x =
    Block sect tkbs nest form (cont++[x])

compile_language :: LangCode -> IO Language
compile_language langcode = -- TODO: implementation
    return lang_md_to_html 

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\section{Example Language}

% TODO: description

%///////////////////////////////////////////////
\begin{code}

join_content :: String -> String -> [BlockItem] -> TargetCode
join_content header footer xs =
    let f :: Either Token Block -> TargetCode -> TargetCode
        f x tgtcode = case x of
            Left  t -> tgtcode ++ t
            Right b -> tgtcode ++ (block_format_contents b $ block_contents b)
    in (foldr f header xs) ++ footer

make_block sect tkbs nest form = Block sect tkbs nest form []

make_static_block :: String -> String -> String -> Bool -> Block
make_static_block sect cont_begin cont_end nest =
    make_block sect ("","") nest (join_content cont_begin cont_end)

-- lang_example = Language
--     ( make_block "wrapper" ("","") (join_content "" "") )
--     [ make_static_block "header" "" , make_static_block "footer" "" ]
--     (   [ make_block "body" ("(",")") (join_content "<A>" "</A>")
--         , make_block "body" ("[","]") (join_content "<B>" "</B>") ])
--     [ "header", "body", "footer" ]
--     (\fp -> fp ++ ".exp_tgt")

lang_md_to_html = Language
    -- wrapper block
    ( make_static_block "wrapper" "<!DOCTYPE html><html>" "</html>" True )
    -- static blocks
    (   -- head
        [ make_static_block "head" "<head>" "</head>" True ] )
    -- blocks
    (   -- escapes
        [ make_block "body" ("\\","\n") False
            (join_content " " "\n")
        , make_block "body" ("\\"," ") False
            (join_content " " " ")
        -- multiline styles
        , make_block "body" ("$$","$$") False
            (join_content "<div class=\"multiline-math\">" "</div>")
        , make_block "body" ("```","```") False
            (join_content "<div class=\"multiline-code\">" "</div>")
        , make_block "body" (">>>","<<<") True
            (join_content "<div class=\"multiline-quote\">" "</div>")
        -- line styles
        , make_block "body" ("#####","\n") True
            (join_content "<div class=\"line-header5\">" "</div>\n")
        , make_block "body" ("####","\n") True
            (join_content "<div class=\"line-header4\">" "</div>\n")
        , make_block "body" ("###","\n") True
            (join_content "<div class=\"line-header3\">" "</div>\n")
        , make_block "body" ("##","\n") True
            (join_content "<div class=\"line-header2\">" "</div>\n")
        , make_block "body" ("#","\n") True
            (join_content "<div class=\"line-header1\">" "</div>\n")
        , make_block "body" (">","\n") True
            (join_content "<div class=\"line-quote\">" "</div>\n")
        -- inline styles
        , make_block "body" ("**","**") True
            (join_content "<span class=\"inline-bold\">" "</span>")
        , make_block "body" ("*","*") True
            (join_content "<span class=\"inline-italic\">" "</span>")
        , make_block "body" ("$","$") False
            (join_content "<span class=\"inline-math\">" "</span>")
        , make_block "body" ("`","`") False
            (join_content "<span class=\"inline-code\">" "</span>")
        ] )
    -- sections
    [ "header", "body", "footer" ]
    -- file format
    (\fp -> fp ++ ".html")

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\section{Compiling Source}

% TODO: description

%///////////////////////////////////////////////
\begin{code}

compile_source :: Language -> SourceCode -> IO TargetCode
compile_source lang srccode =
    let tokens     = sourcecode_to_tokens lang srccode
        blocktree  = tokens_to_blocktree lang tokens
        targetcode = blocktree_to_targetcode lang blocktree
    in do
        putStrLn "-------------------------------------------------------"
        putStrLn $ "tokens:\n" ++ (show tokens)
        putStrLn "-------------------------------------------------------"
        putStrLn $ "blocktree:\n" ++ (show blocktree)
        putStrLn "-------------------------------------------------------"
        putStrLn $ "targetcode:\n" ++ (targetcode)
        return targetcode

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

% TODO: description

%///////////////////////////////////////////////
\begin{code}

-- separates SourceCode into Tokens,
-- splitting with the tokens reserved by the Language.
sourcecode_to_tokens :: Language -> SourceCode -> [Token]
sourcecode_to_tokens lang srccode =
    let helper :: SourceCode -> [Token] -> Token -> [Token]
        helper srccode lang_tkns work_token = case (srccode, lang_tkns) of
            -- finished all of the srccode.
            -- append work_token if its non-empty.
            ("", _) -> if work_token == ""
                then []
                else [work_token]
            -- have gone through all tokens, so add the front char
            -- to the work_token, and recurse through all of
            -- the lang tokens.
            (c:s, []) -> helper s all_lang_tkns (work_token++[c])
            -- check to see if t extracts from s. if so, then
            -- prepend t and then restart recurse on rest of srccode.
            -- prepend work_token before the newfound token, if work_token
            -- is non-empty
            (s, t:ts) -> case t `extracted_from` s of
                Nothing -> helper s ts work_token
                Just s_rest -> if work_token == ""
                    then t : helper s_rest all_lang_tkns ""
                    else work_token : t : helper s_rest all_lang_tkns ""
        all_lang_tkns = lang_special_tokens lang
    in helper srccode all_lang_tkns ""

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

lang_special_tokens :: Language -> [Token]
lang_special_tokens lang =
    let helper :: [Block] -> [Token] -> [Token]
        helper []      ts = ts
        helper (b:bs)  ts =
            let (t1, t2) = block_token_bounds b
                add1 = if t1 `elem` ts
                    then [] else [t1]
                add2 = if t2 `elem` ts || t2 == t1
                    then [] else [t2]
            in helper bs (ts ++ add1 ++ add2)
    in helper (lang_blocks lang) []

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

% TODO: description

%///////////////////////////////////////////////
\begin{code}

-- breaks Token list into a Block tree
tokens_to_blocktree :: Language -> [Token] -> Block
tokens_to_blocktree lang ts =
    let helper :: [Token] -> Block -> (Block, [Token])
        helper ts work_block = case ts of
            [] -> (work_block, [])
            (t:ts) ->
                -- does token end current work_block?
                if (t == (snd $ block_token_bounds work_block)
                   && ("wrapper" /= block_section work_block))
                    -- token ends current work_block
                    then (work_block, ts)
                    else if (block_allow_nesting work_block)
                        -- can nest, so does token begin new block?
                        then case block_that_begins_with t of
                            -- token begins new block
                            Just block ->
                                let new_work_block = add_content 
                                        work_block (Right new_block)
                                    (new_block, ts_rest) = helper ts block
                                in helper ts_rest new_work_block
                            -- token is normal; append to current block
                            Nothing -> helper ts $ add_content work_block (Left t)
                        -- cannot nest, so append token to current block
                        else helper ts $ add_content work_block (Left t)
        block_that_begins_with :: Token -> Maybe Block
        block_that_begins_with t =
            let helper :: [Block] -> Maybe Block
                helper [] = Nothing
                helper (b:bs) =
                    let (t1, t2) = block_token_bounds b
                    in if t == t1
                        then Just b
                        else helper bs
            in helper $ lang_blocks lang
    in fst $ helper ts (lang_wrapper_block lang)

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

% TODO: description

%///////////////////////////////////////////////
\begin{code}

type TargetStructure = [(String, [BlockItem])]

-- arranges the Block tree into the finalized TargetCode
blocktree_to_targetcode :: Language -> Block -> TargetCode
blocktree_to_targetcode lang wrapper_block =
    let -- appends a block item to the appropriate section of the structure
        add_to_struct :: BlockItem -> TargetStructure -> TargetStructure
        add_to_struct x [] = []
        add_to_struct x ((sect, xs) : ss) = case x of
            Left t -> if sect == "body"
                then (sect, Left t : xs) : ss
                else (sect, xs) : add_to_struct x ss
            Right b -> if sect == (block_section b)
                then (sect, Right b : xs) : ss
                else (sect, xs) : add_to_struct x ss

        -- creates a structure with all of the language sections, as well
        -- as the static blocks
        init_struct :: TargetStructure
        init_struct =
            let helper :: [BlockItem] -> TargetStructure -> TargetStructure
                helper bs struct = case bs of
                    [] -> struct
                    (b:bs) -> add_to_struct b struct
                empty_struct :: TargetStructure
                empty_struct = map (\sect -> (sect, [])) (lang_sections lang)
            in helper (map Right $ lang_static_blocks lang) empty_struct
        
        -- adds top level to TargetStructure (contents of wrapper_block)
        toplevel_struct :: TargetStructure
        toplevel_struct = foldr add_to_struct init_struct
            $ block_contents wrapper_block

        -- format TargetStructure as TargetCode
        format_structure :: TargetStructure -> TargetCode
        format_structure struct =
            let format_blockitems :: [BlockItem] -> TargetCode
                format_blockitems xs = foldl (++) ""
                    $ map (\x -> case x of
                        Left  t -> t
                        Right b -> block_format_contents b $ block_contents b)
                    xs
            in case struct of
                [] -> ""
                ((sect, xs):ss) -> (format_blockitems xs) ++ format_structure ss
    in format_structure toplevel_struct

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\end{document}
%-------------------------------------------------------------------------------
