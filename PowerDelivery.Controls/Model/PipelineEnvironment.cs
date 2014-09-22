using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;

using Microsoft.TeamFoundation.Client;
using Microsoft.TeamFoundation.Framework.Common;
using Microsoft.TeamFoundation.Build.Client;
using Microsoft.TeamFoundation.Build.Workflow;
using System.Threading;
using System.ComponentModel;
using System.Collections.ObjectModel;

namespace PowerDelivery.Controls.Model
{
    public class PipelineEnvironment : INotifyPropertyChanged
    {
        Uri _lastBuildUri;
        PipelineEnvironmentBuildStatus _lastStatus;
        string _lastBuildNumber;
        DateTime _lastBuildFinishTime;
        //List<Build> _builds;
        IQueuedBuildsView _queuedBuildsView;
        IBuildDetailSpec _buildSpec;

        public DeliveryPipeline Pipeline { get; private set; }
        public string EnvironmentName { get; private set; }
        public IBuildDefinition BuildDefinition { get; set; }
        public bool IsPolling { get; set; }
        public event PropertyChangedEventHandler PropertyChanged;
        public Visibility IsCommitBuildVisibility { get; set; }

        /*
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
        */

        public Uri LastBuildUri
        {
            get { return _lastBuildUri; }
            set { _lastBuildUri = value; OnPropertyChanged("LastBuildUri"); }
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

            IsCommitBuildVisibility = EnvironmentName.Equals("Commit", StringComparison.InvariantCultureIgnoreCase) ? Visibility.Visible : Visibility.Collapsed;

            LastStatus = new PipelineEnvironmentBuildStatus(null);
            LastBuildFinishTime = DateTime.MaxValue;
            LastBuildNumber = "0";

            _queuedBuildsView = BuildDefinition.BuildServer.CreateQueuedBuildsView(new Uri[] { BuildDefinition.Uri });

            _queuedBuildsView.StatusFilter = QueueStatus.InProgress | QueueStatus.Queued;
            _queuedBuildsView.QueryOptions = QueryOptions.Definitions;

            _buildSpec = Pipeline.Source.BuildServer.CreateBuildDetailSpec(BuildDefinition);
            _buildSpec.InformationTypes = null;
            
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

            _queuedBuildsView.Refresh(false);

            if (_queuedBuildsView.QueuedBuilds.Length > 0) 
            {
                IQueuedBuild nextQueuedBuild = _queuedBuildsView.QueuedBuilds.OrderBy(b => b.QueuePosition).First();

                if (nextQueuedBuild.Build != null)
                {
                    LastBuildUri = nextQueuedBuild.Build.Uri;
                }
                
                LastStatus = new PipelineEnvironmentBuildStatus(BuildStatus.InProgress);

                isQueued = true;
            }

            if (!isQueued)
            {
                IOrderedEnumerable<IBuildDetail> existingBuilds = BuildDefinition.BuildServer.QueryBuilds(_buildSpec).Builds.OrderByDescending(b => b.StartTime);

                bool foundStatusBuild = false;

                foreach (IBuildDetail build in existingBuilds)
                {
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

                                LastBuildUri = build.Uri;

                                if (EnvironmentName == "Commit")
                                {
                                    LastBuildNumber = new Build(build).Number.ToString();
                                }
                                else if (EnvironmentName == "Production")
                                {
                                    string buildUriString = build.Uri.ToString();

                                    string buildUri = buildUriString.Contains("?") ? buildUriString.Substring(0, buildUriString.IndexOf("?")) : buildUriString;

                                    string buildUriPrefix = buildUri.Substring(0, buildUri.LastIndexOf("/") + 1);

                                    Uri commitBuildUri = new Uri(string.Format("{0}{1}", buildUriPrefix, processParams["PriorBuild"] as string));

                                    IBuildDetail buildDetail = BuildDefinition.BuildServer.GetMinimalBuildDetails(commitBuildUri);

                                    processParams = WorkflowHelpers.DeserializeProcessParameters(buildDetail.ProcessParameters);

                                    LastBuildNumber = processParams["PriorBuild"] as string;
                                }
                                else
                                {
                                    LastBuildNumber = processParams["PriorBuild"] as string;
                                }

                                foundStatusBuild = true;
                                break;
                            }
                        }
                    }
                    catch (Exception) { }
                }

