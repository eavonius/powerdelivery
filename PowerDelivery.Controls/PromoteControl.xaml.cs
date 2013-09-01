using System;
using System.IO;
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

using PowerDelivery.Controls.Pages;
using PowerDelivery.Controls.Dialogs;
using PowerDelivery.Controls.Model;
using Microsoft.TeamFoundation.Build.Client;

namespace PowerDelivery.Controls
{
    /// <summary>
    /// Interaction logic for PromoteControl.xaml
    /// </summary>
    public partial class PromoteControl : UserControl
    {
        Home _home;

        public PromoteControl(Home home)
        {
            _home = home;

            InitializeComponent();
        }

        public PipelineEnvironment Environment { get; set; }
        public PipelineEnvironment NextEnvironment { get; set; }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            ClientConfiguration.Current.StopPolling();

            _home.ShowProgress("Retrieving builds sufficient for promotion...");

            Task.Factory.StartNew(() =>
            {
                IList<BuildNumber> buildNumbers = null;

                try
                {
                    int lastGoodBuildNumber = Int32.Parse(NextEnvironment.LastBuildNumber);

                    buildNumbers = Environment.GetPromotableBuilds(lastGoodBuildNumber);

                    if (buildNumbers.Count == 0)
                    {
                        Dispatcher.Invoke(new Action(delegate()
                        {
                            _home.HideProgress();
                            MessageBox.Show(string.Format("No successful {0} builds newer than the one in {1} are available for promotion.", Environment.EnvironmentName, NextEnvironment.EnvironmentName), "No promotable builds", MessageBoxButton.OK, MessageBoxImage.Information);
                        }), System.Windows.Threading.DispatcherPriority.Background);
                        
                        return;
                    }

                    Dispatcher.Invoke(new Action(delegate()
                    {
                        _home.HideProgress();
                    }), System.Windows.Threading.DispatcherPriority.Background);
                }
                catch (Exception ex)
                {
                    Dispatcher.Invoke(new Action(delegate()
                    {
                        _home.HideProgress();
                        MessageBox.Show(ex.Message, "Error loading builds for promotion", MessageBoxButton.OK, MessageBoxImage.Error);
                    }), System.Windows.Threading.DispatcherPriority.Background);
                }

                if (buildNumbers.Count > 0)
                {
                    Dispatcher.Invoke(new Action(delegate()
                    {
                        PromoteBuildDialog dlg = new PromoteBuildDialog(buildNumbers, Environment, NextEnvironment);

                        dlg.ShowDialog();

                        if (dlg.DialogResult.Value)
                        {
                            int selectedBuildNumber = dlg.SelectedBuildNumber;

                            if (selectedBuildNumber > 0)
                            {
                                NextEnvironment.Promote(selectedBuildNumber);
                            }
                        }

                        ClientConfiguration.Current.StartPolling();

                    }), System.Windows.Threading.DispatcherPriority.Background);
                }
            });
        }
    }
}