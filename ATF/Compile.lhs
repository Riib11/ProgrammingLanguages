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

The core unit in defining a \tc{Translator} is the \tc{Scope}. A \tc{Scope} is defined by the following:
\begin{itemize}
\item \tb{name}: The unique identifier for this scope.
\item \tb{bounds}: Sourcecode bounds that define where this scope begins and ends.
\item \tb{subscopes}: The subscopes that this scope recognizes.
\end{itemize}

%///////////////////////////////////////////////
\begin{code}

type SourceCode = String
type TransCode  = String

data Translator = Translator
    { trans_root_scope_name  :: String
    , trans_scopes           :: [Scope]
    , trans_convert_filepath :: FilePath -> FilePath }

get_trans_scope :: Translator -> String -> Maybe Scope
get_trans_scope trans target_scope_name =
    let helper :: [Scope] -> Maybe Scope
        helper scopes = case scopes of
            [] -> Nothing
            (s:ss) -> if scope_name s == target_scope_name
                then Just s
                else helper ss
    in helper $ trans_scopes trans

data Scope = Scope
    { scope_name           :: String
    , scope_begin          :: String
    , scope_end            :: String
    , scope_subscope_names :: [String] }

instance Show Scope where
    show (Scope name begin end subscope_names) = begin ++ name ++ end

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

trans_md_to_html :: Translator
trans_md_to_html = error "undefined"

-- data Translator = Translator
--     { trans_root_scope_name  :: String
--     , trans_scopes           :: [Scope]
--     , trans_convert_filepath :: FilePath -> FilePath }

-- data Scope = Scope
--     { scope_name           :: String
--     , scope_begin          :: String
--     , scope_end            :: String
--     , scope_subscope_names :: [String] }

trans_example :: Translator
trans_example = Translator
    "root"
    [ Scope "root" "" "" ["A"]
    , Scope "A" "(" ")" [] ]
    (\fp -> fp ++ ".atf_tgt")
    

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

type TargetCode = String

data BlockChild
    = ChildBlock Block
    | ChildToken Token

instance Show BlockChild where
    show (ChildBlock block) = show block
    show (ChildToken token) = show token

data Block = Block
    { block_scope :: Scope
    , block_children :: [BlockChild] }

instance Show Block where
    show (Block scope children) =
        "{ " ++ (show scope) ++ " : " ++ (show children) ++ " }"

make_empty_block :: Scope -> Block
make_empty_block scope = Block scope []

add_token :: Block -> Token -> Block
add_token (Block s cs) t = Block s cs_new
    where
        cs_new = case cs of
            -- previous child is a ChildToken, so append to it
            (ChildToken ct) : cs_ -> (ChildToken $ ct ++ t) : cs_
            -- otherwise, prepend to blockchildren
            _ -> (ChildToken t) : cs

add_block :: Block -> Block -> Block
add_block (Block s cs) b = Block s cs_new
    where cs_new = (ChildBlock b) : cs

sourcecode_to_blocktree :: Translator -> SourceCode -> Block
sourcecode_to_blocktree trans sourcecode =
    let get_scope = get_trans_scope trans

        -- init block
        root_scope_name = trans_root_scope_name trans
        root_scope = get_scope root_scope_name
        init_block = case root_scope of
            Nothing -> error $ "root scope not found: " ++ root_scope_name
            Just scope -> Block scope []

        helper :: Block -> SourceCode -> (Block, SourceCode)
        helper block sourcecode =
            let scope = block_scope block
                behead_scope_end =
                    if (scope_name scope) == (trans_root_scope_name trans)
                        then Nothing
                        else behead (scope_end scope) sourcecode
                subscope_names = scope_subscope_names scope
                matched_subscope_names = filter_somethings
                    $ map (\s -> behead s sourcecode) subscope_names
                mb_subscope = case matched_subscope_names of
                    [] -> Nothing
                    (scope_name:_) -> get_scope scope_name
            in case sourcecode of
                -- end of sourcecode
                "" -> (block, "")
                -- more sourcecode to parse, so
                -- is this the end of the current scope?
                (x:xs) -> case behead_scope_end of
                    -- this IS the end of the current scope
                    Just rest_sourcecode -> (block, rest_sourcecode)
                    -- this is NOT the end of the current scope, so
                    -- is this the beginning of a subscope?
                    Nothing -> case mb_subscope of
                        -- this is NOT the beginning of any subscope,
                        -- so can safely add first character
                        Nothing -> helper (add_token block [x]) xs
                        -- this IS the beginning of a subscope, so
                        -- parse it, add it as child block to current
                        -- block, and then parse the rest of the
                        -- sourcecode left after it
                        Just subscope ->
                            let init_subblock = make_empty_block subscope
                                subscope_begin = scope_begin subscope
                                sub_sourcecode = behead
                                    subscope_begin sourcecode
                                (subblock, rest_sourcecode) =
                                    helper init_subblock sourcecode
                                new_block = add_block block subblock
                            in helper new_block rest_sourcecode

    in fst $ helper init_block sourcecode

filter_somethings :: [Maybe a] -> [a]
filter_somethings xs = case xs of
    [] -> []
    (Nothing:xs) -> filter_somethings xs
    (Just x :xs) -> x : filter_somethings xs

is_something :: Maybe a -> Bool
is_something x = case x of
    Just _ -> True
    Nothing -> False

behead :: String -> String -> Maybe String
behead "" _ = Nothing
behead x y =
    let helper x y =
            case x of
                "" -> Just y
                (x:xs) -> case y of
                    "" -> Nothing
                    (y:ys) -> if x == y
                        then behead xs ys
                        else Nothing
    in helper x y

\end{code}
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%-------------------------------------------------------------------------------
\end{document}
%-------------------------------------------------------------------------------
