# PowerDeliveryASPNETMVC4.ps1
# 
# The script for PowerDeliveryASPNETMVC4's continous delivery pipeline.
#
# https://github.com/eavonius/powerdelivery

Pipeline 'PowerDeliveryASPNETMVC4' -Version '1.0.0'

Import-DeliveryModule MSBuild
Import-DeliveryModule MSTest
Import-DeliveryModule Roundhouse
Import-DeliveryModule WebDeploy