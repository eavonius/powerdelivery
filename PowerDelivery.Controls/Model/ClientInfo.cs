using System;
using System.Linq;
using System.Reflection;
using System.Collections.Generic;
using System.Management.Automation;
using System.Runtime.InteropServices;

namespace PowerDelivery.Controls.Model
{
    public class ClientInfo
    {
        public ClientInfo()
        {
            PowerShell getVersionScript = PowerShell.Create(RunspaceMode.NewRunspace);
            getVersionScript.AddScript("if (get-module -listavailable -name powerdelivery) { (get-module -listavailable -name powerdelivery | select version).Version.ToString() } else { 'Not Found' }");

            try
            {
                IEnumerable<PSObject> results = getVersionScript.Invoke();
                ModuleVersion = results.First().ToString();
            }
            catch (Exception)
            {
                ModuleVersion = "Not Found";
            }

            PowerShell getModulesScript = PowerShell.Create(RunspaceMode.NewRunspace);
            getModulesScript.AddScript("get-module -listavailable -name \"*DeliveryModule\" | select name, version");

            Modules = new List<DeliveryModule>();

            try
            {
                IEnumerable<PSObject> results = getModulesScript.Invoke();

                foreach (PSObject result in results)
                {
                    PSPropertyInfo nameProperty = result.Properties["Name"];
                    PSPropertyInfo versionProperty = result.Properties["Version"];

                    Modules.Add(new DeliveryModule(nameProperty.Value as string, (versionProperty.Value as System.Version).ToString()));
                }
            }
            catch (Exception) {}

            ClientVersion = Assembly.GetAssembly(typeof(ClientControl)).GetName().Version.ToString();

            List<AssemblyName> assemblies = new List<AssemblyName>();

            Assembly clientAssembly = Assembly.GetExecutingAssembly();
            AssemblyName[] referencedAssemblies = clientAssembly.GetReferencedAssemblies();

            assemblies.Add(clientAssembly.GetName());
            assemblies.AddRange(referencedAssemblies);

            Assemblies = assemblies.OrderBy(a => a.Name).ToList();

            DotNetVersion = RuntimeEnvironment.GetSystemVersion();

            PowerShell getTemplatesScript = PowerShell.Create(RunspaceMode.NewRunspace);
            getTemplatesScript.AddScript("gci (join-path (get-module -listavailable -name powerdelivery).ModuleBase Templates) | select name");

            Templates = new List<string>();

            try
            {
                IEnumerable<PSObject> results = getTemplatesScript.Invoke();

                foreach (PSObject result in results)
                {
                    Templates.Add(result.Members["Name"].Value as string);
                }
            }
            catch (Exception) {}
        }

        public string ModuleVersion { get; private set; }
        public string ClientVersion { get; private set; }
        public string DotNetVersion { get; private set; }

        public List<DeliveryModule> Modules { get; set; }
        public List<AssemblyName> Assemblies { get; set; }
        public List<string> Templates { get; set; }
    }
}