                if (foundStatusBuild)
                {
                    return;
                }
                else
                {
                    LastBuildNumber = "0";
                    LastBuildUri = null;
                    LastStatus = new PipelineEnvironmentBuildStatus(BuildStatus.None);
                    LastBuildFinishTime = DateTime.MinValue;
                }
            }
        }

        public void Promote(int buildNumber)
        {
            IBuildRequest request = BuildDefinition.CreateBuildRequest();   
            
            IDictionary<string, object> processParams = WorkflowHelpers.DeserializeProcessParameters(request.ProcessParameters);

            processParams["PriorBuild"] = buildNumber.ToString();

            request.ProcessParameters = WorkflowHelpers.SerializeProcessParameters(processParams);

            IQueuedBuild queuedBuild = BuildDefinition.BuildServer.QueueBuild(request);
        }

        public void QueueCommitBuild()
        {
            IBuildRequest request = BuildDefinition.CreateBuildRequest();

            IQueuedBuild queuedBuild = BuildDefinition.BuildServer.QueueBuild(request);
        }

        public IList<BuildNumber> GetPromotableBuilds(int targetEnvironmentBuildNumber)
        {
            try
            {
                List<BuildNumber> promotableBuilds = new List<BuildNumber>();

                IBuildDetailSpec buildSpec = Pipeline.Source.BuildServer.CreateBuildDetailSpec(BuildDefinition);
                buildSpec.InformationTypes = null;
                buildSpec.Status = BuildStatus.Succeeded;

                IBuildQueryResult buildDetails = Pipeline.Source.BuildServer.QueryBuilds(buildSpec);

                foreach (IBuildDetail buildDetail in buildDetails.Builds)
                {
                    if (buildDetail.BuildFinished)
                    {
                        IDictionary<string, object> processParams = WorkflowHelpers.DeserializeProcessParameters(buildDetail.ProcessParameters);

                        Build build = new Build(buildDetail);

                        int visibleBuildNumber = build.Number;

                        if (EnvironmentName == "Production")
                        {
                            string buildUriString = buildDetail.Uri.ToString();

                            string buildUri = buildUriString.Contains("?") ? buildUriString.Substring(0, buildUriString.IndexOf("?")) : buildUriString;

                            string buildUriPrefix = buildUri.Substring(0, buildUri.LastIndexOf("/") + 1);

                            Uri commitBuildUri = new Uri(string.Format("{0}{1}", buildUriPrefix, processParams["PriorBuild"] as string));

                            IBuildDetail commitBuildDetail = BuildDefinition.BuildServer.GetMinimalBuildDetails(commitBuildUri);

                            IDictionary<string, object> commitProcessParams = WorkflowHelpers.DeserializeProcessParameters(commitBuildDetail.ProcessParameters);

                            visibleBuildNumber = Int32.Parse((string)commitProcessParams["PriorBuild"]);
                        }
                        else if (EnvironmentName != "Commit")
                        {
                            visibleBuildNumber = Int32.Parse((string)processParams["PriorBuild"]);
                        }

                        if (targetEnvironmentBuildNumber > 0)
                        {
                            if (visibleBuildNumber > targetEnvironmentBuildNumber)
                            {
                                promotableBuilds.Add(new BuildNumber(build, visibleBuildNumber));
                            }
                        }
                        else
                        {
                            promotableBuilds.Add(new BuildNumber(build, visibleBuildNumber));
                        }
                    }
                }

                return promotableBuilds;

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
                if (LastBuildFinishTime == DateTime.MaxValue)
                {
                    return "";
                }
                else if (LastBuildFinishTime == DateTime.MinValue)
                {
                    return "No releases found.";
                }
                else
                {
                    return string.Format("{0} at {1} ({2})",
                            LastBuildFinishTime.ToShortDateString(),
                            LastBuildFinishTime.ToShortTimeString(),
                            LastBuildNumber);
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