#
# Module manifest for module 'PowerDelivery'
@{
ModuleToProcess = 'PowerDelivery.psm1'

# Version number of this module.
ModuleVersion = '2.2.13'

# ID used to uniquely identify this module
GUID = 'A5B89536-5B8E-4C6F-8F22-F1EAE066EB45'

# Author of this module
Author = 'Jayme C Edwards'

# Company or vendor of this module
CompanyName = 'Jayme C Edwards'

# Copyright statement for this module
Copyright = 'Copyright (c) 2013 Jayme C Edwards. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Allows you to create a continuous delivery pipeline for software products on TFS'

# Minimum version of the Windows PowerShell engine required by this module
#PowerShellVersion = '2.0'

# Minimum version of the Windows PowerShell host required by this module
#PowerShellHostVersion = ''

# Minimum version of the .NET Framework required by this module
#DotNetFrameworkVersion = '3.5'

# Minimum version of the common language runtime (CLR) required by this module
#CLRVersion = '2.0'

#RequiredModules = @('psake')

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in ModuleToProcess
# NestedModules = @()

# Functions to export from this module
FunctionsToExport = @('Import-DeliveryModule', 'Get-BuildAssemblyVersion', 'Register-DeliveryModuleHook', 'Get-BuildModuleConfig', 'Publish-BuildAssets', 'Get-BuildAssets', 'Pipeline', 'Exec', 'Get-BuildOnServer', 'Get-BuildAppVersion', 'Get-BuildEnvironment', 'Get-BuildDropLocation', 'Get-BuildChangeSet', 'Get-BuildRequestedBy', 'Get-BuildTeamProject', 'Get-BuildWorkspaceName', 'Get-BuildCollectionUri', 'Get-BuildUri', 'Get-BuildNumber', 'Get-BuildName', 'Get-BuildSetting', 'Invoke-EnvironmentCommand', 'Invoke-Powerdelivery', 'Invoke-MSBuild', 'Invoke-MSTest', 'Invoke-SSISPackage', 'Enable-SqlJobs', 'Disable-SqlJobs', 'Mount-IfUNC', 'Enable-WebDeploy', 'Update-AssemblyInfoFiles', 'Publish-Roundhouse', 'Remove-Roundhouse', 'Invoke-Roundhouse', 'Write-BuildSummaryMessage', 'Publish-SSAS', 'Set-SSASConnection', 'Add-Pipeline', 'New-RemoteShare', 'Start-SqlJobs')

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

}# 
 
 #   M o d u l e   m a n i f e s t   f o r   m o d u l e   ' P o w e r D e l i v e r y ' 
 
 @ { 
 
 M o d u l e T o P r o c e s s   =   ' P o w e r D e l i v e r y . p s m 1 ' 
 
 
 
 #   V e r s i o n   n u m b e r   o f   t h i s   m o d u l e . 
 
 M o d u l e V e r s i o n   =   ' 2 . 2 . 1 3 ' 
 
 
 
 #   I D   u s e d   t o   u n i q u e l y   i d e n t i f y   t h i s   m o d u l e 
 
 G U I D   =   ' A 5 B 8 9 5 3 6 - 5 B 8 E - 4 C 6 F - 8 F 2 2 - F 1 E A E 0 6 6 E B 4 5 ' 
 
 
 
 #   A u t h o r   o f   t h i s   m o d u l e 
 
 A u t h o r   =   ' J a y m e   C   E d w a r d s ' 
 
 
 
 #   C o m p a n y   o r   v e n d o r   o f   t h i s   m o d u l e 
 
 C o m p a n y N a m e   =   ' J a y m e   C   E d w a r d s ' 
 
 
 
 #   C o p y r i g h t   s t a t e m e n t   f o r   t h i s   m o d u l e 
 
 C o p y r i g h t   =   ' C o p y r i g h t   ( c )   2 0 1 3   J a y m e   C   E d w a r d s .   A l l   r i g h t s   r e s e r v e d . ' 
 
 
 
 #   D e s c r i p t i o n   o f   t h e   f u n c t i o n a l i t y   p r o v i d e d   b y   t h i s   m o d u l e 
 
 D e s c r i p t i o n   =   ' A l l o w s   y o u   t o   c r e a t e   a   c o n t i n u o u s   d e l i v e r y   p i p e l i n e   f o r   s o f t w a r e   p r o d u c t s   o n   T F S ' 
 
 
 
 #   M i n i m u m   v e r s i o n   o f   t h e   W i n d o w s   P o w e r S h e l l   e n g i n e   r e q u i r e d   b y   t h i s   m o d u l e 
 
 # P o w e r S h e l l V e r s i o n   =   ' 2 . 0 ' 
 
 
 
 #   M i n i m u m   v e r s i o n   o f   t h e   W i n d o w s   P o w e r S h e l l   h o s t   r e q u i r e d   b y   t h i s   m o d u l e 
 
 # P o w e r S h e l l H o s t V e r s i o n   =   ' ' 
 
 
 
 #   M i n i m u m   v e r s i o n   o f   t h e   . N E T   F r a m e w o r k   r e q u i r e d   b y   t h i s   m o d u l e 
 
 # D o t N e t F r a m e w o r k V e r s i o n   =   ' 3 . 5 ' 
 
 
 
 #   M i n i m u m   v e r s i o n   o f   t h e   c o m m o n   l a n g u a g e   r u n t i m e   ( C L R )   r e q u i r e d   b y   t h i s   m o d u l e 
 
 # C L R V e r s i o n   =   ' 2 . 0 ' 
 
 
 
 # R e q u i r e d M o d u l e s   =   @ ( ' p s a k e ' ) 
 
 
 
 #   A s s e m b l i e s   t h a t   m u s t   b e   l o a d e d   p r i o r   t o   i m p o r t i n g   t h i s   m o d u l e 
 
 #   R e q u i r e d A s s e m b l i e s   =   @ ( ) 
 
 
 
 #   S c r i p t   f i l e s   ( . p s 1 )   t h a t   a r e   r u n   i n   t h e   c a l l e r ' s   e n v i r o n m e n t   p r i o r   t o   i m p o r t i n g   t h i s   m o d u l e 
 
 #   S c r i p t s T o P r o c e s s   =   @ ( ) 
 
 
 
 #   T y p e   f i l e s   ( . p s 1 x m l )   t o   b e   l o a d e d   w h e n   i m p o r t i n g   t h i s   m o d u l e 
 
 #   T y p e s T o P r o c e s s   =   @ ( ) 
 
 
 
 #   F o r m a t   f i l e s   ( . p s 1 x m l )   t o   b e   l o a d e d   w h e n   i m p o r t i n g   t h i s   m o d u l e 
 
 #   F o r m a t s T o P r o c e s s   =   @ ( ) 
 
 
 
 #   M o d u l e s   t o   i m p o r t   a s   n e s t e d   m o d u l e s   o f   t h e   m o d u l e   s p e c i f i e d   i n   M o d u l e T o P r o c e s s 
 
 #   N e s t e d M o d u l e s   =   @ ( ) 
 
 
 
 #   F u n c t i o n s   t o   e x p o r t   f r o m   t h i s   m o d u l e 
 
 F u n c t i o n s T o E x p o r t   =   @ ( ' I m p o r t - D e l i v e r y M o d u l e ' ,   ' G e t - B u i l d A s s e m b l y V e r s i o n ' ,   ' R e g i s t e r - D e l i v e r y M o d u l e H o o k ' ,   ' G e t - B u i l d M o d u l e C o n f i g ' ,   ' P u b l i s h - B u i l d A s s e t s ' ,   ' G e t - B u i l d A s s e t s ' ,   ' P i p e l i n e ' ,   ' E x e c ' ,   ' G e t - B u i l d O n S e r v e r ' ,   ' G e t - B u i l d A p p V e r s i o n ' ,   ' G e t - B u i l d E n v i r o n m e n t ' ,   ' G e t - B u i l d D r o p L o c a t i o n ' ,   ' G e t - B u i l d C h a n g e S e t ' ,   ' G e t - B u i l d R e q u e s t e d B y ' ,   ' G e t - B u i l d T e a m P r o j e c t ' ,   ' G e t - B u i l d W o r k s p a c e N a m e ' ,   ' G e t - B u i l d C o l l e c t i o n U r i ' ,   ' G e t - B u i l d U r i ' ,   ' G e t - B u i l d N u m b e r ' ,   ' G e t - B u i l d N a m e ' ,   ' G e t - B u i l d S e t t i n g ' ,   ' I n v o k e - E n v i r o n m e n t C o m m a n d ' ,   ' I n v o k e - P o w e r d e l i v e r y ' ,   ' I n v o k e - M S B u i l d ' ,   ' I n v o k e - M S T e s t ' ,   ' I n v o k e - S S I S P a c k a g e ' ,   ' E n a b l e - S q l J o b s ' ,   ' D i s a b l e - S q l J o b s ' ,   ' M o u n t - I f U N C ' ,   ' E n a b l e - W e b D e p l o y ' ,   ' U p d a t e - A s s e m b l y I n f o F i l e s ' ,   ' P u b l i s h - R o u n d h o u s e ' ,   ' R e m o v e - R o u n d h o u s e ' ,   ' I n v o k e - R o u n d h o u s e ' ,   ' W r i t e - B u i l d S u m m a r y M e s s a g e ' ,   ' P u b l i s h - S S A S ' ,   ' S e t - S S A S C o n n e c t i o n ' ,   ' A d d - P i p e l i n e ' ,   ' N e w - R e m o t e S h a r e ' ,   ' S t a r t - S q l J o b s ' ) 
 
 
 
 #   C m d l e t s   t o   e x p o r t   f r o m   t h i s   m o d u l e 
 
 C m d l e t s T o E x p o r t   =   ' * ' 
 
 
 
 #   V a r i a b l e s   t o   e x p o r t   f r o m   t h i s   m o d u l e 
 
 V a r i a b l e s T o E x p o r t   =   ' * ' 
 
 
 
 #   A l i a s e s   t o   e x p o r t   f r o m   t h i s   m o d u l e 
 
 A l i a s e s T o E x p o r t   =   ' * ' 
 
 
 
 } 
 
 # 
 
 #   M o d u l e   m a n i f e s t   f o r   m o d u l e   ' P o w e r D e l i v e r y ' 
 
 @ { 
 
 M o d u l e T o P r o c e s s   =   ' P o w e r D e l i v e r y . p s m 1 ' 
 
 
 
 #   V e r s i o n   n u m b e r   o f   t h i s   m o d u l e . 
 
 M o d u l e V e r s i o n   =   ' 2 . 2 . 1 3 ' 
 
 
 
 #   I D   u s e d   t o   u n i q u e l y   i d e n t i f y   t h i s   m o d u l e 
 
 G U I D   =   ' A 5 B 8 9 5 3 6 - 5 B 8 E - 4 C 6 F - 8 F 2 2 - F 1 E A E 0 6 6 E B 4 5 ' 
 
 
 
 #   A u t h o r   o f   t h i s   m o d u l e 
 
 A u t h o r   =   ' J a y m e   C   E d w a r d s ' 
 
 
 
 #   C o m p a n y   o r   v e n d o r   o f   t h i s   m o d u l e 
 
 C o m p a n y N a m e   =   ' J a y m e   C   E d w a r d s ' 
 
 
 
 #   C o p y r i g h t   s t a t e m e n t   f o r   t h i s   m o d u l e 
 
 C o p y r i g h t   =   ' C o p y r i g h t   ( c )   2 0 1 3   J a y m e   C   E d w a r d s .   A l l   r i g h t s   r e s e r v e d . ' 
 
 
 
 #   D e s c r i p t i o n   o f   t h e   f u n c t i o n a l i t y   p r o v i d e d   b y   t h i s   m o d u l e 
 
 D e s c r i p t i o n   =   ' A l l o w s   y o u   t o   c r e a t e   a   c o n t i n u o u s   d e l i v e r y   p i p e l i n e   f o r   s o f t w a r e   p r o d u c t s   o n   T F S ' 
 
 
 
 #   M i n i m u m   v e r s i o n   o f   t h e   W i n d o w s   P o w e r S h e l l   e n g i n e   r e q u i r e d   b y   t h i s   m o d u l e 
 
 # P o w e r S h e l l V e r s i o n   =   ' 2 . 0 ' 
 
 
 
 #   M i n i m u m   v e r s i o n   o f   t h e   W i n d o w s   P o w e r S h e l l   h o s t   r e q u i r e d   b y   t h i s   m o d u l e 
 
 # P o w e r S h e l l H o s t V e r s i o n   =   ' ' 
 
 
 
 #   M i n i m u m   v e r s i o n   o f   t h e   . N E T   F r a m e w o r k   r e q u i r e d   b y   t h i s   m o d u l e 
 
 # D o t N e t F r a m e w o r k V e r s i o n   =   ' 3 . 5 ' 
 
 
 
 #   M i n i m u m   v e r s i o n   o f   t h e   c o m m o n   l a n g u a g e   r u n t i m e   ( C L R )   r e q u i r e d   b y   t h i s   m o d u l e 
 
 # C L R V e r s i o n   =   ' 2 . 0 ' 
 
 
 
 # R e q u i r e d M o d u l e s   =   @ ( ' p s a k e ' ) 
 
 
 
 #   A s s e m b l i e s   t h a t   m u s t   b e   l o a d e d   p r i o r   t o   i m p o r t i n g   t h i s   m o d u l e 
 
 #   R e q u i r e d A s s e m b l i e s   =   @ ( ) 
 
 
 
 #   S c r i p t   f i l e s   ( . p s 1 )   t h a t   a r e   r u n   i n   t h e   c a l l e r ' s   e n v i r o n m e n t   p r i o r   t o   i m p o r t i n g   t h i s   m o d u l e 
 
 #   S c r i p t s T o P r o c e s s   =   @ ( ) 
 
 
 
 #   T y p e   f i l e s   ( . p s 1 x m l )   t o   b e   l o a d e d   w h e n   i m p o r t i n g   t h i s   m o d u l e 
 
 #   T y p e s T o P r o c e s s   =   @ ( ) 
 
 
 
 #   F o r m a t   f i l e s   ( . p s 1 x m l )   t o   b e   l o a d e d   w h e n   i m p o r t i n g   t h i s   m o d u l e 
 
 #   F o r m a t s T o P r o c e s s   =   @ ( ) 
 
 
 
 #   M o d u l e s   t o   i m p o r t   a s   n e s t e d   m o d u l e s   o f   t h e   m o d u l e   s p e c i f i e d   i n   M o d u l e T o P r o c e s s 
 
 #   N e s t e d M o d u l e s   =   @ ( ) 
 
 
 
 #   F u n c t i o n s   t o   e x p o r t   f r o m   t h i s   m o d u l e 
 
 F u n c t i o n s T o E x p o r t   =   @ ( ' I m p o r t - D e l i v e r y M o d u l e ' ,   ' G e t - B u i l d A s s e m b l y V e r s i o n ' ,   ' R e g i s t e r - D e l i v e r y M o d u l e H o o k ' ,   ' G e t - B u i l d M o d u l e C o n f i g ' ,   ' P u b l i s h - B u i l d A s s e t s ' ,   ' G e t - B u i l d A s s e t s ' ,   ' P i p e l i n e ' ,   ' E x e c ' ,   ' G e t - B u i l d O n S e r v e r ' ,   ' G e t - B u i l d A p p V e r s i o n ' ,   ' G e t - B u i l d E n v i r o n m e n t ' ,   ' G e t - B u i l d D r o p L o c a t i o n ' ,   ' G e t - B u i l d C h a n g e S e t ' ,   ' G e t - B u i l d R e q u e s t e d B y ' ,   ' G e t - B u i l d T e a m P r o j e c t ' ,   ' G e t - B u i l d W o r k s p a c e N a m e ' ,   ' G e t - B u i l d C o l l e c t i o n U r i ' ,   ' G e t - B u i l d U r i ' ,   ' G e t - B u i l d N u m b e r ' ,   ' G e t - B u i l d N a m e ' ,   ' G e t - B u i l d S e t t i n g ' ,   ' I n v o k e - E n v i r o n m e n t C o m m a n d ' ,   ' I n v o k e - P o w e r d e l i v e r y ' ,   ' I n v o k e - M S B u i l d ' ,   ' I n v o k e - M S T e s t ' ,   ' I n v o k e - S S I S P a c k a g e ' ,   ' E n a b l e - S q l J o b s ' ,   ' D i s a b l e - S q l J o b s ' ,   ' M o u n t - I f U N C ' ,   ' E n a b l e - W e b D e p l o y ' ,   ' U p d a t e - A s s e m b l y I n f o F i l e s ' ,   ' P u b l i s h - R o u n d h o u s e ' ,   ' R e m o v e - R o u n d h o u s e ' ,   ' I n v o k e - R o u n d h o u s e ' ,   ' W r i t e - B u i l d S u m m a r y M e s s a g e ' ,   ' P u b l i s h - S S A S ' ,   ' S e t - S S A S C o n n e c t i o n ' ,   ' A d d - P i p e l i n e ' ,   ' N e w - R e m o t e S h a r e ' ,   ' S t a r t - S q l J o b s ' ) 
 
 
 
 #   C m d l e t s   t o   e x p o r t   f r o m   t h i s   m o d u l e 
 
 C m d l e t s T o E x p o r t   =   ' * ' 
 
 
 
 #   V a r i a b l e s   t o   e x p o r t   f r o m   t h i s   m o d u l e 
 
 V a r i a b l e s T o E x p o r t   =   ' * ' 
 
 
 
 #   A l i a s e s   t o   e x p o r t   f r o m   t h i s   m o d u l e 
 
 A l i a s e s T o E x p o r t   =   ' * ' 
 
 
 
 } #   
 
   
 
   #       M   o   d   u   l   e       m   a   n   i   f   e   s   t       f   o   r       m   o   d   u   l   e       '   P   o   w   e   r   D   e   l   i   v   e   r   y   '   
 
   
 
   @   {   
 
   
 
   M   o   d   u   l   e   T   o   P   r   o   c   e   s   s       =       '   P   o   w   e   r   D   e   l   i   v   e   r   y   .   p   s   m   1   '   
 
   
 
   
 
   
 
   #       V   e   r   s   i   o   n       n   u   m   b   e   r       o   f       t   h   i   s       m   o   d   u   l   e   .   
 
   
 
   M   o   d   u   l   e   V   e   r   s   i   o   n       =       '   2   .   2   .   1   3   '   
 
   
 
   
 
   
 
   #       I   D       u   s   e   d       t   o       u   n   i   q   u   e   l   y       i   d   e   n   t   i   f   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   G   U   I   D       =       '   A   5   B   8   9   5   3   6   -   5   B   8   E   -   4   C   6   F   -   8   F   2   2   -   F   1   E   A   E   0   6   6   E   B   4   5   '   
 
   
 
   
 
   
 
   #       A   u   t   h   o   r       o   f       t   h   i   s       m   o   d   u   l   e   
 
   
 
   A   u   t   h   o   r       =       '   J   a   y   m   e       C       E   d   w   a   r   d   s   '   
 
   
 
   
 
   
 
   #       C   o   m   p   a   n   y       o   r       v   e   n   d   o   r       o   f       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   o   m   p   a   n   y   N   a   m   e       =       '   J   a   y   m   e       C       E   d   w   a   r   d   s   '   
 
   
 
   
 
   
 
   #       C   o   p   y   r   i   g   h   t       s   t   a   t   e   m   e   n   t       f   o   r       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   o   p   y   r   i   g   h   t       =       '   C   o   p   y   r   i   g   h   t       (   c   )       2   0   1   3       J   a   y   m   e       C       E   d   w   a   r   d   s   .       A   l   l       r   i   g   h   t   s       r   e   s   e   r   v   e   d   .   '   
 
   
 
   
 
   
 
   #       D   e   s   c   r   i   p   t   i   o   n       o   f       t   h   e       f   u   n   c   t   i   o   n   a   l   i   t   y       p   r   o   v   i   d   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   D   e   s   c   r   i   p   t   i   o   n       =       '   A   l   l   o   w   s       y   o   u       t   o       c   r   e   a   t   e       a       c   o   n   t   i   n   u   o   u   s       d   e   l   i   v   e   r   y       p   i   p   e   l   i   n   e       f   o   r       s   o   f   t   w   a   r   e       p   r   o   d   u   c   t   s       o   n       T   F   S   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       W   i   n   d   o   w   s       P   o   w   e   r   S   h   e   l   l       e   n   g   i   n   e       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   P   o   w   e   r   S   h   e   l   l   V   e   r   s   i   o   n       =       '   2   .   0   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       W   i   n   d   o   w   s       P   o   w   e   r   S   h   e   l   l       h   o   s   t       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   P   o   w   e   r   S   h   e   l   l   H   o   s   t   V   e   r   s   i   o   n       =       '   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       .   N   E   T       F   r   a   m   e   w   o   r   k       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   D   o   t   N   e   t   F   r   a   m   e   w   o   r   k   V   e   r   s   i   o   n       =       '   3   .   5   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       c   o   m   m   o   n       l   a   n   g   u   a   g   e       r   u   n   t   i   m   e       (   C   L   R   )       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   C   L   R   V   e   r   s   i   o   n       =       '   2   .   0   '   
 
   
 
   
 
   
 
   #   R   e   q   u   i   r   e   d   M   o   d   u   l   e   s       =       @   (   '   p   s   a   k   e   '   )   
 
   
 
   
 
   
 
   #       A   s   s   e   m   b   l   i   e   s       t   h   a   t       m   u   s   t       b   e       l   o   a   d   e   d       p   r   i   o   r       t   o       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       R   e   q   u   i   r   e   d   A   s   s   e   m   b   l   i   e   s       =       @   (   )   
 
   
 
   
 
   
 
   #       S   c   r   i   p   t       f   i   l   e   s       (   .   p   s   1   )       t   h   a   t       a   r   e       r   u   n       i   n       t   h   e       c   a   l   l   e   r   '   s       e   n   v   i   r   o   n   m   e   n   t       p   r   i   o   r       t   o       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       S   c   r   i   p   t   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       T   y   p   e       f   i   l   e   s       (   .   p   s   1   x   m   l   )       t   o       b   e       l   o   a   d   e   d       w   h   e   n       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       T   y   p   e   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       F   o   r   m   a   t       f   i   l   e   s       (   .   p   s   1   x   m   l   )       t   o       b   e       l   o   a   d   e   d       w   h   e   n       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       F   o   r   m   a   t   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       M   o   d   u   l   e   s       t   o       i   m   p   o   r   t       a   s       n   e   s   t   e   d       m   o   d   u   l   e   s       o   f       t   h   e       m   o   d   u   l   e       s   p   e   c   i   f   i   e   d       i   n       M   o   d   u   l   e   T   o   P   r   o   c   e   s   s   
 
   
 
   #       N   e   s   t   e   d   M   o   d   u   l   e   s       =       @   (   )   
 
   
 
   
 
   
 
   #       F   u   n   c   t   i   o   n   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   F   u   n   c   t   i   o   n   s   T   o   E   x   p   o   r   t       =       @   (   '   I   m   p   o   r   t   -   D   e   l   i   v   e   r   y   M   o   d   u   l   e   '   ,       '   G   e   t   -   B   u   i   l   d   A   s   s   e   m   b   l   y   V   e   r   s   i   o   n   '   ,       '   R   e   g   i   s   t   e   r   -   D   e   l   i   v   e   r   y   M   o   d   u   l   e   H   o   o   k   '   ,       '   G   e   t   -   B   u   i   l   d   M   o   d   u   l   e   C   o   n   f   i   g   '   ,       '   P   u   b   l   i   s   h   -   B   u   i   l   d   A   s   s   e   t   s   '   ,       '   G   e   t   -   B   u   i   l   d   A   s   s   e   t   s   '   ,       '   P   i   p   e   l   i   n   e   '   ,       '   E   x   e   c   '   ,       '   G   e   t   -   B   u   i   l   d   O   n   S   e   r   v   e   r   '   ,       '   G   e   t   -   B   u   i   l   d   A   p   p   V   e   r   s   i   o   n   '   ,       '   G   e   t   -   B   u   i   l   d   E   n   v   i   r   o   n   m   e   n   t   '   ,       '   G   e   t   -   B   u   i   l   d   D   r   o   p   L   o   c   a   t   i   o   n   '   ,       '   G   e   t   -   B   u   i   l   d   C   h   a   n   g   e   S   e   t   '   ,       '   G   e   t   -   B   u   i   l   d   R   e   q   u   e   s   t   e   d   B   y   '   ,       '   G   e   t   -   B   u   i   l   d   T   e   a   m   P   r   o   j   e   c   t   '   ,       '   G   e   t   -   B   u   i   l   d   W   o   r   k   s   p   a   c   e   N   a   m   e   '   ,       '   G   e   t   -   B   u   i   l   d   C   o   l   l   e   c   t   i   o   n   U   r   i   '   ,       '   G   e   t   -   B   u   i   l   d   U   r   i   '   ,       '   G   e   t   -   B   u   i   l   d   N   u   m   b   e   r   '   ,       '   G   e   t   -   B   u   i   l   d   N   a   m   e   '   ,       '   G   e   t   -   B   u   i   l   d   S   e   t   t   i   n   g   '   ,       '   I   n   v   o   k   e   -   E   n   v   i   r   o   n   m   e   n   t   C   o   m   m   a   n   d   '   ,       '   I   n   v   o   k   e   -   P   o   w   e   r   d   e   l   i   v   e   r   y   '   ,       '   I   n   v   o   k   e   -   M   S   B   u   i   l   d   '   ,       '   I   n   v   o   k   e   -   M   S   T   e   s   t   '   ,       '   I   n   v   o   k   e   -   S   S   I   S   P   a   c   k   a   g   e   '   ,       '   E   n   a   b   l   e   -   S   q   l   J   o   b   s   '   ,       '   D   i   s   a   b   l   e   -   S   q   l   J   o   b   s   '   ,       '   M   o   u   n   t   -   I   f   U   N   C   '   ,       '   E   n   a   b   l   e   -   W   e   b   D   e   p   l   o   y   '   ,       '   U   p   d   a   t   e   -   A   s   s   e   m   b   l   y   I   n   f   o   F   i   l   e   s   '   ,       '   P   u   b   l   i   s   h   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   R   e   m   o   v   e   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   I   n   v   o   k   e   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   W   r   i   t   e   -   B   u   i   l   d   S   u   m   m   a   r   y   M   e   s   s   a   g   e   '   ,       '   P   u   b   l   i   s   h   -   S   S   A   S   '   ,       '   S   e   t   -   S   S   A   S   C   o   n   n   e   c   t   i   o   n   '   ,       '   A   d   d   -   P   i   p   e   l   i   n   e   '   ,       '   N   e   w   -   R   e   m   o   t   e   S   h   a   r   e   '   ,       '   S   t   a   r   t   -   S   q   l   J   o   b   s   '   )   
 
   
 
   
 
   
 
   #       C   m   d   l   e   t   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   m   d   l   e   t   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   #       V   a   r   i   a   b   l   e   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   V   a   r   i   a   b   l   e   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   #       A   l   i   a   s   e   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   A   l   i   a   s   e   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   }   
 
   
 
   
 
 # 
 
 #   M o d u l e   m a n i f e s t   f o r   m o d u l e   ' P o w e r D e l i v e r y ' 
 
 @ { 
 
 M o d u l e T o P r o c e s s   =   ' P o w e r D e l i v e r y . p s m 1 ' 
 
 
 
 #   V e r s i o n   n u m b e r   o f   t h i s   m o d u l e . 
 
 M o d u l e V e r s i o n   =   ' 2 . 2 . 1 3 ' 
 
 
 
 #   I D   u s e d   t o   u n i q u e l y   i d e n t i f y   t h i s   m o d u l e 
 
 G U I D   =   ' A 5 B 8 9 5 3 6 - 5 B 8 E - 4 C 6 F - 8 F 2 2 - F 1 E A E 0 6 6 E B 4 5 ' 
 
 
 
 #   A u t h o r   o f   t h i s   m o d u l e 
 
 A u t h o r   =   ' J a y m e   C   E d w a r d s ' 
 
 
 
 #   C o m p a n y   o r   v e n d o r   o f   t h i s   m o d u l e 
 
 C o m p a n y N a m e   =   ' J a y m e   C   E d w a r d s ' 
 
 
 
 #   C o p y r i g h t   s t a t e m e n t   f o r   t h i s   m o d u l e 
 
 C o p y r i g h t   =   ' C o p y r i g h t   ( c )   2 0 1 3   J a y m e   C   E d w a r d s .   A l l   r i g h t s   r e s e r v e d . ' 
 
 
 
 #   D e s c r i p t i o n   o f   t h e   f u n c t i o n a l i t y   p r o v i d e d   b y   t h i s   m o d u l e 
 
 D e s c r i p t i o n   =   ' A l l o w s   y o u   t o   c r e a t e   a   c o n t i n u o u s   d e l i v e r y   p i p e l i n e   f o r   s o f t w a r e   p r o d u c t s   o n   T F S ' 
 
 
 
 #   M i n i m u m   v e r s i o n   o f   t h e   W i n d o w s   P o w e r S h e l l   e n g i n e   r e q u i r e d   b y   t h i s   m o d u l e 
 
 # P o w e r S h e l l V e r s i o n   =   ' 2 . 0 ' 
 
 
 
 #   M i n i m u m   v e r s i o n   o f   t h e   W i n d o w s   P o w e r S h e l l   h o s t   r e q u i r e d   b y   t h i s   m o d u l e 
 
 # P o w e r S h e l l H o s t V e r s i o n   =   ' ' 
 
 
 
 #   M i n i m u m   v e r s i o n   o f   t h e   . N E T   F r a m e w o r k   r e q u i r e d   b y   t h i s   m o d u l e 
 
 # D o t N e t F r a m e w o r k V e r s i o n   =   ' 3 . 5 ' 
 
 
 
 #   M i n i m u m   v e r s i o n   o f   t h e   c o m m o n   l a n g u a g e   r u n t i m e   ( C L R )   r e q u i r e d   b y   t h i s   m o d u l e 
 
 # C L R V e r s i o n   =   ' 2 . 0 ' 
 
 
 
 # R e q u i r e d M o d u l e s   =   @ ( ' p s a k e ' ) 
 
 
 
 #   A s s e m b l i e s   t h a t   m u s t   b e   l o a d e d   p r i o r   t o   i m p o r t i n g   t h i s   m o d u l e 
 
 #   R e q u i r e d A s s e m b l i e s   =   @ ( ) 
 
 
 
 #   S c r i p t   f i l e s   ( . p s 1 )   t h a t   a r e   r u n   i n   t h e   c a l l e r ' s   e n v i r o n m e n t   p r i o r   t o   i m p o r t i n g   t h i s   m o d u l e 
 
 #   S c r i p t s T o P r o c e s s   =   @ ( ) 
 
 
 
 #   T y p e   f i l e s   ( . p s 1 x m l )   t o   b e   l o a d e d   w h e n   i m p o r t i n g   t h i s   m o d u l e 
 
 #   T y p e s T o P r o c e s s   =   @ ( ) 
 
 
 
 #   F o r m a t   f i l e s   ( . p s 1 x m l )   t o   b e   l o a d e d   w h e n   i m p o r t i n g   t h i s   m o d u l e 
 
 #   F o r m a t s T o P r o c e s s   =   @ ( ) 
 
 
 
 #   M o d u l e s   t o   i m p o r t   a s   n e s t e d   m o d u l e s   o f   t h e   m o d u l e   s p e c i f i e d   i n   M o d u l e T o P r o c e s s 
 
 #   N e s t e d M o d u l e s   =   @ ( ) 
 
 
 
 #   F u n c t i o n s   t o   e x p o r t   f r o m   t h i s   m o d u l e 
 
 F u n c t i o n s T o E x p o r t   =   @ ( ' I m p o r t - D e l i v e r y M o d u l e ' ,   ' G e t - B u i l d A s s e m b l y V e r s i o n ' ,   ' R e g i s t e r - D e l i v e r y M o d u l e H o o k ' ,   ' G e t - B u i l d M o d u l e C o n f i g ' ,   ' P u b l i s h - B u i l d A s s e t s ' ,   ' G e t - B u i l d A s s e t s ' ,   ' P i p e l i n e ' ,   ' E x e c ' ,   ' G e t - B u i l d O n S e r v e r ' ,   ' G e t - B u i l d A p p V e r s i o n ' ,   ' G e t - B u i l d E n v i r o n m e n t ' ,   ' G e t - B u i l d D r o p L o c a t i o n ' ,   ' G e t - B u i l d C h a n g e S e t ' ,   ' G e t - B u i l d R e q u e s t e d B y ' ,   ' G e t - B u i l d T e a m P r o j e c t ' ,   ' G e t - B u i l d W o r k s p a c e N a m e ' ,   ' G e t - B u i l d C o l l e c t i o n U r i ' ,   ' G e t - B u i l d U r i ' ,   ' G e t - B u i l d N u m b e r ' ,   ' G e t - B u i l d N a m e ' ,   ' G e t - B u i l d S e t t i n g ' ,   ' I n v o k e - E n v i r o n m e n t C o m m a n d ' ,   ' I n v o k e - P o w e r d e l i v e r y ' ,   ' I n v o k e - M S B u i l d ' ,   ' I n v o k e - M S T e s t ' ,   ' I n v o k e - S S I S P a c k a g e ' ,   ' E n a b l e - S q l J o b s ' ,   ' D i s a b l e - S q l J o b s ' ,   ' M o u n t - I f U N C ' ,   ' E n a b l e - W e b D e p l o y ' ,   ' U p d a t e - A s s e m b l y I n f o F i l e s ' ,   ' P u b l i s h - R o u n d h o u s e ' ,   ' R e m o v e - R o u n d h o u s e ' ,   ' I n v o k e - R o u n d h o u s e ' ,   ' W r i t e - B u i l d S u m m a r y M e s s a g e ' ,   ' P u b l i s h - S S A S ' ,   ' S e t - S S A S C o n n e c t i o n ' ,   ' A d d - P i p e l i n e ' ,   ' N e w - R e m o t e S h a r e ' ,   ' S t a r t - S q l J o b s ' ) 
 
 
 
 #   C m d l e t s   t o   e x p o r t   f r o m   t h i s   m o d u l e 
 
 C m d l e t s T o E x p o r t   =   ' * ' 
 
 
 
 #   V a r i a b l e s   t o   e x p o r t   f r o m   t h i s   m o d u l e 
 
 V a r i a b l e s T o E x p o r t   =   ' * ' 
 
 
 
 #   A l i a s e s   t o   e x p o r t   f r o m   t h i s   m o d u l e 
 
 A l i a s e s T o E x p o r t   =   ' * ' 
 
 
 
 } #   
 
   
 
   #       M   o   d   u   l   e       m   a   n   i   f   e   s   t       f   o   r       m   o   d   u   l   e       '   P   o   w   e   r   D   e   l   i   v   e   r   y   '   
 
   
 
   @   {   
 
   
 
   M   o   d   u   l   e   T   o   P   r   o   c   e   s   s       =       '   P   o   w   e   r   D   e   l   i   v   e   r   y   .   p   s   m   1   '   
 
   
 
   
 
   
 
   #       V   e   r   s   i   o   n       n   u   m   b   e   r       o   f       t   h   i   s       m   o   d   u   l   e   .   
 
   
 
   M   o   d   u   l   e   V   e   r   s   i   o   n       =       '   2   .   2   .   1   3   '   
 
   
 
   
 
   
 
   #       I   D       u   s   e   d       t   o       u   n   i   q   u   e   l   y       i   d   e   n   t   i   f   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   G   U   I   D       =       '   A   5   B   8   9   5   3   6   -   5   B   8   E   -   4   C   6   F   -   8   F   2   2   -   F   1   E   A   E   0   6   6   E   B   4   5   '   
 
   
 
   
 
   
 
   #       A   u   t   h   o   r       o   f       t   h   i   s       m   o   d   u   l   e   
 
   
 
   A   u   t   h   o   r       =       '   J   a   y   m   e       C       E   d   w   a   r   d   s   '   
 
   
 
   
 
   
 
   #       C   o   m   p   a   n   y       o   r       v   e   n   d   o   r       o   f       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   o   m   p   a   n   y   N   a   m   e       =       '   J   a   y   m   e       C       E   d   w   a   r   d   s   '   
 
   
 
   
 
   
 
   #       C   o   p   y   r   i   g   h   t       s   t   a   t   e   m   e   n   t       f   o   r       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   o   p   y   r   i   g   h   t       =       '   C   o   p   y   r   i   g   h   t       (   c   )       2   0   1   3       J   a   y   m   e       C       E   d   w   a   r   d   s   .       A   l   l       r   i   g   h   t   s       r   e   s   e   r   v   e   d   .   '   
 
   
 
   
 
   
 
   #       D   e   s   c   r   i   p   t   i   o   n       o   f       t   h   e       f   u   n   c   t   i   o   n   a   l   i   t   y       p   r   o   v   i   d   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   D   e   s   c   r   i   p   t   i   o   n       =       '   A   l   l   o   w   s       y   o   u       t   o       c   r   e   a   t   e       a       c   o   n   t   i   n   u   o   u   s       d   e   l   i   v   e   r   y       p   i   p   e   l   i   n   e       f   o   r       s   o   f   t   w   a   r   e       p   r   o   d   u   c   t   s       o   n       T   F   S   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       W   i   n   d   o   w   s       P   o   w   e   r   S   h   e   l   l       e   n   g   i   n   e       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   P   o   w   e   r   S   h   e   l   l   V   e   r   s   i   o   n       =       '   2   .   0   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       W   i   n   d   o   w   s       P   o   w   e   r   S   h   e   l   l       h   o   s   t       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   P   o   w   e   r   S   h   e   l   l   H   o   s   t   V   e   r   s   i   o   n       =       '   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       .   N   E   T       F   r   a   m   e   w   o   r   k       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   D   o   t   N   e   t   F   r   a   m   e   w   o   r   k   V   e   r   s   i   o   n       =       '   3   .   5   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       c   o   m   m   o   n       l   a   n   g   u   a   g   e       r   u   n   t   i   m   e       (   C   L   R   )       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   C   L   R   V   e   r   s   i   o   n       =       '   2   .   0   '   
 
   
 
   
 
   
 
   #   R   e   q   u   i   r   e   d   M   o   d   u   l   e   s       =       @   (   '   p   s   a   k   e   '   )   
 
   
 
   
 
   
 
   #       A   s   s   e   m   b   l   i   e   s       t   h   a   t       m   u   s   t       b   e       l   o   a   d   e   d       p   r   i   o   r       t   o       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       R   e   q   u   i   r   e   d   A   s   s   e   m   b   l   i   e   s       =       @   (   )   
 
   
 
   
 
   
 
   #       S   c   r   i   p   t       f   i   l   e   s       (   .   p   s   1   )       t   h   a   t       a   r   e       r   u   n       i   n       t   h   e       c   a   l   l   e   r   '   s       e   n   v   i   r   o   n   m   e   n   t       p   r   i   o   r       t   o       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       S   c   r   i   p   t   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       T   y   p   e       f   i   l   e   s       (   .   p   s   1   x   m   l   )       t   o       b   e       l   o   a   d   e   d       w   h   e   n       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       T   y   p   e   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       F   o   r   m   a   t       f   i   l   e   s       (   .   p   s   1   x   m   l   )       t   o       b   e       l   o   a   d   e   d       w   h   e   n       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       F   o   r   m   a   t   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       M   o   d   u   l   e   s       t   o       i   m   p   o   r   t       a   s       n   e   s   t   e   d       m   o   d   u   l   e   s       o   f       t   h   e       m   o   d   u   l   e       s   p   e   c   i   f   i   e   d       i   n       M   o   d   u   l   e   T   o   P   r   o   c   e   s   s   
 
   
 
   #       N   e   s   t   e   d   M   o   d   u   l   e   s       =       @   (   )   
 
   
 
   
 
   
 
   #       F   u   n   c   t   i   o   n   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   F   u   n   c   t   i   o   n   s   T   o   E   x   p   o   r   t       =       @   (   '   I   m   p   o   r   t   -   D   e   l   i   v   e   r   y   M   o   d   u   l   e   '   ,       '   G   e   t   -   B   u   i   l   d   A   s   s   e   m   b   l   y   V   e   r   s   i   o   n   '   ,       '   R   e   g   i   s   t   e   r   -   D   e   l   i   v   e   r   y   M   o   d   u   l   e   H   o   o   k   '   ,       '   G   e   t   -   B   u   i   l   d   M   o   d   u   l   e   C   o   n   f   i   g   '   ,       '   P   u   b   l   i   s   h   -   B   u   i   l   d   A   s   s   e   t   s   '   ,       '   G   e   t   -   B   u   i   l   d   A   s   s   e   t   s   '   ,       '   P   i   p   e   l   i   n   e   '   ,       '   E   x   e   c   '   ,       '   G   e   t   -   B   u   i   l   d   O   n   S   e   r   v   e   r   '   ,       '   G   e   t   -   B   u   i   l   d   A   p   p   V   e   r   s   i   o   n   '   ,       '   G   e   t   -   B   u   i   l   d   E   n   v   i   r   o   n   m   e   n   t   '   ,       '   G   e   t   -   B   u   i   l   d   D   r   o   p   L   o   c   a   t   i   o   n   '   ,       '   G   e   t   -   B   u   i   l   d   C   h   a   n   g   e   S   e   t   '   ,       '   G   e   t   -   B   u   i   l   d   R   e   q   u   e   s   t   e   d   B   y   '   ,       '   G   e   t   -   B   u   i   l   d   T   e   a   m   P   r   o   j   e   c   t   '   ,       '   G   e   t   -   B   u   i   l   d   W   o   r   k   s   p   a   c   e   N   a   m   e   '   ,       '   G   e   t   -   B   u   i   l   d   C   o   l   l   e   c   t   i   o   n   U   r   i   '   ,       '   G   e   t   -   B   u   i   l   d   U   r   i   '   ,       '   G   e   t   -   B   u   i   l   d   N   u   m   b   e   r   '   ,       '   G   e   t   -   B   u   i   l   d   N   a   m   e   '   ,       '   G   e   t   -   B   u   i   l   d   S   e   t   t   i   n   g   '   ,       '   I   n   v   o   k   e   -   E   n   v   i   r   o   n   m   e   n   t   C   o   m   m   a   n   d   '   ,       '   I   n   v   o   k   e   -   P   o   w   e   r   d   e   l   i   v   e   r   y   '   ,       '   I   n   v   o   k   e   -   M   S   B   u   i   l   d   '   ,       '   I   n   v   o   k   e   -   M   S   T   e   s   t   '   ,       '   I   n   v   o   k   e   -   S   S   I   S   P   a   c   k   a   g   e   '   ,       '   E   n   a   b   l   e   -   S   q   l   J   o   b   s   '   ,       '   D   i   s   a   b   l   e   -   S   q   l   J   o   b   s   '   ,       '   M   o   u   n   t   -   I   f   U   N   C   '   ,       '   E   n   a   b   l   e   -   W   e   b   D   e   p   l   o   y   '   ,       '   U   p   d   a   t   e   -   A   s   s   e   m   b   l   y   I   n   f   o   F   i   l   e   s   '   ,       '   P   u   b   l   i   s   h   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   R   e   m   o   v   e   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   I   n   v   o   k   e   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   W   r   i   t   e   -   B   u   i   l   d   S   u   m   m   a   r   y   M   e   s   s   a   g   e   '   ,       '   P   u   b   l   i   s   h   -   S   S   A   S   '   ,       '   S   e   t   -   S   S   A   S   C   o   n   n   e   c   t   i   o   n   '   ,       '   A   d   d   -   P   i   p   e   l   i   n   e   '   ,       '   N   e   w   -   R   e   m   o   t   e   S   h   a   r   e   '   ,       '   S   t   a   r   t   -   S   q   l   J   o   b   s   '   )   
 
   
 
   
 
   
 
   #       C   m   d   l   e   t   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   m   d   l   e   t   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   #       V   a   r   i   a   b   l   e   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   V   a   r   i   a   b   l   e   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   #       A   l   i   a   s   e   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   A   l   i   a   s   e   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   }   
 
   
 
   #   
 
   
 
   #       M   o   d   u   l   e       m   a   n   i   f   e   s   t       f   o   r       m   o   d   u   l   e       '   P   o   w   e   r   D   e   l   i   v   e   r   y   '   
 
   
 
   @   {   
 
   
 
   M   o   d   u   l   e   T   o   P   r   o   c   e   s   s       =       '   P   o   w   e   r   D   e   l   i   v   e   r   y   .   p   s   m   1   '   
 
   
 
   
 
   
 
   #       V   e   r   s   i   o   n       n   u   m   b   e   r       o   f       t   h   i   s       m   o   d   u   l   e   .   
 
   
 
   M   o   d   u   l   e   V   e   r   s   i   o   n       =       '   2   .   2   .   1   3   '   
 
   
 
   
 
   
 
   #       I   D       u   s   e   d       t   o       u   n   i   q   u   e   l   y       i   d   e   n   t   i   f   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   G   U   I   D       =       '   A   5   B   8   9   5   3   6   -   5   B   8   E   -   4   C   6   F   -   8   F   2   2   -   F   1   E   A   E   0   6   6   E   B   4   5   '   
 
   
 
   
 
   
 
   #       A   u   t   h   o   r       o   f       t   h   i   s       m   o   d   u   l   e   
 
   
 
   A   u   t   h   o   r       =       '   J   a   y   m   e       C       E   d   w   a   r   d   s   '   
 
   
 
   
 
   
 
   #       C   o   m   p   a   n   y       o   r       v   e   n   d   o   r       o   f       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   o   m   p   a   n   y   N   a   m   e       =       '   J   a   y   m   e       C       E   d   w   a   r   d   s   '   
 
   
 
   
 
   
 
   #       C   o   p   y   r   i   g   h   t       s   t   a   t   e   m   e   n   t       f   o   r       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   o   p   y   r   i   g   h   t       =       '   C   o   p   y   r   i   g   h   t       (   c   )       2   0   1   3       J   a   y   m   e       C       E   d   w   a   r   d   s   .       A   l   l       r   i   g   h   t   s       r   e   s   e   r   v   e   d   .   '   
 
   
 
   
 
   
 
   #       D   e   s   c   r   i   p   t   i   o   n       o   f       t   h   e       f   u   n   c   t   i   o   n   a   l   i   t   y       p   r   o   v   i   d   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   D   e   s   c   r   i   p   t   i   o   n       =       '   A   l   l   o   w   s       y   o   u       t   o       c   r   e   a   t   e       a       c   o   n   t   i   n   u   o   u   s       d   e   l   i   v   e   r   y       p   i   p   e   l   i   n   e       f   o   r       s   o   f   t   w   a   r   e       p   r   o   d   u   c   t   s       o   n       T   F   S   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       W   i   n   d   o   w   s       P   o   w   e   r   S   h   e   l   l       e   n   g   i   n   e       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   P   o   w   e   r   S   h   e   l   l   V   e   r   s   i   o   n       =       '   2   .   0   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       W   i   n   d   o   w   s       P   o   w   e   r   S   h   e   l   l       h   o   s   t       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   P   o   w   e   r   S   h   e   l   l   H   o   s   t   V   e   r   s   i   o   n       =       '   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       .   N   E   T       F   r   a   m   e   w   o   r   k       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   D   o   t   N   e   t   F   r   a   m   e   w   o   r   k   V   e   r   s   i   o   n       =       '   3   .   5   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       c   o   m   m   o   n       l   a   n   g   u   a   g   e       r   u   n   t   i   m   e       (   C   L   R   )       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   C   L   R   V   e   r   s   i   o   n       =       '   2   .   0   '   
 
   
 
   
 
   
 
   #   R   e   q   u   i   r   e   d   M   o   d   u   l   e   s       =       @   (   '   p   s   a   k   e   '   )   
 
   
 
   
 
   
 
   #       A   s   s   e   m   b   l   i   e   s       t   h   a   t       m   u   s   t       b   e       l   o   a   d   e   d       p   r   i   o   r       t   o       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       R   e   q   u   i   r   e   d   A   s   s   e   m   b   l   i   e   s       =       @   (   )   
 
   
 
   
 
   
 
   #       S   c   r   i   p   t       f   i   l   e   s       (   .   p   s   1   )       t   h   a   t       a   r   e       r   u   n       i   n       t   h   e       c   a   l   l   e   r   '   s       e   n   v   i   r   o   n   m   e   n   t       p   r   i   o   r       t   o       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       S   c   r   i   p   t   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       T   y   p   e       f   i   l   e   s       (   .   p   s   1   x   m   l   )       t   o       b   e       l   o   a   d   e   d       w   h   e   n       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       T   y   p   e   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       F   o   r   m   a   t       f   i   l   e   s       (   .   p   s   1   x   m   l   )       t   o       b   e       l   o   a   d   e   d       w   h   e   n       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       F   o   r   m   a   t   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       M   o   d   u   l   e   s       t   o       i   m   p   o   r   t       a   s       n   e   s   t   e   d       m   o   d   u   l   e   s       o   f       t   h   e       m   o   d   u   l   e       s   p   e   c   i   f   i   e   d       i   n       M   o   d   u   l   e   T   o   P   r   o   c   e   s   s   
 
   
 
   #       N   e   s   t   e   d   M   o   d   u   l   e   s       =       @   (   )   
 
   
 
   
 
   
 
   #       F   u   n   c   t   i   o   n   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   F   u   n   c   t   i   o   n   s   T   o   E   x   p   o   r   t       =       @   (   '   I   m   p   o   r   t   -   D   e   l   i   v   e   r   y   M   o   d   u   l   e   '   ,       '   G   e   t   -   B   u   i   l   d   A   s   s   e   m   b   l   y   V   e   r   s   i   o   n   '   ,       '   R   e   g   i   s   t   e   r   -   D   e   l   i   v   e   r   y   M   o   d   u   l   e   H   o   o   k   '   ,       '   G   e   t   -   B   u   i   l   d   M   o   d   u   l   e   C   o   n   f   i   g   '   ,       '   P   u   b   l   i   s   h   -   B   u   i   l   d   A   s   s   e   t   s   '   ,       '   G   e   t   -   B   u   i   l   d   A   s   s   e   t   s   '   ,       '   P   i   p   e   l   i   n   e   '   ,       '   E   x   e   c   '   ,       '   G   e   t   -   B   u   i   l   d   O   n   S   e   r   v   e   r   '   ,       '   G   e   t   -   B   u   i   l   d   A   p   p   V   e   r   s   i   o   n   '   ,       '   G   e   t   -   B   u   i   l   d   E   n   v   i   r   o   n   m   e   n   t   '   ,       '   G   e   t   -   B   u   i   l   d   D   r   o   p   L   o   c   a   t   i   o   n   '   ,       '   G   e   t   -   B   u   i   l   d   C   h   a   n   g   e   S   e   t   '   ,       '   G   e   t   -   B   u   i   l   d   R   e   q   u   e   s   t   e   d   B   y   '   ,       '   G   e   t   -   B   u   i   l   d   T   e   a   m   P   r   o   j   e   c   t   '   ,       '   G   e   t   -   B   u   i   l   d   W   o   r   k   s   p   a   c   e   N   a   m   e   '   ,       '   G   e   t   -   B   u   i   l   d   C   o   l   l   e   c   t   i   o   n   U   r   i   '   ,       '   G   e   t   -   B   u   i   l   d   U   r   i   '   ,       '   G   e   t   -   B   u   i   l   d   N   u   m   b   e   r   '   ,       '   G   e   t   -   B   u   i   l   d   N   a   m   e   '   ,       '   G   e   t   -   B   u   i   l   d   S   e   t   t   i   n   g   '   ,       '   I   n   v   o   k   e   -   E   n   v   i   r   o   n   m   e   n   t   C   o   m   m   a   n   d   '   ,       '   I   n   v   o   k   e   -   P   o   w   e   r   d   e   l   i   v   e   r   y   '   ,       '   I   n   v   o   k   e   -   M   S   B   u   i   l   d   '   ,       '   I   n   v   o   k   e   -   M   S   T   e   s   t   '   ,       '   I   n   v   o   k   e   -   S   S   I   S   P   a   c   k   a   g   e   '   ,       '   E   n   a   b   l   e   -   S   q   l   J   o   b   s   '   ,       '   D   i   s   a   b   l   e   -   S   q   l   J   o   b   s   '   ,       '   M   o   u   n   t   -   I   f   U   N   C   '   ,       '   E   n   a   b   l   e   -   W   e   b   D   e   p   l   o   y   '   ,       '   U   p   d   a   t   e   -   A   s   s   e   m   b   l   y   I   n   f   o   F   i   l   e   s   '   ,       '   P   u   b   l   i   s   h   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   R   e   m   o   v   e   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   I   n   v   o   k   e   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   W   r   i   t   e   -   B   u   i   l   d   S   u   m   m   a   r   y   M   e   s   s   a   g   e   '   ,       '   P   u   b   l   i   s   h   -   S   S   A   S   '   ,       '   S   e   t   -   S   S   A   S   C   o   n   n   e   c   t   i   o   n   '   ,       '   A   d   d   -   P   i   p   e   l   i   n   e   '   ,       '   N   e   w   -   R   e   m   o   t   e   S   h   a   r   e   '   ,       '   S   t   a   r   t   -   S   q   l   J   o   b   s   '   )   
 
   
 
   
 
   
 
   #       C   m   d   l   e   t   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   m   d   l   e   t   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   #       V   a   r   i   a   b   l   e   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   V   a   r   i   a   b   l   e   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   #       A   l   i   a   s   e   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   A   l   i   a   s   e   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   }   #       
 
   
 
       
 
   
 
       #               M       o       d       u       l       e               m       a       n       i       f       e       s       t               f       o       r               m       o       d       u       l       e               '       P       o       w       e       r       D       e       l       i       v       e       r       y       '       
 
   
 
       
 
   
 
       @       {       
 
   
 
       
 
   
 
       M       o       d       u       l       e       T       o       P       r       o       c       e       s       s               =               '       P       o       w       e       r       D       e       l       i       v       e       r       y       .       p       s       m       1       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               V       e       r       s       i       o       n               n       u       m       b       e       r               o       f               t       h       i       s               m       o       d       u       l       e       .       
 
   
 
       
 
   
 
       M       o       d       u       l       e       V       e       r       s       i       o       n               =               '       2       .       2       .       1       3       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               I       D               u       s       e       d               t       o               u       n       i       q       u       e       l       y               i       d       e       n       t       i       f       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       G       U       I       D               =               '       A       5       B       8       9       5       3       6       -       5       B       8       E       -       4       C       6       F       -       8       F       2       2       -       F       1       E       A       E       0       6       6       E       B       4       5       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               A       u       t       h       o       r               o       f               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       A       u       t       h       o       r               =               '       J       a       y       m       e               C               E       d       w       a       r       d       s       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               C       o       m       p       a       n       y               o       r               v       e       n       d       o       r               o       f               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       C       o       m       p       a       n       y       N       a       m       e               =               '       J       a       y       m       e               C               E       d       w       a       r       d       s       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               C       o       p       y       r       i       g       h       t               s       t       a       t       e       m       e       n       t               f       o       r               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       C       o       p       y       r       i       g       h       t               =               '       C       o       p       y       r       i       g       h       t               (       c       )               2       0       1       3               J       a       y       m       e               C               E       d       w       a       r       d       s       .               A       l       l               r       i       g       h       t       s               r       e       s       e       r       v       e       d       .       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               D       e       s       c       r       i       p       t       i       o       n               o       f               t       h       e               f       u       n       c       t       i       o       n       a       l       i       t       y               p       r       o       v       i       d       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       D       e       s       c       r       i       p       t       i       o       n               =               '       A       l       l       o       w       s               y       o       u               t       o               c       r       e       a       t       e               a               c       o       n       t       i       n       u       o       u       s               d       e       l       i       v       e       r       y               p       i       p       e       l       i       n       e               f       o       r               s       o       f       t       w       a       r       e               p       r       o       d       u       c       t       s               o       n               T       F       S       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       i       n       i       m       u       m               v       e       r       s       i       o       n               o       f               t       h       e               W       i       n       d       o       w       s               P       o       w       e       r       S       h       e       l       l               e       n       g       i       n       e               r       e       q       u       i       r       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #       P       o       w       e       r       S       h       e       l       l       V       e       r       s       i       o       n               =               '       2       .       0       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       i       n       i       m       u       m               v       e       r       s       i       o       n               o       f               t       h       e               W       i       n       d       o       w       s               P       o       w       e       r       S       h       e       l       l               h       o       s       t               r       e       q       u       i       r       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #       P       o       w       e       r       S       h       e       l       l       H       o       s       t       V       e       r       s       i       o       n               =               '       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       i       n       i       m       u       m               v       e       r       s       i       o       n               o       f               t       h       e               .       N       E       T               F       r       a       m       e       w       o       r       k               r       e       q       u       i       r       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #       D       o       t       N       e       t       F       r       a       m       e       w       o       r       k       V       e       r       s       i       o       n               =               '       3       .       5       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       i       n       i       m       u       m               v       e       r       s       i       o       n               o       f               t       h       e               c       o       m       m       o       n               l       a       n       g       u       a       g       e               r       u       n       t       i       m       e               (       C       L       R       )               r       e       q       u       i       r       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #       C       L       R       V       e       r       s       i       o       n               =               '       2       .       0       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #       R       e       q       u       i       r       e       d       M       o       d       u       l       e       s               =               @       (       '       p       s       a       k       e       '       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               A       s       s       e       m       b       l       i       e       s               t       h       a       t               m       u       s       t               b       e               l       o       a       d       e       d               p       r       i       o       r               t       o               i       m       p       o       r       t       i       n       g               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #               R       e       q       u       i       r       e       d       A       s       s       e       m       b       l       i       e       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               S       c       r       i       p       t               f       i       l       e       s               (       .       p       s       1       )               t       h       a       t               a       r       e               r       u       n               i       n               t       h       e               c       a       l       l       e       r       '       s               e       n       v       i       r       o       n       m       e       n       t               p       r       i       o       r               t       o               i       m       p       o       r       t       i       n       g               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #               S       c       r       i       p       t       s       T       o       P       r       o       c       e       s       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               T       y       p       e               f       i       l       e       s               (       .       p       s       1       x       m       l       )               t       o               b       e               l       o       a       d       e       d               w       h       e       n               i       m       p       o       r       t       i       n       g               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #               T       y       p       e       s       T       o       P       r       o       c       e       s       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               F       o       r       m       a       t               f       i       l       e       s               (       .       p       s       1       x       m       l       )               t       o               b       e               l       o       a       d       e       d               w       h       e       n               i       m       p       o       r       t       i       n       g               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #               F       o       r       m       a       t       s       T       o       P       r       o       c       e       s       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       o       d       u       l       e       s               t       o               i       m       p       o       r       t               a       s               n       e       s       t       e       d               m       o       d       u       l       e       s               o       f               t       h       e               m       o       d       u       l       e               s       p       e       c       i       f       i       e       d               i       n               M       o       d       u       l       e       T       o       P       r       o       c       e       s       s       
 
   
 
       
 
   
 
       #               N       e       s       t       e       d       M       o       d       u       l       e       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               F       u       n       c       t       i       o       n       s               t       o               e       x       p       o       r       t               f       r       o       m               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       F       u       n       c       t       i       o       n       s       T       o       E       x       p       o       r       t               =               @       (       '       I       m       p       o       r       t       -       D       e       l       i       v       e       r       y       M       o       d       u       l       e       '       ,               '       G       e       t       -       B       u       i       l       d       A       s       s       e       m       b       l       y       V       e       r       s       i       o       n       '       ,               '       R       e       g       i       s       t       e       r       -       D       e       l       i       v       e       r       y       M       o       d       u       l       e       H       o       o       k       '       ,               '       G       e       t       -       B       u       i       l       d       M       o       d       u       l       e       C       o       n       f       i       g       '       ,               '       P       u       b       l       i       s       h       -       B       u       i       l       d       A       s       s       e       t       s       '       ,               '       G       e       t       -       B       u       i       l       d       A       s       s       e       t       s       '       ,               '       P       i       p       e       l       i       n       e       '       ,               '       E       x       e       c       '       ,               '       G       e       t       -       B       u       i       l       d       O       n       S       e       r       v       e       r       '       ,               '       G       e       t       -       B       u       i       l       d       A       p       p       V       e       r       s       i       o       n       '       ,               '       G       e       t       -       B       u       i       l       d       E       n       v       i       r       o       n       m       e       n       t       '       ,               '       G       e       t       -       B       u       i       l       d       D       r       o       p       L       o       c       a       t       i       o       n       '       ,               '       G       e       t       -       B       u       i       l       d       C       h       a       n       g       e       S       e       t       '       ,               '       G       e       t       -       B       u       i       l       d       R       e       q       u       e       s       t       e       d       B       y       '       ,               '       G       e       t       -       B       u       i       l       d       T       e       a       m       P       r       o       j       e       c       t       '       ,               '       G       e       t       -       B       u       i       l       d       W       o       r       k       s       p       a       c       e       N       a       m       e       '       ,               '       G       e       t       -       B       u       i       l       d       C       o       l       l       e       c       t       i       o       n       U       r       i       '       ,               '       G       e       t       -       B       u       i       l       d       U       r       i       '       ,               '       G       e       t       -       B       u       i       l       d       N       u       m       b       e       r       '       ,               '       G       e       t       -       B       u       i       l       d       N       a       m       e       '       ,               '       G       e       t       -       B       u       i       l       d       S       e       t       t       i       n       g       '       ,               '       I       n       v       o       k       e       -       E       n       v       i       r       o       n       m       e       n       t       C       o       m       m       a       n       d       '       ,               '       I       n       v       o       k       e       -       P       o       w       e       r       d       e       l       i       v       e       r       y       '       ,               '       I       n       v       o       k       e       -       M       S       B       u       i       l       d       '       ,               '       I       n       v       o       k       e       -       M       S       T       e       s       t       '       ,               '       I       n       v       o       k       e       -       S       S       I       S       P       a       c       k       a       g       e       '       ,               '       E       n       a       b       l       e       -       S       q       l       J       o       b       s       '       ,               '       D       i       s       a       b       l       e       -       S       q       l       J       o       b       s       '       ,               '       M       o       u       n       t       -       I       f       U       N       C       '       ,               '       E       n       a       b       l       e       -       W       e       b       D       e       p       l       o       y       '       ,               '       U       p       d       a       t       e       -       A       s       s       e       m       b       l       y       I       n       f       o       F       i       l       e       s       '       ,               '       P       u       b       l       i       s       h       -       R       o       u       n       d       h       o       u       s       e       '       ,               '       R       e       m       o       v       e       -       R       o       u       n       d       h       o       u       s       e       '       ,               '       I       n       v       o       k       e       -       R       o       u       n       d       h       o       u       s       e       '       ,               '       W       r       i       t       e       -       B       u       i       l       d       S       u       m       m       a       r       y       M       e       s       s       a       g       e       '       ,               '       P       u       b       l       i       s       h       -       S       S       A       S       '       ,               '       S       e       t       -       S       S       A       S       C       o       n       n       e       c       t       i       o       n       '       ,               '       A       d       d       -       P       i       p       e       l       i       n       e       '       ,               '       N       e       w       -       R       e       m       o       t       e       S       h       a       r       e       '       ,               '       S       t       a       r       t       -       S       q       l       J       o       b       s       '       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               C       m       d       l       e       t       s               t       o               e       x       p       o       r       t               f       r       o       m               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       C       m       d       l       e       t       s       T       o       E       x       p       o       r       t               =               '       *       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               V       a       r       i       a       b       l       e       s               t       o               e       x       p       o       r       t               f       r       o       m               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       V       a       r       i       a       b       l       e       s       T       o       E       x       p       o       r       t               =               '       *       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               A       l       i       a       s       e       s               t       o               e       x       p       o       r       t               f       r       o       m               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       A       l       i       a       s       e       s       T       o       E       x       p       o       r       t               =               '       *       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       }       
 
   
 
       
 
   
 
       
 
   
 
   
 
 # 
 
 #   M o d u l e   m a n i f e s t   f o r   m o d u l e   ' P o w e r D e l i v e r y ' 
 
 @ { 
 
 M o d u l e T o P r o c e s s   =   ' P o w e r D e l i v e r y . p s m 1 ' 
 
 
 
 #   V e r s i o n   n u m b e r   o f   t h i s   m o d u l e . 
 
 M o d u l e V e r s i o n   =   ' 2 . 2 . 1 3 ' 
 
 
 
 #   I D   u s e d   t o   u n i q u e l y   i d e n t i f y   t h i s   m o d u l e 
 
 G U I D   =   ' A 5 B 8 9 5 3 6 - 5 B 8 E - 4 C 6 F - 8 F 2 2 - F 1 E A E 0 6 6 E B 4 5 ' 
 
 
 
 #   A u t h o r   o f   t h i s   m o d u l e 
 
 A u t h o r   =   ' J a y m e   C   E d w a r d s ' 
 
 
 
 #   C o m p a n y   o r   v e n d o r   o f   t h i s   m o d u l e 
 
 C o m p a n y N a m e   =   ' J a y m e   C   E d w a r d s ' 
 
 
 
 #   C o p y r i g h t   s t a t e m e n t   f o r   t h i s   m o d u l e 
 
 C o p y r i g h t   =   ' C o p y r i g h t   ( c )   2 0 1 3   J a y m e   C   E d w a r d s .   A l l   r i g h t s   r e s e r v e d . ' 
 
 
 
 #   D e s c r i p t i o n   o f   t h e   f u n c t i o n a l i t y   p r o v i d e d   b y   t h i s   m o d u l e 
 
 D e s c r i p t i o n   =   ' A l l o w s   y o u   t o   c r e a t e   a   c o n t i n u o u s   d e l i v e r y   p i p e l i n e   f o r   s o f t w a r e   p r o d u c t s   o n   T F S ' 
 
 
 
 #   M i n i m u m   v e r s i o n   o f   t h e   W i n d o w s   P o w e r S h e l l   e n g i n e   r e q u i r e d   b y   t h i s   m o d u l e 
 
 # P o w e r S h e l l V e r s i o n   =   ' 2 . 0 ' 
 
 
 
 #   M i n i m u m   v e r s i o n   o f   t h e   W i n d o w s   P o w e r S h e l l   h o s t   r e q u i r e d   b y   t h i s   m o d u l e 
 
 # P o w e r S h e l l H o s t V e r s i o n   =   ' ' 
 
 
 
 #   M i n i m u m   v e r s i o n   o f   t h e   . N E T   F r a m e w o r k   r e q u i r e d   b y   t h i s   m o d u l e 
 
 # D o t N e t F r a m e w o r k V e r s i o n   =   ' 3 . 5 ' 
 
 
 
 #   M i n i m u m   v e r s i o n   o f   t h e   c o m m o n   l a n g u a g e   r u n t i m e   ( C L R )   r e q u i r e d   b y   t h i s   m o d u l e 
 
 # C L R V e r s i o n   =   ' 2 . 0 ' 
 
 
 
 # R e q u i r e d M o d u l e s   =   @ ( ' p s a k e ' ) 
 
 
 
 #   A s s e m b l i e s   t h a t   m u s t   b e   l o a d e d   p r i o r   t o   i m p o r t i n g   t h i s   m o d u l e 
 
 #   R e q u i r e d A s s e m b l i e s   =   @ ( ) 
 
 
 
 #   S c r i p t   f i l e s   ( . p s 1 )   t h a t   a r e   r u n   i n   t h e   c a l l e r ' s   e n v i r o n m e n t   p r i o r   t o   i m p o r t i n g   t h i s   m o d u l e 
 
 #   S c r i p t s T o P r o c e s s   =   @ ( ) 
 
 
 
 #   T y p e   f i l e s   ( . p s 1 x m l )   t o   b e   l o a d e d   w h e n   i m p o r t i n g   t h i s   m o d u l e 
 
 #   T y p e s T o P r o c e s s   =   @ ( ) 
 
 
 
 #   F o r m a t   f i l e s   ( . p s 1 x m l )   t o   b e   l o a d e d   w h e n   i m p o r t i n g   t h i s   m o d u l e 
 
 #   F o r m a t s T o P r o c e s s   =   @ ( ) 
 
 
 
 #   M o d u l e s   t o   i m p o r t   a s   n e s t e d   m o d u l e s   o f   t h e   m o d u l e   s p e c i f i e d   i n   M o d u l e T o P r o c e s s 
 
 #   N e s t e d M o d u l e s   =   @ ( ) 
 
 
 
 #   F u n c t i o n s   t o   e x p o r t   f r o m   t h i s   m o d u l e 
 
 F u n c t i o n s T o E x p o r t   =   @ ( ' I m p o r t - D e l i v e r y M o d u l e ' ,   ' G e t - B u i l d A s s e m b l y V e r s i o n ' ,   ' R e g i s t e r - D e l i v e r y M o d u l e H o o k ' ,   ' G e t - B u i l d M o d u l e C o n f i g ' ,   ' P u b l i s h - B u i l d A s s e t s ' ,   ' G e t - B u i l d A s s e t s ' ,   ' P i p e l i n e ' ,   ' E x e c ' ,   ' G e t - B u i l d O n S e r v e r ' ,   ' G e t - B u i l d A p p V e r s i o n ' ,   ' G e t - B u i l d E n v i r o n m e n t ' ,   ' G e t - B u i l d D r o p L o c a t i o n ' ,   ' G e t - B u i l d C h a n g e S e t ' ,   ' G e t - B u i l d R e q u e s t e d B y ' ,   ' G e t - B u i l d T e a m P r o j e c t ' ,   ' G e t - B u i l d W o r k s p a c e N a m e ' ,   ' G e t - B u i l d C o l l e c t i o n U r i ' ,   ' G e t - B u i l d U r i ' ,   ' G e t - B u i l d N u m b e r ' ,   ' G e t - B u i l d N a m e ' ,   ' G e t - B u i l d S e t t i n g ' ,   ' I n v o k e - E n v i r o n m e n t C o m m a n d ' ,   ' I n v o k e - P o w e r d e l i v e r y ' ,   ' I n v o k e - M S B u i l d ' ,   ' I n v o k e - M S T e s t ' ,   ' I n v o k e - S S I S P a c k a g e ' ,   ' E n a b l e - S q l J o b s ' ,   ' D i s a b l e - S q l J o b s ' ,   ' M o u n t - I f U N C ' ,   ' E n a b l e - W e b D e p l o y ' ,   ' U p d a t e - A s s e m b l y I n f o F i l e s ' ,   ' P u b l i s h - R o u n d h o u s e ' ,   ' R e m o v e - R o u n d h o u s e ' ,   ' I n v o k e - R o u n d h o u s e ' ,   ' W r i t e - B u i l d S u m m a r y M e s s a g e ' ,   ' P u b l i s h - S S A S ' ,   ' S e t - S S A S C o n n e c t i o n ' ,   ' A d d - P i p e l i n e ' ,   ' N e w - R e m o t e S h a r e ' ,   ' S t a r t - S q l J o b s ' ) 
 
 
 
 #   C m d l e t s   t o   e x p o r t   f r o m   t h i s   m o d u l e 
 
 C m d l e t s T o E x p o r t   =   ' * ' 
 
 
 
 #   V a r i a b l e s   t o   e x p o r t   f r o m   t h i s   m o d u l e 
 
 V a r i a b l e s T o E x p o r t   =   ' * ' 
 
 
 
 #   A l i a s e s   t o   e x p o r t   f r o m   t h i s   m o d u l e 
 
 A l i a s e s T o E x p o r t   =   ' * ' 
 
 
 
 } #   
 
   
 
   #       M   o   d   u   l   e       m   a   n   i   f   e   s   t       f   o   r       m   o   d   u   l   e       '   P   o   w   e   r   D   e   l   i   v   e   r   y   '   
 
   
 
   @   {   
 
   
 
   M   o   d   u   l   e   T   o   P   r   o   c   e   s   s       =       '   P   o   w   e   r   D   e   l   i   v   e   r   y   .   p   s   m   1   '   
 
   
 
   
 
   
 
   #       V   e   r   s   i   o   n       n   u   m   b   e   r       o   f       t   h   i   s       m   o   d   u   l   e   .   
 
   
 
   M   o   d   u   l   e   V   e   r   s   i   o   n       =       '   2   .   2   .   1   3   '   
 
   
 
   
 
   
 
   #       I   D       u   s   e   d       t   o       u   n   i   q   u   e   l   y       i   d   e   n   t   i   f   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   G   U   I   D       =       '   A   5   B   8   9   5   3   6   -   5   B   8   E   -   4   C   6   F   -   8   F   2   2   -   F   1   E   A   E   0   6   6   E   B   4   5   '   
 
   
 
   
 
   
 
   #       A   u   t   h   o   r       o   f       t   h   i   s       m   o   d   u   l   e   
 
   
 
   A   u   t   h   o   r       =       '   J   a   y   m   e       C       E   d   w   a   r   d   s   '   
 
   
 
   
 
   
 
   #       C   o   m   p   a   n   y       o   r       v   e   n   d   o   r       o   f       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   o   m   p   a   n   y   N   a   m   e       =       '   J   a   y   m   e       C       E   d   w   a   r   d   s   '   
 
   
 
   
 
   
 
   #       C   o   p   y   r   i   g   h   t       s   t   a   t   e   m   e   n   t       f   o   r       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   o   p   y   r   i   g   h   t       =       '   C   o   p   y   r   i   g   h   t       (   c   )       2   0   1   3       J   a   y   m   e       C       E   d   w   a   r   d   s   .       A   l   l       r   i   g   h   t   s       r   e   s   e   r   v   e   d   .   '   
 
   
 
   
 
   
 
   #       D   e   s   c   r   i   p   t   i   o   n       o   f       t   h   e       f   u   n   c   t   i   o   n   a   l   i   t   y       p   r   o   v   i   d   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   D   e   s   c   r   i   p   t   i   o   n       =       '   A   l   l   o   w   s       y   o   u       t   o       c   r   e   a   t   e       a       c   o   n   t   i   n   u   o   u   s       d   e   l   i   v   e   r   y       p   i   p   e   l   i   n   e       f   o   r       s   o   f   t   w   a   r   e       p   r   o   d   u   c   t   s       o   n       T   F   S   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       W   i   n   d   o   w   s       P   o   w   e   r   S   h   e   l   l       e   n   g   i   n   e       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   P   o   w   e   r   S   h   e   l   l   V   e   r   s   i   o   n       =       '   2   .   0   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       W   i   n   d   o   w   s       P   o   w   e   r   S   h   e   l   l       h   o   s   t       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   P   o   w   e   r   S   h   e   l   l   H   o   s   t   V   e   r   s   i   o   n       =       '   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       .   N   E   T       F   r   a   m   e   w   o   r   k       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   D   o   t   N   e   t   F   r   a   m   e   w   o   r   k   V   e   r   s   i   o   n       =       '   3   .   5   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       c   o   m   m   o   n       l   a   n   g   u   a   g   e       r   u   n   t   i   m   e       (   C   L   R   )       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   C   L   R   V   e   r   s   i   o   n       =       '   2   .   0   '   
 
   
 
   
 
   
 
   #   R   e   q   u   i   r   e   d   M   o   d   u   l   e   s       =       @   (   '   p   s   a   k   e   '   )   
 
   
 
   
 
   
 
   #       A   s   s   e   m   b   l   i   e   s       t   h   a   t       m   u   s   t       b   e       l   o   a   d   e   d       p   r   i   o   r       t   o       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       R   e   q   u   i   r   e   d   A   s   s   e   m   b   l   i   e   s       =       @   (   )   
 
   
 
   
 
   
 
   #       S   c   r   i   p   t       f   i   l   e   s       (   .   p   s   1   )       t   h   a   t       a   r   e       r   u   n       i   n       t   h   e       c   a   l   l   e   r   '   s       e   n   v   i   r   o   n   m   e   n   t       p   r   i   o   r       t   o       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       S   c   r   i   p   t   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       T   y   p   e       f   i   l   e   s       (   .   p   s   1   x   m   l   )       t   o       b   e       l   o   a   d   e   d       w   h   e   n       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       T   y   p   e   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       F   o   r   m   a   t       f   i   l   e   s       (   .   p   s   1   x   m   l   )       t   o       b   e       l   o   a   d   e   d       w   h   e   n       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       F   o   r   m   a   t   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       M   o   d   u   l   e   s       t   o       i   m   p   o   r   t       a   s       n   e   s   t   e   d       m   o   d   u   l   e   s       o   f       t   h   e       m   o   d   u   l   e       s   p   e   c   i   f   i   e   d       i   n       M   o   d   u   l   e   T   o   P   r   o   c   e   s   s   
 
   
 
   #       N   e   s   t   e   d   M   o   d   u   l   e   s       =       @   (   )   
 
   
 
   
 
   
 
   #       F   u   n   c   t   i   o   n   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   F   u   n   c   t   i   o   n   s   T   o   E   x   p   o   r   t       =       @   (   '   I   m   p   o   r   t   -   D   e   l   i   v   e   r   y   M   o   d   u   l   e   '   ,       '   G   e   t   -   B   u   i   l   d   A   s   s   e   m   b   l   y   V   e   r   s   i   o   n   '   ,       '   R   e   g   i   s   t   e   r   -   D   e   l   i   v   e   r   y   M   o   d   u   l   e   H   o   o   k   '   ,       '   G   e   t   -   B   u   i   l   d   M   o   d   u   l   e   C   o   n   f   i   g   '   ,       '   P   u   b   l   i   s   h   -   B   u   i   l   d   A   s   s   e   t   s   '   ,       '   G   e   t   -   B   u   i   l   d   A   s   s   e   t   s   '   ,       '   P   i   p   e   l   i   n   e   '   ,       '   E   x   e   c   '   ,       '   G   e   t   -   B   u   i   l   d   O   n   S   e   r   v   e   r   '   ,       '   G   e   t   -   B   u   i   l   d   A   p   p   V   e   r   s   i   o   n   '   ,       '   G   e   t   -   B   u   i   l   d   E   n   v   i   r   o   n   m   e   n   t   '   ,       '   G   e   t   -   B   u   i   l   d   D   r   o   p   L   o   c   a   t   i   o   n   '   ,       '   G   e   t   -   B   u   i   l   d   C   h   a   n   g   e   S   e   t   '   ,       '   G   e   t   -   B   u   i   l   d   R   e   q   u   e   s   t   e   d   B   y   '   ,       '   G   e   t   -   B   u   i   l   d   T   e   a   m   P   r   o   j   e   c   t   '   ,       '   G   e   t   -   B   u   i   l   d   W   o   r   k   s   p   a   c   e   N   a   m   e   '   ,       '   G   e   t   -   B   u   i   l   d   C   o   l   l   e   c   t   i   o   n   U   r   i   '   ,       '   G   e   t   -   B   u   i   l   d   U   r   i   '   ,       '   G   e   t   -   B   u   i   l   d   N   u   m   b   e   r   '   ,       '   G   e   t   -   B   u   i   l   d   N   a   m   e   '   ,       '   G   e   t   -   B   u   i   l   d   S   e   t   t   i   n   g   '   ,       '   I   n   v   o   k   e   -   E   n   v   i   r   o   n   m   e   n   t   C   o   m   m   a   n   d   '   ,       '   I   n   v   o   k   e   -   P   o   w   e   r   d   e   l   i   v   e   r   y   '   ,       '   I   n   v   o   k   e   -   M   S   B   u   i   l   d   '   ,       '   I   n   v   o   k   e   -   M   S   T   e   s   t   '   ,       '   I   n   v   o   k   e   -   S   S   I   S   P   a   c   k   a   g   e   '   ,       '   E   n   a   b   l   e   -   S   q   l   J   o   b   s   '   ,       '   D   i   s   a   b   l   e   -   S   q   l   J   o   b   s   '   ,       '   M   o   u   n   t   -   I   f   U   N   C   '   ,       '   E   n   a   b   l   e   -   W   e   b   D   e   p   l   o   y   '   ,       '   U   p   d   a   t   e   -   A   s   s   e   m   b   l   y   I   n   f   o   F   i   l   e   s   '   ,       '   P   u   b   l   i   s   h   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   R   e   m   o   v   e   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   I   n   v   o   k   e   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   W   r   i   t   e   -   B   u   i   l   d   S   u   m   m   a   r   y   M   e   s   s   a   g   e   '   ,       '   P   u   b   l   i   s   h   -   S   S   A   S   '   ,       '   S   e   t   -   S   S   A   S   C   o   n   n   e   c   t   i   o   n   '   ,       '   A   d   d   -   P   i   p   e   l   i   n   e   '   ,       '   N   e   w   -   R   e   m   o   t   e   S   h   a   r   e   '   ,       '   S   t   a   r   t   -   S   q   l   J   o   b   s   '   )   
 
   
 
   
 
   
 
   #       C   m   d   l   e   t   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   m   d   l   e   t   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   #       V   a   r   i   a   b   l   e   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   V   a   r   i   a   b   l   e   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   #       A   l   i   a   s   e   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   A   l   i   a   s   e   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   }   
 
   
 
   #   
 
   
 
   #       M   o   d   u   l   e       m   a   n   i   f   e   s   t       f   o   r       m   o   d   u   l   e       '   P   o   w   e   r   D   e   l   i   v   e   r   y   '   
 
   
 
   @   {   
 
   
 
   M   o   d   u   l   e   T   o   P   r   o   c   e   s   s       =       '   P   o   w   e   r   D   e   l   i   v   e   r   y   .   p   s   m   1   '   
 
   
 
   
 
   
 
   #       V   e   r   s   i   o   n       n   u   m   b   e   r       o   f       t   h   i   s       m   o   d   u   l   e   .   
 
   
 
   M   o   d   u   l   e   V   e   r   s   i   o   n       =       '   2   .   2   .   1   3   '   
 
   
 
   
 
   
 
   #       I   D       u   s   e   d       t   o       u   n   i   q   u   e   l   y       i   d   e   n   t   i   f   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   G   U   I   D       =       '   A   5   B   8   9   5   3   6   -   5   B   8   E   -   4   C   6   F   -   8   F   2   2   -   F   1   E   A   E   0   6   6   E   B   4   5   '   
 
   
 
   
 
   
 
   #       A   u   t   h   o   r       o   f       t   h   i   s       m   o   d   u   l   e   
 
   
 
   A   u   t   h   o   r       =       '   J   a   y   m   e       C       E   d   w   a   r   d   s   '   
 
   
 
   
 
   
 
   #       C   o   m   p   a   n   y       o   r       v   e   n   d   o   r       o   f       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   o   m   p   a   n   y   N   a   m   e       =       '   J   a   y   m   e       C       E   d   w   a   r   d   s   '   
 
   
 
   
 
   
 
   #       C   o   p   y   r   i   g   h   t       s   t   a   t   e   m   e   n   t       f   o   r       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   o   p   y   r   i   g   h   t       =       '   C   o   p   y   r   i   g   h   t       (   c   )       2   0   1   3       J   a   y   m   e       C       E   d   w   a   r   d   s   .       A   l   l       r   i   g   h   t   s       r   e   s   e   r   v   e   d   .   '   
 
   
 
   
 
   
 
   #       D   e   s   c   r   i   p   t   i   o   n       o   f       t   h   e       f   u   n   c   t   i   o   n   a   l   i   t   y       p   r   o   v   i   d   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   D   e   s   c   r   i   p   t   i   o   n       =       '   A   l   l   o   w   s       y   o   u       t   o       c   r   e   a   t   e       a       c   o   n   t   i   n   u   o   u   s       d   e   l   i   v   e   r   y       p   i   p   e   l   i   n   e       f   o   r       s   o   f   t   w   a   r   e       p   r   o   d   u   c   t   s       o   n       T   F   S   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       W   i   n   d   o   w   s       P   o   w   e   r   S   h   e   l   l       e   n   g   i   n   e       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   P   o   w   e   r   S   h   e   l   l   V   e   r   s   i   o   n       =       '   2   .   0   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       W   i   n   d   o   w   s       P   o   w   e   r   S   h   e   l   l       h   o   s   t       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   P   o   w   e   r   S   h   e   l   l   H   o   s   t   V   e   r   s   i   o   n       =       '   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       .   N   E   T       F   r   a   m   e   w   o   r   k       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   D   o   t   N   e   t   F   r   a   m   e   w   o   r   k   V   e   r   s   i   o   n       =       '   3   .   5   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       c   o   m   m   o   n       l   a   n   g   u   a   g   e       r   u   n   t   i   m   e       (   C   L   R   )       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   C   L   R   V   e   r   s   i   o   n       =       '   2   .   0   '   
 
   
 
   
 
   
 
   #   R   e   q   u   i   r   e   d   M   o   d   u   l   e   s       =       @   (   '   p   s   a   k   e   '   )   
 
   
 
   
 
   
 
   #       A   s   s   e   m   b   l   i   e   s       t   h   a   t       m   u   s   t       b   e       l   o   a   d   e   d       p   r   i   o   r       t   o       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       R   e   q   u   i   r   e   d   A   s   s   e   m   b   l   i   e   s       =       @   (   )   
 
   
 
   
 
   
 
   #       S   c   r   i   p   t       f   i   l   e   s       (   .   p   s   1   )       t   h   a   t       a   r   e       r   u   n       i   n       t   h   e       c   a   l   l   e   r   '   s       e   n   v   i   r   o   n   m   e   n   t       p   r   i   o   r       t   o       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       S   c   r   i   p   t   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       T   y   p   e       f   i   l   e   s       (   .   p   s   1   x   m   l   )       t   o       b   e       l   o   a   d   e   d       w   h   e   n       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       T   y   p   e   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       F   o   r   m   a   t       f   i   l   e   s       (   .   p   s   1   x   m   l   )       t   o       b   e       l   o   a   d   e   d       w   h   e   n       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       F   o   r   m   a   t   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       M   o   d   u   l   e   s       t   o       i   m   p   o   r   t       a   s       n   e   s   t   e   d       m   o   d   u   l   e   s       o   f       t   h   e       m   o   d   u   l   e       s   p   e   c   i   f   i   e   d       i   n       M   o   d   u   l   e   T   o   P   r   o   c   e   s   s   
 
   
 
   #       N   e   s   t   e   d   M   o   d   u   l   e   s       =       @   (   )   
 
   
 
   
 
   
 
   #       F   u   n   c   t   i   o   n   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   F   u   n   c   t   i   o   n   s   T   o   E   x   p   o   r   t       =       @   (   '   I   m   p   o   r   t   -   D   e   l   i   v   e   r   y   M   o   d   u   l   e   '   ,       '   G   e   t   -   B   u   i   l   d   A   s   s   e   m   b   l   y   V   e   r   s   i   o   n   '   ,       '   R   e   g   i   s   t   e   r   -   D   e   l   i   v   e   r   y   M   o   d   u   l   e   H   o   o   k   '   ,       '   G   e   t   -   B   u   i   l   d   M   o   d   u   l   e   C   o   n   f   i   g   '   ,       '   P   u   b   l   i   s   h   -   B   u   i   l   d   A   s   s   e   t   s   '   ,       '   G   e   t   -   B   u   i   l   d   A   s   s   e   t   s   '   ,       '   P   i   p   e   l   i   n   e   '   ,       '   E   x   e   c   '   ,       '   G   e   t   -   B   u   i   l   d   O   n   S   e   r   v   e   r   '   ,       '   G   e   t   -   B   u   i   l   d   A   p   p   V   e   r   s   i   o   n   '   ,       '   G   e   t   -   B   u   i   l   d   E   n   v   i   r   o   n   m   e   n   t   '   ,       '   G   e   t   -   B   u   i   l   d   D   r   o   p   L   o   c   a   t   i   o   n   '   ,       '   G   e   t   -   B   u   i   l   d   C   h   a   n   g   e   S   e   t   '   ,       '   G   e   t   -   B   u   i   l   d   R   e   q   u   e   s   t   e   d   B   y   '   ,       '   G   e   t   -   B   u   i   l   d   T   e   a   m   P   r   o   j   e   c   t   '   ,       '   G   e   t   -   B   u   i   l   d   W   o   r   k   s   p   a   c   e   N   a   m   e   '   ,       '   G   e   t   -   B   u   i   l   d   C   o   l   l   e   c   t   i   o   n   U   r   i   '   ,       '   G   e   t   -   B   u   i   l   d   U   r   i   '   ,       '   G   e   t   -   B   u   i   l   d   N   u   m   b   e   r   '   ,       '   G   e   t   -   B   u   i   l   d   N   a   m   e   '   ,       '   G   e   t   -   B   u   i   l   d   S   e   t   t   i   n   g   '   ,       '   I   n   v   o   k   e   -   E   n   v   i   r   o   n   m   e   n   t   C   o   m   m   a   n   d   '   ,       '   I   n   v   o   k   e   -   P   o   w   e   r   d   e   l   i   v   e   r   y   '   ,       '   I   n   v   o   k   e   -   M   S   B   u   i   l   d   '   ,       '   I   n   v   o   k   e   -   M   S   T   e   s   t   '   ,       '   I   n   v   o   k   e   -   S   S   I   S   P   a   c   k   a   g   e   '   ,       '   E   n   a   b   l   e   -   S   q   l   J   o   b   s   '   ,       '   D   i   s   a   b   l   e   -   S   q   l   J   o   b   s   '   ,       '   M   o   u   n   t   -   I   f   U   N   C   '   ,       '   E   n   a   b   l   e   -   W   e   b   D   e   p   l   o   y   '   ,       '   U   p   d   a   t   e   -   A   s   s   e   m   b   l   y   I   n   f   o   F   i   l   e   s   '   ,       '   P   u   b   l   i   s   h   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   R   e   m   o   v   e   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   I   n   v   o   k   e   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   W   r   i   t   e   -   B   u   i   l   d   S   u   m   m   a   r   y   M   e   s   s   a   g   e   '   ,       '   P   u   b   l   i   s   h   -   S   S   A   S   '   ,       '   S   e   t   -   S   S   A   S   C   o   n   n   e   c   t   i   o   n   '   ,       '   A   d   d   -   P   i   p   e   l   i   n   e   '   ,       '   N   e   w   -   R   e   m   o   t   e   S   h   a   r   e   '   ,       '   S   t   a   r   t   -   S   q   l   J   o   b   s   '   )   
 
   
 
   
 
   
 
   #       C   m   d   l   e   t   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   m   d   l   e   t   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   #       V   a   r   i   a   b   l   e   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   V   a   r   i   a   b   l   e   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   #       A   l   i   a   s   e   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   A   l   i   a   s   e   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   }   #       
 
   
 
       
 
   
 
       #               M       o       d       u       l       e               m       a       n       i       f       e       s       t               f       o       r               m       o       d       u       l       e               '       P       o       w       e       r       D       e       l       i       v       e       r       y       '       
 
   
 
       
 
   
 
       @       {       
 
   
 
       
 
   
 
       M       o       d       u       l       e       T       o       P       r       o       c       e       s       s               =               '       P       o       w       e       r       D       e       l       i       v       e       r       y       .       p       s       m       1       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               V       e       r       s       i       o       n               n       u       m       b       e       r               o       f               t       h       i       s               m       o       d       u       l       e       .       
 
   
 
       
 
   
 
       M       o       d       u       l       e       V       e       r       s       i       o       n               =               '       2       .       2       .       1       3       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               I       D               u       s       e       d               t       o               u       n       i       q       u       e       l       y               i       d       e       n       t       i       f       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       G       U       I       D               =               '       A       5       B       8       9       5       3       6       -       5       B       8       E       -       4       C       6       F       -       8       F       2       2       -       F       1       E       A       E       0       6       6       E       B       4       5       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               A       u       t       h       o       r               o       f               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       A       u       t       h       o       r               =               '       J       a       y       m       e               C               E       d       w       a       r       d       s       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               C       o       m       p       a       n       y               o       r               v       e       n       d       o       r               o       f               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       C       o       m       p       a       n       y       N       a       m       e               =               '       J       a       y       m       e               C               E       d       w       a       r       d       s       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               C       o       p       y       r       i       g       h       t               s       t       a       t       e       m       e       n       t               f       o       r               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       C       o       p       y       r       i       g       h       t               =               '       C       o       p       y       r       i       g       h       t               (       c       )               2       0       1       3               J       a       y       m       e               C               E       d       w       a       r       d       s       .               A       l       l               r       i       g       h       t       s               r       e       s       e       r       v       e       d       .       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               D       e       s       c       r       i       p       t       i       o       n               o       f               t       h       e               f       u       n       c       t       i       o       n       a       l       i       t       y               p       r       o       v       i       d       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       D       e       s       c       r       i       p       t       i       o       n               =               '       A       l       l       o       w       s               y       o       u               t       o               c       r       e       a       t       e               a               c       o       n       t       i       n       u       o       u       s               d       e       l       i       v       e       r       y               p       i       p       e       l       i       n       e               f       o       r               s       o       f       t       w       a       r       e               p       r       o       d       u       c       t       s               o       n               T       F       S       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       i       n       i       m       u       m               v       e       r       s       i       o       n               o       f               t       h       e               W       i       n       d       o       w       s               P       o       w       e       r       S       h       e       l       l               e       n       g       i       n       e               r       e       q       u       i       r       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #       P       o       w       e       r       S       h       e       l       l       V       e       r       s       i       o       n               =               '       2       .       0       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       i       n       i       m       u       m               v       e       r       s       i       o       n               o       f               t       h       e               W       i       n       d       o       w       s               P       o       w       e       r       S       h       e       l       l               h       o       s       t               r       e       q       u       i       r       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #       P       o       w       e       r       S       h       e       l       l       H       o       s       t       V       e       r       s       i       o       n               =               '       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       i       n       i       m       u       m               v       e       r       s       i       o       n               o       f               t       h       e               .       N       E       T               F       r       a       m       e       w       o       r       k               r       e       q       u       i       r       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #       D       o       t       N       e       t       F       r       a       m       e       w       o       r       k       V       e       r       s       i       o       n               =               '       3       .       5       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       i       n       i       m       u       m               v       e       r       s       i       o       n               o       f               t       h       e               c       o       m       m       o       n               l       a       n       g       u       a       g       e               r       u       n       t       i       m       e               (       C       L       R       )               r       e       q       u       i       r       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #       C       L       R       V       e       r       s       i       o       n               =               '       2       .       0       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #       R       e       q       u       i       r       e       d       M       o       d       u       l       e       s               =               @       (       '       p       s       a       k       e       '       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               A       s       s       e       m       b       l       i       e       s               t       h       a       t               m       u       s       t               b       e               l       o       a       d       e       d               p       r       i       o       r               t       o               i       m       p       o       r       t       i       n       g               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #               R       e       q       u       i       r       e       d       A       s       s       e       m       b       l       i       e       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               S       c       r       i       p       t               f       i       l       e       s               (       .       p       s       1       )               t       h       a       t               a       r       e               r       u       n               i       n               t       h       e               c       a       l       l       e       r       '       s               e       n       v       i       r       o       n       m       e       n       t               p       r       i       o       r               t       o               i       m       p       o       r       t       i       n       g               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #               S       c       r       i       p       t       s       T       o       P       r       o       c       e       s       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               T       y       p       e               f       i       l       e       s               (       .       p       s       1       x       m       l       )               t       o               b       e               l       o       a       d       e       d               w       h       e       n               i       m       p       o       r       t       i       n       g               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #               T       y       p       e       s       T       o       P       r       o       c       e       s       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               F       o       r       m       a       t               f       i       l       e       s               (       .       p       s       1       x       m       l       )               t       o               b       e               l       o       a       d       e       d               w       h       e       n               i       m       p       o       r       t       i       n       g               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #               F       o       r       m       a       t       s       T       o       P       r       o       c       e       s       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       o       d       u       l       e       s               t       o               i       m       p       o       r       t               a       s               n       e       s       t       e       d               m       o       d       u       l       e       s               o       f               t       h       e               m       o       d       u       l       e               s       p       e       c       i       f       i       e       d               i       n               M       o       d       u       l       e       T       o       P       r       o       c       e       s       s       
 
   
 
       
 
   
 
       #               N       e       s       t       e       d       M       o       d       u       l       e       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               F       u       n       c       t       i       o       n       s               t       o               e       x       p       o       r       t               f       r       o       m               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       F       u       n       c       t       i       o       n       s       T       o       E       x       p       o       r       t               =               @       (       '       I       m       p       o       r       t       -       D       e       l       i       v       e       r       y       M       o       d       u       l       e       '       ,               '       G       e       t       -       B       u       i       l       d       A       s       s       e       m       b       l       y       V       e       r       s       i       o       n       '       ,               '       R       e       g       i       s       t       e       r       -       D       e       l       i       v       e       r       y       M       o       d       u       l       e       H       o       o       k       '       ,               '       G       e       t       -       B       u       i       l       d       M       o       d       u       l       e       C       o       n       f       i       g       '       ,               '       P       u       b       l       i       s       h       -       B       u       i       l       d       A       s       s       e       t       s       '       ,               '       G       e       t       -       B       u       i       l       d       A       s       s       e       t       s       '       ,               '       P       i       p       e       l       i       n       e       '       ,               '       E       x       e       c       '       ,               '       G       e       t       -       B       u       i       l       d       O       n       S       e       r       v       e       r       '       ,               '       G       e       t       -       B       u       i       l       d       A       p       p       V       e       r       s       i       o       n       '       ,               '       G       e       t       -       B       u       i       l       d       E       n       v       i       r       o       n       m       e       n       t       '       ,               '       G       e       t       -       B       u       i       l       d       D       r       o       p       L       o       c       a       t       i       o       n       '       ,               '       G       e       t       -       B       u       i       l       d       C       h       a       n       g       e       S       e       t       '       ,               '       G       e       t       -       B       u       i       l       d       R       e       q       u       e       s       t       e       d       B       y       '       ,               '       G       e       t       -       B       u       i       l       d       T       e       a       m       P       r       o       j       e       c       t       '       ,               '       G       e       t       -       B       u       i       l       d       W       o       r       k       s       p       a       c       e       N       a       m       e       '       ,               '       G       e       t       -       B       u       i       l       d       C       o       l       l       e       c       t       i       o       n       U       r       i       '       ,               '       G       e       t       -       B       u       i       l       d       U       r       i       '       ,               '       G       e       t       -       B       u       i       l       d       N       u       m       b       e       r       '       ,               '       G       e       t       -       B       u       i       l       d       N       a       m       e       '       ,               '       G       e       t       -       B       u       i       l       d       S       e       t       t       i       n       g       '       ,               '       I       n       v       o       k       e       -       E       n       v       i       r       o       n       m       e       n       t       C       o       m       m       a       n       d       '       ,               '       I       n       v       o       k       e       -       P       o       w       e       r       d       e       l       i       v       e       r       y       '       ,               '       I       n       v       o       k       e       -       M       S       B       u       i       l       d       '       ,               '       I       n       v       o       k       e       -       M       S       T       e       s       t       '       ,               '       I       n       v       o       k       e       -       S       S       I       S       P       a       c       k       a       g       e       '       ,               '       E       n       a       b       l       e       -       S       q       l       J       o       b       s       '       ,               '       D       i       s       a       b       l       e       -       S       q       l       J       o       b       s       '       ,               '       M       o       u       n       t       -       I       f       U       N       C       '       ,               '       E       n       a       b       l       e       -       W       e       b       D       e       p       l       o       y       '       ,               '       U       p       d       a       t       e       -       A       s       s       e       m       b       l       y       I       n       f       o       F       i       l       e       s       '       ,               '       P       u       b       l       i       s       h       -       R       o       u       n       d       h       o       u       s       e       '       ,               '       R       e       m       o       v       e       -       R       o       u       n       d       h       o       u       s       e       '       ,               '       I       n       v       o       k       e       -       R       o       u       n       d       h       o       u       s       e       '       ,               '       W       r       i       t       e       -       B       u       i       l       d       S       u       m       m       a       r       y       M       e       s       s       a       g       e       '       ,               '       P       u       b       l       i       s       h       -       S       S       A       S       '       ,               '       S       e       t       -       S       S       A       S       C       o       n       n       e       c       t       i       o       n       '       ,               '       A       d       d       -       P       i       p       e       l       i       n       e       '       ,               '       N       e       w       -       R       e       m       o       t       e       S       h       a       r       e       '       ,               '       S       t       a       r       t       -       S       q       l       J       o       b       s       '       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               C       m       d       l       e       t       s               t       o               e       x       p       o       r       t               f       r       o       m               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       C       m       d       l       e       t       s       T       o       E       x       p       o       r       t               =               '       *       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               V       a       r       i       a       b       l       e       s               t       o               e       x       p       o       r       t               f       r       o       m               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       V       a       r       i       a       b       l       e       s       T       o       E       x       p       o       r       t               =               '       *       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               A       l       i       a       s       e       s               t       o               e       x       p       o       r       t               f       r       o       m               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       A       l       i       a       s       e       s       T       o       E       x       p       o       r       t               =               '       *       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       }       
 
   
 
       
 
   
 
       
 
   
 
   #   
 
   
 
   #       M   o   d   u   l   e       m   a   n   i   f   e   s   t       f   o   r       m   o   d   u   l   e       '   P   o   w   e   r   D   e   l   i   v   e   r   y   '   
 
   
 
   @   {   
 
   
 
   M   o   d   u   l   e   T   o   P   r   o   c   e   s   s       =       '   P   o   w   e   r   D   e   l   i   v   e   r   y   .   p   s   m   1   '   
 
   
 
   
 
   
 
   #       V   e   r   s   i   o   n       n   u   m   b   e   r       o   f       t   h   i   s       m   o   d   u   l   e   .   
 
   
 
   M   o   d   u   l   e   V   e   r   s   i   o   n       =       '   2   .   2   .   1   3   '   
 
   
 
   
 
   
 
   #       I   D       u   s   e   d       t   o       u   n   i   q   u   e   l   y       i   d   e   n   t   i   f   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   G   U   I   D       =       '   A   5   B   8   9   5   3   6   -   5   B   8   E   -   4   C   6   F   -   8   F   2   2   -   F   1   E   A   E   0   6   6   E   B   4   5   '   
 
   
 
   
 
   
 
   #       A   u   t   h   o   r       o   f       t   h   i   s       m   o   d   u   l   e   
 
   
 
   A   u   t   h   o   r       =       '   J   a   y   m   e       C       E   d   w   a   r   d   s   '   
 
   
 
   
 
   
 
   #       C   o   m   p   a   n   y       o   r       v   e   n   d   o   r       o   f       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   o   m   p   a   n   y   N   a   m   e       =       '   J   a   y   m   e       C       E   d   w   a   r   d   s   '   
 
   
 
   
 
   
 
   #       C   o   p   y   r   i   g   h   t       s   t   a   t   e   m   e   n   t       f   o   r       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   o   p   y   r   i   g   h   t       =       '   C   o   p   y   r   i   g   h   t       (   c   )       2   0   1   3       J   a   y   m   e       C       E   d   w   a   r   d   s   .       A   l   l       r   i   g   h   t   s       r   e   s   e   r   v   e   d   .   '   
 
   
 
   
 
   
 
   #       D   e   s   c   r   i   p   t   i   o   n       o   f       t   h   e       f   u   n   c   t   i   o   n   a   l   i   t   y       p   r   o   v   i   d   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   D   e   s   c   r   i   p   t   i   o   n       =       '   A   l   l   o   w   s       y   o   u       t   o       c   r   e   a   t   e       a       c   o   n   t   i   n   u   o   u   s       d   e   l   i   v   e   r   y       p   i   p   e   l   i   n   e       f   o   r       s   o   f   t   w   a   r   e       p   r   o   d   u   c   t   s       o   n       T   F   S   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       W   i   n   d   o   w   s       P   o   w   e   r   S   h   e   l   l       e   n   g   i   n   e       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   P   o   w   e   r   S   h   e   l   l   V   e   r   s   i   o   n       =       '   2   .   0   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       W   i   n   d   o   w   s       P   o   w   e   r   S   h   e   l   l       h   o   s   t       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   P   o   w   e   r   S   h   e   l   l   H   o   s   t   V   e   r   s   i   o   n       =       '   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       .   N   E   T       F   r   a   m   e   w   o   r   k       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   D   o   t   N   e   t   F   r   a   m   e   w   o   r   k   V   e   r   s   i   o   n       =       '   3   .   5   '   
 
   
 
   
 
   
 
   #       M   i   n   i   m   u   m       v   e   r   s   i   o   n       o   f       t   h   e       c   o   m   m   o   n       l   a   n   g   u   a   g   e       r   u   n   t   i   m   e       (   C   L   R   )       r   e   q   u   i   r   e   d       b   y       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #   C   L   R   V   e   r   s   i   o   n       =       '   2   .   0   '   
 
   
 
   
 
   
 
   #   R   e   q   u   i   r   e   d   M   o   d   u   l   e   s       =       @   (   '   p   s   a   k   e   '   )   
 
   
 
   
 
   
 
   #       A   s   s   e   m   b   l   i   e   s       t   h   a   t       m   u   s   t       b   e       l   o   a   d   e   d       p   r   i   o   r       t   o       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       R   e   q   u   i   r   e   d   A   s   s   e   m   b   l   i   e   s       =       @   (   )   
 
   
 
   
 
   
 
   #       S   c   r   i   p   t       f   i   l   e   s       (   .   p   s   1   )       t   h   a   t       a   r   e       r   u   n       i   n       t   h   e       c   a   l   l   e   r   '   s       e   n   v   i   r   o   n   m   e   n   t       p   r   i   o   r       t   o       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       S   c   r   i   p   t   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       T   y   p   e       f   i   l   e   s       (   .   p   s   1   x   m   l   )       t   o       b   e       l   o   a   d   e   d       w   h   e   n       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       T   y   p   e   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       F   o   r   m   a   t       f   i   l   e   s       (   .   p   s   1   x   m   l   )       t   o       b   e       l   o   a   d   e   d       w   h   e   n       i   m   p   o   r   t   i   n   g       t   h   i   s       m   o   d   u   l   e   
 
   
 
   #       F   o   r   m   a   t   s   T   o   P   r   o   c   e   s   s       =       @   (   )   
 
   
 
   
 
   
 
   #       M   o   d   u   l   e   s       t   o       i   m   p   o   r   t       a   s       n   e   s   t   e   d       m   o   d   u   l   e   s       o   f       t   h   e       m   o   d   u   l   e       s   p   e   c   i   f   i   e   d       i   n       M   o   d   u   l   e   T   o   P   r   o   c   e   s   s   
 
   
 
   #       N   e   s   t   e   d   M   o   d   u   l   e   s       =       @   (   )   
 
   
 
   
 
   
 
   #       F   u   n   c   t   i   o   n   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   F   u   n   c   t   i   o   n   s   T   o   E   x   p   o   r   t       =       @   (   '   I   m   p   o   r   t   -   D   e   l   i   v   e   r   y   M   o   d   u   l   e   '   ,       '   G   e   t   -   B   u   i   l   d   A   s   s   e   m   b   l   y   V   e   r   s   i   o   n   '   ,       '   R   e   g   i   s   t   e   r   -   D   e   l   i   v   e   r   y   M   o   d   u   l   e   H   o   o   k   '   ,       '   G   e   t   -   B   u   i   l   d   M   o   d   u   l   e   C   o   n   f   i   g   '   ,       '   P   u   b   l   i   s   h   -   B   u   i   l   d   A   s   s   e   t   s   '   ,       '   G   e   t   -   B   u   i   l   d   A   s   s   e   t   s   '   ,       '   P   i   p   e   l   i   n   e   '   ,       '   E   x   e   c   '   ,       '   G   e   t   -   B   u   i   l   d   O   n   S   e   r   v   e   r   '   ,       '   G   e   t   -   B   u   i   l   d   A   p   p   V   e   r   s   i   o   n   '   ,       '   G   e   t   -   B   u   i   l   d   E   n   v   i   r   o   n   m   e   n   t   '   ,       '   G   e   t   -   B   u   i   l   d   D   r   o   p   L   o   c   a   t   i   o   n   '   ,       '   G   e   t   -   B   u   i   l   d   C   h   a   n   g   e   S   e   t   '   ,       '   G   e   t   -   B   u   i   l   d   R   e   q   u   e   s   t   e   d   B   y   '   ,       '   G   e   t   -   B   u   i   l   d   T   e   a   m   P   r   o   j   e   c   t   '   ,       '   G   e   t   -   B   u   i   l   d   W   o   r   k   s   p   a   c   e   N   a   m   e   '   ,       '   G   e   t   -   B   u   i   l   d   C   o   l   l   e   c   t   i   o   n   U   r   i   '   ,       '   G   e   t   -   B   u   i   l   d   U   r   i   '   ,       '   G   e   t   -   B   u   i   l   d   N   u   m   b   e   r   '   ,       '   G   e   t   -   B   u   i   l   d   N   a   m   e   '   ,       '   G   e   t   -   B   u   i   l   d   S   e   t   t   i   n   g   '   ,       '   I   n   v   o   k   e   -   E   n   v   i   r   o   n   m   e   n   t   C   o   m   m   a   n   d   '   ,       '   I   n   v   o   k   e   -   P   o   w   e   r   d   e   l   i   v   e   r   y   '   ,       '   I   n   v   o   k   e   -   M   S   B   u   i   l   d   '   ,       '   I   n   v   o   k   e   -   M   S   T   e   s   t   '   ,       '   I   n   v   o   k   e   -   S   S   I   S   P   a   c   k   a   g   e   '   ,       '   E   n   a   b   l   e   -   S   q   l   J   o   b   s   '   ,       '   D   i   s   a   b   l   e   -   S   q   l   J   o   b   s   '   ,       '   M   o   u   n   t   -   I   f   U   N   C   '   ,       '   E   n   a   b   l   e   -   W   e   b   D   e   p   l   o   y   '   ,       '   U   p   d   a   t   e   -   A   s   s   e   m   b   l   y   I   n   f   o   F   i   l   e   s   '   ,       '   P   u   b   l   i   s   h   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   R   e   m   o   v   e   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   I   n   v   o   k   e   -   R   o   u   n   d   h   o   u   s   e   '   ,       '   W   r   i   t   e   -   B   u   i   l   d   S   u   m   m   a   r   y   M   e   s   s   a   g   e   '   ,       '   P   u   b   l   i   s   h   -   S   S   A   S   '   ,       '   S   e   t   -   S   S   A   S   C   o   n   n   e   c   t   i   o   n   '   ,       '   A   d   d   -   P   i   p   e   l   i   n   e   '   ,       '   N   e   w   -   R   e   m   o   t   e   S   h   a   r   e   '   ,       '   S   t   a   r   t   -   S   q   l   J   o   b   s   '   )   
 
   
 
   
 
   
 
   #       C   m   d   l   e   t   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   C   m   d   l   e   t   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   #       V   a   r   i   a   b   l   e   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   V   a   r   i   a   b   l   e   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   #       A   l   i   a   s   e   s       t   o       e   x   p   o   r   t       f   r   o   m       t   h   i   s       m   o   d   u   l   e   
 
   
 
   A   l   i   a   s   e   s   T   o   E   x   p   o   r   t       =       '   *   '   
 
   
 
   
 
   
 
   }   #       
 
   
 
       
 
   
 
       #               M       o       d       u       l       e               m       a       n       i       f       e       s       t               f       o       r               m       o       d       u       l       e               '       P       o       w       e       r       D       e       l       i       v       e       r       y       '       
 
   
 
       
 
   
 
       @       {       
 
   
 
       
 
   
 
       M       o       d       u       l       e       T       o       P       r       o       c       e       s       s               =               '       P       o       w       e       r       D       e       l       i       v       e       r       y       .       p       s       m       1       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               V       e       r       s       i       o       n               n       u       m       b       e       r               o       f               t       h       i       s               m       o       d       u       l       e       .       
 
   
 
       
 
   
 
       M       o       d       u       l       e       V       e       r       s       i       o       n               =               '       2       .       2       .       1       3       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               I       D               u       s       e       d               t       o               u       n       i       q       u       e       l       y               i       d       e       n       t       i       f       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       G       U       I       D               =               '       A       5       B       8       9       5       3       6       -       5       B       8       E       -       4       C       6       F       -       8       F       2       2       -       F       1       E       A       E       0       6       6       E       B       4       5       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               A       u       t       h       o       r               o       f               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       A       u       t       h       o       r               =               '       J       a       y       m       e               C               E       d       w       a       r       d       s       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               C       o       m       p       a       n       y               o       r               v       e       n       d       o       r               o       f               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       C       o       m       p       a       n       y       N       a       m       e               =               '       J       a       y       m       e               C               E       d       w       a       r       d       s       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               C       o       p       y       r       i       g       h       t               s       t       a       t       e       m       e       n       t               f       o       r               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       C       o       p       y       r       i       g       h       t               =               '       C       o       p       y       r       i       g       h       t               (       c       )               2       0       1       3               J       a       y       m       e               C               E       d       w       a       r       d       s       .               A       l       l               r       i       g       h       t       s               r       e       s       e       r       v       e       d       .       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               D       e       s       c       r       i       p       t       i       o       n               o       f               t       h       e               f       u       n       c       t       i       o       n       a       l       i       t       y               p       r       o       v       i       d       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       D       e       s       c       r       i       p       t       i       o       n               =               '       A       l       l       o       w       s               y       o       u               t       o               c       r       e       a       t       e               a               c       o       n       t       i       n       u       o       u       s               d       e       l       i       v       e       r       y               p       i       p       e       l       i       n       e               f       o       r               s       o       f       t       w       a       r       e               p       r       o       d       u       c       t       s               o       n               T       F       S       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       i       n       i       m       u       m               v       e       r       s       i       o       n               o       f               t       h       e               W       i       n       d       o       w       s               P       o       w       e       r       S       h       e       l       l               e       n       g       i       n       e               r       e       q       u       i       r       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #       P       o       w       e       r       S       h       e       l       l       V       e       r       s       i       o       n               =               '       2       .       0       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       i       n       i       m       u       m               v       e       r       s       i       o       n               o       f               t       h       e               W       i       n       d       o       w       s               P       o       w       e       r       S       h       e       l       l               h       o       s       t               r       e       q       u       i       r       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #       P       o       w       e       r       S       h       e       l       l       H       o       s       t       V       e       r       s       i       o       n               =               '       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       i       n       i       m       u       m               v       e       r       s       i       o       n               o       f               t       h       e               .       N       E       T               F       r       a       m       e       w       o       r       k               r       e       q       u       i       r       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #       D       o       t       N       e       t       F       r       a       m       e       w       o       r       k       V       e       r       s       i       o       n               =               '       3       .       5       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       i       n       i       m       u       m               v       e       r       s       i       o       n               o       f               t       h       e               c       o       m       m       o       n               l       a       n       g       u       a       g       e               r       u       n       t       i       m       e               (       C       L       R       )               r       e       q       u       i       r       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #       C       L       R       V       e       r       s       i       o       n               =               '       2       .       0       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #       R       e       q       u       i       r       e       d       M       o       d       u       l       e       s               =               @       (       '       p       s       a       k       e       '       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               A       s       s       e       m       b       l       i       e       s               t       h       a       t               m       u       s       t               b       e               l       o       a       d       e       d               p       r       i       o       r               t       o               i       m       p       o       r       t       i       n       g               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #               R       e       q       u       i       r       e       d       A       s       s       e       m       b       l       i       e       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               S       c       r       i       p       t               f       i       l       e       s               (       .       p       s       1       )               t       h       a       t               a       r       e               r       u       n               i       n               t       h       e               c       a       l       l       e       r       '       s               e       n       v       i       r       o       n       m       e       n       t               p       r       i       o       r               t       o               i       m       p       o       r       t       i       n       g               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #               S       c       r       i       p       t       s       T       o       P       r       o       c       e       s       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               T       y       p       e               f       i       l       e       s               (       .       p       s       1       x       m       l       )               t       o               b       e               l       o       a       d       e       d               w       h       e       n               i       m       p       o       r       t       i       n       g               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #               T       y       p       e       s       T       o       P       r       o       c       e       s       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               F       o       r       m       a       t               f       i       l       e       s               (       .       p       s       1       x       m       l       )               t       o               b       e               l       o       a       d       e       d               w       h       e       n               i       m       p       o       r       t       i       n       g               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #               F       o       r       m       a       t       s       T       o       P       r       o       c       e       s       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       o       d       u       l       e       s               t       o               i       m       p       o       r       t               a       s               n       e       s       t       e       d               m       o       d       u       l       e       s               o       f               t       h       e               m       o       d       u       l       e               s       p       e       c       i       f       i       e       d               i       n               M       o       d       u       l       e       T       o       P       r       o       c       e       s       s       
 
   
 
       
 
   
 
       #               N       e       s       t       e       d       M       o       d       u       l       e       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               F       u       n       c       t       i       o       n       s               t       o               e       x       p       o       r       t               f       r       o       m               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       F       u       n       c       t       i       o       n       s       T       o       E       x       p       o       r       t               =               @       (       '       I       m       p       o       r       t       -       D       e       l       i       v       e       r       y       M       o       d       u       l       e       '       ,               '       G       e       t       -       B       u       i       l       d       A       s       s       e       m       b       l       y       V       e       r       s       i       o       n       '       ,               '       R       e       g       i       s       t       e       r       -       D       e       l       i       v       e       r       y       M       o       d       u       l       e       H       o       o       k       '       ,               '       G       e       t       -       B       u       i       l       d       M       o       d       u       l       e       C       o       n       f       i       g       '       ,               '       P       u       b       l       i       s       h       -       B       u       i       l       d       A       s       s       e       t       s       '       ,               '       G       e       t       -       B       u       i       l       d       A       s       s       e       t       s       '       ,               '       P       i       p       e       l       i       n       e       '       ,               '       E       x       e       c       '       ,               '       G       e       t       -       B       u       i       l       d       O       n       S       e       r       v       e       r       '       ,               '       G       e       t       -       B       u       i       l       d       A       p       p       V       e       r       s       i       o       n       '       ,               '       G       e       t       -       B       u       i       l       d       E       n       v       i       r       o       n       m       e       n       t       '       ,               '       G       e       t       -       B       u       i       l       d       D       r       o       p       L       o       c       a       t       i       o       n       '       ,               '       G       e       t       -       B       u       i       l       d       C       h       a       n       g       e       S       e       t       '       ,               '       G       e       t       -       B       u       i       l       d       R       e       q       u       e       s       t       e       d       B       y       '       ,               '       G       e       t       -       B       u       i       l       d       T       e       a       m       P       r       o       j       e       c       t       '       ,               '       G       e       t       -       B       u       i       l       d       W       o       r       k       s       p       a       c       e       N       a       m       e       '       ,               '       G       e       t       -       B       u       i       l       d       C       o       l       l       e       c       t       i       o       n       U       r       i       '       ,               '       G       e       t       -       B       u       i       l       d       U       r       i       '       ,               '       G       e       t       -       B       u       i       l       d       N       u       m       b       e       r       '       ,               '       G       e       t       -       B       u       i       l       d       N       a       m       e       '       ,               '       G       e       t       -       B       u       i       l       d       S       e       t       t       i       n       g       '       ,               '       I       n       v       o       k       e       -       E       n       v       i       r       o       n       m       e       n       t       C       o       m       m       a       n       d       '       ,               '       I       n       v       o       k       e       -       P       o       w       e       r       d       e       l       i       v       e       r       y       '       ,               '       I       n       v       o       k       e       -       M       S       B       u       i       l       d       '       ,               '       I       n       v       o       k       e       -       M       S       T       e       s       t       '       ,               '       I       n       v       o       k       e       -       S       S       I       S       P       a       c       k       a       g       e       '       ,               '       E       n       a       b       l       e       -       S       q       l       J       o       b       s       '       ,               '       D       i       s       a       b       l       e       -       S       q       l       J       o       b       s       '       ,               '       M       o       u       n       t       -       I       f       U       N       C       '       ,               '       E       n       a       b       l       e       -       W       e       b       D       e       p       l       o       y       '       ,               '       U       p       d       a       t       e       -       A       s       s       e       m       b       l       y       I       n       f       o       F       i       l       e       s       '       ,               '       P       u       b       l       i       s       h       -       R       o       u       n       d       h       o       u       s       e       '       ,               '       R       e       m       o       v       e       -       R       o       u       n       d       h       o       u       s       e       '       ,               '       I       n       v       o       k       e       -       R       o       u       n       d       h       o       u       s       e       '       ,               '       W       r       i       t       e       -       B       u       i       l       d       S       u       m       m       a       r       y       M       e       s       s       a       g       e       '       ,               '       P       u       b       l       i       s       h       -       S       S       A       S       '       ,               '       S       e       t       -       S       S       A       S       C       o       n       n       e       c       t       i       o       n       '       ,               '       A       d       d       -       P       i       p       e       l       i       n       e       '       ,               '       N       e       w       -       R       e       m       o       t       e       S       h       a       r       e       '       ,               '       S       t       a       r       t       -       S       q       l       J       o       b       s       '       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               C       m       d       l       e       t       s               t       o               e       x       p       o       r       t               f       r       o       m               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       C       m       d       l       e       t       s       T       o       E       x       p       o       r       t               =               '       *       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               V       a       r       i       a       b       l       e       s               t       o               e       x       p       o       r       t               f       r       o       m               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       V       a       r       i       a       b       l       e       s       T       o       E       x       p       o       r       t               =               '       *       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               A       l       i       a       s       e       s               t       o               e       x       p       o       r       t               f       r       o       m               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       A       l       i       a       s       e       s       T       o       E       x       p       o       r       t               =               '       *       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       }       
 
   
 
       
 
   
 
       #       
 
   
 
       
 
   
 
       #               M       o       d       u       l       e               m       a       n       i       f       e       s       t               f       o       r               m       o       d       u       l       e               '       P       o       w       e       r       D       e       l       i       v       e       r       y       '       
 
   
 
       
 
   
 
       @       {       
 
   
 
       
 
   
 
       M       o       d       u       l       e       T       o       P       r       o       c       e       s       s               =               '       P       o       w       e       r       D       e       l       i       v       e       r       y       .       p       s       m       1       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               V       e       r       s       i       o       n               n       u       m       b       e       r               o       f               t       h       i       s               m       o       d       u       l       e       .       
 
   
 
       
 
   
 
       M       o       d       u       l       e       V       e       r       s       i       o       n               =               '       2       .       2       .       1       3       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               I       D               u       s       e       d               t       o               u       n       i       q       u       e       l       y               i       d       e       n       t       i       f       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       G       U       I       D               =               '       A       5       B       8       9       5       3       6       -       5       B       8       E       -       4       C       6       F       -       8       F       2       2       -       F       1       E       A       E       0       6       6       E       B       4       5       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               A       u       t       h       o       r               o       f               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       A       u       t       h       o       r               =               '       J       a       y       m       e               C               E       d       w       a       r       d       s       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               C       o       m       p       a       n       y               o       r               v       e       n       d       o       r               o       f               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       C       o       m       p       a       n       y       N       a       m       e               =               '       J       a       y       m       e               C               E       d       w       a       r       d       s       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               C       o       p       y       r       i       g       h       t               s       t       a       t       e       m       e       n       t               f       o       r               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       C       o       p       y       r       i       g       h       t               =               '       C       o       p       y       r       i       g       h       t               (       c       )               2       0       1       3               J       a       y       m       e               C               E       d       w       a       r       d       s       .               A       l       l               r       i       g       h       t       s               r       e       s       e       r       v       e       d       .       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               D       e       s       c       r       i       p       t       i       o       n               o       f               t       h       e               f       u       n       c       t       i       o       n       a       l       i       t       y               p       r       o       v       i       d       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       D       e       s       c       r       i       p       t       i       o       n               =               '       A       l       l       o       w       s               y       o       u               t       o               c       r       e       a       t       e               a               c       o       n       t       i       n       u       o       u       s               d       e       l       i       v       e       r       y               p       i       p       e       l       i       n       e               f       o       r               s       o       f       t       w       a       r       e               p       r       o       d       u       c       t       s               o       n               T       F       S       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       i       n       i       m       u       m               v       e       r       s       i       o       n               o       f               t       h       e               W       i       n       d       o       w       s               P       o       w       e       r       S       h       e       l       l               e       n       g       i       n       e               r       e       q       u       i       r       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #       P       o       w       e       r       S       h       e       l       l       V       e       r       s       i       o       n               =               '       2       .       0       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       i       n       i       m       u       m               v       e       r       s       i       o       n               o       f               t       h       e               W       i       n       d       o       w       s               P       o       w       e       r       S       h       e       l       l               h       o       s       t               r       e       q       u       i       r       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #       P       o       w       e       r       S       h       e       l       l       H       o       s       t       V       e       r       s       i       o       n               =               '       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       i       n       i       m       u       m               v       e       r       s       i       o       n               o       f               t       h       e               .       N       E       T               F       r       a       m       e       w       o       r       k               r       e       q       u       i       r       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #       D       o       t       N       e       t       F       r       a       m       e       w       o       r       k       V       e       r       s       i       o       n               =               '       3       .       5       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       i       n       i       m       u       m               v       e       r       s       i       o       n               o       f               t       h       e               c       o       m       m       o       n               l       a       n       g       u       a       g       e               r       u       n       t       i       m       e               (       C       L       R       )               r       e       q       u       i       r       e       d               b       y               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #       C       L       R       V       e       r       s       i       o       n               =               '       2       .       0       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #       R       e       q       u       i       r       e       d       M       o       d       u       l       e       s               =               @       (       '       p       s       a       k       e       '       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               A       s       s       e       m       b       l       i       e       s               t       h       a       t               m       u       s       t               b       e               l       o       a       d       e       d               p       r       i       o       r               t       o               i       m       p       o       r       t       i       n       g               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #               R       e       q       u       i       r       e       d       A       s       s       e       m       b       l       i       e       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               S       c       r       i       p       t               f       i       l       e       s               (       .       p       s       1       )               t       h       a       t               a       r       e               r       u       n               i       n               t       h       e               c       a       l       l       e       r       '       s               e       n       v       i       r       o       n       m       e       n       t               p       r       i       o       r               t       o               i       m       p       o       r       t       i       n       g               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #               S       c       r       i       p       t       s       T       o       P       r       o       c       e       s       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               T       y       p       e               f       i       l       e       s               (       .       p       s       1       x       m       l       )               t       o               b       e               l       o       a       d       e       d               w       h       e       n               i       m       p       o       r       t       i       n       g               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #               T       y       p       e       s       T       o       P       r       o       c       e       s       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               F       o       r       m       a       t               f       i       l       e       s               (       .       p       s       1       x       m       l       )               t       o               b       e               l       o       a       d       e       d               w       h       e       n               i       m       p       o       r       t       i       n       g               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       #               F       o       r       m       a       t       s       T       o       P       r       o       c       e       s       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               M       o       d       u       l       e       s               t       o               i       m       p       o       r       t               a       s               n       e       s       t       e       d               m       o       d       u       l       e       s               o       f               t       h       e               m       o       d       u       l       e               s       p       e       c       i       f       i       e       d               i       n               M       o       d       u       l       e       T       o       P       r       o       c       e       s       s       
 
   
 
       
 
   
 
       #               N       e       s       t       e       d       M       o       d       u       l       e       s               =               @       (       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               F       u       n       c       t       i       o       n       s               t       o               e       x       p       o       r       t               f       r       o       m               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       F       u       n       c       t       i       o       n       s       T       o       E       x       p       o       r       t               =               @       (       '       I       m       p       o       r       t       -       D       e       l       i       v       e       r       y       M       o       d       u       l       e       '       ,               '       G       e       t       -       B       u       i       l       d       A       s       s       e       m       b       l       y       V       e       r       s       i       o       n       '       ,               '       R       e       g       i       s       t       e       r       -       D       e       l       i       v       e       r       y       M       o       d       u       l       e       H       o       o       k       '       ,               '       G       e       t       -       B       u       i       l       d       M       o       d       u       l       e       C       o       n       f       i       g       '       ,               '       P       u       b       l       i       s       h       -       B       u       i       l       d       A       s       s       e       t       s       '       ,               '       G       e       t       -       B       u       i       l       d       A       s       s       e       t       s       '       ,               '       P       i       p       e       l       i       n       e       '       ,               '       E       x       e       c       '       ,               '       G       e       t       -       B       u       i       l       d       O       n       S       e       r       v       e       r       '       ,               '       G       e       t       -       B       u       i       l       d       A       p       p       V       e       r       s       i       o       n       '       ,               '       G       e       t       -       B       u       i       l       d       E       n       v       i       r       o       n       m       e       n       t       '       ,               '       G       e       t       -       B       u       i       l       d       D       r       o       p       L       o       c       a       t       i       o       n       '       ,               '       G       e       t       -       B       u       i       l       d       C       h       a       n       g       e       S       e       t       '       ,               '       G       e       t       -       B       u       i       l       d       R       e       q       u       e       s       t       e       d       B       y       '       ,               '       G       e       t       -       B       u       i       l       d       T       e       a       m       P       r       o       j       e       c       t       '       ,               '       G       e       t       -       B       u       i       l       d       W       o       r       k       s       p       a       c       e       N       a       m       e       '       ,               '       G       e       t       -       B       u       i       l       d       C       o       l       l       e       c       t       i       o       n       U       r       i       '       ,               '       G       e       t       -       B       u       i       l       d       U       r       i       '       ,               '       G       e       t       -       B       u       i       l       d       N       u       m       b       e       r       '       ,               '       G       e       t       -       B       u       i       l       d       N       a       m       e       '       ,               '       G       e       t       -       B       u       i       l       d       S       e       t       t       i       n       g       '       ,               '       I       n       v       o       k       e       -       E       n       v       i       r       o       n       m       e       n       t       C       o       m       m       a       n       d       '       ,               '       I       n       v       o       k       e       -       P       o       w       e       r       d       e       l       i       v       e       r       y       '       ,               '       I       n       v       o       k       e       -       M       S       B       u       i       l       d       '       ,               '       I       n       v       o       k       e       -       M       S       T       e       s       t       '       ,               '       I       n       v       o       k       e       -       S       S       I       S       P       a       c       k       a       g       e       '       ,               '       E       n       a       b       l       e       -       S       q       l       J       o       b       s       '       ,               '       D       i       s       a       b       l       e       -       S       q       l       J       o       b       s       '       ,               '       M       o       u       n       t       -       I       f       U       N       C       '       ,               '       E       n       a       b       l       e       -       W       e       b       D       e       p       l       o       y       '       ,               '       U       p       d       a       t       e       -       A       s       s       e       m       b       l       y       I       n       f       o       F       i       l       e       s       '       ,               '       P       u       b       l       i       s       h       -       R       o       u       n       d       h       o       u       s       e       '       ,               '       R       e       m       o       v       e       -       R       o       u       n       d       h       o       u       s       e       '       ,               '       I       n       v       o       k       e       -       R       o       u       n       d       h       o       u       s       e       '       ,               '       W       r       i       t       e       -       B       u       i       l       d       S       u       m       m       a       r       y       M       e       s       s       a       g       e       '       ,               '       P       u       b       l       i       s       h       -       S       S       A       S       '       ,               '       S       e       t       -       S       S       A       S       C       o       n       n       e       c       t       i       o       n       '       ,               '       A       d       d       -       P       i       p       e       l       i       n       e       '       ,               '       N       e       w       -       R       e       m       o       t       e       S       h       a       r       e       '       ,               '       S       t       a       r       t       -       S       q       l       J       o       b       s       '       )       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               C       m       d       l       e       t       s               t       o               e       x       p       o       r       t               f       r       o       m               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       C       m       d       l       e       t       s       T       o       E       x       p       o       r       t               =               '       *       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               V       a       r       i       a       b       l       e       s               t       o               e       x       p       o       r       t               f       r       o       m               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       V       a       r       i       a       b       l       e       s       T       o       E       x       p       o       r       t               =               '       *       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       #               A       l       i       a       s       e       s               t       o               e       x       p       o       r       t               f       r       o       m               t       h       i       s               m       o       d       u       l       e       
 
   
 
       
 
   
 
       A       l       i       a       s       e       s       T       o       E       x       p       o       r       t               =               '       *       '       
 
   
 
       
 
   
 
       
 
   
 
       
 
   
 
       }       #               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               M               o               d               u               l               e                               m               a               n               i               f               e               s               t                               f               o               r                               m               o               d               u               l               e                               '               P               o               w               e               r               D               e               l               i               v               e               r               y               '               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               @               {               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               M               o               d               u               l               e               T               o               P               r               o               c               e               s               s                               =                               '               P               o               w               e               r               D               e               l               i               v               e               r               y               .               p               s               m               1               '               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               V               e               r               s               i               o               n                               n               u               m               b               e               r                               o               f                               t               h               i               s                               m               o               d               u               l               e               .               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               M               o               d               u               l               e               V               e               r               s               i               o               n                               =                               '               2               .               2               .               1               3               '               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               I               D                               u               s               e               d                               t               o                               u               n               i               q               u               e               l               y                               i               d               e               n               t               i               f               y                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               G               U               I               D                               =                               '               A               5               B               8               9               5               3               6               -               5               B               8               E               -               4               C               6               F               -               8               F               2               2               -               F               1               E               A               E               0               6               6               E               B               4               5               '               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               A               u               t               h               o               r                               o               f                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               A               u               t               h               o               r                               =                               '               J               a               y               m               e                               C                               E               d               w               a               r               d               s               '               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               C               o               m               p               a               n               y                               o               r                               v               e               n               d               o               r                               o               f                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               C               o               m               p               a               n               y               N               a               m               e                               =                               '               J               a               y               m               e                               C                               E               d               w               a               r               d               s               '               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               C               o               p               y               r               i               g               h               t                               s               t               a               t               e               m               e               n               t                               f               o               r                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               C               o               p               y               r               i               g               h               t                               =                               '               C               o               p               y               r               i               g               h               t                               (               c               )                               2               0               1               3                               J               a               y               m               e                               C                               E               d               w               a               r               d               s               .                               A               l               l                               r               i               g               h               t               s                               r               e               s               e               r               v               e               d               .               '               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               D               e               s               c               r               i               p               t               i               o               n                               o               f                               t               h               e                               f               u               n               c               t               i               o               n               a               l               i               t               y                               p               r               o               v               i               d               e               d                               b               y                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               D               e               s               c               r               i               p               t               i               o               n                               =                               '               A               l               l               o               w               s                               y               o               u                               t               o                               c               r               e               a               t               e                               a                               c               o               n               t               i               n               u               o               u               s                               d               e               l               i               v               e               r               y                               p               i               p               e               l               i               n               e                               f               o               r                               s               o               f               t               w               a               r               e                               p               r               o               d               u               c               t               s                               o               n                               T               F               S               '               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               M               i               n               i               m               u               m                               v               e               r               s               i               o               n                               o               f                               t               h               e                               W               i               n               d               o               w               s                               P               o               w               e               r               S               h               e               l               l                               e               n               g               i               n               e                               r               e               q               u               i               r               e               d                               b               y                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #               P               o               w               e               r               S               h               e               l               l               V               e               r               s               i               o               n                               =                               '               2               .               0               '               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               M               i               n               i               m               u               m                               v               e               r               s               i               o               n                               o               f                               t               h               e                               W               i               n               d               o               w               s                               P               o               w               e               r               S               h               e               l               l                               h               o               s               t                               r               e               q               u               i               r               e               d                               b               y                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #               P               o               w               e               r               S               h               e               l               l               H               o               s               t               V               e               r               s               i               o               n                               =                               '               '               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               M               i               n               i               m               u               m                               v               e               r               s               i               o               n                               o               f                               t               h               e                               .               N               E               T                               F               r               a               m               e               w               o               r               k                               r               e               q               u               i               r               e               d                               b               y                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #               D               o               t               N               e               t               F               r               a               m               e               w               o               r               k               V               e               r               s               i               o               n                               =                               '               3               .               5               '               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               M               i               n               i               m               u               m                               v               e               r               s               i               o               n                               o               f                               t               h               e                               c               o               m               m               o               n                               l               a               n               g               u               a               g               e                               r               u               n               t               i               m               e                               (               C               L               R               )                               r               e               q               u               i               r               e               d                               b               y                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #               C               L               R               V               e               r               s               i               o               n                               =                               '               2               .               0               '               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #               R               e               q               u               i               r               e               d               M               o               d               u               l               e               s                               =                               @               (               '               p               s               a               k               e               '               )               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               A               s               s               e               m               b               l               i               e               s                               t               h               a               t                               m               u               s               t                               b               e                               l               o               a               d               e               d                               p               r               i               o               r                               t               o                               i               m               p               o               r               t               i               n               g                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               R               e               q               u               i               r               e               d               A               s               s               e               m               b               l               i               e               s                               =                               @               (               )               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               S               c               r               i               p               t                               f               i               l               e               s                               (               .               p               s               1               )                               t               h               a               t                               a               r               e                               r               u               n                               i               n                               t               h               e                               c               a               l               l               e               r               '               s                               e               n               v               i               r               o               n               m               e               n               t                               p               r               i               o               r                               t               o                               i               m               p               o               r               t               i               n               g                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               S               c               r               i               p               t               s               T               o               P               r               o               c               e               s               s                               =                               @               (               )               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               T               y               p               e                               f               i               l               e               s                               (               .               p               s               1               x               m               l               )                               t               o                               b               e                               l               o               a               d               e               d                               w               h               e               n                               i               m               p               o               r               t               i               n               g                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               T               y               p               e               s               T               o               P               r               o               c               e               s               s                               =                               @               (               )               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               F               o               r               m               a               t                               f               i               l               e               s                               (               .               p               s               1               x               m               l               )                               t               o                               b               e                               l               o               a               d               e               d                               w               h               e               n                               i               m               p               o               r               t               i               n               g                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               F               o               r               m               a               t               s               T               o               P               r               o               c               e               s               s                               =                               @               (               )               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               M               o               d               u               l               e               s                               t               o                               i               m               p               o               r               t                               a               s                               n               e               s               t               e               d                               m               o               d               u               l               e               s                               o               f                               t               h               e                               m               o               d               u               l               e                               s               p               e               c               i               f               i               e               d                               i               n                               M               o               d               u               l               e               T               o               P               r               o               c               e               s               s               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               N               e               s               t               e               d               M               o               d               u               l               e               s                               =                               @               (               )               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               F               u               n               c               t               i               o               n               s                               t               o                               e               x               p               o               r               t                               f               r               o               m                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               F               u               n               c               t               i               o               n               s               T               o               E               x               p               o               r               t                               =                               @               (               '               I               m               p               o               r               t               -               D               e               l               i               v               e               r               y               M               o               d               u               l               e               '               ,                               '               G               e               t               -               B               u               i               l               d               A               s               s               e               m               b               l               y               V               e               r               s               i               o               n               '               ,                               '               R               e               g               i               s               t               e               r               -               D               e               l               i               v               e               r               y               M               o               d               u               l               e               H               o               o               k               '               ,                               '               G               e               t               -               B               u               i               l               d               M               o               d               u               l               e               C               o               n               f               i               g               '               ,                               '               P               u               b               l               i               s               h               -               B               u               i               l               d               A               s               s               e               t               s               '               ,                               '               G               e               t               -               B               u               i               l               d               A               s               s               e               t               s               '               ,                               '               P               i               p               e               l               i               n               e               '               ,                               '               E               x               e               c               '               ,                               '               G               e               t               -               B               u               i               l               d               O               n               S               e               r               v               e               r               '               ,                               '               G               e               t               -               B               u               i               l               d               A               p               p               V               e               r               s               i               o               n               '               ,                               '               G               e               t               -               B               u               i               l               d               E               n               v               i               r               o               n               m               e               n               t               '               ,                               '               G               e               t               -               B               u               i               l               d               D               r               o               p               L               o               c               a               t               i               o               n               '               ,                               '               G               e               t               -               B               u               i               l               d               C               h               a               n               g               e               S               e               t               '               ,                               '               G               e               t               -               B               u               i               l               d               R               e               q               u               e               s               t               e               d               B               y               '               ,                               '               G               e               t               -               B               u               i               l               d               T               e               a               m               P               r               o               j               e               c               t               '               ,                               '               G               e               t               -               B               u               i               l               d               W               o               r               k               s               p               a               c               e               N               a               m               e               '               ,                               '               G               e               t               -               B               u               i               l               d               C               o               l               l               e               c               t               i               o               n               U               r               i               '               ,                               '               G               e               t               -               B               u               i               l               d               U               r               i               '               ,                               '               G               e               t               -               B               u               i               l               d               N               u               m               b               e               r               '               ,                               '               G               e               t               -               B               u               i               l               d               N               a               m               e               '               ,                               '               G               e               t               -               B               u               i               l               d               S               e               t               t               i               n               g               '               ,                               '               I               n               v               o               k               e               -               E               n               v               i               r               o               n               m               e               n               t               C               o               m               m               a               n               d               '               ,                               '               I               n               v               o               k               e               -               P               o               w               e               r               d               e               l               i               v               e               r               y               '               ,                               '               I               n               v               o               k               e               -               M               S               B               u               i               l               d               '               ,                               '               I               n               v               o               k               e               -               M               S               T               e               s               t               '               ,                               '               I               n               v               o               k               e               -               S               S               I               S               P               a               c               k               a               g               e               '               ,                               '               E               n               a               b               l               e               -               S               q               l               J               o               b               s               '               ,                               '               D               i               s               a               b               l               e               -               S               q               l               J               o               b               s               '               ,                               '               M               o               u               n               t               -               I               f               U               N               C               '               ,                               '               E               n               a               b               l               e               -               W               e               b               D               e               p               l               o               y               '               ,                               '               U               p               d               a               t               e               -               A               s               s               e               m               b               l               y               I               n               f               o               F               i               l               e               s               '               ,                               '               P               u               b               l               i               s               h               -               R               o               u               n               d               h               o               u               s               e               '               ,                               '               R               e               m               o               v               e               -               R               o               u               n               d               h               o               u               s               e               '               ,                               '               I               n               v               o               k               e               -               R               o               u               n               d               h               o               u               s               e               '               ,                               '               W               r               i               t               e               -               B               u               i               l               d               S               u               m               m               a               r               y               M               e               s               s               a               g               e               '               ,                               '               P               u               b               l               i               s               h               -               S               S               A               S               '               ,                               '               S               e               t               -               S               S               A               S               C               o               n               n               e               c               t               i               o               n               '               ,                               '               A               d               d               -               P               i               p               e               l               i               n               e               '               ,                               '               N               e               w               -               R               e               m               o               t               e               S               h               a               r               e               '               ,                               '               S               t               a               r               t               -               S               q               l               J               o               b               s               '               )               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               C               m               d               l               e               t               s                               t               o                               e               x               p               o               r               t                               f               r               o               m                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               C               m               d               l               e               t               s               T               o               E               x               p               o               r               t                               =                               '               *               '               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               V               a               r               i               a               b               l               e               s                               t               o                               e               x               p               o               r               t                               f               r               o               m                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               V               a               r               i               a               b               l               e               s               T               o               E               x               p               o               r               t                               =                               '               *               '               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               #                               A               l               i               a               s               e               s                               t               o                               e               x               p               o               r               t                               f               r               o               m                               t               h               i               s                               m               o               d               u               l               e               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               A               l               i               a               s               e               s               T               o               E               x               p               o               r               t                               =                               '               *               '               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               }               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
               
 
   
 
       
 
   
 
       
 
   
 
   
 
 
