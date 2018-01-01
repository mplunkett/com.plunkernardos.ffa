<%@ Page Title="" Language="C#" MasterPageFile="~/Auctioneer.master" AutoEventWireup="true" CodeFile="Auctioneer.aspx.cs" Inherits="Auctioneer" %>

<asp:Content ID="Content3" ContentPlaceHolderID="pagejs" Runat="Server">
    <script type="text/javascript">
        $(document).ready(function () {
            setInterval(function () {
                OfferRefresh();
                BidRefresh();
                StatRefresh();
                BidHistory();
            }, 500);
        });

        function SellOffer() {
            var cancelFlag = false;
            var bidId = $("#CurrentAuctionBid").val();
            var offer = $("#CurrentAuctionOffer").val();
            var auction = $("#LoggedAuctionVal").val();
            $("#SellingBid").val(bidId);
            $("#SellingCount").val(0);
            SetIntervalX(function () {
                var sellCt = $("#SellingCount").val();
                sellCt++;
                var dataString = "{bidId: '" + bidId + "', sellStep: '" + sellCt + "', offerId: '" + offer + "', auctionId: '" + auction + "'}";
                $.ajax({
                    type: "POST",
                    url: "Auctioneer.aspx/SellOffer",
                    data: dataString,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        var resp = msg.d;
                        
                        switch (resp) {
                            case "OK":
                                $("#GoingGoingGone").html("<h3>Going " + sellCt + "</h3>");
                                break;
                            case "X":
                                break;
                            case "SOLD":
                                $("#GoingGoingGone").html("<h3>Sold!</h3>");
                                $("#SellingBid").val("");
                                setTimeout(function () {
                                    $("#GoingGoingGone").html("");
                                },3000);
                                break;
                            case "CANCEL":
                                $("#GoingGoingGone").html("Another bid came in!");
                                $("#SellingBid").val("");
                                setTimeout(function () {
                                    $("#GoingGoingGone").html("");
                                }, 1000);
                                break;
                            default:
                                break;
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, exception) {
                        $("#AjaxMessage").html(exception);
                    },
                    async: false
                });               
                $("#SellingCount").val(sellCt);
            }, 3000, 3);
        }

        function SetIntervalX(callback, delay, repetitions) {
            var x = 0;
            var intervalID = window.setInterval(function () {

                callback();

                if (++x === repetitions) {
                    window.clearInterval(intervalID);
                }
            }, delay);
        }

        function OfferRefresh() {
            var offer = $("#CurrentAuctionOffer").val();
            var auction = $("#LoggedAuctionVal").val();
            var user = $("#LoggedUserVal").val();

            var dataString = "{offerId: '" + offer + "', auctionId: '" + auction + "', userId: '" + user + "'}";
            $.ajax({
                type: "POST",
                url: "Auctioneer.aspx/OfferRefresh",
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
                url: "Auctioneer.aspx/BidRefresh",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp == "OK") {
                        // no bid found
                        $("#CurrentBidDiv").html("");
                        $("#CurrentBidDiv").html("Waiting for player to select");
                    }
                    else {
                        var retObj = jQuery.parseJSON(resp)
                        $("#CurrentAuctionBid").val(retObj.Bid_rid);
                        $("#CurrentBidDiv").html("");
                        $("#CurrentBidDiv").html("$" + retObj.BidAmount + "<br />" + retObj.HighBidTeam);
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
                url: "Auctioneer.aspx/StatRefresh",
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

        function BidHistory() {
            var offerId = $("#CurrentAuctionOffer").val();
            var dataString = "{offerId: '" + offerId + "'}";
            $.ajax({
                type: "POST",
                url: "Auctioneer.aspx/BidHistory",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    $("#HistBidDiv").html(resp);
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
        <input type="hidden" id="SellingBid" value="" />
        <input type="hidden" id="SellingCount" value="" />
        <button type="button" class="btn btn-link shortcut" onclick="SellOffer();">
            <i class="icon-coin"></i>
            <span class="title">Sell</span>
        </button>
        <div id="GoingGoingGone">

        </div>
    </div>
    <div class="block">
    </div>
    <div class="row m-container">
        <div class="col-lg-12 masonry">
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
                        <div class="col-lg-4 col-md-4 col-sm-4 masonry">
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
                        <div class="col-lg-4 col-md-4 col-sm-4 masonry">
                            <div class="row m-container">
                                <div class="col-lg-12">
                                    <div class="block">
                                        <h2>Bid History</h2>
                                        <div class="block-body" id="HistBidDiv">

                                        </div>
                                    </div>
                                </div>
                            </div>
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
</asp:Content>

