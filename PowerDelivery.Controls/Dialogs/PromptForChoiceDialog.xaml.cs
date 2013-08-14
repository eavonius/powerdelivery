using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Management.Automation.Host;
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

namespace PowerDelivery.Controls.Dialogs
{
    /// <summary>
    /// Interaction logic for PromptForChoiceDialog.xaml
    /// </summary>
    public partial class PromptForChoiceDialog : Window
    {
        List<Choice> _choiceList;

        public PromptForChoiceDialog(string caption, string message, Collection<ChoiceDescription> choices, int defaultChoice)
        {
            Caption = caption;
            Message = message;

            DataContext = this;

            InitializeComponent();

            _choiceList = new List<Choice>();
            
            foreach (ChoiceDescription choiceDescription in choices)
            {
                int choiceIndex = choices.IndexOf(choiceDescription);
                _choiceList.Add(new Choice(choiceDescription, choiceIndex, choiceIndex == defaultChoice));
            }

            itmChoices.ItemsSource = _choiceList;
        }

        public int SelectedChoice
        {
            get
            {
                return _choiceList.First(c => c.Selected == true).Index;
            }
        }

        public string Caption { get; private set; }
        public string Message { get; private set; }

        private void btnOK_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }
    }
}