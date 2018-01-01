using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class Main : System.Web.UI.MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        //string User = System.Web.HttpContext.Current.User.Identity.Name;
        //int domainStart = User.IndexOf("\\");
        //string UserName = User.Substring(domainStart + 1);

        //string verifyQ = "SELECT * FROM Manager WHERE SystemUserName = '" + UserName + "'";
        //Dictionary<int, Dictionary<string, string>> result = DBUtility.SqlRead(verifyQ, "FFA");
        //if (result.Count > 0)
        //{
        //    Dictionary<string, string> userResult = result[0];
        //    LoggedUserVal.Value = userResult["rid"];

        //    string getValQ = "SELECT * FROM TEMP_UserTeamMap WHERE Manager_rid = " + userResult["rid"];
        //    Dictionary<int, Dictionary<string, string>> valRet = DBUtility.SqlRead(getValQ, "FFA");
        //    Dictionary<string, string> valObj = valRet[0];

        //    LoggedAuctionVal.Value = valObj["LeagueSeason_rid"];
        //    LoggedTeamVal.Value = valObj["TeamLeagueSeason_rid"];
        //    LoggedTeamName.Value = valObj["TeamName"];
        //}
        //else
        //{
        //    // redirect
        //}
        LoggedAuctionVal.Value = "1";
        LoggedUserVal.Value = "1";
        LoggedTeamVal.Value = "1";
        LoggedTeamName.Value = "Los Plunkernardos";
    }

}
