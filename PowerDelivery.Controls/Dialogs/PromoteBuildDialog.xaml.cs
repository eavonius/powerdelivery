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

namespace PowerDelivery.Controls.Dialogs
{
    /// <summary>
    /// Interaction logic for PromoteBuildDialog.xaml
    /// </summary>
    public partial class PromoteBuildDialog : Window
    {
        public PromoteBuildDialog(PipelineEnvironment environment, PipelineEnvironment nextEnvironment)
        {
            DataContext = this;

            Environment = environment;
            NextEnvironment = nextEnvironment;

            PageTitle = string.Format("Promote {0} to {1}", Environment.Pipeline.ScriptName, NextEnvironment.EnvironmentName);
            PageDescription = string.Format("Select a successful {0} build to promote to {1}.", Environment.EnvironmentName, NextEnvironment.EnvironmentName);

            InitializeComponent();

            lblPromote.Text = string.Format("{0} Build to Promote:  ", Environment.EnvironmentName);

            SelectedBuildNumber = 0;

            try
            {
                int lastGoodBuildNumber = Int32.Parse(NextEnvironment.LastBuildNumber);

                PromotableBuilds = Environment.GetPromotableBuilds(lastGoodBuildNumber);

                if (PromotableBuilds.Length == 0)
                {
                    MessageBox.Show(string.Format("No successful {0} builds newer than the one in {1} are available for promotion.", Environment.EnvironmentName, NextEnvironment.EnvironmentName), "No promotable builds", MessageBoxButton.OK, MessageBoxImage.Information);
                    Close();
                }

                List<BuildNumber> buildNumbers = new List<BuildNumber>();

                foreach (IBuildDetail build in PromotableBuilds)
                {
                    buildNumbers.Add(new BuildNumber(build));
                }

                cboBuilds.ItemsSource = buildNumbers.OrderByDescending(b => b.Number);

                if (PromotableBuilds.Length > 0)
                {
                    cboBuilds.SelectedIndex = 0;
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error loading builds for promotion", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        public string PageTitle { get; set; }
        public string PageDescription { get; set; }

        public IBuildDetail[] PromotableBuilds { get; set; }
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