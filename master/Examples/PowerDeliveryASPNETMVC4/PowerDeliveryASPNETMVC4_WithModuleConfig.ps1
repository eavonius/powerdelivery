# PowerDeliveryASPNETMVC4_WithModuleConfig.ps1
# 
# The script for PowerDeliveryASPNETMVC4's continous delivery pipeline.
#
# This sample script uses primarily module configuration. See the same script 
# suffixed with _WithCmdlets for a sample that uses primarily cmdlets.
#
# https://github.com/eavonius/powerdelivery

Pipeline 'PowerDeliveryASPNETMVC4_WithModuleConfig' -Version '1.0.0'

Import-DeliveryModule MSBuild
Import-DeliveryModule MSTest
Import-DeliveryModule Roundhouse
Import-DeliveryModule WebDeploy