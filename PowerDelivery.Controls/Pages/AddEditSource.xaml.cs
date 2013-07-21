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

namespace PowerDelivery.Controls.Pages
{
    /// <summary>
    /// Interaction logic for AddEditSource.xaml
    /// </summary>
    public partial class AddEditSource : Page
    {
        ClientControl _clientControl;

        public AddEditSource(ClientControl clientControl, ClientCollectionSource source)
        {
            _clientControl = clientControl;
            DataContext = source;

            InitializeComponent();

            if (ClientConfiguration.Current.Sources.Contains(source))
            {
                btnRemove.Visibility = Visibility.Visible;
            }

            this.Loaded += AddEditSource_Loaded;
        }

        void AddEditSource_Loaded(object sender, RoutedEventArgs e)
        {
            txtCollectionURL.Focus();
        }

        private void btnSaveChanges_Click(object sender, RoutedEventArgs e)
        {
            Uri collectionUri = null;
            TfsTeamProjectCollection collection = null;

            try
            {
                collectionUri = new Uri(txtCollectionURL.Text);
                collection = new TfsTeamProjectCollection(collectionUri);
            }
            catch (Exception)
            {
                MessageBox.Show("Invalid URL, please enter a valid URL to a TFS Project Collection.", "Invalid URL", MessageBoxButton.OK, MessageBoxImage.Stop);
                txtCollectionURL.Focus();
                return;
            }

            try
            {
                collection.Connect(ConnectOptions.IncludeServices);

                ClientCollectionSource source = (ClientCollectionSource)DataContext;

                bool added = true;

                if (!ClientConfiguration.Current.Sources.Contains(source))
                {
                    ClientControl.Configuration.Sources.Add(new ClientCollectionSource() { Uri = collectionUri.ToString() });

                    added = false;
                }

                ClientControl.Configuration.Save();

                if (added)
                {
                    NavigationService.Navigate(new Pages.Home(_clientControl));
                }
                else
                {
                    NavigationService.Navigate(new Pages.Sources(_clientControl));
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error connecting to TFS", MessageBoxButton.OK, MessageBoxImage.Stop);
                txtCollectionURL.Focus();
                return;
            }
        }

        private void btnCancel_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.GoBack();
        }

        private void btnRemove_Click(object sender, RoutedEventArgs e)
        {
            if (MessageBox.Show("Are you sure you want to remove this Team Foundation Server source?", "Confirm remove source", MessageBoxButton.YesNo, MessageBoxImage.Question) == MessageBoxResult.Yes)
            {
                ClientCollectionSource source = (ClientCollectionSource)DataContext;

                ClientConfiguration.Current.Sources.Remove(source);
                ClientConfiguration.Current.Save();

                NavigationService.Navigate(new Pages.Sources(_clientControl));
            }
        }
    }
}