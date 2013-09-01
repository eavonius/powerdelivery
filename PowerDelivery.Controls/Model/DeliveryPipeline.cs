using Microsoft.TeamFoundation.Client;
using Microsoft.TeamFoundation.Server;
using Microsoft.TeamFoundation.VersionControl.Client;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;
using System.Windows;

namespace PowerDelivery.Controls.Model
{
    public class DeliveryPipeline : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        public ClientCollectionSource Source { get; private set; }
        public string PortalUrl { get; private set; }
        public string ProjectUri { get; private set; }
        public string ProjectName { get; private set; }
        public string CollectionName { get; private set; }
        public string ScriptName { get; private set; }

        private IList<PipelineEnvironment> _environments;

        public DeliveryPipeline(ClientCollectionSource source, ProjectInfo projectInfo, string scriptName)
        {
            Source = source;
            ProjectName = projectInfo.Name;
            CollectionName = source.ProjectCollection.Name;
            ScriptName = scriptName;

            ProjectUri = string.Format("{0}/{1}", source.Uri.TrimEnd('/'), ProjectName.TrimStart('/'));

            _environments = new List<PipelineEnvironment>();

            RegistrationEntry[] entries = source.Registration.GetRegistrationEntries("Wss");

            foreach (ServiceInterface si in entries[0].ServiceInterfaces)
            {
                if (si.Name == "BaseSiteUrl")
                {
                    PortalUrl = si.Url;
                }
            }
        }

        public IList<PipelineEnvironment> Environments {
            get { return _environments; }
            set { _environments = value; OnPropertyChanged("Environments"); }
        }

        public string GetWorkingDirectory()
        {
            string localDirectory = null;

            try
            {
                Workspace[] workspaces = Source.VersionControlServer.QueryWorkspaces(null, Source.VersionControlServer.AuthorizedUser, Environment.MachineName);

                foreach (Workspace workspace in workspaces)
                {
                    WorkingFolder workingFolder = workspace.Folders.FirstOrDefault(f => f.ServerItem.ToLower() == "$/" + ProjectName.ToLower());

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
                    throw new Exception(
                        "You do not have a local working folder with this project's source code on your computer.\n\n" + 
                        "Use Team Explorer in Visual Studio or the tf.exe console application to map a working folder and get the source code."
                    );
                }
            }
            catch (Exception ex)
            {
                throw new Exception(string.Format("Error connecting to TFS. Error was:\n\n{0}", ex.GetBaseException().Message));
            }

            return localDirectory;
        }

        public void StopPolling()
        {
            foreach (PipelineEnvironment environment in Environments)
            {
                environment.IsPolling = false;
            }
        }

        public void StartPolling()
        {
            foreach (PipelineEnvironment environment in Environments)
            {
                if (!environment.IsPolling)
                {
                    environment.StartPolling();
                }
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