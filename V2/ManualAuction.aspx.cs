using System;
using System.Collections.Generic;
using System.Web.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class V2_ManualAuction : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string OfferModListLoad(string positionId, string auctionId)
    {
        string resp = "";
        try
        {
            // get the season to pull the correct list of playerseason
            string seasonQ = "SELECT Season_rid FROM League_Season WHERE rid = " + auctionId;
            string seasonRid = DBUtility.ExecuteScalar(seasonQ, "FFA");

            string playerQ = "SELECT p.* FROM NewOfferPlayerView p LEFT OUTER JOIN AuctionOffering a ON p.rid = a.Player_rid AND a.League_Season_rid = " + auctionId;
            playerQ += " WHERE p.PlayerPosition_rid = " + positionId + " AND a.rid IS NULL ORDER BY p.FPro_Rank";
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(playerQ, "FFA");

            resp = JsonConvert.SerializeObject(ret);
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string OfferModPlayerSelect(string playerId, string positionId, string auctionId)
    {
        string resp = "";
        try
        {
            // get the season
            string seasonQ = "SELECT Season_rid FROM League_Season WHERE rid = " + auctionId;
            string seasonId = DBUtility.ExecuteScalar(seasonQ, "FFA");

            string statQ = "";
            switch (positionId)
            {
                case "1":
                    statQ = "SELECT * FROM QuarterBackStatView WHERE rid = " + playerId + " AND Season_rid = " + seasonId;
                    break;
                case "2":
                    statQ = "SELECT * FROM RunningBackStatView WHERE rid = " + playerId + " AND Season_rid = " + seasonId;
                    break;
                case "3":
                    statQ = "SELECT * FROM WideReceiverStatView WHERE rid = " + playerId + " AND Season_rid = " + seasonId;
                    break;
                case "4":
                    statQ = "SELECT * FROM TightEndStatView WHERE rid = " + playerId + " AND Season_rid = " + seasonId;
                    break;
                case "5":
                    statQ = "SELECT * FROM KickerStatView WHERE rid = " + playerId + " AND Season_rid = " + seasonId;
                    break;
                case "6":
                    statQ = "SELECT * FROM DefenseStatView WHERE rid = " + playerId + " AND Season_rid = " + seasonId;
                    break;
                default:
                    break;
            }

            Dictionary<int, Dictionary<string, string>> statRet = DBUtility.SqlRead(statQ, "FFA");
            Dictionary<string, string> statObj = statRet[0];
            string playerName = statObj["PlayerName"].ToString();

            List<string> statKeys = new List<string>();
            foreach (string key in statObj.Keys)
            {
                if (key.Contains("FPro_") || key.Contains("Proj_"))
                {
                    statKeys.Add(key);
                }
            }

            resp += "<h3>" + playerName + "</h3>";
            resp += "<table class='table' id='PlayerStatTbl'>";
            resp += "<tbody>";
            foreach (string stat in statKeys)
            {
                resp += "<tr>";
                resp += "<td><strong>";
                resp += stat;
                resp += "</strong></td>";
                resp += "<td>";
                resp += statObj[stat];
                resp += "</td>";
                resp += "</tr>";
            }
            resp += "</tbody>";
            resp += "</table>";
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string PlayerRefresh(string playId)
    {
        string resp = "";
        try
        {
            string pQ = "SELECT * FROM PlayerSeasonView WHERE rid = " + playId;
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(pQ, "FFA");
            Dictionary<string, string> retObj = ret[0];
            resp = JsonConvert.SerializeObject(retObj);
        }
        catch
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string StatRefresh(string playId)
    {
        string resp = "";
        try
        {
            //string posQ = "SELECT Position_rid, PlayerSeason_rid, Season_rid FROM CurrentOfferView WHERE OfferRid = " + playId;
            string posQ = "SELECT p.PlayerPosition_rid, ps.rid, ps.Season_rid FROM Player_Season ps LEFT OUTER JOIN Player p ON ps.Player_rid = p.rid WHERE ps.rid = " + playId;
            Dictionary<int, Dictionary<string, string>> posRet = DBUtility.SqlRead(posQ, "FFA");
            Dictionary<string, string> posObj = posRet[0];
            string posId = posObj["PlayerPosition_rid"].ToString();
            string seasonId = posObj["Season_rid"].ToString();
            string playerId = posObj["rid"].ToString();

            string statQ = "";
            switch (posId)
            {
                case "1":
                    statQ = "SELECT * FROM QuarterBackStatView WHERE rid = " + playerId + " AND Season_rid = " + seasonId;
                    break;
                case "2":
                    statQ = "SELECT * FROM RunningBackStatView WHERE rid = " + playerId + " AND Season_rid = " + seasonId;
                    break;
                case "3":
                    statQ = "SELECT * FROM WideReceiverStatView WHERE rid = " + playerId + " AND Season_rid = " + seasonId;
                    break;
                case "4":
                    statQ = "SELECT * FROM TightEndStatView WHERE rid = " + playerId + " AND Season_rid = " + seasonId;
                    break;
                case "5":
                    statQ = "SELECT * FROM KickerStatView WHERE rid = " + playerId + " AND Season_rid = " + seasonId;
                    break;
                case "6":
                    statQ = "SELECT * FROM DefenseStatView WHERE rid = " + playerId + " AND Season_rid = " + seasonId;
                    break;
                default:
                    break;
            }

            Dictionary<int, Dictionary<string, string>> statRet = DBUtility.SqlRead(statQ, "FFA");
            Dictionary<string, string> statObj = statRet[0];
            List<string> statKeys = new List<string>();
            foreach (string key in statObj.Keys)
            {
                if (key.Contains("FPro_") || key.Contains("Proj_"))
                {
                    statKeys.Add(key);
                }
            }

            resp += "<thead><tr>";
            foreach (string kName in statKeys)
            {
                resp += "<th>" + kName + "</th>";
            }
            resp += "</tr></thead>";

            resp += "<tbody>";
            resp += "<tr>";
            foreach (string stat in statKeys)
            {
                resp += "<td>";
                resp += statObj[stat];
                resp += "</td>";
            }
            resp += "</tr>";
            resp += "</tbody>";
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }
}