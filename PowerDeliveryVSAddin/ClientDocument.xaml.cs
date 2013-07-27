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
using stdole;

namespace PowerDeliveryVSAddin
{
    /// <summary>
    /// Interaction logic for ClientDocument.xaml
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    public partial class ClientDocument : UserControl, IDispatch
    {
        /// <summary>
        /// Creates a new client document.
        /// </summary>
        public ClientDocument()
        {
            InitializeComponent();
        }
    }
}