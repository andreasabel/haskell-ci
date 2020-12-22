module HaskellCI.TestedWith (
    TestedWithJobs (..),
    checkVersions,
    ) where

import Prelude ()
import Prelude.Compat

import Control.Applicative  ((<|>))
import Data.List            (intercalate)

import qualified Data.Foldable                   as F
import qualified Data.Set                        as S
import qualified Distribution.Compat.CharParsing as C
import qualified Distribution.Parsec             as C
import qualified Distribution.Pretty             as C
import qualified Text.PrettyPrint                as PP

import Cabal.Project
import HaskellCI.Compiler
import HaskellCI.Package

data TestedWithJobs
    = TestedWithUniform
    | TestedWithAny
  deriving (Eq, Show)

instance C.Parsec TestedWithJobs where
    parsec = TestedWithUniform <$ C.string "uniform"
        <|> TestedWithAny <$ C.string "any"

instance C.Pretty TestedWithJobs where
    pretty TestedWithUniform = PP.text "uniform"
    pretty TestedWithAny     = PP.text "any"

-------------------------------------------------------------------------------
-- Selection
-------------------------------------------------------------------------------

checkVersions
    :: TestedWithJobs
    -> Project a b Package
    -> Either [String] (S.Set CompilerVersion, Project a b Package)
checkVersions TestedWithUniform = checkVersionsUniform
checkVersions TestedWithAny     = checkVersionsAny

checkVersionsUniform
    :: Project a b Package
    -> Either [String] (S.Set CompilerVersion, Project a b Package)
checkVersionsUniform prj | null (prjPackages prj) = Left ["Error reading cabal file(s)!"]
checkVersionsUniform prj = do
    let (errors, names) = F.foldl' collectConfig mempty prj
    if not (null errors)
    then Left $ init errors ++ [ last errors ++ "\n(Consider option --jobs-selection any)" ]
    else Right (allVersions, prj { prjPackages = names, prjOptPackages = [] })
  where
    allVersions :: S.Set CompilerVersion
    allVersions = F.foldMap pkgJobs prj

    collectConfig
        :: ([String], [Package])
        -> Package
        -> ([String], [Package])
    collectConfig aggregate pkg =
        aggregate <> (errors, [pkg])
      where
        testWith = pkgJobs pkg
        symDiff a b = S.union a b `S.difference` S.intersection a b
        diff = symDiff testWith allVersions
        missingVersions = map dispGhcVersion $ S.toList diff
        errors | S.null diff = []
               | otherwise = pure $ mconcat
                    [ pkgName pkg
                    , " is missing tested-with annotations for: "
                    , intercalate ", " missingVersions
                    ]

checkVersionsAny
    :: Project a b Package
    -> Either [String] (S.Set CompilerVersion, Project a b Package)
checkVersionsAny prj | null (prjPackages prj) = Left ["Error reading cabal file(s)!"]
checkVersionsAny prj =
    Right (allVersions, prj)
  where
    allVersions :: S.Set CompilerVersion
    allVersions = F.foldMap pkgJobs prj
