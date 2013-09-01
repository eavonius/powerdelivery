using System;
using System.Xml;
using System.Xml.Serialization;
using System.IO;
using System.IO.IsolatedStorage;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Windows;

using Microsoft.TeamFoundation.Client;
using Microsoft.TeamFoundation.Build.Client;
using Microsoft.TeamFoundation.Server;
using Microsoft.TeamFoundation.Build.Workflow;
using Microsoft.TeamFoundation.Framework.Common;

using System.Diagnostics;
using System.Reflection;
using System.ComponentModel;

namespace PowerDelivery.Controls.Model
{
    [XmlRoot(ElementName="Configuration")]
    public class ClientConfiguration : INotifyPropertyChanged
    {
        [NonSerialized]
        bool loadedPipelines = false;

        [NonSerialized]
        const string FILE_PATH = @"client_configuration";

        [NonSerialized]
        static ClientConfiguration _configuration;

        [XmlIgnore]
        ClientInfo _info;

        public event PropertyChangedEventHandler PropertyChanged;

        [XmlIgnore]
        List<ClientCollectionSource> _sources = new List<ClientCollectionSource>();

        [XmlIgnore]
        List<DeliveryPipeline> _pipelines = new List<DeliveryPipeline>();

        [XmlIgnore]
        public ClientInfo ClientInfo
        {
            get
            {
                if (_info == null)
                {
                    ClientInfo = new ClientInfo();
                }
                return _info;
            }

            private set
            {
                _info = value;

                OnPropertyChanged("ClientInfo");
            }
        }

        [XmlIgnore]
        public bool IsInVisualStudio
        {
            get 
            {
                return Process.GetCurrentProcess().MainModule.FileName.Contains("devenv.exe");
            }
        }

        [XmlIgnore]
        public List<DeliveryPipeline> Pipelines
        {
            get
            {
                if (!loadedPipelines)
                {
                    RefreshSources();

                    loadedPipelines = true;
                }

                return _pipelines;
            }

            set
            {
                _pipelines = value;

                OnPropertyChanged("Pipelines");
            }
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

        [XmlArray(ElementName = "Sources")]
        public List<ClientCollectionSource> Sources 
        {
            get { return _sources; }
            set { _sources = value; OnPropertyChanged("Sources"); }
        }

        public static ClientConfiguration Current
        {
            get
            {
                if (_configuration == null)
                {
                    Reload();
                }
                return _configuration;
            }
        }

        public static void Reload()
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

        public void RefreshSources()
        {
            List<DeliveryPipeline> pipelines = new List<DeliveryPipeline>();

            foreach (ClientCollectionSource source in Sources)
            {
                try
                {
                    IList<DeliveryPipeline> sourcePipelines = source.GetPipelines();

                    if (sourcePipelines.Count > 0) {
                        pipelines.AddRange(sourcePipelines);
                    }
                }
                catch (Exception) { }
            }

            Pipelines = pipelines;
        }

        public void StartPolling()
        {
            foreach (DeliveryPipeline pipeline in Pipelines)
            {
                pipeline.StartPolling();
            }
        }

        public void StopPolling()
        {
            foreach (DeliveryPipeline pipeline in Pipelines)
            {
                pipeline.StopPolling();
            }
        }

        protected void OnPropertyChanged(string propertyName)
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
            }
        }
    }
}