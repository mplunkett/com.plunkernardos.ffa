using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string GetCurrentCash(string teamId, string auctionId)
    {
        string resp = "";
        try
        {
            // get total auction amount
            string capQ = "SELECT AuctionDollars FROM League_Season WHERE rid = " + auctionId;
            int totalCash = Int32.Parse(DBUtility.ExecuteScalar(capQ, "FFA"));

            // get what the team has left
            string cashQ = "SELECT ISNULL(SUM(BidAmount),0) As TotalSpend FROM SeasonRosterView WHERE TeamLeagueSeason_rid = " + teamId;
            int spentCash = Int32.Parse(DBUtility.ExecuteScalar(cashQ, "FFA"));

            int cashLeft = totalCash - spentCash;
            resp = cashLeft.ToString();
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string GetHighBid(string teamId, string auctionId)
    {
        string resp = "";
        try
        {
            // get total auction amount
            string capQ = "SELECT AuctionDollars FROM League_Season WHERE rid = " + auctionId;
            int totalCash = Int32.Parse(DBUtility.ExecuteScalar(capQ, "FFA"));

            // get what the team has left
            string cashQ = "SELECT ISNULL(SUM(BidAmount),0) As TotalSpend FROM SeasonRosterView WHERE TeamLeagueSeason_rid = " + teamId;
            int spentCash = Int32.Parse(DBUtility.ExecuteScalar(cashQ, "FFA"));

            int cashLeft = totalCash - spentCash;

            // now get the number of roster slots in league
            string slotQ = "SELECT ISNULL(COUNT(*),0) As SlotCount FROM LeagueRosterSlot WHERE League_Season_rid = " + auctionId;
            int slotCount = Int32.Parse(DBUtility.ExecuteScalar(slotQ, "FFA"));

            // get the slots the teams has filled
            string rosterQ = "SELECT ISNULL(COUNT(rid),0) As RosterCount FROM SeasonRosterView WHERE TeamLeagueSeason_rid = " + teamId;
            int rosterCount = Int32.Parse(DBUtility.ExecuteScalar(rosterQ, "FFA")) + 1; //add one to simulate the offerbid

            int slotsLeft = slotCount - rosterCount;
            int highBid = cashLeft - slotsLeft;
            resp = highBid.ToString();
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string GetRoster(string teamId, string auctionId)
    {
        string resp = "";
        try
        {
            string rosterQ = "SELECT * FROM SeasonRosterView WHERE TeamLeagueSeason_rid = " + teamId + " ORDER BY PlayerPosition_rid";
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(rosterQ, "FFA");
            
            if (ret.Count > 0)
            {
                resp += "<table>";
                for (int i = 0; i < ret.Count; i++)
                {
                    Dictionary<string, string> slot = ret[i];
                    resp += "<tr>";
                    resp += "<td>" + slot["PlayerName"] + "</td>";
                    resp += "<td>" + slot["PositionAbbrev"] + "</td>";
                    resp += "</tr>";
                }
                resp += "</table>";
            }
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }
}