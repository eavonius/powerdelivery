using System;
using System.IO;
using Extensibility;
using Microsoft.VisualStudio.CommandBars;
using EnvDTE;
using EnvDTE80;

using System.Reflection;

namespace PowerDeliveryVSAddin
{
	/// <summary>
    /// Visual Studio Addin for powerdelivery.
    /// </summary>
	/// <seealso class='IDTExtensibility2' />
	public class Connect : IDTExtensibility2, IDTCommandTarget
	{
        AddIn _addin;
        Windows2 _windows;
        Window _documentWindow;
        string _addinPath;

        Guid powerDeliveryToolWindowId = new Guid("1E7C1152-A7C5-4170-A2B3-940719F50E35");

		/// <summary>
        /// Implements the constructor for the Add-in object. Place your initialization code within this method.
        /// </summary>
		public Connect()
		{
		}

		/// <summary>
        /// Implements the OnConnection method of the IDTExtensibility2 interface. Receives notification that the Add-in is being loaded.
        /// </summary>
		/// <param term='application'>Root object of the host application.</param>
		/// <param term='connectMode'>Describes how the Add-in is being loaded.</param>
		/// <param term='addInInst'>Object representing this Add-in.</param>
		/// <seealso class='IDTExtensibility2' />
		public void OnConnection(object application, ext_ConnectMode connectMode, object addInInst, ref Array custom)
		{
			_applicationObject = (DTE2)application;
			_addInInstance = (AddIn)addInInst;

            // TODO: Check why this check isn't working
            //if (connectMode == ext_ConnectMode.ext_cm_UISetup)
            //{
                object[] contextGUIDS = new object[] { };
                Commands2 commands = (Commands2)_applicationObject.Commands;
                string toolsMenuName = "View";

                // Place the command on the tools menu.
                // Find the MenuBar command bar, which is the top-level command bar holding all the main menu items:
                Microsoft.VisualStudio.CommandBars.CommandBar menuBarCommandBar = ((Microsoft.VisualStudio.CommandBars.CommandBars)_applicationObject.CommandBars)["MenuBar"];

                //Find the Tools command bar on the MenuBar command bar:
                CommandBarControl toolsControl = menuBarCommandBar.Controls[toolsMenuName];
                CommandBarPopup toolsPopup = (CommandBarPopup)toolsControl;

                // This try/catch block can be duplicated if you wish to add multiple commands to be handled by your Add-in,
                // just make sure you also update the QueryStatus/Exec method to include the new command names.
                try
                {
                    //Add a command to the Commands collection:
                    Command command = commands.AddNamedCommand2(_addInInstance, 
                        "Pipelines", 
                        "Powerdelivery", 
                        "Opens the powerdelivery deployment pipelines page.", 
                        true, 
                        59, 
                        ref contextGUIDS, 
                        (int)vsCommandStatus.vsCommandStatusSupported + (int)vsCommandStatus.vsCommandStatusEnabled, 
                        (int)vsCommandStyle.vsCommandStylePictAndText, 
                        vsCommandControlType.vsCommandControlTypeButton);

                    //Add a control for the command to the tools menu:
                    if ((command != null) && (toolsPopup != null))
                    {
                        command.AddControl(toolsPopup.CommandBar, 1);
                    }
                }
                catch (System.ArgumentException)
                {
                    //If we are here, then the exception is probably because a command with that name
                    //  already exists. If so there is no need to recreate the command and we can 
                    //  safely ignore the exception.
                }
            //}

            _addin = _applicationObject.AddIns.Item(1);
            _windows = (Windows2)_applicationObject.Windows;

            string assemblyCodeBase = Assembly.GetAssembly(this.GetType()).CodeBase;
            UriBuilder uriBuilder = new UriBuilder(assemblyCodeBase);
            string path = Uri.UnescapeDataString(uriBuilder.Path);
            _addinPath = Path.Combine(Path.GetDirectoryName(path), "PowerDeliveryVSAddin.dll");

            ShowDocumentWindow();
		}

