using System;
using System.Xml.Serialization;

namespace PowerDeliveryClient
{
    [XmlType(TypeName="Source")]
    public class ClientCollectionSource
    {
        [XmlAttribute(AttributeName="Uri")]
        public string Uri { get; set; }
    }
}