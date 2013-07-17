using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Microsoft.TeamFoundation.Build.Client;

namespace PowerDeliveryClient
{
    public class PipelineEnvironment
    {
        public DeliveryPipeline Pipeline { get; private set; }
        public string EnvironmentName { get; private set; }
        public string LastStatus { get; private set; }
        public string LastBuildNumber { get; private set; }

        public PipelineEnvironment(DeliveryPipeline pipeline, string environmentName, string lastStatus, string lastBuildNumber)
        {
            Pipeline = pipeline;
            EnvironmentName = environmentName;
            LastStatus = lastStatus;
            LastBuildNumber = lastBuildNumber;
        }
    }
}
