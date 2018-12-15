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

data Block = Block
    { block_name         :: String
    , block_token_begin :: Token
    , block_token_end   :: Token
    , block_code_begin   :: Code
    , block_code_end     :: Code }

instance Show Block where
    show (Block name tokn_b tokn_e code_b code_e) =
        code_b ++ " " ++ code_e

-- if the token begins a block, returns that block
-- otherwise, returns Nothing
extract_block_begin :: Token -> Maybe Block
extract_block_begin t =
    let helper :: [Block] -> Maybe Block
        helper [] = Nothing
        helper (b:bs) = if t == block_token_begin b
            then Just b
            else helper bs
    in helper blocks

is_end_of :: Token -> Block -> Bool
is_end_of t b =
    let token_end = block_token_end b
    in t == token_end || (t == "\n" && token_end == " ")

-- =--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=-
-- =--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=-

blocks =
    -- line styles
    [ Block "line-h5"     "#####"  "\n" "<h5 class=\"line-h5\">" "</h5>"
    , Block "line-h4"     "####"   "\n" "<h4 class=\"line-h4\">" "</h4>"
    , Block "line-h3"     "###"    "\n" "<h3 class=\"line-h3\">" "</h3>"
    , Block "line-h2"     "##"     "\n" "<h2 class=\"line-h2\">" "</h2>"
    , Block "line-h1"     "#"      "\n" "<h1 class=\"line-h1\">" "</h1>"
    , Block "line-quote"  ">" "\n" "<div class=\"line-quote\">"  "</div>"
    , Block "line-bullet" "-" "\n" "<div class=\"line-bullet\">" "</div>"

    -- block styles
    , Block "block-math"  ""  "$$"  "<div class=\"block-math\">" "</div>"
    , Block "block-code"  "```" "```" "<div class=\"block-code\">" "</div>"
    , Block "block-image" "{" "}" "<img src=\"" "\">"
    , Block "block-link"  "[" "]" "<a href=\"" "\">hard-coded link</a>"
    -- inline styles
    , Block "inline-bold"   "**" "**" "<span class=\"inline-bold\">"   "</span>"
    , Block "inline-italic" "*"  "*"  "<span class=\"inline-italic\">" "</span>"
    , Block "inline-uline"  "~~" "~~" "<span class=\"inline-uline\">"  "</span>"
    , Block "inline-mline"  "--" "--" "<span class=\"inline-mline\">"  "</span>"
    , Block "inline-math"   "$"  "$"  "<span class=\"inline-math\">"   "</span>"
    , Block "inline-code"   "`"  "`"  "<span class=\"inline-code\">"   "</span>"
    
    
    -- comment
    , Block "line-comment"  "//"  "\n"  "" ""
    , Block "block-comment" "///" "///" "" ""
    -- escape
    , Block "word-escape" "\\" " " "" ""
    ]

blocknames_nosub =
    [ "inline-math", "inline-code"
    , "block-math", "block-code"
    , "word-escape" ]

-- =--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=-
-- =--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=-

compile :: [Token] -> Code
compile ts =
    let helper :: [Token] -> Maybe Block -> ([Token], Code)
        helper [] Nothing  = ([], "")
        helper [] (Just _) = error "ATL Compile: missing block-end"
        helper (t:ts) mb_block = case mb_block of
            Nothing -> recurse t ts mb_block -- at top level call
            Just b ->                        -- at lower level recurse
                if t `is_end_of` b           -- at end of sub-block?
                    then (ts, block_code_end b) -- end sub-block
                    else recurse t ts mb_block  -- recurse
        recurse :: Token -> [Token] -> Maybe Block -> ([Token], Code)
        recurse t ts mb_block =
            -- token begins a new sub-block?
            case extract_block_begin t of
                Nothing -> -- t is literal token
                    let (ts_next, code_next) = helper ts mb_block
                    in (ts_next, t ++ code_next)
                Just bn -> -- t is block begin token
                    let code_begin = block_code_begin bn         -- sub-recurse
                        (ts_sub, code_sub) = helper ts (Just bn) -- recurse
                        (ts_next, code_next) = helper ts_sub mb_block
                    in (ts_next, code_begin ++ code_sub ++ code_next)
        -- `Nothing` represents top-level block
        (_, compiled_code) = helper ts Nothing
    in
        compiled_code

\end{code}
%------------------------------------------------

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
\end{document}
