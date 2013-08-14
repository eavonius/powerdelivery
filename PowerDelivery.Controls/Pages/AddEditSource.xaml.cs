using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

using PowerDelivery.Controls.Model;

namespace PowerDelivery.Controls.Pages
{
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

            this.KeyUp += AddEditSource_KeyUp;

            this.Loaded += AddEditSource_Loaded;

            txtCollectionURL.SelectAll();
        }

        void AddEditSource_KeyUp(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                btnSaveChanges_Click(this, new RoutedEventArgs());
            }
        }

        void AddEditSource_Loaded(object sender, RoutedEventArgs e)
        {
            txtCollectionURL.Focus();
        }

        private void btnSaveChanges_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                ClientCollectionSource source = (ClientCollectionSource)DataContext;
                source.Uri = txtCollectionURL.Text;

                source.Save();

                ClientConfiguration.Reload();

                NavigationService.Navigate(new Pages.Home(_clientControl));
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error saving TFS source", MessageBoxButton.OK, MessageBoxImage.Error);

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
            if (MessageBox.Show("Are you sure you want to remove this Team Foundation Server source?", "Confirm remove source", 
                MessageBoxButton.YesNo, MessageBoxImage.Question) == MessageBoxResult.Yes)
            {
                ClientCollectionSource source = (ClientCollectionSource)DataContext;

                ClientConfiguration.Current.Sources.Remove(source);
                ClientConfiguration.Current.Save();

                ClientConfiguration.Reload();

                NavigationService.Navigate(new Pages.Home(_clientControl));
            }
        }
    }
}