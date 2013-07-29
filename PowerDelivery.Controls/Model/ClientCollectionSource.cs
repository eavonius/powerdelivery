using System;
using System.Xml.Serialization;

using Microsoft.TeamFoundation.Client;
using Microsoft.TeamFoundation.Framework.Common;

namespace PowerDelivery.Controls.Model
{
    [XmlType(TypeName="Source")]
    public class ClientCollectionSource
    {
        [XmlAttribute(AttributeName="Uri")]
        public string Uri { get; set; }

        public void Save()
        {
            Uri collectionUri = null;
            TfsTeamProjectCollection collection = null;

            try
            {
                collectionUri = new Uri(Uri);
                collection = new TfsTeamProjectCollection(collectionUri);
            }
            catch (Exception)
            {
                throw new Exception("Invalid URL, please enter a valid URL to a TFS Project Collection.");
            }

            try
            {
                collection.Connect(ConnectOptions.IncludeServices);

                if (!ClientConfiguration.Current.Sources.Contains(this))
                {
                    ClientConfiguration.Current.Sources.Add(this);
                }

                ClientConfiguration.Current.Save();
            }
            catch (Exception ex)
            {
                throw new Exception(string.Format("Unable to connect to TFS, error message was:\n\n{0}", ex.Message));
            }
        }
    }
}