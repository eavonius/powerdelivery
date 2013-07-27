using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Diagnostics;

using Microsoft.TeamFoundation.Framework;
using Microsoft.TeamFoundation.Client;
using Microsoft.TeamFoundation.Build.Client;
using Microsoft.TeamFoundation.Server;
using Microsoft.TeamFoundation.VersionControl.Client;
using Microsoft.TeamFoundation.VersionControl.Common;
using Microsoft.TeamFoundation.Build.Workflow;
using System.ComponentModel;
using System.Security.Principal;

namespace PowerDelivery.Controls.Pages
{
    /// <summary>
    /// Interaction logic for Home.xaml
    /// </summary>
    public partial class Home : Page
    {
        bool _useDarkTheme = false;
        ClientControl _clientControl;

        public Home(ClientControl clientControl)
        {
            _clientControl = clientControl;

            InitializeComponent();

            LoadPipelines();
        }

        private void LoadPipelines()
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

                                    string scriptName = Path.GetFileNameWithoutExtension(scriptPath.Substring(scriptPath.LastIndexOf("/")));

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

                                    if (environmentName == "Commit")
                                    {
                                        pipeline.Commit = environment;
                                    }
                                    else if (environmentName == "Test")
                                    {
                                        pipeline.Test = environment;
                                    }
                                    else if (environmentName == "Capacity Test")
                                    {
                                        pipeline.CapacityTest = environment;
                                    }
                                    else if (environmentName == "Production")
                                    {
                                        pipeline.Production = environment;
                                    }
                                }
                            }
                        }
                    }
                }
                catch (Exception ex) {

                    int x = 0;
                }
            }

            lstPipelines.ItemsSource = pipelines;
        }

        private void btnSources_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.Navigate(new Pages.Sources(_clientControl));
        }

        private void btnEditPipelineScript_Click(object sender, RoutedEventArgs e)
        {
            Button btnSource = (Button)sender;

            DeliveryPipeline pipeline = (DeliveryPipeline)btnSource.DataContext;

            string localDirectory = pipeline.GetWorkingDirectory();

            if (localDirectory != null)
            {
                string envConfigPath = string.Format("{0}\\{1}.ps1", localDirectory, pipeline.ScriptName);

                if (!File.Exists(envConfigPath))
                {
                    MessageBox.Show(string.Format("File:\n\n{0}\n\nCouldn't be found on disk. Did you move your working folder?", envConfigPath),
                        "Environment configuration file not found", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }

                ProcessStartInfo psi = new ProcessStartInfo();
                psi.Verb = "edit";
                psi.FileName = envConfigPath;

                Process.Start(psi);
            }
        }

        private void btnEditEnvironmentConfig_Click(object sender, RoutedEventArgs e)
        {
            Button btnSource = (Button)sender;

            PipelineEnvironment environment = (PipelineEnvironment)btnSource.DataContext;

            string localDirectory = environment.Pipeline.GetWorkingDirectory();

            if (localDirectory != null)
            {
                string envConfigPath = string.Format("{0}\\{1}{2}.yml", localDirectory, environment.Pipeline.ScriptName, environment.EnvironmentName);

                if (!File.Exists(envConfigPath))
                {
                    MessageBox.Show(string.Format("File:\n\n{0}\n\nCouldn't be found on disk. Did you move your working folder?", envConfigPath),
                        "Environment configuration file not found", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }

                try
                {
                    ProcessStartInfo psi = new ProcessStartInfo();
                    psi.FileName = envConfigPath;
                    psi.WorkingDirectory = Path.GetDirectoryName(envConfigPath);

                    Process.Start(psi);
                }
                catch (Exception ex)
                {
                    MessageBox.Show(string.Format("Unable to edit configuration file:\n\n{0}\n\n{1}", envConfigPath, ex.Message),
                        "Error opening environment configuration", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        private void btnEditPipelineEnvironment_Click(object sender, RoutedEventArgs e)
        {
            Button btnSource = (Button)sender;

            DeliveryPipeline pipeline = (DeliveryPipeline)btnSource.DataContext;

            string localDirectory = pipeline.GetWorkingDirectory();

            if (localDirectory != null)
            {
                string envConfigPath = string.Format("{0}\\{1}Shared.yml", localDirectory, pipeline.ScriptName);

                if (!File.Exists(envConfigPath))
                {
                    MessageBox.Show(string.Format("File:\n\n{0}\n\nCouldn't be found on disk. Did you move your working folder?", envConfigPath),
                        "Environment configuration file not found", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }

                try
                {
                    ProcessStartInfo psi = new ProcessStartInfo();
                    psi.FileName = envConfigPath;
                    psi.WorkingDirectory = Path.GetDirectoryName(envConfigPath);

                    Process.Start(psi);
                }
                catch (Exception ex)
                {
                    MessageBox.Show(string.Format("Unable to edit configuration file:\n\n{0}\n\n{1}", envConfigPath, ex.Message), 
                        "Error opening shared environment configuration", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        private void btnAddPipeline_Click(object sender, EventArgs e)
        {
            NavigationService.Navigate(new AddPipeline(_clientControl));
        }
    }
}