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

namespace PowerDeliveryClient.Pages
{
    /// <summary>
    /// Interaction logic for Sources.xaml
    /// </summary>
    public partial class Sources : Page
    {
        public Sources()
        {
            InitializeComponent();

            itmsSource.ItemsSource = MainWindow.Configuration.Sources;
        }

        private void btnAddSource_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.Navigate(new AddEditSource(new ClientCollectionSource() { Uri = "" }));
        }

        private void btnAddEditSource_Click(object sender, RoutedEventArgs e)
        {
            Button btnSender = (Button)sender;

            NavigationService.Navigate(new AddEditSource((ClientCollectionSource)btnSender.DataContext));
        }
    }
}
