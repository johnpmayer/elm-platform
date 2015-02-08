{-| This script builds any version of the Elm Platform from source.
Before you use it, make sure you have the Haskell Platform with a recent
version of cabal.

To install a released version of Elm, run something like this:

    runhaskell BuildFromSource.hs 0.14

Whatever directory you run this in, you will now have a new directory for the
Elm Platform, like this:

    Elm-Platform/0.14/
        bin/             -- all the relevant executables
        elm-make/        -- git repo for the build tool, ready to edit
        elm-repl/        -- git repo for the REPL, ready to edit
        ...

All of the executables you need are in bin/ so add
wherever/Elm-Platform/0.14/bin to your PATH to use them from anywhere.

You can build many versions of the Elm Platform, so it is possible to have
Elm-Platform/0.14/ and Elm-Platform/0.12.3/ with no problems. It is up to you
to manage your PATH variable or symlinks though.

To get set up with the master branch of all Elm Platform projects, run this:

    runhaskell BuildFromSource.hs master

From there you can start developing on any of the projects, switching branches
and testing interactions between projects.
-}
module Main where

import qualified Data.List as List
import qualified Data.Map as Map
import System.Directory (createDirectoryIfMissing, setCurrentDirectory, getCurrentDirectory)
import System.Environment (getArgs)
import System.Exit (ExitCode, exitFailure)
import System.FilePath ((</>))
import System.IO (hPutStrLn, stderr)
import System.Process (rawSystem)


(=:) = (,)

-- NOTE: The order of the dependencies is also the build order,
-- so do not just go alphebetizing things.
configs :: [String]
configs =
  [ "elm-compiler" 
  , "elm-package" 
  , "elm-make"    
  , "elm-reactor" 
  , "elm-repl"    
  ]


main :: IO ()
main = 
 do args <- getArgs
    case args of
      [version] ->
          let artifactDirectory = "Elm-Platform" </> version
          in
              buildRepos artifactDirectory configs

      _ ->
        do hPutStrLn stderr $ "Expecting a branch as an argument" 
           exitFailure


buildRepos :: FilePath -> [String] -> IO ()
buildRepos artifactDirectory repos =
 do createDirectoryIfMissing True artifactDirectory
    setCurrentDirectory artifactDirectory
    cabal [ "update" ]
    root <- getCurrentDirectory
    mapM_ (buildRepo root) repos


buildRepo :: FilePath -> String -> IO ()
buildRepo root projectName =
 do  -- get the right version of the repo
    setCurrentDirectory projectName

    -- actually build things
    cabal [ "install", "-j" ]

    -- move back into the root
    setCurrentDirectory root

-- HELPER FUNCTIONS

cabal :: [String] -> IO ExitCode
cabal = rawSystem "cabal"

