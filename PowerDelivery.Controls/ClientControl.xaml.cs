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
using System.Runtime.InteropServices;

using PowerDelivery.Controls.Model;

namespace PowerDelivery.Controls
{
    public class UrlOpenedEventArgs : EventArgs
    {
        public UrlOpenedEventArgs(string url)
        {
            Url = url;
        }

        public string Url { get; private set; }
    }

    /// <summary>
    /// Client control for PowerDelivery.
    /// </summary>
    public partial class ClientControl : UserControl
    {
        /// <summary>
        /// Creates the control.
        /// </summary>
        public ClientControl()
        {
            InitializeComponent();

            DataContext = ClientConfiguration.Current;

            frmContent.Navigate(new Pages.Home(this));
        }

        public event EventHandler<UrlOpenedEventArgs> UrlOpened;

        private void btnPipelines_Click(object sender, RoutedEventArgs e)
        {
            if (!(frmContent.Content is Pages.Home))
            {
                frmContent.Navigate(new Pages.Home(this));
            }
        }

        private void btnSources_Click(object sender, RoutedEventArgs e)
        {
            if (!(frmContent.Content is Pages.Sources))
            {
                frmContent.Navigate(new Pages.Sources(this));
            }
        }

        private void btnAbout_Click(object sender, RoutedEventArgs e)
        {
            if (!(frmContent.Content is Pages.About))
            {
                frmContent.Navigate(new Pages.About());
            }
        }

        internal void OnUrlOpened(UrlOpenedEventArgs e)
        {
            if (UrlOpened != null)
            {
                UrlOpened(this, e);
            }
        }
    }
}