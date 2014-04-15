// Guids.cs
// MUST match guids.h
using System;

namespace JaymeEdwards.PowerDeliveryVSExtension2013
{
    static class GuidList
    {
        public const string guidPowerDeliveryVSExtension2013PkgString = "9c6c2f23-b97a-4797-86c1-08f94e0e4300";
        public const string guidPowerDeliveryVSExtension2013CmdSetString = "249f012b-e0c8-4a3c-ae14-c6b7ffadee0d";
        public const string guidToolWindowPersistanceString = "428E4E9C-0A4D-4583-92D6-A6E8C25AF756";

        public static readonly Guid guidPowerDeliveryVSExtension2013CmdSet = new Guid(guidPowerDeliveryVSExtension2013CmdSetString);
    };
}