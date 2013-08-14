using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation.Host;
using System.Text;
using System.Threading.Tasks;

namespace PowerDelivery.Controls.Model
{
    public class Choice
    {
        public string Label { get; private set; }
        public string HelpMessage { get; private set; }
        public int Index { get; private set; }
        public bool Selected { get; set; }

        public Choice(ChoiceDescription choiceDescription, int index, bool selected) 
        {
            Label = choiceDescription.Label.Replace("&", "");
            HelpMessage = choiceDescription.HelpMessage;
            Index = index;
            Selected = selected;
        }
    }
}