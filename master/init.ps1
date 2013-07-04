param($installPath, $toolsPath, $package)

$powerdeliveryModule = Join-Path $toolsPath PowerDelivery.psm1
import-module $powerdeliveryModule