module Paths_printableHelper (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/blischalk/haskell/printableHelper/.stack-work/install/x86_64-osx/lts-5.9/7.10.3/bin"
libdir     = "/Users/blischalk/haskell/printableHelper/.stack-work/install/x86_64-osx/lts-5.9/7.10.3/lib/x86_64-osx-ghc-7.10.3/printableHelper-0.1.0.0-JleMP8rVKxN1s7oLXqSLDl"
datadir    = "/Users/blischalk/haskell/printableHelper/.stack-work/install/x86_64-osx/lts-5.9/7.10.3/share/x86_64-osx-ghc-7.10.3/printableHelper-0.1.0.0"
libexecdir = "/Users/blischalk/haskell/printableHelper/.stack-work/install/x86_64-osx/lts-5.9/7.10.3/libexec"
sysconfdir = "/Users/blischalk/haskell/printableHelper/.stack-work/install/x86_64-osx/lts-5.9/7.10.3/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "printableHelper_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "printableHelper_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "printableHelper_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "printableHelper_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "printableHelper_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
