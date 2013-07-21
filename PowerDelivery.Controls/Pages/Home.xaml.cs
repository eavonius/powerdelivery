using System;
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
using System.Windows.Shapes;

using Microsoft.TeamFoundation.Framework;
using Microsoft.TeamFoundation.Client;
using Microsoft.TeamFoundation.Build.Client;
using Microsoft.TeamFoundation.Server;
using System.ComponentModel;

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

                                if (pipeline == null)
                                {
                                    pipeline = new DeliveryPipeline(source, project.Name, collection.Name);
                                    pipelines.Add(pipeline);
                                }

                                string lastBuildStatus = "Never Run";
                                string lastBuildNumber = "";
                                DateTime lastBuildFinishTime = DateTime.MinValue;

                                if (definition.LastBuildUri != null)
                                {
                                    try
                                    {
                                        IBuildDetail lastBuild = buildServer.GetBuild(definition.LastBuildUri);
                                        lastBuildStatus = lastBuild.Status.ToString();
                                        lastBuildFinishTime = lastBuild.FinishTime;
                                        lastBuildNumber = definition.LastBuildUri.ToString().Substring(definition.LastBuildUri.ToString().LastIndexOf("/") + 1);
                                    }
                                    catch (Exception) { // Build was deleted 
                                        lastBuildStatus = "No Longer Exists";
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

            PipelineEnvironment environment = (PipelineEnvironment)btnSource.DataContext;
        }

        private void btnEditEnvironmentConfig_Click(object sender, RoutedEventArgs e)
        {
            Button btnSource = (Button)sender;

            PipelineEnvironment environment = (PipelineEnvironment)btnSource.DataContext;

            Uri collectionUri = null;
            TfsTeamProjectCollection collection = null;

            try
            {
                collectionUri = new Uri(environment.Pipeline.CollectionName);
                collection = new TfsTeamProjectCollection(collectionUri);

                       
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.GetBaseException().Message, "Error connecting to TFS", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}