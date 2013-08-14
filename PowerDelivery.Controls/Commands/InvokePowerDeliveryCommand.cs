using System;
using System.Windows;
using System.Windows.Input;
using System.Windows.Navigation;

using System.Management.Automation;

using PowerDelivery.Controls;
using PowerDelivery.Controls.Pages;

namespace PowerDelivery.Controls.Commands
{
    public class InvokePowerDeliveryCommand : PowerShellCommand
    {
        public string ScriptName { get; set; }

        public new bool CanExecute(object parameter)
        {
            return true;
        }

        public new void Execute(object parameter)
        {
            
        }

        public void BuildCommand()
        {
            if (string.IsNullOrWhiteSpace(ScriptName) || ScriptName.Contains(" "))
            {
                throw new Exception("Script name is required and must have no spaces.");
            }

            Script = string.Format("Invoke-Powerdelivery .\\{0}", ScriptName);
        }
    }
}