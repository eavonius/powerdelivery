// Guids.cs
// MUST match guids.h
using System;

namespace JaymeEdwards.PowerDeliveryVSExtension
{
    static class GuidList
    {
        public const string guidPowerDeliveryVSExtensionPkgString = "E4D8E826-0144-4775-B7BA-1FA37BE8EB74";
        public const string guidPowerDeliveryVSExtensionCmdSetString = "52D785F8-8BB4-461B-91B1-C4CC080A8B9F";
        public const string guidToolWindowPersistanceString = "AA04DD9D-3ECE-4500-A860-43060A47B312";

        public static readonly Guid guidPowerDeliveryVSExtensionCmdSet = new Guid(guidPowerDeliveryVSExtensionCmdSetString);
    };
}