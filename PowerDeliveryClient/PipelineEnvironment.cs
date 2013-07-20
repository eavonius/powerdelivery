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
        public DateTime LastBuildFinishTime { get; private set; }

        public PipelineEnvironment(DeliveryPipeline pipeline, string environmentName, string lastStatus, string lastBuildNumber, DateTime lastBuildFinishTime)
        {
            Pipeline = pipeline;
            EnvironmentName = environmentName;
            LastStatus = lastStatus;
            LastBuildNumber = lastBuildNumber;
            LastBuildFinishTime = lastBuildFinishTime;
        }

        public string LastBuildFinishString
        {
            get
            {
                return LastBuildFinishTime == DateTime.MinValue ? "" : 
                    string.Format("{0} at {1} ({2})", 
                        LastBuildFinishTime.ToShortDateString(), 
                        LastBuildFinishTime.ToShortTimeString(), 
                        LastBuildNumber);
            }
        }
    }
}
