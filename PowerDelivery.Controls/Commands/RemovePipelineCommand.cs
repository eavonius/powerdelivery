using System;
using System.Windows;
using System.Windows.Input;
using System.Windows.Navigation;

using System.Management.Automation;

using PowerDelivery.Controls;
using PowerDelivery.Controls.Pages;

namespace PowerDelivery.Controls.Commands
{
    public class DeletePipelineCommand : PowerShellCommand
    {
        public string Name { get; set; }
        public string CollectionURL { get; set; }
        public string ProjectName { get; set; }

        public new bool CanExecute(object parameter)
        {
            return true;
        }

        public new void Execute(object parameter)
        {
            
        }

        public void BuildCommand()
        {
            if (string.IsNullOrWhiteSpace(Name) || Name.Contains(" "))
            {
                throw new Exception("Name is required and must have no spaces.");
            }
            if (string.IsNullOrWhiteSpace(CollectionURL))
            {
                throw new Exception("Collection URL is required.");
            }
            if (string.IsNullOrWhiteSpace(ProjectName))
            {
                throw new Exception("Project name is required.");
            }

            Script = string.Format("Remove-Pipeline -Project '{0}' -Collection '{1}' -Name {2}", 
                ProjectName, CollectionURL, Name);
        }
    }
}