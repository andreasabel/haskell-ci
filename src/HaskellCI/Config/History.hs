{-# LANGUAGE DataKinds        #-}
{-# LANGUAGE TypeApplications #-}
module HaskellCI.Config.History (
    configHistory,
    defaultConfig,
) where

import HaskellCI.Prelude

import qualified Distribution.Version as C
import qualified Data.Map.Strict as Map

import HaskellCI.Config.Initial
import HaskellCI.Config.Type
import HaskellCI.Config.Ubuntu
import HaskellCI.SetupMethod

import HaskellCI.Compiler (invertVersionRange)

configHistory :: [([Int], Config -> Config)]
configHistory =
    [ ver 0 19 20240414 := \cfg -> cfg
        & field @"cfgDocspec" . field @"cfgDocspecUrl"  .~ "https://github.com/phadej/cabal-extras/releases/download/cabal-docspec-0.0.0.20240414/cabal-docspec-0.0.0.20240414-x86_64-linux.xz"
        & field @"cfgDocspec" . field @"cfgDocspecHash" .~ "2d18a3f79619e8ec5f11870f926f6dc2616e02a6c889315b7f82044b95a1adb9"
    , ver 0 19 20240420 := \cfg -> cfg
        & field @"cfgUbuntu" .~ Jammy
    , ver 0 19 20240513 := \cfg -> cfg
        -- defaultHeadHackage = C.orLaterVersion (C.mkVersion [9,11])
    , ver 0 19 20240702 := \cfg -> cfg
        & field @"cfgCabalInstallVersion" ?~ C.mkVersion [3,12,1,0]
        & field @"cfgDocspec" . field @"cfgDocspecUrl"  .~ "https://github.com/phadej/cabal-extras/releases/download/cabal-docspec-0.0.0.20240703/cabal-docspec-0.0.0.20240703-x86_64-linux.xz"
        & field @"cfgDocspec" . field @"cfgDocspecHash" .~ "48bf3b7fd2f7f0caa6162afee57a755be8523e7f467b694900eb420f5f9a7b76"
    , ver 0 19 20240708 := \cfg -> cfg
        & field @"cfgGhcupVersion" .~ C.mkVersion [0,1,30,0]
    , ver 0 19 20241111 := \cfg -> cfg
        & field @"cfgSetupMethods" .~ PerSetupMethod
            { hvrPpa          = C.earlierVersion (C.mkVersion [8,4])
            , ghcup           = C.simplifyVersionRange (C.laterVersion (C.mkVersion [8,4,4]) \/ C.earlierVersion (C.mkVersion [9,12,0]) \/ invertVersionRange (C.withinVersion (C.mkVersion [9,8,3])))
            , ghcupVanilla    = C.withinVersion (C.mkVersion [9,8,3])
            , ghcupPrerelease = C.orLaterVersion (C.mkVersion [9,12,0])
            }
    , ver 0 19 20241114 := \cfg -> cfg
        & field @"cfgSetupMethods" .~ PerSetupMethod
            { hvrPpa          = C.noVersion
            , ghcup           = invertVersionRange (C.withinVersion (C.mkVersion [9,8,3])) /\ C.earlierVersion (C.mkVersion [9,12])
            , ghcupVanilla    = C.withinVersion (C.mkVersion [9,8,3])
            , ghcupPrerelease = C.orLaterVersion (C.mkVersion [9,12])
            }
    , ver 0 19 20241117 := \cfg -> cfg
        & field @"cfgVersionMapping" .~ Map.singleton (mkVersion [9,12,1]) (mkVersion [9,12,0,20241031])
    , ver 0 19 20241121 := \cfg -> cfg
        & field @"cfgVersionMapping" .~ Map.singleton (mkVersion [9,12,1]) (mkVersion [9,12,0,20241114])
    ]
  where
    ver x y z = [x, y, z]

-- staticHistory [ ver 0 19 20240702 := add GHC-9.6.6

defaultConfig :: Config
defaultConfig = foldl' f initialConfig configHistory
  where
    f !cfg (_, g) = g cfg
