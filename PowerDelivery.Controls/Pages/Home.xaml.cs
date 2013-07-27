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
using System.Windows.Shapes;

namespace PowerDelivery.Controls.Pages
{
    /// <summary>
    /// Interaction logic for Home.xaml
    /// </summary>
    public partial class Home : Page
    {
        ClientControl _clientControl;

        const int ENV_BLOCK_HEIGHT = 125;

        public Home(ClientControl clientControl)
        {
            _clientControl = clientControl;

            InitializeComponent();

            lstPipelines.ItemsSource = ClientConfiguration.Current.Pipelines;
        }

        void StackPanel_Loaded(object sender, RoutedEventArgs e)
        {
            FrameworkElement senderElem = sender as FrameworkElement;
            Line linePromotion = senderElem.FindName("linePrePromotion") as Line;

            StackPanel parent = linePromotion.Parent as StackPanel;
            UIElement nextElement = parent.Children[parent.Children.IndexOf(linePromotion) + 1];
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
                    psi.WorkingDirectory = System.IO.Path.GetDirectoryName(envConfigPath);

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
                    psi.WorkingDirectory = System.IO.Path.GetDirectoryName(envConfigPath);

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

        private void itmsPipeline_Loaded(object sender, RoutedEventArgs e)
        {
            ItemsControl itmsPipeline = (ItemsControl)sender;
            Canvas parentCanvas = (Canvas)itmsPipeline.Parent;

            IEnumerable<PipelineEnvironment> environments = itmsPipeline.ItemsSource as IEnumerable<PipelineEnvironment>;

            int middleEnvironmentsCount = environments.Count(
                env => env.EnvironmentName != "Commit" && 
                       env.EnvironmentName != "Production");

            parentCanvas.Height = ENV_BLOCK_HEIGHT * middleEnvironmentsCount;
        }

        private void brdEnvironmentBlock_Loaded(object sender, RoutedEventArgs e)
        {
            Border brdEnvironmentBlock = (Border)sender;

            FrameworkElement parentElement = (FrameworkElement)brdEnvironmentBlock.TemplatedParent;
            Canvas parentCanvas = parentElement.Parent as Canvas;

            PipelineEnvironment environment = brdEnvironmentBlock.DataContext as PipelineEnvironment;

            IEnumerable<PipelineEnvironment> environments = environment.Pipeline.Environments.Where(env => env.EnvironmentName != "Commit" && env.EnvironmentName != "Test");

            int midEnvCount = environments.Count();

            if (environment.EnvironmentName == "Production")
            {
                Canvas.SetLeft(parentElement, 475);

                Canvas.SetTop(parentElement, 0);
            }
            else if (environment.EnvironmentName == "Commit")
            {
                Canvas.SetLeft(parentElement, 0);

                Canvas.SetTop(parentElement, (midEnvCount * ENV_BLOCK_HEIGHT) / 2 - (ENV_BLOCK_HEIGHT / 2));
            }
            else
            {
                Canvas.SetLeft(parentElement, 240);

                int pipelineIndex = environments.ToList().IndexOf(environment) + 1;

                Canvas.SetTop(parentElement, pipelineIndex * ENV_BLOCK_HEIGHT);

                Line commitToMidLine = new Line();
                commitToMidLine.StrokeThickness = 2;
                commitToMidLine.Stroke = Brushes.LightBlue;
                commitToMidLine.X1 = 160;
                commitToMidLine.Y1 = (midEnvCount * ENV_BLOCK_HEIGHT) / 2;
                commitToMidLine.X2 = Canvas.GetLeft(parentElement);
                commitToMidLine.Y2 = Canvas.GetTop(parentElement) + (parentElement.ActualHeight / 2);

                parentCanvas.Children.Add(commitToMidLine);

                if (environment.EnvironmentName == "Test")
                {
                    Line testToProdLine = new Line();
                    testToProdLine.StrokeThickness = 3;
                    testToProdLine.Stroke = Brushes.LightBlue;
                    testToProdLine.X1 = 240 + brdEnvironmentBlock.ActualWidth;
                    testToProdLine.Y1 = Canvas.GetTop(parentElement) + (parentElement.ActualHeight / 2);
                    testToProdLine.X2 = 475;
                    testToProdLine.Y2 = ENV_BLOCK_HEIGHT / 2 - 3;

                    parentCanvas.Children.Add(testToProdLine);
                }
            }
        }
    }
}