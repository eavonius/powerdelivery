using Microsoft.TeamFoundation.Client;
using Microsoft.TeamFoundation.Server;
using Microsoft.TeamFoundation.VersionControl.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;
using System.Windows;

namespace PowerDelivery.Controls
{
    public class DeliveryPipeline
    {
        public DeliveryPipeline(ClientCollectionSource source, string projectName, string collectionName, string scriptName)
        {
            Source = source;
            ProjectName = projectName;
            CollectionName = collectionName;
            ScriptName = scriptName;
        }

        public ClientCollectionSource Source { get; private set; }
        public string ProjectName { get; private set; }
        public string CollectionName { get; private set; }
        public string ScriptName { get; private set; }

        public PipelineEnvironment Commit { get; internal set; }
        public PipelineEnvironment Test { get; internal set; }
        public PipelineEnvironment CapacityTest { get; internal set; }
        public PipelineEnvironment Production { get; internal set; }

        public string GetWorkingDirectory()
        {
            string localDirectory = null;

            Uri collectionUri = null;
            TfsTeamProjectCollection collection = null;

            try
            {
                collectionUri = new Uri(CollectionName);
                collection = new TfsTeamProjectCollection(collectionUri);

                ICommonStructureService commonStructure = collection.GetService<ICommonStructureService>();
                VersionControlServer vcServer = collection.GetService<VersionControlServer>();

                ProjectInfo project = commonStructure.GetProjectFromName(ProjectName);

                Workspace[] workspaces = vcServer.QueryWorkspaces(null, WindowsIdentity.GetCurrent().Name, Environment.MachineName);

                foreach (Workspace workspace in workspaces)
                {
                    WorkingFolder workingFolder = workspace.Folders.FirstOrDefault(f => f.ServerItem == ("$/" + project.Name));

                    if (workingFolder != null)
                    {
                        if (!workspace.Comment.Equals("Workspace created by team build", StringComparison.InvariantCultureIgnoreCase))
                        {
                            localDirectory = workingFolder.LocalItem;
                        }
                    }
                }

                if (localDirectory == null)
                {
                    MessageBox.Show("You do not have a local working folder with this project's source code on your computer.\n\nUse Team Explorer in Visual Studio or the tf.exe console application to map a working folder and get the source code.", "Project source code not available locally", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.GetBaseException().Message, "Error connecting to TFS", MessageBoxButton.OK, MessageBoxImage.Error);
            }

            return localDirectory;
        }
    }
}