using System;

namespace PowerDelivery.Controls.Model
{
    public class DeliveryModule
    {
        public DeliveryModule() { }

        public DeliveryModule(string name, string version)
        {
            Name = name.Substring(0, name.IndexOf("DeliveryModule"));
            Version = version;
        }

        public string Name { get; private set; }
        public string Version { get; private set; }
    }
}