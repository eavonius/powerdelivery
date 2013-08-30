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
        public BuildNumber(Build build, int visibleNumber)
        {
            Number = build.Number;

            DisplayString = string.Format("{0} (Build succeeded on {1} at {2})",
                        visibleNumber,
                        build.BuildDetail.FinishTime.ToShortDateString(),
                        build.BuildDetail.FinishTime.ToShortTimeString());
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