using System;
using System.Windows;
using System.Windows.Input;
using System.Windows.Navigation;

using System.Management.Automation;

using PowerDelivery.Controls;
using PowerDelivery.Controls.Pages;

namespace PowerDelivery.Controls.Commands
{
    public class AddPipelineCommand : PowerShellCommand
    {
        public string Name { get; set; }
        public string CollectionURL { get; set; }
        public string DropFolder { get; set; }
        public string BuildController { get; set; }
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
            if (string.IsNullOrWhiteSpace(BuildController))
            {
                throw new Exception("Build Controller is required.");
            }
            if (string.IsNullOrWhiteSpace(CollectionURL))
            {
                throw new Exception("Collection URL is required.");
            }
            if (string.IsNullOrWhiteSpace(DropFolder) || !DropFolder.StartsWith("\\"))
            {
                throw new Exception("Drop Folder must be a UNC path beginning with \\\\.");
            }
            if (string.IsNullOrWhiteSpace(ProjectName))
            {
                throw new Exception("Project name is required.");
            }

            //Script = "ls C:\\Windows\\System32\\*.*";

            Script = string.Format("Add-Pipeline -Project '{0}' -Collection '{1}' -Controller '{2}' -DropFolder '{3}' -Name {4}", 
                ProjectName, CollectionURL, BuildController, DropFolder, Name);
        }
    }
}