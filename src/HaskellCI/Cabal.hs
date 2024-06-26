module HaskellCI.Cabal where

import HaskellCI.Prelude

import qualified Distribution.Version as C

defaultCabalInstallVersion :: Maybe Version
defaultCabalInstallVersion = Just (C.mkVersion [3,10])

-- | Convert cabal-install version to a version ghcup understands.
cabalGhcupVersion :: Version -> Version
cabalGhcupVersion ver = case C.versionNumbers ver of
      [3,10] -> C.mkVersion [3,10,3,0]
      [3,8]  -> C.mkVersion [3,8,1,0]
      [3,6]  -> C.mkVersion [3,6,2,0]
      [3,4]  -> C.mkVersion [3,4,1,0]
      [2,4]  -> C.mkVersion [2,4,1,0]
      [x,y]  -> C.mkVersion [x,y,0,0]
      _      -> ver
