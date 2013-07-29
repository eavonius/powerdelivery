using Microsoft.TeamFoundation.Build.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PowerDelivery.Controls.Model
{
    public class PipelineEnvironmentBuildStatus
    {
        public PipelineEnvironmentBuildStatus(BuildStatus status)
        {
            Status = status;

            switch (status)
            {
                case BuildStatus.InProgress:
                    Description = "In Progress";
                    break;
                case BuildStatus.Failed:
                    Description = "Failed";
                    break;
                case BuildStatus.None:
                    Description = "Unknown Status";
                    break;
                case BuildStatus.NotStarted:
                    Description = "Unknown Status";
                    break;
                case BuildStatus.PartiallySucceeded:
                    Description = "Partially Succeeded";
                    break;
                case BuildStatus.Stopped:
                    Description = "Stopped";
                    break;
                case BuildStatus.Succeeded:
                    Description = "Succeeded";
                    break;
            }
        }

        public BuildStatus Status { get; private set; }
        public string Description { get; private set; }
    }
}
