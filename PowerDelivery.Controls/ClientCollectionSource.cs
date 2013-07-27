using System;
using System.Xml.Serialization;

namespace PowerDelivery.Controls
{
    [XmlType(TypeName="Source")]
    public class ClientCollectionSource
    {
        
        [XmlAttribute(AttributeName="Uri")]
        public string Uri { get; set; }
    }
}