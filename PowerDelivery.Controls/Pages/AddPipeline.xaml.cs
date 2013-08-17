using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

using Microsoft.TeamFoundation.Client;
using Microsoft.TeamFoundation.Framework.Common;
using Microsoft.TeamFoundation.Server;
using Microsoft.TeamFoundation.Build.Client;

using PowerDelivery.Controls.Model;
using PowerDelivery.Controls.Commands;

namespace PowerDelivery.Controls.Pages
{
    /// <summary>
    /// Interaction logic for AddEditSource.xaml
    /// </summary>
    public partial class AddPipeline : Page
    {
        ClientControl _clientControl;

        public AddPipeline(ClientControl clientControl)
        {
            _clientControl = clientControl;

            InitializeComponent();

            cboCollectionURL.ItemsSource = ClientConfiguration.Current.Sources;
            cboTemplate.ItemsSource = ClientConfiguration.Current.ClientInfo.Templates;

            cboTemplate.SelectedValue = "Blank";

            this.Loaded += AddEditSource_Loaded;
        }

        void AddEditSource_Loaded(object sender, RoutedEventArgs e)
        {
            txtName.Focus();
        }

        private void btnSaveChanges_Click(object sender, RoutedEventArgs e)
        {
            AddPipelineCommand command = new AddPipelineCommand();
            command.Name = txtName.Text;
            command.BuildController = (string)cboBuildController.Text;
            command.CollectionURL = (string)cboCollectionURL.Text;
            command.ProjectName = (string)cboProject.Text;
            command.DropFolder = txtDropFolder.Text;
            command.Template = cboTemplate.SelectedValue as string;

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

            _navService.Navigate(new RunPowerShell(this, "Adding pipeline", command, null,
                () => { ClientConfiguration.Current.RefreshSources(); _navService.Navigate(new Home(_clientControl)); return true; },
                () => { _navService.Navigate(new AddPipeline(_clientControl));  return true; }
            ));
        }

        private void btnCancel_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.GoBack();
        }

        private void cboCollectionURL_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            cboProject.Items.Clear();
            cboBuildController.Items.Clear();

            if (cboCollectionURL.SelectedItem != null)
            {
                ClientCollectionSource source = cboCollectionURL.SelectedItem as ClientCollectionSource;

                Uri collectionUri = null;

                TfsTeamProjectCollection collection = null;

                try
                {
                    collectionUri = new Uri(source.Uri);
                    collection = new TfsTeamProjectCollection(collectionUri);

                    ICommonStructureService commonStructure = collection.GetService<ICommonStructureService>();

                    foreach (ProjectInfo project in commonStructure.ListProjects())
                    {
                        cboProject.Items.Add(new ComboBoxItem() { Content = project.Name, DataContext = project.Name });
                    }
                }
                catch (Exception ex)
                {
                    cboProject.Items.Clear();
                    cboBuildController.Items.Clear();

                    MessageBox.Show(ex.Message, string.Format("Error retrieving projects from {0}", collectionUri), MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }

                try
                {
                    IBuildServer buildServer = collection.GetService<IBuildServer>();

                    foreach (IBuildController buildController in buildServer.QueryBuildControllers())
                    {
                        cboBuildController.Items.Add(new ComboBoxItem() { Content = buildController.Name, DataContext = buildController.Name });
                    }
                }
                catch (Exception ex)
                {
                    cboBuildController.Items.Clear();
                    MessageBox.Show(ex.Message, string.Format("Error retrieving build controllers from {0}", collectionUri), MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
            }
        }

        private void cboProject_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            
        }
    }
}