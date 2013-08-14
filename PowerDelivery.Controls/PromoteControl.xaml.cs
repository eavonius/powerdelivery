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
            PromoteBuildDialog dlg = new PromoteBuildDialog(Environment, NextEnvironment);

            if (dlg.PromotableBuilds.Length > 0)
            {
                dlg.ShowDialog();

                if (dlg.DialogResult.Value)
                {
                    int selectedBuildNumber = dlg.SelectedBuildNumber;

                    if (selectedBuildNumber > 0)
                    {
                        NextEnvironment.Promote(selectedBuildNumber);
                    }
                }
            }
        }
    }
}