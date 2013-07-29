using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
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

using PowerDelivery.Controls.Model;

namespace PowerDelivery.Controls.Pages
{
    /// <summary>
    /// Interaction logic for Sources.xaml
    /// </summary>
    public partial class Sources : Page
    {
        ClientControl _clientControl;

        public Sources(ClientControl clientControl)
        {
            _clientControl = clientControl;

            InitializeComponent();

            itmsSource.ItemsSource = ClientConfiguration.Current.Sources;
        }

        private void btnAddSource_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.Navigate(new AddEditSource(_clientControl, new ClientCollectionSource() { Uri = "" }));
        }

        private void btnAddEditSource_Click(object sender, RoutedEventArgs e)
        {
            Button btnSender = (Button)sender;

            NavigationService.Navigate(new AddEditSource(_clientControl, (ClientCollectionSource)btnSender.DataContext));
        }
    }
}
