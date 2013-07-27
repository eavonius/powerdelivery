using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PowerDelivery.Controls
{
    public class PipelineEnvironment
    {
        public DeliveryPipeline Pipeline { get; private set; }
        public string EnvironmentName { get; private set; }
        public PipelineEnvironmentBuildStatus LastStatus { get; private set; }
        public string LastBuildNumber { get; private set; }
        public DateTime LastBuildFinishTime { get; private set; }

        public PipelineEnvironment(DeliveryPipeline pipeline, string environmentName, PipelineEnvironmentBuildStatus lastStatus, string lastBuildNumber, DateTime lastBuildFinishTime)
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
                return LastBuildFinishTime == DateTime.MinValue ? "Not yet built." : 
                    string.Format("{0} at {1} ({2})", 
                        LastBuildFinishTime.ToShortDateString(), 
                        LastBuildFinishTime.ToShortTimeString(), 
                        LastBuildNumber);
            }
        }
    }
}
