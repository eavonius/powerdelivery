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

namespace PowerDelivery.Controls
{
    /// <summary>
    /// Interaction logic for ClientControl.xaml
    /// </summary>
    public partial class ClientControl : UserControl
    {
        internal static ClientConfiguration Configuration { get; private set; }

        public ClientControl()
        {
            InitializeComponent();

            Configuration = ClientConfiguration.Current;
        }

        private void frmContent_Navigated(object sender, NavigationEventArgs e)
        {
            //Title = "powerdelivery - " + ((Page)frmContent.Content).Title;
        }
    }
}