		/// <summary>Implements the OnDisconnection method of the IDTExtensibility2 interface. Receives notification that the Add-in is being unloaded.</summary>
		/// <param term='disconnectMode'>Describes how the Add-in is being unloaded.</param>
		/// <param term='custom'>Array of parameters that are host application specific.</param>
		/// <seealso class='IDTExtensibility2' />
		public void OnDisconnection(ext_DisconnectMode disconnectMode, ref Array custom)
		{
		}

		/// <summary>Implements the OnAddInsUpdate method of the IDTExtensibility2 interface. Receives notification when the collection of Add-ins has changed.</summary>
		/// <param term='custom'>Array of parameters that are host application specific.</param>
		/// <seealso class='IDTExtensibility2' />		
		public void OnAddInsUpdate(ref Array custom)
		{
		}

		/// <summary>Implements the OnStartupComplete method of the IDTExtensibility2 interface. Receives notification that the host application has completed loading.</summary>
		/// <param term='custom'>Array of parameters that are host application specific.</param>
		/// <seealso class='IDTExtensibility2' />
		public void OnStartupComplete(ref Array custom)
		{
		}

		/// <summary>Implements the OnBeginShutdown method of the IDTExtensibility2 interface. Receives notification that the host application is being unloaded.</summary>
		/// <param term='custom'>Array of parameters that are host application specific.</param>
		/// <seealso class='IDTExtensibility2' />
		public void OnBeginShutdown(ref Array custom)
		{
		}

        /// <summary>Implements the QueryStatus method of the IDTCommandTarget interface. This is called when the command's availability is updated</summary>
        /// <param term='commandName'>The name of the command to determine state for.</param>
        /// <param term='neededText'>Text that is needed for the command.</param>
        /// <param term='status'>The state of the command in the user interface.</param>
        /// <param term='commandText'>Text requested by the neededText parameter.</param>
        /// <seealso class='Exec' />
        public void QueryStatus(string commandName, vsCommandStatusTextWanted neededText, ref vsCommandStatus status, ref object commandText)
        {
            if (neededText == vsCommandStatusTextWanted.vsCommandStatusTextWantedNone)
            {
                if (commandName == "PowerDeliveryVSAddin.Connect.Pipelines")
                {
                    status = (vsCommandStatus)vsCommandStatus.vsCommandStatusSupported | vsCommandStatus.vsCommandStatusEnabled;
                    return;
                }
            }
        }

        /// <summary>Implements the Exec method of the IDTCommandTarget interface. This is called when the command is invoked.</summary>
        /// <param term='commandName'>The name of the command to execute.</param>
        /// <param term='executeOption'>Describes how the command should be run.</param>
        /// <param term='varIn'>Parameters passed from the caller to the command handler.</param>
        /// <param term='varOut'>Parameters passed from the command handler to the caller.</param>
        /// <param term='handled'>Informs the caller if the command was handled or not.</param>
        /// <seealso class='Exec' />
        public void Exec(string commandName, vsCommandExecOption executeOption, ref object varIn, ref object varOut, ref bool handled)
        {
            handled = false;

            if (executeOption == vsCommandExecOption.vsCommandExecOptionDoDefault)
            {
                if (commandName == "PowerDeliveryVSAddin.Connect.Pipelines")
                {
                    ShowDocumentWindow();

                    handled = true;
                    return;
                }
            }
        }

        private void ShowDocumentWindow()
        {
            object controlObject = null;

            if (_documentWindow == null)
            {
                _documentWindow = _windows.CreateToolWindow2(_addin,
                    _addinPath,
                    "PowerDeliveryVSAddin.ClientDocument",
                    "Powerdelivery",
                    powerDeliveryToolWindowId.ToString(),
                    ref controlObject);
            }

            _documentWindow.IsFloating = false;
            _documentWindow.Visible = true;
            _documentWindow.Linkable = false;
        }

		private DTE2 _applicationObject;
		private AddIn _addInInstance;
	}
}