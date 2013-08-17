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

namespace PowerDelivery.Controls.Model
{
    [XmlRoot(ElementName="Configuration")]
    public class ClientConfiguration : DependencyObject
    {
        [NonSerialized]
        bool loadedPipelines = false;

        [NonSerialized]
        const string FILE_PATH = @"client_configuration";

        [NonSerialized]
        static ClientConfiguration _configuration;

        [XmlIgnore]
        ClientInfo _info;

        public static DependencyProperty PipelinesProperty = DependencyProperty.Register(
            "Pipelines", typeof(List<DeliveryPipeline>), typeof(ClientConfiguration),
            new PropertyMetadata(new List<DeliveryPipeline>()));

        public ClientConfiguration()
        {
            Sources = new List<ClientCollectionSource>();
        }

        [XmlIgnore]
        public ClientInfo ClientInfo
        {
            get
            {
                if (_info == null)
                {
                    _info = new ClientInfo();
                }
                return _info;
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

                return (List<DeliveryPipeline>)GetValue(PipelinesProperty);
            }

            set
            {
                SetValue(PipelinesProperty, value);
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
        public List<ClientCollectionSource> Sources { get; set; }

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
                Uri collectionUri = null;

                TfsTeamProjectCollection collection = null;

                try
                {
                    collectionUri = new Uri(source.Uri);
                    collection = new TfsTeamProjectCollection(collectionUri);

                    IBuildServer buildServer = collection.GetService<IBuildServer>();
                    ICommonStructureService commonStructure = collection.GetService<ICommonStructureService>();

                    source.Name = collection.CatalogNode.Resource.DisplayName;

                    foreach (ProjectInfo project in commonStructure.ListProjects())
                    {
                        foreach (IBuildDefinition definition in buildServer.QueryBuildDefinitions(project.Name))
                        {
                            if (definition.Process.ServerPath.Contains("BuildProcessTemplates/PowerDelivery"))
                            {
                                IDictionary<string, object> processParams = WorkflowHelpers.DeserializeProcessParameters(definition.ProcessParameters);

                                if (processParams.ContainsKey("PowerShellScriptPath"))
                                {
                                    string scriptPath = processParams["PowerShellScriptPath"] as string;

                                    string scriptName = System.IO.Path.GetFileNameWithoutExtension(scriptPath.Substring(scriptPath.LastIndexOf("/")));

                                    string environmentName = definition.Name.Substring(definition.Name.LastIndexOf(" - ") + 3);

                                    DeliveryPipeline pipeline = pipelines.FirstOrDefault(p => p.ScriptName == scriptName);

                                    if (pipeline == null)
                                    {
                                        pipeline = new DeliveryPipeline(source, project.Name, collection.Name, scriptName);
                                        pipelines.Add(pipeline);
                                    }

                                    PipelineEnvironment environment = new PipelineEnvironment(pipeline, environmentName, definition);

                                    pipeline.Environments.Add(environment);
                                }
                            }
                        }
                    }
                }
                catch (Exception) { }

                Pipelines = pipelines;
            }
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
    }
}