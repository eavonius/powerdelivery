using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Diagnostics;

using PowerDelivery.Controls.Model;
using System.ComponentModel;
using PowerDelivery.Controls.Commands;
using Microsoft.TeamFoundation.Client;
using Microsoft.TeamFoundation.Server;
using System.Web;

namespace PowerDelivery.Controls.Pages
{
    public partial class Home : Page
    {
        ClientControl _clientControl;

        const int ENV_BLOCK_HEIGHT = 125;

        const int PROD_BLOCK_LEFT = 495;

        public Home(ClientControl clientControl)
        {
            _clientControl = clientControl;

            Loaded += Home_Loaded;
            Unloaded += Home_Unloaded;

            InitializeComponent();
        }

        void Home_Unloaded(object sender, RoutedEventArgs e)
        {
            ClientConfiguration.Current.StopPolling();
        }

        void Home_Loaded(object sender, RoutedEventArgs e)
        {
            Task.Factory.StartNew(() =>
            {
                Dispatcher.Invoke(new Action(delegate()
                {
                    var x = ClientConfiguration.Current.Pipelines;
                }));

                Dispatcher.Invoke(new Action(delegate()
                {
                    lstPipelines.ItemsSource = ClientConfiguration.Current.Pipelines;
               
                    pnlLoadingPipelines.Visibility = System.Windows.Visibility.Collapsed;
                    lstPipelines.Visibility = System.Windows.Visibility.Visible;

                    ClientConfiguration.Current.StartPolling();
                }), System.Windows.Threading.DispatcherPriority.Background);
            });
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

            try
            {
                string localDirectory = pipeline.GetWorkingDirectory();

                if (localDirectory != null)
                {
                    string envConfigPath = string.Format("{0}\\{1}.ps1", localDirectory, pipeline.ScriptName);

                    if (!File.Exists(envConfigPath))
                    {
                        throw new Exception(
                            string.Format("File:\n\n{0}\n\nCouldn't be found on disk. Did you move your working folder?", envConfigPath));
                    }

                    ProcessStartInfo psi = new ProcessStartInfo();
                    psi.Verb = "edit";
                    psi.FileName = envConfigPath;

                    Process.Start(psi);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message,
                    "Unable to edit powerdelivery script",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btnEditEnvironmentConfig_Click(object sender, RoutedEventArgs e)
        {
            Button btnSource = (Button)sender;

            PipelineEnvironment environment = (PipelineEnvironment)btnSource.DataContext;

            try
            {
                string localDirectory = environment.Pipeline.GetWorkingDirectory();

                if (localDirectory != null)
                {
                    string envConfigPath = string.Format("{0}\\{1}{2}.yml", localDirectory, environment.Pipeline.ScriptName, environment.EnvironmentName);

                    if (!File.Exists(envConfigPath))
                    {
                        throw new Exception(string.Format("File:\n\n{0}\n\nCouldn't be found on disk. Did you move your working folder?", envConfigPath));
                    }

                    ProcessStartInfo psi = new ProcessStartInfo();
                    psi.FileName = envConfigPath;
                    psi.WorkingDirectory = System.IO.Path.GetDirectoryName(envConfigPath);

                    Process.Start(psi);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, 
                    string.Format("Unable to edit {0} environment configuration file", environment.EnvironmentName), 
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btnEditPipelineEnvironment_Click(object sender, RoutedEventArgs e)
        {
            Button btnSource = (Button)sender;

            DeliveryPipeline pipeline = (DeliveryPipeline)btnSource.DataContext;

            try
            {

                string localDirectory = pipeline.GetWorkingDirectory();

                if (localDirectory != null)
                {
                    string envConfigPath = string.Format("{0}\\{1}Shared.yml", localDirectory, pipeline.ScriptName);

                    if (!File.Exists(envConfigPath))
                    {
                        throw new Exception(string.Format("File:\n\n{0}\n\nCouldn't be found on disk. Did you move your working folder?", envConfigPath));
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
                        throw new Exception(string.Format("Unable to edit configuration file:\n\n{0}\n\n{1}", envConfigPath, ex.Message));
                    }
                }
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message,
                    "Unable to edit shared environment configuration file",
                    MessageBoxButton.OK, MessageBoxImage.Error);
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
            Canvas.SetZIndex(brdEnvironmentBlock, 1);

            FrameworkElement parentElement = (FrameworkElement)brdEnvironmentBlock.TemplatedParent;
            Canvas parentCanvas = parentElement.Parent as Canvas;

            PipelineEnvironment environment = brdEnvironmentBlock.DataContext as PipelineEnvironment;

            IEnumerable<PipelineEnvironment> environments = environment.Pipeline.Environments.Where(env => env.EnvironmentName != "Commit" && env.EnvironmentName != "Test");

            int midEnvCount = environments.Count();

            if (environment.EnvironmentName == "Production")
            {
                Canvas.SetLeft(parentElement, 495);

                Canvas.SetTop(parentElement, 0);
            }
            else if (environment.EnvironmentName == "Commit")
            {
                Canvas.SetLeft(parentElement, 0);

                Canvas.SetTop(parentElement, (midEnvCount * ENV_BLOCK_HEIGHT) / 2 - (ENV_BLOCK_HEIGHT / 2));
            }
            else
            {
                Canvas.SetLeft(parentElement, 250);

                int pipelineIndex = environments.ToList().IndexOf(environment) + 1;

                PipelineEnvironment commitEnvironment = environment.Pipeline.Environments.FirstOrDefault(env => env.EnvironmentName == "Commit");
                PipelineEnvironment productionEnvironment = environment.Pipeline.Environments.FirstOrDefault(env => env.EnvironmentName == "Production");

                Canvas.SetTop(parentElement, pipelineIndex * ENV_BLOCK_HEIGHT);

                Line commitToMidLine = new Line();
                commitToMidLine.StrokeThickness = 3;
                commitToMidLine.Stroke = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#555"));
                commitToMidLine.X1 = 170;
                commitToMidLine.Y1 = (midEnvCount * ENV_BLOCK_HEIGHT) / 2;
                commitToMidLine.X2 = Canvas.GetLeft(parentElement);
                commitToMidLine.Y2 = Canvas.GetTop(parentElement) + (parentElement.ActualHeight / 2);

                parentCanvas.Children.Add(commitToMidLine);

                PromoteControl promoteFromCommit = new PromoteControl(this);
                promoteFromCommit.Environment = commitEnvironment;
                promoteFromCommit.NextEnvironment = environment;
                promoteFromCommit.ToolTip = string.Format("Promote {0} from Commit to {1}", environment.Pipeline.ScriptName, environment.EnvironmentName);
                parentCanvas.Children.Add(promoteFromCommit);

                RotateTransform rotatePromoteButton = new RotateTransform();
                rotatePromoteButton.CenterX = 10;
                rotatePromoteButton.CenterY = 10;
                promoteFromCommit.RenderTransform = rotatePromoteButton;

                Double angleInRadians = Math.Atan2(commitToMidLine.Y2 - commitToMidLine.Y1, commitToMidLine.X2 - commitToMidLine.X1);
                rotatePromoteButton.Angle = angleInRadians * (180 / Math.PI);

                if (commitToMidLine.Y2 > commitToMidLine.Y1)
                {
                    Canvas.SetTop(promoteFromCommit, commitToMidLine.Y1 + ((commitToMidLine.Y2 - commitToMidLine.Y1) / 2) - (promoteFromCommit.ActualHeight / 2) - 16);
                }
                else
                {
                    Canvas.SetTop(promoteFromCommit, commitToMidLine.Y2 + ((commitToMidLine.Y1 - commitToMidLine.Y2) / 2) - (promoteFromCommit.ActualHeight / 2) - 16);
                }

                Canvas.SetLeft(promoteFromCommit, 200);

                if (environment.EnvironmentName == "Test")
                {
                    Line testToProdLine = new Line();
                    testToProdLine.StrokeThickness = 3;
                    testToProdLine.Stroke = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#555"));
                    testToProdLine.X1 = 250 + brdEnvironmentBlock.ActualWidth;
                    testToProdLine.Y1 = Canvas.GetTop(parentElement) + (parentElement.ActualHeight / 2);
                    testToProdLine.X2 = PROD_BLOCK_LEFT;
                    testToProdLine.Y2 = ENV_BLOCK_HEIGHT / 2 - 3;

                    parentCanvas.Children.Add(testToProdLine);

                    PromoteControl promoteFromTest = new PromoteControl(this);
                    promoteFromTest.Environment = environment;
                    promoteFromTest.NextEnvironment = productionEnvironment;
                    promoteFromTest.ToolTip = string.Format("Promote {0} from {1} to Production", environment.Pipeline.ScriptName, environment.EnvironmentName);
                    parentCanvas.Children.Add(promoteFromTest);

                    if (testToProdLine.Y2 > testToProdLine.Y1)
                    {
                        Canvas.SetTop(promoteFromTest, testToProdLine.Y1 + ((testToProdLine.Y2 - testToProdLine.Y1) / 2) - (promoteFromTest.ActualHeight / 2) - 15);
                    }
                    else
                    {
                        Canvas.SetTop(promoteFromTest, testToProdLine.Y2 + ((testToProdLine.Y1 - testToProdLine.Y2) / 2) - (promoteFromTest.ActualHeight / 2) - 15);
                    }

                    Canvas.SetLeft(promoteFromTest, 445);
                }
            }
        }

        private void btnDeletePipeline_Click(object sender, RoutedEventArgs e)
        {
            DeliveryPipeline pipeline = ((Button)sender).DataContext as DeliveryPipeline;

            if (MessageBox.Show(string.Format("Are you sure you want to remove pipeline \"{0}\"\r\nfrom \"{1}\"?", pipeline.ScriptName, pipeline.ProjectName ), 
                "Confirm remove pipeline", MessageBoxButton.YesNo, MessageBoxImage.Question) == MessageBoxResult.Yes) {

                DeletePipelineCommand command = new DeletePipelineCommand();
                command.Name = pipeline.ScriptName;
                command.CollectionURL = pipeline.CollectionName;
                command.ProjectName = pipeline.ProjectName;

                try
                {
                    command.BuildCommand();
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message, "Correct invalid entries", MessageBoxButton.OK, MessageBoxImage.Error);

                    return;
                }

                NavigationService _navService = NavigationService;

                _navService.Navigate(new RunPowerShell(this, "Removing pipeline", command, null,
                    () => { ClientConfiguration.Current.RefreshSources(); _navService.Navigate(new Home(_clientControl)); return true; },
                    () => { _navService.Navigate(new Home(_clientControl));  return true; }
                ));
            }
        }

        protected void btnBuild_Click(object sender, RoutedEventArgs e)
        {
            Button btnSource = (Button)sender;

            DeliveryPipeline pipeline = btnSource.DataContext as DeliveryPipeline;

            try
            {
                string localDirectory = pipeline.GetWorkingDirectory();

                if (localDirectory != null)
                {
                    string scriptName = string.Format("{0}.ps1", pipeline.ScriptName);

                    string scriptPath = string.Format("{0}\\{1}", localDirectory, scriptName);

                    if (!File.Exists(scriptPath))
                    {
                        throw new Exception(string.Format("File:\n\n{0}\n\nCouldn't be found on disk. Did you move your working folder?", scriptPath));
                    }

                    InvokePowerDeliveryCommand command = new InvokePowerDeliveryCommand();

                    command.ScriptName = scriptName;

                    try
                    {
                        command.BuildCommand();
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show(ex.Message, "Correct invalid entries", MessageBoxButton.OK, MessageBoxImage.Error);

                        return;
                    }

                    NavigationService _navService = NavigationService;

                    _navService.Navigate(new RunPowerShell(this, "Running local build", command, localDirectory,
                        () => { ClientConfiguration.Current.RefreshSources(); _navService.Navigate(new Home(_clientControl)); return true; },
                        () => { _navService.Navigate(new Home(_clientControl));  return true; }
                    ));
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message,
                    string.Format("Unable to run {0}.ps1", pipeline.ScriptName),
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void EnvironmentBlockTitle_MouseDown(object sender, MouseButtonEventArgs e)
        {
            FrameworkElement blockBorder = (FrameworkElement)sender;

            PipelineEnvironment environment = (PipelineEnvironment)blockBorder.DataContext;

            NavigationService.Navigate(new ShowPipelineEnvironment(environment));

            /*
            TfsTeamProjectCollection tfs = new TfsTeamProjectCollection(new Uri(environment.Pipeline.Source.Uri));

            IRegistration registration = (IRegistration)tfs.GetService(typeof(IRegistration));

            RegistrationEntry[] entries = registration.GetRegistrationEntries("Wss");

            foreach (ServiceInterface si in entries[0].ServiceInterfaces)
            {
                if (si.Name == "BaseSiteUrl") 
                {
                    Process.Start(
                        string.Format("{0}{1}/{2}/_Build#definitionUri={3}&_a=completed", 
                            si.Url, 
                            environment.Pipeline.Source.Name, 
                            environment.Pipeline.ProjectName, 
                            HttpUtility.UrlEncode(environment.BuildDefinition.Uri.ToString())));
                }
            }*/
        }
    }
}