{-# LANGUAGE DataKinds        #-}
{-# LANGUAGE TypeApplications #-}
module HaskellCI.Config.Initial where

import HaskellCI.Prelude

import qualified Distribution.Version as C

import HaskellCI.Config.Components
import HaskellCI.Config.CopyFields
import HaskellCI.Config.Docspec
import HaskellCI.Config.Doctest
import HaskellCI.Config.PackageScope
import HaskellCI.Config.Type
import HaskellCI.Config.Ubuntu
import HaskellCI.Ghcup
import HaskellCI.HeadHackage
import HaskellCI.TestedWith

-- | This is an "initial" configuration. It's meant to stay immutable.
-- All changes to defaults should be done in History.
initialConfig :: Config
initialConfig = Config
    { cfgCabalInstallVersion = Just (C.mkVersion [3,10,2,0])
    , cfgJobs                = Nothing
    , cfgUbuntu              = Bionic
    , cfgTestedWith          = TestedWithUniform
    , cfgEnabledJobs         = anyVersion
    , cfgCopyFields          = CopyFieldsSome
    , cfgLocalGhcOptions     = []
    , cfgSubmodules          = False
    , cfgCache               = True
    , cfgInstallDeps         = True
    , cfgInstalled           = []
    , cfgTests               = anyVersion
    , cfgRunTests            = anyVersion
    , cfgBenchmarks          = anyVersion
    , cfgHaddock             = anyVersion
    , cfgHaddockComponents   = ComponentsAll
    , cfgNoTestsNoBench      = anyVersion
    , cfgUnconstrainted      = anyVersion
    , cfgHeadHackage         = defaultHeadHackage
    , cfgHeadHackageOverride = True
    , cfgGhcjsTests          = False
    , cfgGhcjsTools          = []
    , cfgTestOutputDirect    = True
    , cfgCheck               = True
    , cfgOnlyBranches        = []
    , cfgIrcChannels         = []
    , cfgIrcNickname         = Nothing
    , cfgIrcPassword         = Nothing
    , cfgIrcIfInOriginRepo   = False
    , cfgEmailNotifications  = True
    , cfgProjectName         = Nothing
    , cfgGhcHead             = False
    , cfgPostgres            = False
    , cfgGoogleChrome        = False
    , cfgEnv                 = mempty
    , cfgAllowFailures       = noVersion
    , cfgLastInSeries        = False
    , cfgLinuxJobs           = anyVersion
    , cfgMacosJobs           = noVersion
    , cfgGhcupCabal          = True
    , cfgGhcupJobs           = ghcupVersions
    , cfgGhcupVersion        = defaultGhcupVersion
    , cfgApt                 = mempty
    , cfgTravisPatches       = []
    , cfgGitHubPatches       = []
    , cfgInsertVersion       = True
    , cfgErrorMissingMethods = PackageScopeLocal
    , cfgDoctest             = initialDoctestConfig
    , cfgDocspec             = initialDocspecConfig
    , cfgConstraintSets      = []
    , cfgRawProject          = []
    , cfgRawTravis           = ""
    , cfgGitHubActionName    = Nothing
    , cfgTimeoutMinutes      = 60
    }
  where
    -- Versions supported by GHCup.
    -- As of 2023-10-12, GHCup supports all minor versions of GHC 8.4 and up
    -- and the latest minor versions of 8.2, 8.0, and 7.10.
    -- However, GH 7.10.3 has problems when installed with GHCup, so we don't include it here.
    ghcupVersions :: C.VersionRange
    ghcupVersions = foldr1 C.unionVersionRanges
      [ C.laterVersion $ mkVersion [8,4,1]
      , C.thisVersion  $ mkVersion [8,2,2]
      , C.thisVersion  $ mkVersion [8,0,2]
      ]
