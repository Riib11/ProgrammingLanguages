import System.Environment

parseArgs :: [String] -> String
parseArgs args = case args of
    ["-h"] -> help_msg
    [] -> parseArgs ["-h"]
    fs -> foldr (\x y -> x ++ "\n" ++ y) "" fs
    where
        help_msg = "usage: ./main file1 file2 ... fileN"

main = do
    args <- getArgs
    putStrLn $ parseArgs args
