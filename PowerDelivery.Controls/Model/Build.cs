using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Microsoft.TeamFoundation.Build.Client;
using System.ComponentModel;

namespace PowerDelivery.Controls.Model
{
    public class Build : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        IBuildDetail _build;

        int _number;
        string _requestedBy;
        PipelineEnvironmentBuildStatus _status;
        DateTime _finishDate;
        
        public Build(IBuildDetail build)
        {
            _build = build;
        
            string buildUriString = build.Uri.ToString();

            string buildUri = buildUriString.Contains("?") ? buildUriString.Substring(0, buildUriString.IndexOf("?")) : buildUriString;

            Number = Int32.Parse(buildUri.Substring(buildUri.LastIndexOf("/") + 1));

            RequestedBy = build.RequestedFor;
            Status = new PipelineEnvironmentBuildStatus(build.Status);
            FinishDate = build.FinishTime;
        }

        public IBuildDetail BuildDetail
        {
            get { return _build; }
        }

        /*
        private void CalculateTotals()
        {
            _totalTests = 0;
            _failedTests = 0;
            _succeededTests = 0;

            foreach (ITestRun testRun in _testRuns)
            {
                ITestCaseResultCollection passedTests = testRun.QueryResultsByOutcome(TestOutcome.Passed);
                ITestCaseResultCollection failedTests = testRun.QueryResultsByOutcome(TestOutcome.Failed);
                ITestCaseResultCollection totalTests = testRun.QueryResultsByOutcome(TestOutcome.MaxValue);

                _totalTests += totalTests.Count;
                _failedTests += failedTests.Count;
                _succeededTests += passedTests.Count;
            }

            OnPropertyChanged("TotalTests");
            OnPropertyChanged("FailedTests");
            OnPropertyChanged("SucceededTests");
        }

        public int TotalTests
        {
            get
            {
                lock (_totalsCalcLock)
                {
                    if (_totalTests == -1)
                    {
                        lock (_totalsCalcLock)
                        {
                            CalculateTotals();
                        }
                    }
                }
                return _totalTests;
            }
        }

        public int FailedTests
        {
            get
            {
                lock (_totalsCalcLock)
                {
                    if (_failedTests == -1)
                    {
                        lock (_totalsCalcLock)
                        {
                            CalculateTotals();
                        }
                    }
                }
                return _failedTests;
            }
        }

        public int SucceededTests
        {
            get
            {
                lock (_totalsCalcLock)
                {
                    if (_totalTests == -1)
                    {
                        lock (_totalsCalcLock)
                        {
                            CalculateTotals();
                        }
                    }
                }
                return _totalTests;
            }
        }*/

        public int Number
        {
            get { return _number; }
            set { _number = value; OnPropertyChanged("Number"); }
        }

        /*
         *  TODO: DONT DELETE, TEST OUTCOME INFO
         * 
        public IEnumerable<ITestResult> FailedTests
        {
            get
            {
                if (_failedTests == null)
                {
                    _failedTests = new List<ITestCaseResult>();

                    foreach (ITestRun testRun in _testRuns)
                    {
                        ITestCaseResultCollection failedTests = testRun.QueryResultsByOutcome(TestOutcome.Failed);
                        _failedTests.AddRange(failedTests);
                    }
                }
                return _failedTests;
            }
        }*/

        public PipelineEnvironmentBuildStatus Status
        {
            get { return _status; }
            set { _status = value; OnPropertyChanged("Status"); }
        }

        public DateTime FinishDate
        {
            get { return _finishDate; }
            set { _finishDate = value; OnPropertyChanged("FinishDate"); }
        }

        public string RequestedBy
        {
            get { return _requestedBy; }
            set { _requestedBy = value; OnPropertyChanged("RequestedBy"); }
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