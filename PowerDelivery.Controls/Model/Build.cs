using Microsoft.TeamFoundation.Build.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PowerDelivery.Controls.Model
{
    public class Build
    {
        IBuildDetail _build;

        public Build(IBuildDetail build)
        {
            _build = build;
        }
    }
}