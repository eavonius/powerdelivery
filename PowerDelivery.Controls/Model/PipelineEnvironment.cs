using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Microsoft.TeamFoundation.Client;
using Microsoft.TeamFoundation.Framework.Common;
using Microsoft.TeamFoundation.Build.Client;
using Microsoft.TeamFoundation.Build.Workflow;
using System.Threading;
using System.ComponentModel;
using System.Collections.ObjectModel;
using Microsoft.TeamFoundation.TestManagement.Client;

namespace PowerDelivery.Controls.Model
{
    public class PipelineEnvironment : INotifyPropertyChanged
    {
        PipelineEnvironmentBuildStatus _lastStatus;
        string _lastBuildNumber;
        DateTime _lastBuildFinishTime;
        List<Build> _builds;

        public DeliveryPipeline Pipeline { get; private set; }
        public string EnvironmentName { get; private set; }
        public IBuildDefinition BuildDefinition { get; set; }
        public bool IsPolling { get; set; }
        public event PropertyChangedEventHandler PropertyChanged;

        public List<Build> Builds
        {
            get { return _builds; }

            private set
            {
                if (value != _builds)
                {
                    _builds = value;

                    OnPropertyChanged("Builds");
                }
            }
        }

        public PipelineEnvironmentBuildStatus LastStatus 
        {
            get { return _lastStatus; }
            
            private set
            {
                if (value != _lastStatus)
                {
                    _lastStatus = value;

                    OnPropertyChanged("LastStatus");
                }
            }
        }
        
        public string LastBuildNumber 
        {
            get { return _lastBuildNumber; }

            private set
            {
                if (value != _lastBuildNumber)
                {
                    _lastBuildNumber = value;

                    OnPropertyChanged("LastBuildNumber");
                    OnPropertyChanged("LastBuildFinishString");
                }
            }
        }

        public DateTime LastBuildFinishTime 
        {
            get { return _lastBuildFinishTime; }
            
            private set
            {
                if (value != _lastBuildFinishTime)
                {
                    _lastBuildFinishTime = value;

                    OnPropertyChanged("LastBuildFinishTime");
                    OnPropertyChanged("LastBuildFinishString");
                }
            }
        }

        public PipelineEnvironment(DeliveryPipeline pipeline, string environmentName, IBuildDefinition buildDefinition)
        {
            Pipeline = pipeline;
            EnvironmentName = environmentName;
            BuildDefinition = buildDefinition;

            Builds = new List<Build>();

            LastStatus = new PipelineEnvironmentBuildStatus(BuildStatus.None);
            LastBuildFinishTime = DateTime.MinValue;
            LastBuildNumber = "0";

            StartPolling();
        }

        public void StartPolling()
        {
            IsPolling = true;

            Task pollStatus = Task.Factory.StartNew(() =>
            {
                while (IsPolling)
                {
                    RefreshStatus();

                    Thread.Sleep(5000);
                }
            });
        }

