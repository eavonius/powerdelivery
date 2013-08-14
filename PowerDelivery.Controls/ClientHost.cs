using PowerDelivery.Controls.Dialogs;
using PowerDelivery.Controls.Pages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation.Host;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Documents;
using System.Windows.Media;

namespace PowerDelivery.Controls
{
    public class ClientHost : PSHost
    {
        RunPowerShell _page;
        ClientHostUserInterface _ui;
        Guid _id;

        public ClientHost(RunPowerShell page)
        {
            _id = Guid.NewGuid();
            _page = page;

            _ui = new ClientHostUserInterface(this);
        }

        public RunPowerShell Page 
        { 
            get { return _page; } 
        }

        public override PSHostUserInterface UI
        {
            get { return _ui; }
        }

        public override System.Globalization.CultureInfo CurrentCulture
        {
            get { return Thread.CurrentThread.CurrentCulture; }
        }

        public override System.Globalization.CultureInfo CurrentUICulture
        {
            get { return Thread.CurrentThread.CurrentUICulture; }
        }

        public override void EnterNestedPrompt()
        {
            throw new NotImplementedException();
        }

        public override void ExitNestedPrompt()
        {
            throw new NotImplementedException();
        }

        public override Guid InstanceId
        {
            get { return _id; }
        }

        public override string Name
        {
            get { return "Powerdelivery Client Host"; }
        }

        public override void NotifyBeginApplication()
        {
            
        }

        public override void NotifyEndApplication()
        {
            
        }

        public override void SetShouldExit(int exitCode)
        {
            if (exitCode == 0)
            {

            }
        }

        public override Version Version
        {
            get { return new Version(3, 0); }
        }
    }

    public class ClientHostUserInterface : PSHostUserInterface
    {
        ClientHostRawUserInterface _rawUI;

        public ClientHost Host { get; private set; }

        public ClientHostUserInterface(ClientHost host)
        {
            Host = host;

            _rawUI = new ClientHostRawUserInterface(this);
        }

        public override Dictionary<string, System.Management.Automation.PSObject> Prompt(string caption, string message, System.Collections.ObjectModel.Collection<FieldDescription> descriptions)
        {
            throw new NotImplementedException();
        }

        public override int PromptForChoice(string caption, string message, System.Collections.ObjectModel.Collection<ChoiceDescription> choices, int defaultChoice)
        {
            int result = -1;

            if (caption.Equals("Security Warning", StringComparison.CurrentCultureIgnoreCase))
            {
                return 1;
            }
            else if (caption.Equals("Execution Policy Change", StringComparison.CurrentCultureIgnoreCase))
            {
                return 0;
            }

            Host.Page.Dispatcher.Invoke(new Action(delegate() 
                {
                    PromptForChoiceDialog dlg = new PromptForChoiceDialog(caption, message, choices, defaultChoice);
                    dlg.ShowDialog();
                    result = dlg.SelectedChoice;
                }));

            return result;
        }

        public override System.Management.Automation.PSCredential PromptForCredential(string caption, string message, string userName, string targetName, System.Management.Automation.PSCredentialTypes allowedCredentialTypes, System.Management.Automation.PSCredentialUIOptions options)
        {
            throw new NotImplementedException();
        }

        public override System.Management.Automation.PSCredential PromptForCredential(string caption, string message, string userName, string targetName)
        {
            throw new NotImplementedException();
        }

        public override PSHostRawUserInterface RawUI
        {
            get { return _rawUI; }
        }

        public override string ReadLine()
        {
            throw new NotImplementedException();
        }

        public override System.Security.SecureString ReadLineAsSecureString()
        {
            throw new NotImplementedException();
        }

        public override void Write(ConsoleColor foregroundColor, ConsoleColor backgroundColor, string value)
        {
            Color color = (Color)ColorConverter.ConvertFromString(foregroundColor.ToString());

            if (foregroundColor == ConsoleColor.White) {
                color = (Color)ColorConverter.ConvertFromString("#F1F1F1");
            }

            Host.Page.AppendText(color, value);
        }

