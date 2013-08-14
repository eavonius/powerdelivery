// Guids.cs
// MUST match guids.h
using System;

namespace JaymeEdwards.PowerDeliveryVSExtension
{
    static class GuidList
    {
        public const string guidPowerDeliveryVSExtensionPkgString = "8d0861c8-1688-40be-bdcd-cffa25e18d40";
        public const string guidPowerDeliveryVSExtensionCmdSetString = "8b9b38ad-aeab-4c25-82ee-47943c13dcf8";
        public const string guidToolWindowPersistanceString = "0d6fe536-bcb5-4172-8d20-b47f9d0f1989";

        public static readonly Guid guidPowerDeliveryVSExtensionCmdSet = new Guid(guidPowerDeliveryVSExtensionCmdSetString);
    };
}