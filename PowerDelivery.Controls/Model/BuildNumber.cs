using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Microsoft.TeamFoundation.Build.Client;

namespace PowerDelivery.Controls.Model
{
    public class BuildNumber
    {
        public BuildNumber(IBuildDetail build)
        {
            string buildUri = build.Uri.ToString();
            Number = Int32.Parse(buildUri.Substring(buildUri.LastIndexOf("/") + 1));

            DisplayString = string.Format("{0} (Build succeeded on {1} at {2})",
                        Number,
                        build.FinishTime.ToShortDateString(),
                        build.FinishTime.ToShortTimeString());
        }

        public int Number
        {
            get;
            private set;
        }

        public string DisplayString
        {
            get;
            private set;
        }
    }
}