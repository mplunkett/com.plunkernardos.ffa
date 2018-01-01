<%@ Page Title="" Language="C#" MasterPageFile="~/V2/Auctioneer2.master" AutoEventWireup="true" CodeFile="ManualAuction.aspx.cs" Inherits="V2_ManualAuction" %>

<asp:Content ID="Content3" ContentPlaceHolderID="pagejs" Runat="Server">
    <script type="text/javascript">
        
        function PlayerRefresh() {
            var playerId = $("#SelPlayerId").val();
            var dataString = "{playId: '" + playerId + "'}";
            $.ajax({
                type: "POST",
                url: "ManualAuction.aspx/PlayerRefresh",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    $("#PlayerDetails").html("");
                    var resp = msg.d;
                    var retObj = jQuery.parseJSON(resp);
                    var dets = "<p>" + retObj["PlayerName"] + "</p><p>" + retObj["PositionName"] + "</p><p>" + retObj["FranchiseName"] + "</p><p>" + retObj["ByeWeek"] + "</p>";
                    $("#PlayerDetails").html(dets);
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    $("#AjaxMessage").html(exception);
                },
                async: false
            });
        }

        function StatRefresh() {
            var playerId = $("#SelPlayerId").val();
            var dataString = "{playId: '" + playerId + "'}";
            $.ajax({
                type: "POST",
                url: "ManualAuction.aspx/StatRefresh",
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

        function ShowPlayerMod() {
            $("#NewOfferMod").modal("show");
        }

        function SelectPlayerMod() {
            var newId = $("#SelectedOfferPlayer").val();
            $("#SelPlayerId").val(newId);
            StatRefresh();
            PlayerRefresh();
            $("#NewOfferMod").modal("hide");
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
                url: "ManualAuction.aspx/OfferModListLoad",
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
                            tbodLoad += "<td><button type='button' class='btn btn-link' onclick='OfferModPlayerSelect(" + value.rid + "," + value.PlayerPosition_rid + ");'>Select</button></td>";
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
                url: "ManualAuction.aspx/OfferModPlayerSelect",
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
    <div class="row">
        <div class="col-lg-6 col-md-6 col-sm-6">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <input type="hidden" id="SelPlayerId" value="" />
                    Player | <button class="btn btn-link" onclick="ShowPlayerMod();">Change</button>
                </div>
                <div class="panel-body" id="PlayerDetails">

                </div>
                <div class="panel-footer" id="AjaxMessage"></div>
            </div>
        </div>
        <div class="col-lg-6 col-md-6 col-sm-6">
            <div class="panel panel-default">
                <div class="panel-heading">

                </div>
                <div class="panel-body">
                    <form class="form">
                        <div class="form-group">
                            <label>Select Team</label>
                            <select id="TeamSel" class="form-control">
                                <option value="">Select...</option>
                                <option value="1">Los Plunkernardos</option>
                                <option value="2">Merry Hookers</option>
                                <option value="3">Moosehead Raiders</option>
                                <option value="4">Bill Murray</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Sold Amount</label>
                            <input type="text" id="SoldAmt" class="form-control" />
                        </div>
                    </form>
                    <div class="form-group">
                        <button type="button" class="btn btn-danger form-control" onclick="SellOffer();">Sell</button>
                    </div>                    
                </div>
                <div class="panel-footer"></div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-lg-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    Stats
                </div>
                <div class="panel-body">
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
                            <div class="form-group">
                                <button type="button" class="btn btn-info form-control" onclick="SelectPlayerMod();">Place Offer</button>
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


