using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;
using System.ComponentModel;
using System.Collections.Generic;
using System.Collections.ObjectModel;

using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Threading;
using System.Windows.Shapes;

using System.Management.Automation;
using System.Management.Automation.Host;
using System.Management.Automation.Runspaces;

using Microsoft.Win32;

using PowerDelivery.Controls.Commands;

namespace PowerDelivery.Controls.Pages
{
    /// <summary>
    /// Interaction logic for RunPowerShell.xaml
    /// </summary>
    public partial class RunPowerShell : Page
    {
        public Page PreviousPage { get; set; }
        public Commands.PowerShellCommand Command { get; set; }

        Runspace _runspace;
        Pipeline _pipeline;
        Func<bool> _onSuccess;
        Func<bool> _onFailure;

        bool _result = false;
        string _workingDirectory;
        string _originalDirectory;

        public RunPowerShell(Page previousPage, string title, Commands.PowerShellCommand command, string workingDirectory, Func<bool> onSuccess, Func<bool> onFailure)
        {
            PreviousPage = previousPage;
            Title = title;
            Command = command;
            _onSuccess = onSuccess;
            _onFailure = onFailure;
            _workingDirectory = workingDirectory;
            _originalDirectory = Environment.CurrentDirectory;

            DataContext = this;

            InitializeComponent();

            txtCommandOutput.AppendText("Initializing PowerShell Environment...\r\n");

            txtCommandOutput.Document.PageWidth = 10000;

            Loaded += RunPowerShell_Loaded;
            Unloaded += RunPowerShell_Unloaded;
        }

        void RunPowerShell_Unloaded(object sender, RoutedEventArgs e)
        {
            if (_pipeline.PipelineStateInfo.State == PipelineState.Running)
            {
                _pipeline.Stop();
            }

            Environment.CurrentDirectory = _originalDirectory;

            _runspace.Close();
        }

        void RunPowerShell_Loaded(object sender, RoutedEventArgs e)
        {
            InitialSessionState state = InitialSessionState.CreateDefault();

            ClientHost clientHost = new ClientHost(this);

            _runspace = RunspaceFactory.CreateRunspace(clientHost, state);

            if (_workingDirectory != null)
            {
                Environment.CurrentDirectory = _workingDirectory;
            }

            try
            {
                _runspace.Open();

                _pipeline = _runspace.CreatePipeline();

                //Command setExecutionPolicyCommand = new System.Management.Automation.Runspaces.Command("Set-ExecutionPolicy");
                //setExecutionPolicyCommand.Parameters.Add("ExecutionPolicy", "Unrestricted");
                //setExecutionPolicyCommand.Parameters.Add("Scope", "User");
                //setExecutionPolicyCommand.Parameters.Add("Force", new SwitchParameter(true));
                //_pipeline.Commands.Add(setExecutionPolicyCommand);

                _pipeline.Commands.AddScript(Command.Script);

                _pipeline.Output.DataReady += Output_DataReady;
                _pipeline.Error.DataReady += Error_DataReady;

                _pipeline.Input.Close();
                _pipeline.InvokeAsync();
            }
            finally
            {
                Environment.CurrentDirectory = _originalDirectory;
            }
        }

        public void AppendText(Color foregroundColor, string text)
        {
            try
            {
                this.Dispatcher.Invoke(
                    new Action(delegate() 
                    {
                        if (!(txtCommandOutput.Document.Blocks.LastBlock is Paragraph))
                        {
                            txtCommandOutput.Document.Blocks.Add(new Paragraph(new Run(text) { Foreground = new SolidColorBrush(foregroundColor) }));
                        }
                        else
                        {
                            ((Paragraph)txtCommandOutput.Document.Blocks.LastBlock).Inlines.Add(
                                    new Run(text) { Foreground = new SolidColorBrush(foregroundColor) });
                        }
                    
                        txtCommandOutput.ScrollToEnd();
                    }), DispatcherPriority.Background);
            }
            catch (TaskCanceledException)
            {
                _result = false;

                _pipeline.StopAsync();

                Environment.CurrentDirectory = _originalDirectory;
            }
        }
        
        void Error_DataReady(object sender, EventArgs e)
        {
            Collection<object> data = _pipeline.Error.NonBlockingRead();

            foreach (object o in data)
            {
                AppendText(Colors.Red, string.Format("{0}\r\n", o.ToString()));
            }
        }
        
        void Output_DataReady(object sender, EventArgs e)
        {
            Collection<PSObject> data = _pipeline.Output.NonBlockingRead();

            foreach (PSObject o in data)
            {
                AppendText((Color)ColorConverter.ConvertFromString("#F1F1F1"), o.ToString() + "\r\n");
            }

            if (_pipeline.Output.EndOfPipeline)
            {
                Environment.CurrentDirectory = _originalDirectory;

                if (_pipeline.PipelineStateInfo.State == PipelineState.Failed)
                {
                    AppendText(Colors.Red, string.Format("Script Error: {0}\r\n", _pipeline.PipelineStateInfo.Reason));

                    Dispatcher.Invoke(new Action(delegate() 
                    {
                        txtStatus.Content = "Script failed.";
                    }));

                    _result = false;
                }
                else
                {
                    _result = true;
                }

                Dispatcher.Invoke(new Action(delegate() 
                {
                    try
                    {
                        txtStatus.Content = string.Format("Script {0}", _pipeline.PipelineStateInfo.State.ToString());
                    }
                    catch (TaskCanceledException)
                    {
                        Environment.CurrentDirectory = _originalDirectory;
                        _result = false;
                    }
                }));

                try
                {
                    this.Dispatcher.Invoke(new Action(delegate() 
                        {
                            btnClose.IsEnabled = true;
                            btnStop.IsEnabled = false;
                        }));
                }
                catch (TaskCanceledException) { Environment.CurrentDirectory = _originalDirectory; _result = false; }
            }
        }

        private void btnStop_Click(object sender, RoutedEventArgs e)
        {
            if (_pipeline.PipelineStateInfo.State == PipelineState.Running)
            {
                if (MessageBox.Show("Are you sure you want to cancel the script?\n\nThis could leave your deployment pipeline in a broken state!", "Confirm cancel script", MessageBoxButton.YesNo, MessageBoxImage.Question) == MessageBoxResult.Yes)
                {
                    Environment.CurrentDirectory = _originalDirectory;

                    _pipeline.StopAsync();

                    btnClose.IsEnabled = true;
                    btnStop.IsEnabled = false;

                    txtStatus.Content = "Script Stopped";

                    _result = false;
                }
            }
        }

        private void btnClose_Click(object sender, RoutedEventArgs e)
        {
            if (_result)
            {
                Dispatcher.Invoke(new Action(delegate() 
                {
                    _onSuccess();
                }));
            }
            else
            {
                Dispatcher.Invoke(new Action(delegate() 
                    {
                        _onFailure();
                    }));
            }
        }
    }
}