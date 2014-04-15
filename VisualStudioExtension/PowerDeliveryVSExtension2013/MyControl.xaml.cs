using EnvDTE;
using Microsoft.VisualStudio.Shell;
using Microsoft.VisualStudio.TeamFoundation.Build;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace JaymeEdwards.PowerDeliveryVSExtension2013
{
    /// <summary>
    /// Interaction logic for MyControl.xaml
    /// </summary>
    public partial class MyControl : UserControl
    {
        public MyControl()
        {
            InitializeComponent();

            clientControl.UrlOpened += clientControl_UrlOpened;
        }

        public IVsTeamFoundationBuild TfsBuild { get; set; }
        public Package Package { get; set; }

        void clientControl_UrlOpened(object sender, PowerDelivery.Controls.UrlOpenedEventArgs e)
        {
            TfsBuild.DetailsManager.OpenBuild(new Uri(e.Url));
        }
    }
}
