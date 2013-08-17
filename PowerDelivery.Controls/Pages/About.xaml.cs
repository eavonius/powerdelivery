using System;
using System.Windows;
using System.Windows.Controls;

using PowerDelivery.Controls.Model;

namespace PowerDelivery.Controls.Pages
{
    /// <summary>
    /// Interaction logic for About.xaml
    /// </summary>
    public partial class About : Page
    {
        public About()
        {
            DataContext = ClientConfiguration.Current.ClientInfo;

            InitializeComponent();
        }
    }
}