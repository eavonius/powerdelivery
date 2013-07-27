using System;
using System.Xml;
using System.Xml.Serialization;
using System.IO;
using System.IO.IsolatedStorage;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using Microsoft.TeamFoundation.Client;
using Microsoft.TeamFoundation.Build.Client;
using Microsoft.TeamFoundation.Server;
using Microsoft.TeamFoundation.Build.Workflow;

namespace PowerDelivery.Controls
{
    [XmlRoot(ElementName="Configuration")]
    public class ClientConfiguration : DependencyObject
    {
        [NonSerialized]
        const string FILE_PATH = @"client_configuration";

        [NonSerialized]
        static ClientConfiguration _configuration;

        public static DependencyProperty PipelinesProperty = DependencyProperty.Register(
            "Pipelines", typeof(List<DeliveryPipeline>), typeof(ClientConfiguration),
            new PropertyMetadata(new List<DeliveryPipeline>()));

        public ClientConfiguration()
        {
            Sources = new List<ClientCollectionSource>();
        }

        [XmlIgnore]
        public List<DeliveryPipeline> Pipelines
        {
            get
            {
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

                        _configuration.Refresh();
                    }
                }
                return _configuration;
            }
        }

        public void Refresh()
        {
            List<DeliveryPipeline> pipelines = new List<DeliveryPipeline>();

            foreach (ClientCollectionSource source in ClientConfiguration.Current.Sources)
            {
                Uri collectionUri = null;

                TfsTeamProjectCollection collection = null;

                try
                {
                    collectionUri = new Uri(source.Uri);
                    collection = new TfsTeamProjectCollection(collectionUri);

                    IBuildServer buildServer = collection.GetService<IBuildServer>();
                    ICommonStructureService commonStructure = collection.GetService<ICommonStructureService>();

                    foreach (ProjectInfo project in commonStructure.ListProjects())
                    {
                        foreach (IBuildDefinition definition in buildServer.QueryBuildDefinitions(project.Name))
                        {
                            if (definition.Process.ServerPath.Contains("BuildProcessTemplates/PowerDelivery"))
                            {
                                DeliveryPipeline pipeline = pipelines.FirstOrDefault(p => p.ProjectName == project.Name);

                                string environmentName = definition.Name.Substring(definition.Name.LastIndexOf(" - ") + 3);

                                IDictionary<string, object> processParams = WorkflowHelpers.DeserializeProcessParameters(definition.ProcessParameters);

                                if (processParams.ContainsKey("PowerShellScriptPath"))
                                {
                                    string scriptPath = processParams["PowerShellScriptPath"] as string;

                                    string scriptName = System.IO.Path.GetFileNameWithoutExtension(scriptPath.Substring(scriptPath.LastIndexOf("/")));

                                    if (pipeline == null)
                                    {
                                        pipeline = new DeliveryPipeline(source, project.Name, collection.Name, scriptName);
                                        pipelines.Add(pipeline);
                                    }

                                    PipelineEnvironmentBuildStatus lastBuildStatus = new PipelineEnvironmentBuildStatus(BuildStatus.None);
                                    string lastBuildNumber = "";
                                    DateTime lastBuildFinishTime = DateTime.MinValue;

                                    if (definition.LastBuildUri != null)
                                    {
                                        try
                                        {
                                            IBuildDetail lastBuild = buildServer.GetBuild(definition.LastBuildUri);
                                            lastBuildStatus = new PipelineEnvironmentBuildStatus(lastBuild.Status);
                                            lastBuildFinishTime = lastBuild.FinishTime;
                                            lastBuildNumber = definition.LastBuildUri.ToString().Substring(definition.LastBuildUri.ToString().LastIndexOf("/") + 1);
                                        }
                                        catch (Exception)
                                        {
                                        }
                                    }

                                    PipelineEnvironment environment = new PipelineEnvironment(pipeline, environmentName, lastBuildStatus, lastBuildNumber, lastBuildFinishTime);

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
    }
}