        public override void Write(string value)
        {
            Host.Page.AppendText((Color)ColorConverter.ConvertFromString("#F1F1F1"), value);
        }

        public override void WriteDebugLine(string message)
        {
            Host.Page.AppendText((Color)ColorConverter.ConvertFromString("#F1F1F1"), message);
        }

        public override void WriteErrorLine(string value)
        {
            Host.Page.AppendText(Colors.Red, value);
        }

        public override void WriteLine(string value)
        {
            Host.Page.AppendText((Color)ColorConverter.ConvertFromString("#F1F1F1"), value);
        }

        public override void WriteProgress(long sourceId, System.Management.Automation.ProgressRecord record)
        {
            
        }

        public override void WriteVerboseLine(string message)
        {
            Host.Page.AppendText((Color)ColorConverter.ConvertFromString("#F1F1F1"), message);
        }

        public override void WriteWarningLine(string message)
        {
            Host.Page.AppendText((Color)ColorConverter.ConvertFromString("#F1F1F1"), message);
        }
    }

    class ClientHostRawUserInterface : PSHostRawUserInterface
    {
        private ClientHostUserInterface _ui;

        public ClientHostRawUserInterface(ClientHostUserInterface ui)
        {
            _ui = ui;
        }

        public override ConsoleColor BackgroundColor
        {
            get
            {
                return ConsoleColor.Gray;
            }
            set
            {
                throw new NotImplementedException();
            }
        }

        public override System.Management.Automation.Host.Size BufferSize
        {
            get
            {
                return new System.Management.Automation.Host.Size(600, 600);
            }
            set
            {
                throw new NotImplementedException();
            }
        }

        public override Coordinates CursorPosition
        {
            get
            {
                return new Coordinates();
            }
            set
            {
                throw new NotImplementedException();
            }
        }

        public override int CursorSize
        {
            get
            {
                return 10;
            }
            set
            {
                throw new NotImplementedException();
            }
        }

        public override void FlushInputBuffer()
        {
            throw new NotImplementedException();
        }

        public override ConsoleColor ForegroundColor
        {
            get
            {
                return ConsoleColor.White;
            }
            set
            {
                throw new NotImplementedException();
            }
        }

        public override BufferCell[,] GetBufferContents(Rectangle rectangle)
        {
            throw new NotImplementedException();
        }

        public override bool KeyAvailable
        {
            get { throw new NotImplementedException(); }
        }

        public override System.Management.Automation.Host.Size MaxPhysicalWindowSize
        {
            get { throw new NotImplementedException(); }
        }

        public override System.Management.Automation.Host.Size MaxWindowSize
        {
            get { throw new NotImplementedException(); }
        }

        public override KeyInfo ReadKey(ReadKeyOptions options)
        {
            throw new NotImplementedException();
        }

        public override void ScrollBufferContents(Rectangle source, Coordinates destination, Rectangle clip, BufferCell fill)
        {
            throw new NotImplementedException();
        }

        public override void SetBufferContents(Rectangle rectangle, BufferCell fill)
        {
            throw new NotImplementedException();
        }

        public override void SetBufferContents(Coordinates origin, BufferCell[,] contents)
        {
            throw new NotImplementedException();
        }

        public override Coordinates WindowPosition
        {
            get
            {
                throw new NotImplementedException();
            }
            set
            {
                throw new NotImplementedException();
            }
        }

        public override System.Management.Automation.Host.Size WindowSize
        {
            get
            {
                throw new NotImplementedException();
            }
            set
            {
                throw new NotImplementedException();
            }
        }

        public override string WindowTitle
        {
            get
            {
                throw new NotImplementedException();
            }
            set
            {
                throw new NotImplementedException();
            }
        }
    }
}