using PowerDelivery.Controls.Model;
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

using System.Diagnostics;
using System.Web;
using System.Text.RegularExpressions;

namespace PowerDelivery.Controls.Pages
{
    /// <summary>
    /// Interaction logic for PipelineEnvironment.xaml
    /// </summary>
    public partial class ShowPipelineEnvironment : Page
    {
        public PipelineEnvironment Environment { get; private set; }

        public ShowPipelineEnvironment(PipelineEnvironment environment)
        {
            Environment = environment;

            DataContext = environment;

            InitializeComponent();

            txtTitle.Text = string.Format("{0} Releases of {1}", environment.EnvironmentName, environment.Pipeline.ScriptName);
        }

        static string UrlEncodeUpperCase(string value)
        {
            value = HttpUtility.UrlEncode(value);
            return Regex.Replace(value, "(%[0-9a-f][0-9a-f])", c => c.Value.ToUpper());
        }

        private void btnBuilds_Click(object sender, RoutedEventArgs e)
        {
            //if (ClientConfiguration.Current.IsInVisualStudio)
            
            Process.Start(string.Format("{0}/{1}/{2}/_build#definitionUri={3}&_a=completed",
                Environment.Pipeline.PortalUrl.TrimEnd('/'),
                Environment.Pipeline.Source.Name,
                Environment.Pipeline.ProjectName,
                HttpUtility.UrlEncode(Environment.BuildDefinition.Uri.ToString())));
        }
    }
}