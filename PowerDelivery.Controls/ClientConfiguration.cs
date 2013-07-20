using System;
using System.Xml;
using System.Xml.Serialization;
using System.IO;
using System.IO.IsolatedStorage;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PowerDelivery.Controls
{
    [XmlRoot(ElementName="Configuration")]
    public class ClientConfiguration
    {
        [NonSerialized]
        const string FILE_PATH = @"client_configuration";

        [NonSerialized]
        static ClientConfiguration _configuration;

        public ClientConfiguration()
        {
            Sources = new List<ClientCollectionSource>();
        }

        public void Save()
        {
            using (IsolatedStorageFile file = IsolatedStorageFile.GetUserStoreForAssembly())
            {
                XmlSerializer serializer = new XmlSerializer(typeof(ClientConfiguration));

                using (IsolatedStorageFileStream stream = file.OpenFile(FILE_PATH, FileMode.OpenOrCreate))
                {
                    serializer.Serialize(stream, this);

                    stream.Flush();
                }
            }
        }

        [XmlArray(ElementName="Sources")]
        public List<ClientCollectionSource> Sources { get; set; }

        public static ClientConfiguration Current
        {
            get
            {
                if (_configuration == null)
                {
                    using (IsolatedStorageFile file = IsolatedStorageFile.GetUserStoreForAssembly())
                    {
                        if (file.FileExists(FILE_PATH))
                        {
                            XmlSerializer serializer = new XmlSerializer(typeof(ClientConfiguration));

                            using (IsolatedStorageFileStream stream = file.OpenFile(FILE_PATH, FileMode.Open))
                            {
                                try
                                {
                                    _configuration = (ClientConfiguration)serializer.Deserialize(stream);
                                }
                                catch (Exception)
                                {
                                    stream.Close();

                                    file.DeleteFile(FILE_PATH);

                                    _configuration = new ClientConfiguration();
                                }
                            }
                        }
                        else
                        {
                            _configuration = new ClientConfiguration();
                        }
                    }
                }
                return _configuration;
            }
        }
    }
}
