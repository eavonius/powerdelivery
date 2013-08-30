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
using System.Windows.Shapes;

using PowerDelivery.Controls.Model;
using Microsoft.TeamFoundation.Build.Client;
using PowerDelivery.Controls.Pages;

namespace PowerDelivery.Controls.Dialogs
{
    /// <summary>
    /// Interaction logic for PromoteBuildDialog.xaml
    /// </summary>
    public partial class PromoteBuildDialog : Window
    {
        public PromoteBuildDialog(IList<BuildNumber> buildNumbers, PipelineEnvironment environment, PipelineEnvironment nextEnvironment)
        {
            DataContext = this;

            Environment = environment;
            NextEnvironment = nextEnvironment;

            PageTitle = string.Format("Promote {0} to {1}", Environment.Pipeline.ScriptName, NextEnvironment.EnvironmentName);
            PageDescription = string.Format("Select a successful {0} build to promote to {1}.", Environment.EnvironmentName, NextEnvironment.EnvironmentName);

            InitializeComponent();

            lblPromote.Content = string.Format("{0} Build to Promote:  ", Environment.EnvironmentName);

            SelectedBuildNumber = 0;

            cboBuilds.ItemsSource = buildNumbers.OrderByDescending(b => b.Number);

            if (buildNumbers.Count > 0)
            {
                cboBuilds.SelectedIndex = 0;
            }
        }

        public string PageTitle { get; set; }
        public string PageDescription { get; set; }

        public PipelineEnvironment Environment { get; set; }
        public PipelineEnvironment NextEnvironment { get; set; }
        public int SelectedBuildNumber { get; set; }

        protected void btnOK_Click(object sender, RoutedEventArgs e)
        {
            SelectedBuildNumber = (int)cboBuilds.SelectedValue;

            DialogResult = true;

            Close();
        }

        protected void btnCancel_Click(object sender, RoutedEventArgs e)
        {
            DialogResult = false;

            Close();
        }
    }
}