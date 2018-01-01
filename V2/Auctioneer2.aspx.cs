using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class V2_Auctioneer2 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string OfferRefresh(string offerId, string auctionId, string userId)
    {
        string resp = "";
        try
        {
            string checkQ = "SELECT * FROM CurrentOfferView WHERE League_Season_rid = " + auctionId;
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(checkQ, "FFA");

            if (ret.Count > 0)
            {
                Dictionary<string, string> retObj = ret[0];
                string currentOffer = retObj["OfferRid"];

                if (currentOffer != offerId)
                {
                    resp = JsonConvert.SerializeObject(retObj);
                }
                else
                {
                    resp = JsonConvert.SerializeObject(retObj);
                }
            }
            else
            {
                resp = "OK";
            }
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string BidRefresh(string offerId, string auctionId, string userId, string bidId)
    {
        string resp = "";
        try
        {
            string checkQ = "SELECT * FROM CurrentBidView WHERE OfferRid = " + offerId;
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(checkQ, "FFA");

            if (ret.Count > 0)
            {
                Dictionary<string, string> retObj = ret[0];
                string currentBid = retObj["Bid_rid"];

                if (currentBid != bidId)
                {
                    resp = JsonConvert.SerializeObject(retObj);
                }
                else
                {
                    resp = JsonConvert.SerializeObject(retObj);
                }
            }
            else
            {
                resp = "OK";
            }
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string BidHistory(string offerId)
    {
        string resp = "";
        try
        {
            string bidQ = "SELECT TOP 10 * FROM BidHistoryView WHERE AuctionOffering_rid = " + offerId + " ORDER BY BidTimeStamp DESC";
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(bidQ, "FFA");
            resp += "<table class='table'>";
            resp += "<thead><tr><th>Team</th><th>Amt.</th><th>Time</th></tr></thead><tbody>";

            for (int i = 0; i < ret.Count; i++)
            {
                Dictionary<string, string> bid = ret[i];
                resp += "<tr>";
                resp += "<td>" + bid["TeamName"] + "</td>";
                resp += "<td>" + bid["BidAmount"] + "</td>";
                resp += "<td>" + bid["BidTime"] + "</td>";
                resp += "</tr>";
            }

            resp += "</tbody><table>";
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string SellOffer(string bidId, string sellStep, string offerId, string auctionId)
    {
        string resp = "";
        try
        {
            // first make sure that the bid is still the most up to date
            string currentBidQ = "SELECT Bid_rid FROM CurrentBidView WHERE OfferRid = " + offerId;
            string curBidId = DBUtility.ExecuteScalar(currentBidQ, "FFA");
            if (bidId != curBidId)
            {
                // new bid is there send back cancel message
                resp = "CANCEL";
            }
            else
            {
                if (sellStep == "3")
                {
                    // final step so sell it
                    string playerQ = "SELECT Player_rid FROM AuctionOffering WHERE rid = " + offerId;
                    string playerId = DBUtility.ExecuteScalar(playerQ, "FFA");
                    string teamQ = "SELECT Team_LeagueSeason_rid FROM AuctionBid WHERE rid = " + bidId;
                    string teamId = DBUtility.ExecuteScalar(teamQ, "FFA");

                    // update offer
                    string updtOfferQ = "UPDATE AuctionOffering SET OfferingStatus = 'Sold', WinningBid_rid = " + bidId + " WHERE rid = " + offerId;
                    DBUtility.ExecuteSql(updtOfferQ, "FFA");

                    // update bid
                    string updtBidQ = "UPDATE AuctionBid SET WinningBidFlag = 1 WHERE rid = " + bidId;
                    DBUtility.ExecuteSql(updtBidQ, "FFA");

                    // insert to roster
                    string instRosterQ = "INSERT INTO SeasonRoster (TeamLeagueSeason_rid,Player_rid,Bid_rid) VALUES (" + teamId + "," + playerId + "," + bidId + ")";
                    DBUtility.ExecuteSql(instRosterQ, "FFA");

                    // now create the new offer row
                    string offerQ = "SELECT * FROM OfferView WHERE OfferRid = " + offerId;
                    Dictionary<int, Dictionary<string, string>> offerRet = DBUtility.SqlRead(offerQ, "FFA");
                    Dictionary<string, string> offerRetObj = offerRet[0];

                    // first see if the auction is over
                    int roundNo = Int32.Parse(offerRetObj["LastRound"]);
                    int totalRounds = Int32.Parse(offerRetObj["TotalRounds"]);
                    if (roundNo < totalRounds)
                    {
                        // more auction to go. get the next person to offer
                        roundNo++;
                        string newOfferround = roundNo.ToString();
                        string teamOfferQ = "";
                        int previousAuctionOrder = Int32.Parse(offerRetObj["AuctionOrder"]);
                        int totalTeams = Int32.Parse(offerRetObj["TeamTotal"]);
                        if (previousAuctionOrder < totalTeams)
                        {
                            previousAuctionOrder++;
                            string newOfferTeam = previousAuctionOrder.ToString();
                            teamOfferQ = "SELECT rid FROM Team_LeagueSeason WHERE LeagueSeason_rid = " + auctionId + " AND AuctionOrder = " + newOfferTeam;
                        }
                        else
                        {
                            teamOfferQ = "SELECT rid FROM Team_LeagueSeason WHERE LeagueSeason_rid = " + auctionId + " AND AuctionOrder = 1";
                        }
                        string newTeamId = DBUtility.ExecuteScalar(teamOfferQ, "FFA");
                        string instOfferQ = "INSERT INTO AuctionOffering (League_Season_rid,Team_LeagueSeason_rid,OfferingStatus,AuctionRound) VALUES (" + auctionId + "," + newTeamId + ",'New'," + newOfferround + ")";
                        DBUtility.ExecuteSql(instOfferQ, "FFA");
                    }

                    resp = "SOLD";
                }
                else
                {
                    resp = "OK";
                }
            }
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }
}