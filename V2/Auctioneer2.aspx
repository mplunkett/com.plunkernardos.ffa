<%@ Page Title="" Language="C#" MasterPageFile="~/V2/Auctioneer2.master" AutoEventWireup="true" CodeFile="Auctioneer2.aspx.cs" Inherits="V2_Auctioneer2" %>

<asp:Content ID="Content3" ContentPlaceHolderID="pagejs" Runat="Server">
    <script type="text/javascript">
        $(document).ready(function () {
            setInterval(function () {
                OfferRefresh();
                BidRefresh();
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
                    url: "Auctioneer2.aspx/SellOffer",
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
                url: "Auctioneer2.aspx/OfferRefresh",
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
                url: "Auctioneer2.aspx/BidRefresh",
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

        function BidHistory() {
            var offerId = $("#CurrentAuctionOffer").val();
            var dataString = "{offerId: '" + offerId + "'}";
            $.ajax({
                type: "POST",
                url: "Auctioneer2.aspx/BidHistory",
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
    <div class="row">
        <input type="hidden" id="SellingBid" value="" />
        <input type="hidden" id="SellingCount" value="" />
        <div class="col-lg-4 col-md-4">
            <button type="button" class="btn btn-danger" onclick="SellOffer();">Sell!</button>
        </div>
        <div class="col-lg-4 col-md-4" id="GoingGoingGone">

        </div>
    </div>
    <hr />
    <div class="row">
        <div class="col-lg-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    Current Offer
                </div>                
                <div class="panel-body">
                    <div class="row">
                        <div class="col-lg-4 col-md-4 col-sm-4">
                            <div class="panel panel-default">
                                <div class="panel-heading">
                                    Current Offer
                                </div>                                
                                <div class="panel-body" id="CurrentOfferDiv">

                                </div>
                            </div>
                        </div>
                        <div class="col-lg-4 col-md-4 col-sm-4">
                            <div class="row">
                                <div class="col-lg-12">
                                    <div class="panel panel-default">
                                        <div class="panel-heading">
                                            Current High Bid
                                        </div>                                        
                                        <div class="panel-body" id="CurrentBidDiv">

                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-4 col-md-4 col-sm-4">
                            <div class="row">
                                <div class="col-lg-12">
                                    <div class="panel panel-default">
                                        <div class="panel-heading">
                                            Bid History
                                        </div>                                        
                                        <div class="panel-body" id="HistBidDiv">

                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <hr />
    </div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ModalContent" Runat="Server">
</asp:Content>


