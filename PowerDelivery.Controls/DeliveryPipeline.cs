using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PowerDelivery.Controls
{
    public class DeliveryPipeline
    {
        public DeliveryPipeline(ClientCollectionSource source, string projectName, string collectionName)
        {
            Source = source;
            ProjectName = projectName;
            CollectionName = collectionName;
        }

        public ClientCollectionSource Source { get; private set; }
        public string ProjectName { get; private set; }
        public string CollectionName { get; private set; }

        public PipelineEnvironment Commit { get; internal set; }
        public PipelineEnvironment Test { get; internal set; }
        public PipelineEnvironment CapacityTest { get; internal set; }
        public PipelineEnvironment Production { get; internal set; }
    }
}
