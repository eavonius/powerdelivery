using System;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Collections.Generic;

using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

using System.Management.Automation;
using Microsoft.Win32;
using System.IO;
using System.Diagnostics;
using System.Threading;
using System.Management.Automation.Runspaces;

namespace PowerDelivery.Controls.Pages
{
    /// <summary>
    /// Interaction logic for RunPowerShell.xaml
    /// </summary>
    public partial class RunPowerShell : Page
    {
        Pipeline _pipeline;

        public RunPowerShell(Page previousPage, string title, Commands.PowerShellCommand command)
        {
            PreviousPage = previousPage;
            Title = title;
            Command = command;

            DataContext = this;

            InitializeComponent();

            Loaded += RunPowerShell_Loaded;
        }

        void RunPowerShell_Loaded(object sender, RoutedEventArgs e)
        {
            string powerShellExeLocation = "powershell";

            ProcessStartInfo processInfo = new ProcessStartInfo();
            processInfo.Verb = "runas";
            processInfo.UseShellExecute = false;
            //processInfo.CreateNoWindow = true;
            processInfo.RedirectStandardError = true;
            processInfo.RedirectStandardOutput = true;
            processInfo.WindowStyle = ProcessWindowStyle.Hidden;
            processInfo.WorkingDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
            processInfo.FileName = powerShellExeLocation;
            processInfo.Arguments = "-NoLogo -NonInteractive -ExecutionPolicy -WindowStyle Hidden -OutputFormat Text Unrestricted -Command \"" + Command.Script + "\"";

            Process powerShellProcess = new Process();
            powerShellProcess.StartInfo = processInfo;
            powerShellProcess.EnableRaisingEvents = true;
            powerShellProcess.OutputDataReceived += new DataReceivedEventHandler(powerShellProcess_OutputDataReceived);
            powerShellProcess.ErrorDataReceived += new DataReceivedEventHandler(powerShellProcess_ErrorDataReceived);
            powerShellProcess.Exited += powerShellProcess_Exited;

            if (!powerShellProcess.Start())
            {
                MessageBox.Show(string.Format("Failed to start command, exit code: {0}", powerShellProcess.ExitCode));
            }
        }

        void powerShellProcess_Exited(object sender, EventArgs e)
        {
            Dispatcher.Invoke(() =>
            {
                btnClose.IsEnabled = true;
            });
        }

        private void powerShellProcess_ErrorDataReceived(object sender, DataReceivedEventArgs e)
        {
            Dispatcher.Invoke(() =>
            {
                txtCommandOutput.Text += e.Data;
            });
        }

        private void powerShellProcess_OutputDataReceived(object sender, DataReceivedEventArgs e)
        {
            Dispatcher.Invoke(() =>
            {
                txtCommandOutput.Text += e.Data;
            });  
        }

        public Page PreviousPage { get; set; }
        public Commands.PowerShellCommand Command { get; set; }
    }
}