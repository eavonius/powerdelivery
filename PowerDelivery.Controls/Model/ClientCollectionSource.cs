using System;
using System.Linq;
using System.Xml.Serialization;

using Microsoft.TeamFoundation.Client;
using Microsoft.TeamFoundation.Framework.Common;
using Microsoft.TeamFoundation.Build.Client;
using Microsoft.TeamFoundation.Server;
using System.Collections.Generic;
using Microsoft.TeamFoundation.Build.Workflow;
using Microsoft.TeamFoundation.VersionControl.Client;

namespace PowerDelivery.Controls.Model
{
    [XmlType(TypeName="Source")]
    public class ClientCollectionSource
    {
        [XmlAttribute(AttributeName="Uri")]
        public string Uri { get; set; }

        [XmlIgnore]
        public string Name { get; private set; }

        [XmlIgnore]
        public IBuildServer BuildServer { get; private set; }

        [XmlIgnore]
        public TfsTeamProjectCollection ProjectCollection { get; private set; }

        [XmlIgnore]
        public ICommonStructureService CommonStructureService { get; private set; }

        [XmlIgnore]
        public IRegistration Registration { get; private set; }

        [XmlIgnore]
        public VersionControlServer VersionControlServer { get; private set; }

        [XmlIgnore]
        public int TfsVersion { get; private set; }

        [XmlIgnore]
        public TswaClientHyperlinkService ClientHyperlinkService { get; private set; }

        public IList<DeliveryPipeline> GetPipelines()
        {
            IList<DeliveryPipeline> pipelines = new List<DeliveryPipeline>();

            Uri collectionUri = new Uri(Uri);
            ProjectCollection = new TfsTeamProjectCollection(collectionUri);

            BuildServer = ProjectCollection.GetService<IBuildServer>();
            CommonStructureService = ProjectCollection.GetService<ICommonStructureService>();
            Registration = ProjectCollection.GetService<IRegistration>();
            VersionControlServer = ProjectCollection.GetService<VersionControlServer>();
            ClientHyperlinkService = ProjectCollection.GetService<TswaClientHyperlinkService>();

            Name = ProjectCollection.CatalogNode.Resource.DisplayName;

            if (BuildServer.BuildServerVersion.ToString() == "v3") {
                TfsVersion = 2010;
            }
            else {
                TfsVersion = 2012;
            }

            foreach (ProjectInfo project in CommonStructureService.ListProjects())
            {
                foreach (IBuildDefinition definition in BuildServer.QueryBuildDefinitions(project.Name))
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
                                pipeline = new DeliveryPipeline(this, project, scriptName);
                                pipelines.Add(pipeline);
                            }

                            PipelineEnvironment environment = new PipelineEnvironment(pipeline, environmentName, definition);

                            pipeline.Environments.Add(environment);
                        }
                    }
                }
            }

            return pipelines;
        }

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