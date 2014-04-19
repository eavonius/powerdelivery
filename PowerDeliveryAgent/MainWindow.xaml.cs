using System;
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
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Security.Principal;

using System.DirectoryServices;
using System.DirectoryServices.AccountManagement;

namespace PowerDeliveryAgent
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();

            Loaded += MainWindow_Loaded;
        }

        void MainWindow_Loaded(object sender, RoutedEventArgs e)
        {
            AppDomain.CurrentDomain.SetPrincipalPolicy(PrincipalPolicy.WindowsPrincipal);

            WindowsIdentity currentUser = WindowsIdentity.GetCurrent();
            WindowsPrincipal currentUserPrincipal = new WindowsPrincipal(currentUser);

            if (!currentUserPrincipal.IsInRole(WindowsBuiltInRole.Administrator))
            {
                MessageBox.Show("Please run this application as an administrator.");
                Application.Current.Shutdown();
            }
            else
            {
                txtServer.Focus();
            }
        }

        private void btnConfigure_Click(object sender, RoutedEventArgs e)
        {
            string accountName = txtAccountName.Text;
            string serverName = txtServer.Text;

            ConfigurationProgress progress = new ConfigurationProgress(accountName, serverName);

            progress.ShowDialog();
        }
    }
}