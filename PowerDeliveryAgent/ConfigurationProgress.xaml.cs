using System;
using System.Threading;
using System.Collections;
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
using System.Windows.Shapes;

using System.Management.Automation;
using System.Management.Automation.Host;
using System.Management.Automation.Runspaces;
using System.DirectoryServices;

namespace PowerDeliveryAgent
{
    /// <summary>
    /// Interaction logic for ConfigurationProgress.xaml
    /// </summary>
    public partial class ConfigurationProgress : Window
    {
        bool _failed = false;

        private string _accountName, _serverName;

        public ConfigurationProgress(string accountName, string serverName)
        {
            _accountName = accountName;
            _serverName = serverName;

            InitializeComponent();

            txtProgress.Text = "";

            ThreadStart newThreadStart = new ThreadStart(DoConfiguration);
            Thread newThread = new Thread(newThreadStart);

            newThread.Start();
        }

        private void DoConfiguration()
        {
            string[] accountNameSegments = _accountName.Split('\\');
            string accountDomain = accountNameSegments[0];
            string accountUsername = accountNameSegments[1];

            string computerName = Environment.MachineName;

            DirectoryEntry computerEntry = new DirectoryEntry(string.Format("WinNT://{0}", computerName));
            DirectoryEntry adminsEntry = computerEntry.Children.Find("Administrators", "group");

            object adminMembers = null;

            try
            {
                adminMembers = adminsEntry.Invoke("Members", null);
            }
            catch (Exception)
            {
                _failed = true;

                Dispatcher.BeginInvoke(new Action(delegate()
                {
                    txtProgress.Text += string.Format("Unable to retrieve list of Administrators members on {0}.", computerName);
                }), System.Windows.Threading.DispatcherPriority.Background);

                return;
            }

            bool userIsAdmin = false;

            foreach (object adminMember in (IEnumerable)adminMembers)
            {
                DirectoryEntry adminMemberEntry = new DirectoryEntry(adminMember);

                if (adminMemberEntry.Name.Equals(accountUsername, StringComparison.InvariantCultureIgnoreCase))
                {
                    Dispatcher.BeginInvoke(new Action(delegate() 
                    {
                        txtProgress.Text += string.Format("Found user {0} already as member of local Administrators group.", _accountName);
                    }), System.Windows.Threading.DispatcherPriority.Background);
                    
                    userIsAdmin = true;
                }
            }

            if (!userIsAdmin)
            {
                Dispatcher.BeginInvoke(new Action(delegate() 
                {
                    txtProgress.Text += string.Format("Adding user {0} to local Administrators group.", _accountName);
                }), System.Windows.Threading.DispatcherPriority.Background);

                try
                {
                    adminsEntry.Invoke("Add", new DirectoryEntry("WinNT://{0}/{1}", accountDomain, accountUsername).Path);
                }
                catch (Exception exAddUser)
                {
                    _failed = true;

                    Dispatcher.BeginInvoke(new Action(delegate()
                    {
                        txtProgress.Text += string.Format("Unable to add user {0} to local Administrators group. Message was {1}", _accountName, exAddUser.Message);
                    }), System.Windows.Threading.DispatcherPriority.Background);

                    return;
                }
            }

            Dispatcher.BeginInvoke(new Action(delegate()
            {
                txtProgress.Text += "\n\nConfiguration successful! Click Finish to continue.";

                btnFinish.IsEnabled = true;
            }), System.Windows.Threading.DispatcherPriority.Background);
        }

        private void btnFinish_Click(object sender, RoutedEventArgs e)
        {
            DialogResult = !_failed;

            Close();
        }
    }
}