        private void RefreshStatus()
        {
            bool isQueued = false;

            ITestManagementService testManagementService = BuildDefinition.BuildServer.TeamProjectCollection.GetService<ITestManagementService>();
            ITestManagementTeamProject testManagementTeamProject = testManagementService.GetTeamProject(Pipeline.ProjectName);

            IQueuedBuildsView queuedBuildsView = BuildDefinition.BuildServer.CreateQueuedBuildsView(new Uri[] { BuildDefinition.Uri });

            queuedBuildsView.StatusFilter = QueueStatus.InProgress | QueueStatus.Queued;
            queuedBuildsView.QueryOptions = QueryOptions.Controllers;

            queuedBuildsView.Refresh(false);

            if (queuedBuildsView.QueuedBuilds.Length > 0) 
            {
                IQueuedBuild nextQueuedBuild = queuedBuildsView.QueuedBuilds.OrderBy(b => b.QueuePosition).First();

                LastStatus = new PipelineEnvironmentBuildStatus(BuildStatus.InProgress);

                isQueued = true;
            }
            
            IOrderedEnumerable<IBuildDetail> existingBuilds = BuildDefinition.QueryBuilds().OrderByDescending(b => b.StartTime);

            Builds.Clear();

            bool foundStatusBuild = false;

            foreach (IBuildDetail build in existingBuilds)
            {
                Builds.Add(new Build(build, testManagementTeamProject));

                try
                {
                    if (!foundStatusBuild)
                    {
                        IDictionary<string, object> processParams = WorkflowHelpers.DeserializeProcessParameters(build.ProcessParameters);

                        if (EnvironmentName == "Commit" || processParams.ContainsKey("PriorBuild"))
                        {
                            if (!isQueued)
                            {
                                LastStatus = new PipelineEnvironmentBuildStatus(build.Status);
                            }

                            LastBuildFinishTime = build.FinishTime;

                            if (EnvironmentName == "Commit")
                            {
                                LastBuildNumber = new Build(build, testManagementTeamProject).Number.ToString();
                            }
                            else if (EnvironmentName == "Production")
                            {
                                string buildUriString = build.Uri.ToString();

                                string buildUri = buildUriString.Contains("?") ? buildUriString.Substring(0, buildUriString.IndexOf("?")) : buildUriString;

                                string buildUriPrefix = buildUri.Substring(0, buildUri.LastIndexOf("/") + 1);

                                Uri commitBuildUri = new Uri(string.Format("{0}{1}", buildUriPrefix, processParams["PriorBuild"] as string));

                                IBuildDetail[] buildDetail = BuildDefinition.BuildServer.QueryBuildsByUri(new Uri[] { commitBuildUri }, new string[] { "*" }, QueryOptions.Definitions);

                                processParams = WorkflowHelpers.DeserializeProcessParameters(buildDetail[0].ProcessParameters);

                                LastBuildNumber = processParams["PriorBuild"] as string;
                            }
                            else
                            {
                                LastBuildNumber = processParams["PriorBuild"] as string;
                            }

                            foundStatusBuild = true;
                        }
                    }
                }
                catch (Exception) {}
            }

            if (foundStatusBuild)
            {
                return;
            }

            if (!isQueued)
            {
                LastStatus = new PipelineEnvironmentBuildStatus(BuildStatus.None);
            }

            LastBuildFinishTime = DateTime.MinValue;
            LastBuildNumber = "0";
        }

        public void Promote(int buildNumber)
        {
            IBuildRequest request = BuildDefinition.CreateBuildRequest();   
            
            IDictionary<string, object> processParams = WorkflowHelpers.DeserializeProcessParameters(request.ProcessParameters);

            processParams["PriorBuild"] = buildNumber.ToString();

            request.ProcessParameters = WorkflowHelpers.SerializeProcessParameters(processParams);

            IQueuedBuild queuedBuild = BuildDefinition.BuildServer.QueueBuild(request);
        }

        public IBuildDetail[] GetPromotableBuilds(int targetEnvironmentBuildNumber)
        {
            try
            {
                List<IBuildDetail> promotableBuilds = new List<IBuildDetail>();

                foreach (IBuildDetail buildDetail in BuildDefinition.QueryBuilds())
                {
                    if (buildDetail.BuildFinished && buildDetail.Status == BuildStatus.Succeeded)
                    {
                        if (targetEnvironmentBuildNumber > 0)
                        {
                            string buildUriString = buildDetail.Uri.ToString();

                            string buildUri = buildUriString.Contains("?") ? buildUriString.Substring(0, buildUriString.IndexOf("?")) : buildUriString;

                            int sourceBuildNumber = Int32.Parse(buildUri.Substring(buildUri.LastIndexOf("/") + 1));

                            if (sourceBuildNumber > targetEnvironmentBuildNumber)
                            {
                                promotableBuilds.Add(buildDetail);
                            }
                        }
                        else
                        {
                            promotableBuilds.Add(buildDetail);
                        }
                    }
                }

                return promotableBuilds.ToArray();

            }
            catch (Exception ex)
            {
                throw new Exception(string.Format("Unable to get builds from TFS, error message was:\n\n{0}", ex.Message));
            }
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

        protected void OnPropertyChanged(string propertyName)
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
            }
        }
    }
}