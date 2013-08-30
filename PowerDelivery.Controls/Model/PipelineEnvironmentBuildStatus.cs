using Microsoft.TeamFoundation.Build.Client;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PowerDelivery.Controls.Model
{
    public class PipelineEnvironmentBuildStatus : INotifyPropertyChanged
    {
        string _description;

        public event PropertyChangedEventHandler PropertyChanged;

        public PipelineEnvironmentBuildStatus(BuildStatus? status)
        {
            if (!status.HasValue)
            {
                Description = "Loading";
            }
            else
            {
                Status = status.Value;

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
        }

        public BuildStatus Status { get; private set; }

        public string Description 
        {
            get { return _description; }
        
            private set
            {
                if (_description != value)
                {
                    _description = value;

                    OnPropertyChanged("Description");
                }
            }
        }

        protected void OnPropertyChanged(string propertyName)
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
            }
        }
    }
}