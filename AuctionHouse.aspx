<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeFile="AuctionHouse.aspx.cs" Inherits="AuctionHouse" %>

<asp:Content ID="Content3" ContentPlaceHolderID="pagejs" Runat="Server">
    <script type="text/javascript">
        $(document).ready(function () {
            setInterval(function () {
                OfferRefresh();
                BidRefresh();
                StatRefresh();
            }, 500);           
        });

        function PlaceBidField() {
            var bidAmt = $("#BidAmt").val();
            if (bidAmt == "") {
                alert("Enter amount");
            }
            else {
                PlaceBid(bidAmt);
            }
        }

        function PlaceOfferField() {
            var offerAmt = $("#OfferAmt").val();
            var selectedPlayer = $("#SelectedOfferPlayer").val();
            if (offerAmt == "" || selectedPlayer == "") {
                alert("Select player and enter a offer");
            }
            else {
                PlaceOffer(offerAmt,selectedPlayer);
            }
        }

        function OfferRefresh() {
            var offer = $("#CurrentAuctionOffer").val();
            var auction = $("#LoggedAuctionVal").val();
            var user = $("#LoggedUserVal").val();

            var dataString = "{offerId: '" + offer + "', auctionId: '" + auction + "', userId: '" + user + "'}";
            $.ajax({
                type: "POST",
                url: "AuctionHouse.aspx/OfferRefresh",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    var retObj = jQuery.parseJSON(resp);
                    $("#CurrentAuctionOffer").val(retObj.OfferRid);
                    var OfferStatus = retObj.OfferingStatus;                    
                    if (OfferStatus == "New") {
                        var TeamId = retObj.Team_LeagueSeason_rid;
                        if (TeamId == $("#LoggedTeamVal").val()) {
                            $("#NewOfferMod").modal("show");
                        }
                        else {
                            // set up view for everyone else
                            $("#CurrentOfferDiv").html("");
                            $("#CurrentOfferDiv").html("Waiting for player to select");
                        }
                    }
                    else {                        
                        $("#CurrentOfferDiv").html("");
                        $("#CurrentOfferDiv").html(retObj.PlayerName + "<br />" + retObj.PositionName + "<br />" + retObj.FranchiseName + "<br />Bye Week:" + retObj.ByeWeek);
                        $("#NewOfferMod").modal("hide");
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    $("#AjaxMessage").html(exception);
                },
                async: false
            });
        }

        function BidRefresh() {
            var bid = $("#CurrentAuctionBid").val();
            var offer = $("#CurrentAuctionOffer").val();
            var auction = $("#LoggedAuctionVal").val();
            var user = $("#LoggedUserVal").val();

            var dataString = "{offerId: '" + offer + "', auctionId: '" + auction + "', userId: '" + user + "', bidId: '" + bid + "'}";
            $.ajax({
                type: "POST",
                url: "AuctionHouse.aspx/BidRefresh",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp == "NEW") {
                        // no bid found
                        $("#CurrentBidDiv").html("");
                        $("#CurrentBidDiv").html("Waiting for player to select");
                        $("#PlusOneBtn").html("");
                        $("#PlusFiveBtn").html("");
                        $("#PlusTenBtn").html("");
                    }
                    else {
                        if (resp != "OK") {
                            var retObj = jQuery.parseJSON(resp)
                            $("#CurrentAuctionBid").val(retObj.Bid_rid);
                            $("#CurrentBidDiv").html("");
                            $("#CurrentBidDiv").html("$" + retObj.BidAmount + "<br />" + retObj.HighBidTeam);

                            // now set the quick buttons +1 +5 +10
                            var plusOne = retObj.PlusOne
                            var plusFive = retObj.PlusFive
                            var plusTen = retObj.PlusTen

                            //$("#PlusOneBtn").html("");
                            $("#PlusOneBtn").html("<button type='button' class='btn btn-danger form-control' onclick='PlaceBid(" + plusOne + ");'>$" + plusOne + "</button");

                            //$("#PlusFiveBtn").html("");
                            $("#PlusFiveBtn").html("<button type='button' class='btn btn-danger form-control' onclick='PlaceBid(" + plusFive + ");'>$" + plusFive + "</button");

                            //$("#PlusTenBtn").html("");
                            $("#PlusTenBtn").html("<button type='button' class='btn btn-danger form-control' onclick='PlaceBid(" + plusTen + ");'>$" + plusTen + "</button");
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    $("#AjaxMessage").html(exception);
                },
                async: false
            });
        }

        function StatRefresh() {
            var offerId = $("#CurrentAuctionOffer").val();
            var dataString = "{offerId: '" + offerId + "'}";
            $.ajax({
                type: "POST",
                url: "AuctionHouse.aspx/StatRefresh",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    $("#StatTbl").html("");
                    $("#StatTbl").html(resp);
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    $("#AjaxMessage").html(exception);
                },
                async: false
            });
        }

        function PlaceBid(amt) {            
            var team = $("#LoggedTeamVal").val();
            var offer = $("#CurrentAuctionOffer").val();            
            var dataString = "{offerId: '" + offer + "', TeamId: '" + team + "', bidAmt: '" + amt + "'}";
            //alert(dataString);
            $.ajax({
                type: "POST",
                url: "AuctionHouse.aspx/PlaceBid",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    $("#AjaxMessage").html(exception);
                },
                async: false
            });
        }

        function PlaceOffer(amt,player) {
            var team = $("#LoggedTeamVal").val();
            var offer = $("#CurrentAuctionOffer").val();

            var dataString = "{offerId: '" + offer + "', TeamId: '" + team + "', bidAmt: '" + amt + "', playerId: '" + player + "'}";
            //alert(dataString);
            $.ajax({
                type: "POST",
                url: "AuctionHouse.aspx/PlaceOffer",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    alert(resp);
                    OfferRefresh();
                    BidRefresh();
                    StatRefresh();
                    $("#NewOfferMod").modal("hide");
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    $("#AjaxMessage").html(exception);
                },
                async: false
            });
        }

        function OfferModPlayerLoad() {
            var auction = $("#LoggedAuctionVal").val();
            var pos = $("#PositionSel").val();
            $("#SelectedOfferPlayer").val("");
            $("#PlayerStat").html("");

            if (pos == "") {
                $("#PlayerTbl tbody").html("");
                return;
            }

            var dataString = "{positionId: '" + pos + "', auctionId: '" + auction + "'}";
            $.ajax({
                type: "POST",
                url: "AuctionHouse.aspx/OfferModListLoad",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    $("#PlayerTbl tbody").html("");
                    var tbodLoad = "";
                    var resp = msg.d;
                    if (resp != "X") {
                        var retObj = jQuery.parseJSON(resp);
                        $.each(retObj, function (key, value) {
                            tbodLoad += "<tr>";
                            tbodLoad += "<td>" + value.FPro_Rank + "</td>";
                            tbodLoad += "<td>" + value.PlayerName + "</td>";
                            tbodLoad += "<td>" + value.FranchiseNameShort + "</td>";
                            tbodLoad += "<td><button type='button' class='btn btn-link' onclick='OfferModPlayerSelect(" + value.rid + "," + value.PlayerPosition_rid + ");'><i class='icon-hammer'></button></td>";
                            tbodLoad += "</tr>";
                        });
                        $("#PlayerTbl tbody").html(tbodLoad);
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    $("#AjaxMessage").html(exception);
                },
                async: false
            });
        }

        function OfferModPlayerSelect(playerId, positionId) {
            var auctionId = $("#LoggedAuctionVal").val();
            $("#SelectedOfferPlayer").val("");
            $("#PlayerStat").html("");
            var dataString = "{playerId: '" + playerId + "', positionId: '" + positionId + "', auctionId: '" + auctionId + "'}";
            $.ajax({
                type: "POST",
                url: "AuctionHouse.aspx/OfferModPlayerSelect",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    $("#SelectedOfferPlayer").val(playerId);
                    $("#PlayerStat").html("");
                    var resp = msg.d;
                    $("#PlayerStat").html(resp);
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    $("#AjaxMessage").html(exception);
                },
                async: false
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <input type="hidden" value="" id="CurrentAuctionOffer" />
    <input type="hidden" value="" id="CurrentAuctionBid" />
    <input type="hidden" value="0" id="NewOfferViewFlag" />
    <div class="shortcut-area">
        <h2>Auction House</h2>
    </div>
    <div class="block">
    </div>
    <div class="row m-container">
        <div class="col-lg-8 col-md-8 col-sm-8 masonry">
            <div class="block">
                <h2>Current Offer</h2>
                <div class="block-body">
                    <div class="row m-container">
                        <div class="col-lg-4 col-md-4 col-sm-4 masonry">
                            <div class="block">
                                <h2>Current Offer</h2>
                                <div class="block-body" id="CurrentOfferDiv">

                                </div>
                            </div>
                        </div>
                        <div class="col-lg-8 col-md-8 col-sm-8 masonry">
                            <div class="row m-container">
                                <div class="col-lg-12">
                                    <div class="block">
                                        <h2>Current High Bid</h2>
                                        <div class="block-body" id="CurrentBidDiv">

                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-4 col-md-4 col-sm-4 masonry">
            <div class="block">
                <h2>Bid</h2>
                <div class="block-body" id="OfferBidDiv">
                    <div class="row m-container">
                        <div class="col-lg-12">
                            <form role="form">
                                <div class="form-group">
                                    <label for="BidAmt">Enter Amount</label>
                                    <input type="number" class="form-control" id="BidAmt" />
                                </div>
                            </form>
                            <div class="form-group">
                                <button type="button" class="btn btn-info form-control" onclick="PlaceBidField();">Place Bid</button>
                            </div>
                        </div>
                    </div>
                    <div class="block"></div>
                    <div class="row m-container">
                        <div class="col-lg-12">
                            <form role="form">
                                <div class="form-group" id="PlusOneBtn">

                                </div>
                                <div class="form-group" id="PlusFiveBtn">

                                </div>
                                <div class="form-group" id="PlusTenBtn">

                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="block"></div>
        <div class="row m-container">
            <div class="col-lg-12 masonry">
                <div class="c-block">
                    <h4>Stats</h4>
                    <div class="table-condensed">
                        <table class="table" id="StatTbl">

                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>  
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ModalContent" Runat="Server">
    <div class="modal fade" id="NewOfferMod">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title">Select Player</h4>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-lg-6 col-md-6 col-sm-6">
                            <form role="form">
                                <div class="form-group">
                                    <label for="PositionSel">Select Position</label>
                                    <select class="form-control" id="PositionSel" onchange="OfferModPlayerLoad();">
                                        <option value="">Select...</option>
                                        <option value="1">Quarterback</option>
                                        <option value="2">Running Back</option>
                                        <option value="3">Wide Receiver</option>
                                        <option value="4">Tight End</option>
                                        <option value="5">Kicker</option>
                                        <option value="6">Defense</option>
                                    </select>
                                </div>
                            </form>
                        </div>
                        <div class="col-lg-6 col-md-6 col-sm-6" id="NewOfferBid">
                            <form role="form">
                                <div class="form-group">
                                    <label for="OfferAmt">Enter Initial Bid</label>
                                    <input type="number" class="form-control" id="OfferAmt" />
                                </div>
                            </form>
                            <div class="form-group">
                                <button type="button" class="btn btn-info form-control" onclick="PlaceOfferField();">Place Offer</button>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-6 col-md-6 col-sm-6" id="PlayerList">
                            <table class="table" id="PlayerTbl">
                                <thead>
                                    <tr>
                                        <th>Rank</th>
                                        <th>Name</th>
                                        <th>Team</th>
                                        <th>Select</th>
                                    </tr>
                                </thead>
                                <tbody>

                                </tbody>
                            </table>
                        </div>
                        <input type="hidden" id="SelectedOfferPlayer" value="" />
                        <div class="col-lg-6 col-md-6 col-sm-6" id="PlayerStat">
                            <!--<table class="table" id="PlayerStatTbl">
                                <tbody>

                                </tbody>
                            </table>-->
                        </div>
                    </div>
                </div>
                <div class="modal-footer">

                </div>
            </div>
        </div>
    </div>
</asp:Content>

